#!/usr/bin/ruby
# frozen_string_literal: true

# Serves the local HTTP servers that are currently listening, as JSON, for the
# startpage extension. Stdlib only, and kept compatible with the system Ruby (2.6)
# so launchd does not depend on mise.
#
#   GET http://127.0.0.1:47821/ports
#   => [{ "port": 3000, "pid": 123, "command": "ruby", "cwd": "~/src/app",
#         "project": "app", "branch": "main", "repo": "owner/app",
#         "container": null, "service": null, "compose": null,
#         "pr": { "number": 12, "url": "https://github.com/owner/app/pull/12", "state": "OPEN" } }]
#      `container`, `service` and `compose` (project) are set for ports published by a Docker container.
#
#   GET http://127.0.0.1:47821/overview
#   => { "servers": [ …as /ports… ],
#        "stack": { "docker": true, "projects": { "myapp-compose": ["postgres", "rabbitmq", "redis"] } } }
#      `stack` lists the running Docker Compose services per project, and `docker` is
#      false when the daemon (the Colima VM) does not answer. Both come from one `docker ps`.
#
#   GET http://127.0.0.1:47821/urls
#   => the link list in STARTPAGE_URLS_FILE, grouped by heading
#
#   GET http://127.0.0.1:47821/repos?org=owner
#   => ["app", "other"]   (via the gh CLI, most recently pushed first)

require "json"
require "socket"

PORT = Integer(ENV.fetch("STARTPAGE_PORTS_PORT", "47821"))
LSOF = "/usr/sbin/lsof"
GIT = "/usr/bin/git"
URLS_FILE = ENV.fetch("STARTPAGE_URLS_FILE", File.join(Dir.home, ".config/startpage/urls.md"))
DOCKER = %w[/opt/homebrew/bin/docker /usr/local/bin/docker].find { |path| File.executable?(path) }
NEGATIVE_CACHE_SECONDS = 30
GH = %w[/opt/homebrew/bin/gh /usr/local/bin/gh].find { |path| File.executable?(path) }
REPO_CACHE_SECONDS = 3600
REPO_CACHE = {}
# [repo, branch] => { pr:, at: }. A found pull request is kept for an hour, a missing
# one for two minutes so a newly opened pull request shows up soon.
PR_CACHE = {}
PR_CACHE_LOCK = Mutex.new
PR_CACHE_SECONDS = { found: 3600, missing: 120 }.freeze
# cwd => { details:, at: }. The git lookups cost a few process spawns per server, and a
# branch rarely changes between two page loads.
PROJECT_CACHE = {}
PROJECT_CACHE_LOCK = Mutex.new
PROJECT_CACHE_SECONDS = 5
IGNORED_COMMANDS = ["ControlCenter", "rapportd", "sharingd", "Google Drive", "Spotify"].freeze
EXTENSION_ORIGIN = %r{\A[a-z-]+-extension://}.freeze
ALLOWED_HOSTS = ["127.0.0.1:#{PORT}", "localhost:#{PORT}"].freeze

# [pid, port] => true/false. A process does not change protocol, so probe it once.
HTTP_CACHE = {}
HTTP_CACHE_LOCK = Mutex.new

def listeners
  found = {}
  pid = command = nil
  `#{LSOF} +c 0 -nP -iTCP -sTCP:LISTEN -F pcn 2>/dev/null`.each_line do |line|
    value = line[1..-1].chomp
    case line[0]
    when "p" then pid = value.to_i
    when "c" then command = value
    when "n"
      port = value[/:(\d+)\z/, 1]
      found[port.to_i] ||= { port: port.to_i, pid: pid, command: command } if port
    end
  end
  found.values
end

def working_directories(pids)
  return {} if pids.empty?

  dirs = {}
  pid = nil
  `#{LSOF} -a -d cwd -p #{pids.join(",")} -F pn 2>/dev/null`.each_line do |line|
    value = line[1..-1].chomp
    case line[0]
    when "p" then pid = value.to_i
    when "n" then dirs[pid] = value
    end
  end
  dirs
end

# true/false once the server has answered, nil when it stayed silent (a slow dev
# server, most likely), in which case it is listed and probed again next time.
# Both loopback addresses are tried: dev servers often bind only ::1, while ports
# forwarded from containers only answer on 127.0.0.1.
def probe_http(port)
  answers = ["127.0.0.1", "::1"].map do |address|
    answer = probe_address(address, port)
    return true if answer
    answer
  end
  answers.include?(nil) ? nil : false
end

def probe_address(address, port)
  socket = Socket.tcp(address, port, connect_timeout: 0.3)
  socket.write("OPTIONS * HTTP/1.1\r\nHost: localhost:#{port}\r\nConnection: close\r\n\r\n")
  return nil unless socket.wait_readable(1)

  socket.read_nonblock(5, exception: false).to_s.start_with?("HTTP/")
rescue SystemCallError, IOError
  false
ensure
  socket&.close
end

# A "yes" holds for as long as the process keeps the port. A "no" is only kept briefly:
# a forwarded container port refuses until the container behind it is up.
def http?(listener)
  key = [listener[:pid], listener[:port]]
  cached = HTTP_CACHE_LOCK.synchronize { HTTP_CACHE[key] }
  return cached[:answer] if cached && (cached[:answer] || Time.now - cached[:at] < NEGATIVE_CACHE_SECONDS)

  answer = probe_http(listener[:port])
  HTTP_CACHE_LOCK.synchronize { HTTP_CACHE[key] = { answer: answer, at: Time.now } } unless answer.nil?
  answer != false
end

# Every running Docker container with its compose labels, from one `docker ps`, or nil
# when the daemon (the Colima VM) does not answer.
def docker_containers
  return nil unless DOCKER

  format = ["{{.Names}}", "{{.Ports}}"] + %w[project service project.working_dir].map do |label|
    %({{.Label "com.docker.compose.#{label}"}})
  end
  output = IO.popen([DOCKER, "ps", "--format", format.join("\t")], err: File::NULL, &:read).to_s
  return nil unless $?.success?

  output.each_line.map do |line|
    name, ports, project, service, dir = line.chomp.split("\t", -1)
    { name: name, ports: ports, compose: project, service: service, dir: dir }
  end
rescue SystemCallError
  nil
end

# Host port => container, for every port published by a running Docker container
# (Colima forwards those through ssh, so lsof only shows the forwarder).
def published_ports(containers)
  found = {}
  containers.each do |container|
    container[:ports].to_s.scan(/:(\d+)->/) { |(port)| found[port.to_i] ||= container }
  end
  found
end

# Running Docker Compose services per project. This is what `dctl status` boils down to,
# without its several seconds of colima and compose calls.
def stack(containers)
  projects = Hash.new { |hash, key| hash[key] = [] }
  (containers || []).each do |container|
    next if container[:compose].to_s.empty? || container[:service].to_s.empty?

    projects[container[:compose]] << container[:service]
  end
  { docker: !containers.nil?, projects: projects.transform_values { |services| services.uniq.sort } }
end

def run(*command)
  output = IO.popen(command, err: File::NULL, &:read).to_s.strip
  output if $?.success? && !output.empty?
rescue SystemCallError
  nil
end

# Project, branch and GitHub repo for a working directory. Git is asked first; without
# a repo, a bare-repo worktree path (~/src/app.git/feat/thing) or the directory name
# is used instead.
def project_for(cwd, home)
  return { project: nil, branch: nil, repo: nil } if cwd.nil? || cwd == "/" || cwd == home

  key = [cwd, home]
  cached = PROJECT_CACHE_LOCK.synchronize { PROJECT_CACHE[key] }
  return cached[:details].dup if cached && Time.now - cached[:at] < PROJECT_CACHE_SECONDS

  details = git_details(cwd)
  PROJECT_CACHE_LOCK.synchronize { PROJECT_CACHE[key] = { details: details, at: Time.now } }
  details.dup
end

def git_details(cwd)
  branch = run(GIT, "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD")
  branch = nil if branch == "HEAD"
  repo = run(GIT, "-C", cwd, "remote", "get-url", "origin").to_s[%r{github\.com[:/](.+?)(\.git)?\z}, 1]
  worktree = cwd.match(%r{/([^/]+)\.git/(.+)\z})

  {
    project: repo ? repo.split("/").last : (worktree ? worktree[1] : File.basename(cwd)),
    branch: branch || (worktree && worktree[2]),
    repo: repo,
  }
end

# The newest pull request for a branch as { "number", "url", "state" }, or nil. The
# first lookup waits for gh; after that the cached answer is returned at once and
# refreshed in the background when it has expired.
def pull_request(repo, branch)
  return nil unless GH && repo && branch && !%w[main master].include?(branch)

  key = [repo, branch]
  cached = PR_CACHE_LOCK.synchronize do
    entry = PR_CACHE[key]
    if entry && !entry[:refreshing] && Time.now - entry[:at] > PR_CACHE_SECONDS[entry[:pr] ? :found : :missing]
      entry[:refreshing] = true
      Thread.new { fetch_pull_request(key) }
    end
    entry
  end
  cached ? cached[:pr] : fetch_pull_request(key)
end

def fetch_pull_request(key)
  repo, branch = key
  output = run(GH, "pr", "list", "--repo", repo, "--head", branch, "--state", "all", "--limit", "1",
               "--json", "number,url,state")
  pr = output && JSON.parse(output).first
  PR_CACHE_LOCK.synchronize { PR_CACHE[key] = { pr: pr, at: Time.now } }
  pr
end

# The link list in URLS_FILE, grouped by its headings:
#   [{ "group": "Staging · Public", "links": [{ "label": "Web App", "url": "https://…", "note": null }] }]
# Items are `- [Label](url): note` or a bare `- url`.
def urls
  groups = []
  path = []
  File.foreach(URLS_FILE) do |line|
    if (heading = line.match(/\A(\#{2,})\s+(.+?)\s*\z/))
      path = path.first(heading[1].length - 2) << heading[2]
    elsif (item = line.match(/\A\s*[-*]\s+(?:\[(.+?)\]\((\S+?)\)(?::\s*(.+?))?|(https?:\S+))\s*\z/))
      url = item[2] || item[4]
      label = item[1] || url.sub(%r{\Ahttps?://}, "").chomp("/")
      title = path.join(" · ")
      groups << { group: title, links: [] } unless groups.last && groups.last[:group] == title
      groups.last[:links] << { label: label, url: url, note: item[3] }
    end
  end
  groups
rescue SystemCallError
  []
end

# Repository names in a GitHub org, most recently pushed first. Private repos are
# included because the gh CLI is already signed in.
def repos(org)
  cached = REPO_CACHE[org]
  return cached[:names] if cached && Time.now - cached[:at] < REPO_CACHE_SECONDS
  return [] unless GH

  output = run(GH, "repo", "list", org, "--limit", "1000", "--no-archived", "--json", "name,pushedAt")
  return cached ? cached[:names] : [] unless output

  names = JSON.parse(output).sort_by { |repo| repo["pushedAt"].to_s }.reverse.map { |repo| repo["name"] }
  REPO_CACHE[org] = { names: names, at: Time.now }
  names
end

def ports(containers)
  candidates = listeners.reject do |listener|
    listener[:port] == PORT || listener[:port] < 1024 || IGNORED_COMMANDS.include?(listener[:command])
  end
  HTTP_CACHE_LOCK.synchronize do
    alive = candidates.map { |listener| [listener[:pid], listener[:port]] }
    HTTP_CACHE.keep_if { |key, _| alive.include?(key) }
  end
  servers = candidates.map { |listener| Thread.new { listener if http?(listener) } }.map(&:value).compact

  dirs = working_directories(servers.map { |server| server[:pid] }.uniq)
  home = Dir.home
  docker = published_ports(containers.join(2) ? containers.value || [] : [])
  described = servers.sort_by { |server| server[:port] }.map do |server|
    # One thread per server: the git lookups in project_for are the slow part.
    Thread.new do
      # A container is described by its compose project directory, not by the forwarder.
      container = docker[server[:port]]
      cwd = container ? container[:dir] : dirs[server[:pid]]
      cwd = nil if cwd.to_s.empty?
      details = project_for(cwd, home)
      details[:project] ||= container[:name] if container
      server.merge(
        cwd: cwd&.sub(/\A#{Regexp.escape(home)}/, "~"),
        container: container && container[:name],
        compose: container && container[:compose],
        service: container && container[:service],
        pr: pull_request(details[:repo], details[:branch]),
        **details
      )
    end
  end
  described.map(&:value)
end

# Servers and compose stack in one answer, sharing a single `docker ps`.
def overview
  containers = Thread.new { docker_containers }
  servers = ports(containers)
  { servers: servers, stack: stack(containers.value) }
end

def respond(client, status, body, origin)
  headers = [
    "HTTP/1.1 #{status}",
    "Content-Type: application/json",
    "Content-Length: #{body.bytesize}",
    "Cache-Control: no-store",
    "Connection: close",
  ]
  # Only extension pages may read the response; ordinary websites get no CORS header.
  headers << "Access-Control-Allow-Origin: #{origin}" << "Vary: Origin" if origin =~ EXTENSION_ORIGIN
  client.write("#{headers.join("\r\n")}\r\n\r\n#{body}")
end

def handle(client)
  return unless client.wait_readable(2)

  request_line = client.gets.to_s
  headers = {}
  while (line = client.gets) && line != "\r\n"
    name, value = line.split(":", 2)
    headers[name.downcase] = value.to_s.strip
  end
  origin = headers["origin"]

  if !ALLOWED_HOSTS.include?(headers["host"])
    respond(client, "403 Forbidden", "{}", nil)
  elsif request_line.start_with?("GET /ports ")
    respond(client, "200 OK", JSON.generate(ports(Thread.new { docker_containers })), origin)
  elsif request_line.start_with?("GET /overview ")
    respond(client, "200 OK", JSON.generate(overview), origin)
  elsif request_line.start_with?("GET /urls ")
    respond(client, "200 OK", JSON.generate(urls), origin)
  elsif (org = request_line[%r{\AGET /repos\?org=([\w.-]+) }, 1])
    respond(client, "200 OK", JSON.generate(repos(org)), origin)
  else
    respond(client, "404 Not Found", "{}", origin)
  end
rescue SystemCallError, IOError
  nil
ensure
  client.close
end

server = TCPServer.new("127.0.0.1", PORT)
loop do
  Thread.new(server.accept) { |client| handle(client) }
end
