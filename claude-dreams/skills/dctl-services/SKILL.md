---
name: dctl-services
description: Start, stop, restart and tail logs for Dreams backing/dependency services (not the service you're actively developing) using the dctl CLI
disable-model-invocation: false
allowed-tools: Bash
---

## What this is for

`dctl` manages Docker-based Dreams services that you depend on but are **not**
actively developing right now — e.g. you're working on `dreams-web-app` and
need `dreams-registry`, `dreams-ledger`, Postgres, etc. running alongside it.

Do **not** use `dctl` for the repo you're actively coding in. That service
should run via the `overmind` fish function instead (see "Running the service
you're working on" below) so you get live reload and direct log access in a
terminal pane.

`dctl` (`~/.local/bin/dctl`) is a thin wrapper that execs into
`~/src/getdreams/dreams-composer/bin/<subcommand>`. Full source, including
service/profile definitions, lives in that dreams-composer repo if you need to
check exact behavior.

## Commands

```
dctl up <scope> [modifiers]     Start services
dctl down <scope>                Stop services
dctl restart <scope> [modifiers] Restart (shorthand for `up --restart`)
dctl status [-v]                 Show running services
dctl log <scope> [-f] [-n N]     Tail logs
dctl teardown                    Remove all services and data
dctl fixtures                    Load fixture data into running service DBs
dctl self-update                 Pull latest changes to dreams-composer itself
```

### Scope flags (for `up`, `down`, `restart`, `log` — combinable)

- `-bs, --backing-services [name]` — redis, postgres, rabbitmq (all, or one by name)
- `-c, --core` — backing services + PostgREST
- `-cs, --core-services` — logging, registry, ledger, strings
- `-ps, --peek-services` — core services + emails + triggers
- `-s, --service <name>` — one specific service, repeatable
- `-n, --native` / `-w, --web` — unstable, platform-specific bundles
- `-a, --all` — (`down` only) stop everything

### Modifiers (for `up`/`restart` only)

- `-b, --branch <name>` — checkout a branch first (`default` = main/master)
- `-p, --pull` — pull latest before starting
- `-r, --restart` — bring down before starting
- `-f, --fixtures` — load fixtures after up
- `-v, --verbose` — trace output

### `log`-specific options

- `-f, --follow`
- `-n, --tail <lines>`

## Common recipes

```bash
# Bring up everything you typically need alongside a web-app checkout
dctl up --core-services --pull

# Start one dependency, following a specific branch
dctl up --service dreams-registry --branch feature-x --restart

# Tail logs for a couple of dependency services
dctl log --service dreams-registry --service dreams-ledger --follow

# Check what's currently running
dctl status -v

# Stop just one service
dctl down --service dreams-registry

# Nuke everything (containers + data) — confirm with the user first
dctl teardown
```

`dctl teardown` and `dctl down --all` affect shared local state the user may
still need for other work — confirm before running them unless the user
explicitly asked for a full reset.

## Running the service you're working on

The repo you're actively developing does **not** go through `dctl`. Run it
with the `overmind` fish function instead, from a **fresh shell** in that
repo's directory:

```bash
overmind start   # or: overmind s
```

Why a fresh shell matters: the `overmind` function (defined in
`config/fish/functions/overmind.fish` in this dotfiles repo) walks up the
directory tree from `pwd` to:

1. Find `Procfile.dev` (preferred over `Procfile`) to use for `start`/`s`
2. Load `.overmind.env` (search stops at the git root)
3. If run inside a git worktree, also load Rails-style env files
   (`.env`, `.env.development`, `.env.local`, `.env.development.local`) from
   the bare repo root

This traversal only happens once, at the point `overmind start` is invoked in
a shell whose `pwd` is inside the target repo — it does not re-scan on a
running instance. So if you `cd` into a different worktree/repo in an
already-running shell and expect env files to reload, they won't; start
`overmind` in a fresh shell (or new terminal pane) opened at that directory
instead.

Other useful subcommands: `overmind restart <process>`, `overmind stop`,
`overmind connect <process>` (attach to a process's console),
`overmind echo <process>` (tail logs for one process). Add `--debug` to the
`overmind` wrapper itself to see which env files and Procfile it resolved.
