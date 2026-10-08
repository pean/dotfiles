const api = globalThis.browser ?? globalThis.chrome;
const usesPromises = !!globalThis.browser;
const call = (ns, method, ...args) =>
  usesPromises ? ns[method](...args) : new Promise((resolve) => ns[method](...args, resolve));

const $ = (id) => document.getElementById(id);
const el = (tag, className, text) => {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text != null) node.textContent = text;
  return node;
};

const input = $("q");
const home = $("home");
const results = $("results");
let sel = -1;
const BAR_WIDTH = 10;

// --- header -----------------------------------------------------------------

function isoWeek(date) {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7));
  return Math.ceil(((d - Date.UTC(d.getUTCFullYear(), 0, 1)) / 864e5 + 1) / 7);
}

function tick() {
  const now = new Date();
  const date = now
    .toLocaleDateString("en-GB", { weekday: "short", day: "2-digit", month: "short" })
    .toLowerCase();
  const time = now.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" });
  $("clock").textContent = `${date} · w${isoWeek(now)} · ${time}`;
}

function renderChrome() {
  // Backticked parts of the hint become highlighted spans.
  CONFIG.search.hint?.split("`").forEach((part, i) => $("hint").append(i % 2 ? el("b", null, part) : part));
  for (const heading of document.querySelectorAll("h2[data-icon]")) heading.prepend(svgIcon(heading.dataset.icon));
  $("prompt").prepend(svgIcon("search"));
  tick();
  setInterval(tick, 10_000);
}

// --- rows -------------------------------------------------------------------

const SOURCE_ICONS = {
  bookmark: "bookmark",
  url: "link",
  running: "plug",
  frequent: "flame",
  history: "clock",
  repo: "repo",
  tab: "tabs",
};

// `icon` is `true` for the icon of the url's site, or a `[name, color]` pair.
// `source` says where a search result came from and puts that icon at the end of the row.
function row({ label, url, meta, bar, hint, action, icon, source, tab }) {
  // Without a url it is only a label, like a compose project that has no web port.
  const a = el(url ? "a" : "div", action ? "row action" : "row");
  if (url) a.href = url;
  // A row for an open tab switches to it instead of loading the url again.
  if (tab) {
    a.dataset.tabId = tab.id;
    a.dataset.windowId = tab.windowId;
  }
  if (bar != null) {
    const cells = el("span", "bar-cells", "█".repeat(bar));
    cells.append(el("span", "rest", "░".repeat(BAR_WIDTH - bar)));
    a.append(cells);
  }
  if (icon) a.append(svgIcon(...(icon === true ? iconSpec(url) : icon)));
  a.append(el("span", "label", label));
  if (hint) a.append(el("span", "hint", hint));
  if (meta != null) a.append(el("span", "meta", meta));
  if (source) {
    const mark = svgIcon(SOURCE_ICONS[source], null, source);
    mark.classList.add("source");
    a.append(mark);
  }
  return a;
}

// What two urls must share to count as the same page: scheme, `www.` and a trailing
// slash are ignored.
const urlKey = (url) => {
  try {
    const { host, pathname, search, hash } = new URL(url);
    return host.replace(/^www\./, "") + pathname.replace(/\/$/, "") + search + hash;
  } catch {
    return url;
  }
};

const hostOf = (url) => {
  try {
    return new URL(url).hostname.replace(/^www\./, "");
  } catch {
    return url;
  }
};

// --- history ----------------------------------------------------------------

// One history query feeds both the frequent list and the prompt. The result is kept
// in localStorage, so a new tab starts from the previous tab's copy straight away and
// swaps in the fresh one when the browser has answered.
const HISTORY_KEY = "history-v1";
let historyItems;

// Adds a `score` to each item, visits halved for every `halfLife` days since the last
// one, and sorts by it. `visitCount` is the lifetime count, so on its own it would let
// an old habit outrank what is in use now.
function ranked(items) {
  const now = Date.now();
  const { days, halfLife } = CONFIG.history;
  // Days since the last visit. Browsers disagree on the unit of `lastVisitTime`, so
  // seconds are accepted too, and anything outside the queried window is pulled into
  // it: a time that cannot be read then costs the ranking, not the whole list.
  const age = (time) => {
    const ms = time < 1e11 ? time * 1000 : time;
    return Math.min(Math.max((now - ms) / 864e5, 0), days) || 0;
  };
  return items
    .map((item) => ({ ...item, score: item.visitCount * 0.5 ** (age(Number(item.lastVisitTime)) / halfLife) }))
    .sort((a, b) => b.score - a.score);
}

async function fetchHistory() {
  const started = performance.now();
  const items = await call(api.history, "search", {
    text: "",
    startTime: Date.now() - CONFIG.history.days * 864e5,
    maxResults: CONFIG.history.max,
  });
  const slim = (items ?? []).map(({ url, title, visitCount = 1, lastVisitTime }) => ({
    url,
    title,
    visitCount,
    lastVisitTime,
  }));
  console.debug(
    `history: ${slim.length} items in ${Math.round(performance.now() - started)}ms, lastVisitTime e.g.`,
    slim[0]?.lastVisitTime,
  );
  try {
    localStorage.setItem(HISTORY_KEY, JSON.stringify(slim));
  } catch {}
  return ranked(slim);
}

// Resolves to history items sorted by score, highest first.
function recentHistory() {
  if (!api?.history?.search) return Promise.resolve([]);
  if (historyItems) return historyItems;

  let cached = [];
  try {
    cached = ranked(JSON.parse(localStorage.getItem(HISTORY_KEY)) ?? []);
  } catch {}
  const fresh = fetchHistory().catch((error) => {
    console.warn("history.search failed", error);
    return cached;
  });
  if (cached.length) {
    historyItems = Promise.resolve(cached);
    fresh.then((items) => (historyItems = Promise.resolve(items)));
  } else {
    historyItems = fresh;
  }
  return historyItems;
}

// --- frequently visited -----------------------------------------------------

// `count` is visits at or below this path and `score` their recency-weighted sum, which
// is what rows are ranked by. `own` is visits to exactly this path.
const newNode = (label, url) => ({ label, url, count: 0, score: 0, own: 0, children: new Map() });

const isLocal = (hostname) =>
  /^(localhost|0\.0\.0\.0|127(\.\d+){3}|\[::1\])$/.test(hostname) || hostname.endsWith(".localhost");

function pathLabel(segments) {
  const parts = segments.map((segment) => {
    try {
      return decodeURIComponent(segment);
    } catch {
      return segment;
    }
  });
  return parts.length > 3 ? `${parts[0]}/…/${parts.slice(-2).join("/")}` : parts.join("/");
}

// Paths below `node` that were visited themselves and hold a meaningful share of the
// host's visits. A path is dropped when one deeper path holds nearly all of its visits,
// or when it holds nearly all of the host's (the host row already covers it).
function hotPaths(node, hostTotal) {
  const found = [];
  for (const child of node.children.values()) {
    if (child.score < CONFIG.top.share * hostTotal) continue;
    const deeper = hotPaths(child, hostTotal);
    const redundant = child.score >= 0.9 * hostTotal || deeper.some((d) => d.score >= 0.8 * child.score);
    if (child.own > 0 && !redundant) found.push(child);
    found.push(...deeper);
  }
  return found;
}

async function frequentSites() {
  const { limit, ignore } = CONFIG.top;

  if (api?.history?.search) {
    try {
      const items = await recentHistory();
      const hosts = new Map();
      const ports = new Map();
      for (const { url, title, visitCount = 1, score = visitCount } of items ?? []) {
        if (!/^https?:/.test(url)) continue;
        const { origin, pathname, hostname, host: hostAndPort } = new URL(url);
        // Local servers are keyed by host:port and kept out of the main list.
        const local = isLocal(hostname);
        const host = local ? hostAndPort : hostOf(url);
        if (!local && ignore.some((suffix) => host.endsWith(suffix))) continue;
        const group = local ? ports : hosts;
        let node = group.get(host);
        if (!node) group.set(host, (node = newNode(host, origin)));
        node.count += visitCount;
        node.score += score;
        if (title && visitCount > (node.titleVisits ?? 0)) {
          node.title = title;
          node.titleVisits = visitCount;
        }
        // Query string and fragment are dropped, so variants of a page count together.
        const segments = pathname.split("/").filter(Boolean);
        segments.forEach((segment, i) => {
          let child = node.children.get(segment);
          if (!child) {
            const path = segments.slice(0, i + 1);
            child = newNode(pathLabel(path), `${origin}/${path.join("/")}`);
            node.children.set(segment, child);
          }
          child.count += visitCount;
          child.score += score;
          node = child;
        });
        node.own += visitCount;
      }
      const rank = (group, max) =>
        [...group.values()]
          .sort((a, b) => b.score - a.score)
          .slice(0, max)
          .map((host) => ({
            label: host.label,
            url: host.url,
            count: host.count,
            score: host.score,
            title: host.title,
            paths: hotPaths(host, host.score)
              .sort((a, b) => b.score - a.score)
              .slice(0, CONFIG.top.paths),
          }));
      if (hosts.size || ports.size) {
        return { sites: rank(hosts, limit), local: rank(ports, Infinity) };
      }
    } catch (error) {
      console.warn("history.search failed", error);
    }
  }

  if (api?.topSites?.get) {
    try {
      const sites = await call(api.topSites, "get");
      return { sites: (sites ?? []).slice(0, limit).map((s) => ({ label: hostOf(s.url), url: s.url })), local: [] };
    } catch (error) {
      console.warn("topSites.get failed", error);
    }
  }

  return null;
}

let topSites = [];

function renderSites(container, sites, withTitle) {
  // Bars follow the score the rows are ranked by; the number at the end is plain visits.
  const max = Math.max(...sites.map((s) => s.score ?? 0)) || 1;
  const barFor = (score) => (score != null ? Math.max(1, Math.round((score / max) * BAR_WIDTH)) : undefined);
  for (const site of sites) {
    const hint = withTitle ? site.title : undefined;
    container.append(
      row({ label: site.label, url: site.url, hint, meta: site.count, bar: barFor(site.score), icon: true }),
    );
    for (const path of site.paths ?? []) {
      const sub = row({ label: path.label, url: path.url, meta: path.count, bar: barFor(path.score) });
      sub.classList.add("sub");
      container.append(sub);
    }
  }
}

async function renderTop() {
  const container = $("top");
  const found = await frequentSites();
  if (!found) {
    container.append(el("p", "empty", "history api unavailable — load this as an extension"));
    return;
  }
  const { sites, local } = found;
  topSites = [...sites, ...local].flatMap((site) => [
    site,
    ...(site.paths ?? []).map((path) => ({ ...path, label: `${site.label}/${path.label}` })),
  ]);
  if (sites.length) renderSites(container, sites);
  else container.append(el("p", "empty", "no history yet"));
  localHistory = local;
  renderLocal();
}

// --- helper -----------------------------------------------------------------

// JSON from the launchd helper (helper/ports.rb), or null when it cannot be reached.
async function helper(path, timeout) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeout);
  try {
    const response = await fetch(CONFIG.helper + path, { signal: controller.signal, cache: "no-store" });
    return response.ok ? await response.json() : null;
  } catch {
    return null;
  } finally {
    clearTimeout(timer);
  }
}

// Compose projects of the work stack share a name prefix (`CONFIG.services.prefix`).
const inStack = (project) => !!CONFIG.services.prefix && !!project?.startsWith(CONFIG.services.prefix);
const stackName = (project) => (inStack(project) ? project.slice(CONFIG.services.prefix.length) : project);

const isRepoQuery = (text) => !!CONFIG.github.org && text.startsWith(CONFIG.github.prefix);
const linearIssue = (id) => `https://linear.app/${CONFIG.linear.workspace}/issue/${id}`;
// An issue id of a known team, in either case (`feat/con-39-thing`).
const ISSUE_IN_BRANCH = CONFIG.linear.teams.length
  ? new RegExp(`\\b(${CONFIG.linear.teams.join("|")})-\\d+\\b`, "i")
  : /(?!)/;

// --- repositories -----------------------------------------------------------

// Org repositories, most recently pushed first. Starts from the copy in localStorage
// and replaces it with the helper's answer.
const REPOS_KEY = "repos-v1";
let repos = [];

async function loadRepos() {
  if (!CONFIG.github.org) return;
  try {
    repos = JSON.parse(localStorage.getItem(REPOS_KEY)) ?? [];
  } catch {}
  const fresh = await helper(`/repos?org=${encodeURIComponent(CONFIG.github.org)}`, 15000);
  if (!fresh?.length) return;
  repos = fresh;
  try {
    localStorage.setItem(REPOS_KEY, JSON.stringify(fresh));
  } catch {}
}

const isSubsequence = (needle, text) => {
  let i = 0;
  for (const char of text) if (char === needle[i]) i++;
  return i === needle.length;
};

// Prefix matches first, then substring, then letters in order (`gdw` finds org-web).
// Within each class the most recently pushed repo wins.
function matchRepos(query) {
  const needle = query.toLowerCase();
  const classOf = (name) =>
    name.startsWith(needle) ? 0 : name.includes(needle) ? 1 : isSubsequence(needle, name) ? 2 : 3;
  return repos
    .map((name) => ({ name, rank: classOf(name.toLowerCase()) }))
    .filter((repo) => repo.rank < 3)
    .sort((a, b) => a.rank - b.rank)
    .map(({ name }) => ({
      label: `${CONFIG.github.org}/${name}`,
      url: `https://github.com/${CONFIG.github.org}/${name}`,
      icon: true,
      source: "repo",
    }));
}

// --- url list ---------------------------------------------------------------

// Links from the helper's markdown file, in a foldable section. Starts from the copy
// in localStorage and re-renders when the helper has answered.
const URLS_KEY = "urls-v1";
const URLS_OPEN_KEY = "urls-open";
let urlLinks = [];

function renderUrls(groups) {
  urlLinks = groups.flatMap(({ group, links }) =>
    links.map(({ label, url, note }) => ({ label, url, hint: [group, note].filter(Boolean).join(" · ") })),
  );
  const container = $("urls");
  container.replaceChildren();
  for (const { group, links } of groups) {
    container.append(el("h3", null, group));
    for (const { label, url, note } of links) {
      // Named links show where they go; bare urls are already their own label.
      container.append(row({ label, url, hint: note ?? (label.includes(".") ? "" : hostOf(url)), icon: true }));
    }
  }
  $("urls-section").hidden = !groups.length;
}

async function loadUrls() {
  const section = $("urls-section");
  $("urls-title").textContent = CONFIG.urls.title;
  const fold = svgIcon("chevron");
  fold.classList.add("fold");
  $("urls-title").after(fold);
  let cached = "";
  try {
    section.open = localStorage.getItem(URLS_OPEN_KEY) === "1";
    cached = localStorage.getItem(URLS_KEY) ?? "";
    renderUrls(JSON.parse(cached || "[]"));
  } catch {}
  section.addEventListener("toggle", () => {
    // Folding changes which rows exist, so drop the keyboard selection.
    home.querySelector(".sel")?.classList.remove("sel");
    sel = -1;
    try {
      localStorage.setItem(URLS_OPEN_KEY, section.open ? "1" : "0");
    } catch {}
  });

  const fresh = await helper("/urls", 3000);
  if (!fresh || JSON.stringify(fresh) === cached) return;
  renderUrls(fresh);
  try {
    localStorage.setItem(URLS_KEY, JSON.stringify(fresh));
  } catch {}
}

// --- localhost --------------------------------------------------------------

let localHistory = [];
let running = [];

// Listening servers and the compose stack, from the launchd helper (helper/ports.rb).
// Null when the helper cannot be reached. The last answer is kept in localStorage, so a
// new tab draws it straight away and swaps in the fresh one a moment later.
const LOCAL_KEY = "local-v1";
const overview = () => helper("/overview", 8000);

// The Linear issue named in a branch (`feat/thing-CON-39`) and the branch's pull requests.
function branchLinks(branch, repo, pr) {
  const links = [];
  if (!branch) return links;
  const issue = branch.match(ISSUE_IN_BRANCH)?.[0].toUpperCase();
  if (issue) links.push([issue, linearIssue(issue), "linear"]);
  if (pr) {
    links.push([`PR#${String(pr.number).padStart(4, "0")}`, pr.url, "github"]);
  } else if (repo && !["main", "master"].includes(branch)) {
    // No pull request known (yet): link to the branch's pull request search instead.
    links.push(["PR", `https://github.com/${repo}/pulls?q=${encodeURIComponent(`is:pr head:${branch}`)}`, "github"]);
  }
  return links;
}

// Button that copies `value` to the clipboard when clicked. Its icon turns into a
// check mark for a moment afterwards.
function copyChip(iconName, label, value, title, className = "") {
  const chip = el("button", `chip ${className}`);
  chip.type = "button";
  chip.title = title;
  chip.append(svgIcon(iconName), label);
  chip.addEventListener("click", async () => {
    try {
      await navigator.clipboard.writeText(value);
    } catch {
      // Clipboard API refused: fall back to copying from a temporary field.
      const field = el("textarea");
      field.value = value;
      document.body.append(field);
      field.select();
      document.execCommand("copy");
      field.remove();
    }
    chip.firstChild.replaceWith(svgIcon("check"));
    setTimeout(() => chip.firstChild.replaceWith(svgIcon(iconName)), 1200);
  });
  return chip;
}

// One row with an up/down chip per background service of the compose project.
function serviceStatus(up, colima) {
  const wrap = el("div", "row-wrap services");
  const title = el("h3", "services-title");
  title.append(svgIcon("box"), stackName(CONFIG.services.project));
  wrap.append(title, statusChip("colima", colima ? "up" : "down"));
  for (const name of CONFIG.services.names) wrap.append(statusChip(name, up.includes(name) ? "up" : "down"));
  return wrap;
}

function statusChip(name, state) {
  const chip = el("span", `chip service ${state}`);
  chip.title = `${name}: ${state}`;
  chip.append(svgIcon(state === "up" ? "check" : "alert"), name);
  return chip;
}

async function renderLocal() {
  const fresh = await overview();
  try {
    if (fresh) localStorage.setItem(LOCAL_KEY, JSON.stringify(fresh));
  } catch {}
  drawLocal(fresh);
}

function drawLocal(data) {
  const servers = data?.servers;
  const stack = data?.stack;
  const projects = stack?.projects ?? {};
  const up = projects[CONFIG.services.project] ?? [];
  const colima = stack?.docker ?? false;
  const container = $("local");
  container.replaceChildren();

  if (!servers) {
    // Helper is not running: fall back to the ports found in history.
    running = [];
    $("local-title").textContent = "Localhost · from history";
    renderSites(container, localHistory.slice(0, CONFIG.top.ports), true);
    $("local-section").hidden = !localHistory.length;
    return;
  }

  running = servers.map(({ port, pid, command, project, branch, repo, pr, container, service, compose }) => ({
    pid,
    grouped: inStack(compose),
    container,
    icon: ["plug", "green"],
    // Named after the project with its port; service and branch go below.
    label: `${compose === CONFIG.services.project ? service : (stackName(project) ?? "localhost")}:${port}`,
    url: `http://localhost:${port}`,
    // Everything the compose project runs, so it reads like a project without a web port.
    hint: [...(compose === CONFIG.services.project ? [] : (projects[compose] ?? [service])), branch]
      .filter(Boolean)
      .join(" · ") || (project ? "" : command),
    links: branchLinks(branch, repo, pr),
    // Pages often visited on this port, whichever local hostname was used.
    paths: localHistory.find((site) => site.label.endsWith(`:${port}`))?.paths ?? [],
  }));
  $("local-title").textContent = "Localhost";
  // Other servers first; the compose stack (status row and its servers) closes the list.
  const stackBox = el("div", "stack");
  if (stack && CONFIG.services.project) stackBox.append(serviceStatus(up, colima));
  // Compose projects without a listed web port (ledger) still run against the services.
  const shown = new Set(servers.map((server) => server.compose));
  const silent = Object.entries(projects).filter(
    ([project]) => project !== CONFIG.services.project && !shown.has(project) && inStack(project),
  );
  const tree = el("div", "tree");
  if (silent.length || running.some((server) => server.grouped)) stackBox.append(tree);
  for (const server of running) {
    // Grouped servers hang off the tree, each node holding its row and sub-rows.
    const node = server.grouped ? el("div", "node") : container;
    const wrap = el("div", "row-wrap");
    const main = row(server);
    main.classList.add("two-line");
    wrap.append(main);
    for (const [label, url, kind] of server.links) {
      const chip = el("a", `chip ${kind}`);
      chip.href = url;
      chip.append(svgIcon(kind === "linear" ? "linear" : "pr"), label);
      wrap.append(chip);
    }
    // A container's pid is only the port forwarder, so offer its name instead.
    wrap.append(
      server.container
        ? copyChip("box", "", server.container, `Copy container name: ${server.container}`, "container")
        : copyChip("copy", String(server.pid), String(server.pid), `Copy PID: ${server.pid}`),
    );
    node.append(wrap);
    if (server.grouped) tree.append(node);
    for (const path of server.paths) {
      const sub = row({ label: path.label, url: new URL(new URL(path.url).pathname, server.url).href });
      sub.classList.add("sub");
      node.append(sub);
    }
  }
  for (const [project, services] of silent) {
    const node = el("div", "node");
    const main = row({
      label: stackName(project),
      hint: services.join(" · "),
      icon: ["box", "green"],
    });
    main.classList.add("two-line");
    node.append(main);
    tree.append(node);
  }
  if (stackBox.children.length) container.append(stackBox);
  $("local-section").hidden = !running.length && !stack;
}

document.addEventListener("visibilitychange", () => {
  if (!document.hidden) renderLocal();
});

function drawCachedLocal() {
  try {
    const cached = JSON.parse(localStorage.getItem(LOCAL_KEY));
    if (cached) drawLocal(cached);
  } catch {}
}

// --- open tabs --------------------------------------------------------------

let openTabs = [];
let selfTab;

// Switches to a tab, in whichever window it is, then closes this startpage tab. Each
// step is tried on its own, since a browser may implement only part of the API. When
// nothing works the reason goes to the hint line instead of loading the url again.
async function jumpToTab({ tabId, windowId }) {
  const errors = [];
  const attempt = async (name, fn) => {
    try {
      await fn();
      return true;
    } catch (error) {
      errors.push(`${name}: ${error?.message ?? error}`);
      return false;
    }
  };
  const activated = await attempt("tabs.update", () => call(api.tabs, "update", +tabId, { active: true }));
  const focused = await attempt("windows.update", () => call(api.windows, "update", +windowId, { focused: true }));
  if (activated || focused) {
    if (selfTab) call(api.tabs, "remove", selfTab.id);
  } else {
    $("hint").textContent = `could not switch tab — ${errors.join("; ")}`;
  }
  if (errors.length) console.warn("jumpToTab", { tabId, windowId, errors });
}

// Closes a tab and drops its row. Empties the section when it was the last one.
async function closeTab(rowEl) {
  try {
    await call(api.tabs, "remove", +rowEl.dataset.tabId);
  } catch {
    return;
  }
  openTabs = openTabs.filter((t) => String(t.tab.id) !== rowEl.dataset.tabId);
  const index = rows().indexOf(rowEl);
  const heading = rowEl.previousElementSibling;
  const orphaned = heading?.tagName === "H3" && !rowEl.nextElementSibling?.matches(".row");
  rowEl.remove();
  if (orphaned) heading.remove();
  if (!openTabs.length) $("tabs-section").hidden = true;
  select(Math.min(index, rows().length - 1));
}

async function renderTabs() {
  if (!api.tabs?.query) return;
  let all;
  try {
    [all, selfTab] = await Promise.all([call(api.tabs, "query", {}), call(api.tabs, "getCurrent")]);
  } catch {
    return;
  }
  const own = api.runtime.getURL("");
  const windows = new Map();
  for (const t of all ?? []) {
    if (!t.url || t.url.startsWith(own) || t.id === selfTab?.id) continue;
    const item = { label: t.title || hostOf(t.url), url: t.url, tab: { id: t.id, windowId: t.windowId } };
    if (!windows.has(t.windowId)) windows.set(t.windowId, []);
    windows.get(t.windowId).push(item);
  }
  openTabs = [...windows.values()].flat();
  if (!openTabs.length) return;

  const container = $("tabs");
  container.replaceChildren();
  let n = 0;
  for (const [windowId, items] of windows) {
    const here = windowId === selfTab?.windowId ? " · this window" : "";
    container.append(el("h3", null, `window ${++n}${here} · ${items.length}`));
    for (const item of items) {
      const r = row({ ...item, hint: hostOf(item.url), icon: true });
      const close = svgIcon("x", null, "close tab");
      close.classList.add("close");
      r.append(close);
      container.append(r);
    }
  }
  $("tabs-section").hidden = false;
}

// --- bookmarks --------------------------------------------------------------

const bookmarks = Object.entries(CONFIG.bookmarks).flatMap(([group, links]) =>
  links.map(([label, url]) => ({ label, url, group })),
);

function renderBookmarks() {
  const container = $("bookmarks");
  for (const [group, links] of Object.entries(CONFIG.bookmarks)) {
    container.append(el("h3", null, group));
    for (const [label, url] of links) container.append(row({ label, url, hint: hostOf(url), icon: true }));
  }
}

// --- calendar ---------------------------------------------------------------

// Months laid out like `cal`, weeks starting on Monday: this month with a year on
// either side, in a strip that scrolls sideways.
function renderCalendar() {
  const container = $("calendar");
  const today = new Date();
  for (let offset = -12; offset <= 12; offset++) {
    const first = new Date(today.getFullYear(), today.getMonth() + offset, 1);
    const days = new Date(first.getFullYear(), first.getMonth() + 1, 0).getDate();
    const title = first.toLocaleDateString("en-GB", { month: "long", year: "numeric" });
    const month = el("pre", offset ? "month" : "month current");
    // 20 columns wide: seven two-digit days with a space between.
    month.append(
      el("span", "month-title", `${" ".repeat((20 - title.length) >> 1)}${title}\n`),
      el("span", "weekdays", "Mo Tu We Th Fr Sa Su\n"),
      "   ".repeat((first.getDay() + 6) % 7),
    );
    for (let day = 1; day <= days; day++) {
      const text = String(day).padStart(2);
      month.append(!offset && day === today.getDate() ? el("b", "today", text) : text);
      if (day < days) month.append(new Date(first.getFullYear(), first.getMonth(), day).getDay() ? " " : "\n");
    }
    container.append(month);
  }
  centerCalendar();
}

// Scrolls the strip so this month sits in the middle.
function centerCalendar() {
  const container = $("calendar");
  const current = container.querySelector(".current");
  if (!current) return;
  container.scrollLeft = current.offsetLeft - container.offsetLeft - (container.clientWidth - current.offsetWidth) / 2;
}

window.addEventListener("resize", centerCalendar);

// --- prompt -----------------------------------------------------------------

const looksLikeUrl = (text) =>
  !/\s/.test(text) && /^(https?:\/\/|localhost(:\d+)?(\/|$)|[\w-]+(\.[\w-]+)+(:\d+)?(\/|$))/i.test(text);

function defaultAction(text) {
  const [, team, number] = text.match(/^([a-z]+)-(\d+)$/i) ?? [];
  if (team && CONFIG.linear.teams.includes(team.toUpperCase())) {
    const id = `${team.toUpperCase()}-${number}`;
    return { label: "linear", hint: id, url: linearIssue(id), action: true, icon: ["linear", "peach"] };
  }
  if (looksLikeUrl(text)) {
    const url = /^https?:\/\//i.test(text) ? text : `https://${text}`;
    return { label: "open", hint: url, url, action: true, icon: ["arrow"] };
  }
  const [keyword, ...rest] = text.split(/\s+/);
  const engine = CONFIG.search.engines[keyword];
  if (engine && rest.length) {
    const query = rest.join(" ");
    const url = engine.replace("%s", encodeURIComponent(query));
    return { label: keyword, hint: query, url, action: true, icon: true };
  }
  return {
    label: "search",
    hint: text,
    url: CONFIG.search.default.replace("%s", encodeURIComponent(text)),
    action: true,
    icon: ["search"],
  };
}

// The icon in front of the prompt follows what Enter would do with the text.
let promptIconKey = "search";

function updatePromptIcon(text) {
  let spec = ["search"];
  if (isRepoQuery(text)) {
    spec = ["github", "green"];
  } else if (text) {
    const { icon, url } = defaultAction(text);
    spec = icon === true ? iconSpec(url) : icon;
  }
  if (String(spec) === promptIconKey) return;
  promptIconKey = String(spec);
  $("prompt").firstElementChild.replaceWith(svgIcon(...spec));
}

let searchToken = 0;

async function search(text) {
  const token = ++searchToken;

  if (isRepoQuery(text)) {
    const found = matchRepos(text.slice(CONFIG.github.prefix.length)).slice(0, 12);
    renderResults(found.length ? found : [defaultAction(text)]);
    return;
  }

  // Every whitespace-separated term must appear somewhere in the label, title or url.
  const terms = text.toLowerCase().split(/\s+/);
  const matches = (item) => {
    // The lowercased text is built once per item and reused on later keystrokes.
    item.haystack ??= `${item.label ?? ""} ${item.title ?? ""} ${item.hint ?? ""} ${item.url}`.toLowerCase();
    return terms.every((term) => item.haystack.includes(term));
  };

  // The first source to list a page keeps it.
  const seen = new Set();
  const isNew = ({ url }) => {
    const key = urlKey(url);
    return !seen.has(key) && !!seen.add(key);
  };

  const local = [
    ...openTabs.filter(matches).map((t) => ({ label: t.label, url: t.url, hint: hostOf(t.url), tab: t.tab, source: "tab" })),
    ...bookmarks.filter(matches).map((b) => ({ ...b, hint: hostOf(b.url), source: "bookmark" })),
    ...urlLinks.filter(matches).map((u) => ({ label: u.label, url: u.url, hint: u.hint, source: "url" })),
    ...running.filter(matches).map((s) => ({ label: s.label, url: s.url, hint: s.hint, source: "running" })),
    ...topSites.filter(matches).map((s) => ({ label: s.label, url: s.url, source: "frequent" })),
  ]
    .filter(isNew)
    .map((item) => ({ ...item, icon: true }));
  renderResults([defaultAction(text), ...local]);

  const items = await recentHistory();
  if (token !== searchToken) return;

  // Items are already sorted by score, so stop at the first dozen hits.
  const fromHistory = [];
  for (const item of items) {
    if (!matches(item) || !isNew(item)) continue;
    fromHistory.push({
      label: item.title || hostOf(item.url),
      hint: item.url,
      url: item.url,
      icon: true,
      source: "history",
    });
    if (fromHistory.length === 12) break;
  }
  renderResults([defaultAction(text), ...local, ...fromHistory], sel);
}

function renderResults(items, keep = 0) {
  results.replaceChildren(...items.map(row));
  select(Math.min(keep, items.length - 1));
}

// --- selection --------------------------------------------------------------

// Rows inside a folded section are skipped.
const rows = () =>
  [...(results.hidden ? home : results).querySelectorAll(".row")].filter((r) => !r.closest("details:not([open])"));

function select(index) {
  const all = rows();
  all[sel]?.classList.remove("sel");
  sel = index;
  all[sel]?.classList.add("sel");
  all[sel]?.scrollIntoView({ block: "nearest" });
}

function move(delta) {
  const count = rows().length;
  if (!count) return;
  select(sel < 0 ? (delta > 0 ? 0 : count - 1) : (sel + delta + count) % count);
}

// Not called `open`: a top-level function of that name would replace window.open.
function go(url, newTab) {
  if (newTab) window.open(url, "_blank");
  else location.href = url;
}

input.addEventListener("input", () => {
  const text = input.value.trim();
  rows()[sel]?.classList.remove("sel");
  sel = -1;
  results.hidden = !text;
  home.hidden = !!text;
  updatePromptIcon(text);
  if (text) search(text);
  else searchToken++;
});

document.addEventListener("click", (event) => {
  const close = event.target.closest?.(".icon.close");
  if (close) {
    event.preventDefault();
    closeTab(close.closest(".row"));
    return;
  }
  const link = event.target.closest?.("a[data-tab-id]");
  if (!link || event.metaKey || event.ctrlKey || event.shiftKey || event.button) return;
  event.preventDefault();
  jumpToTab(link.dataset);
});

document.addEventListener("keydown", (event) => {
  const { key, ctrlKey, metaKey } = event;
  if (key === "ArrowDown" || (ctrlKey && key === "n") || (key === "Tab" && !event.shiftKey)) {
    event.preventDefault();
    move(1);
  } else if (key === "ArrowUp" || (ctrlKey && key === "p") || (key === "Tab" && event.shiftKey)) {
    event.preventDefault();
    move(-1);
  } else if (key === "Enter") {
    const target = rows()[sel];
    if (!target) return;
    event.preventDefault();
    if (target.dataset.tabId && !metaKey) jumpToTab(target.dataset);
    else go(target.href, metaKey);
  } else if (key === "Backspace" && metaKey && rows()[sel]?.dataset.tabId) {
    event.preventDefault();
    closeTab(rows()[sel]);
  } else if (key === "Escape") {
    input.value = "";
    input.dispatchEvent(new Event("input"));
  } else if (document.activeElement !== input && key.length === 1 && !ctrlKey && !metaKey) {
    input.focus();
  }
});

renderChrome();
renderBookmarks();
renderCalendar();
renderTabs();
renderTop();
drawCachedLocal();
loadRepos();
loadUrls();
