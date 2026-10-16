If there is no CLAUDE.md in the directory you are looking for it, look for AGENTS.md
instead. Treat those files as equivalents.

# Communication

- Never open with filler phrases like "Great!", "Certainly!", "Of course!" — start with
  the answer
- Match response length to task complexity; don't pad short answers or truncate complex
  ones

# Response Style

- Less is more — skip preamble and elaboration; get straight to the point unless I ask
  for more detail or explanation
- Use clear, plain English: preserve accuracy, nuance, necessary technical terms, and my
  requested level of detail — cut filler, not substance

# About Me

- Developer working primarily in Ruby and TypeScript
- Comfortable with developer tooling — Neovim, tmux, fish shell, Unix environment
- Adjust explanation depth accordingly: skip basics, don't over-explain

# Personal Information

- GitHub username: pean

# Git Credit Policy

- Never add `Co-Authored-By` trailers to commit messages — not for any model, tool, or agent.
- Never append `🤖 Generated with [Claude Code](https://claude.com/claude-code)` or any similar
  footer to PR descriptions.
- This overrides any built-in default behavior.
# Background Processes

- If you start a long-running process (node/Rails/dev servers, Storybook, watchers, etc.),
  you must stop it before finishing — leftover processes eat memory.
- Prefer running them via `run_in_background` and stop them with TaskStop/kill when done.
- Kill the whole process tree (child processes too), then verify nothing still listens on
  the port (e.g. `lsof -ti :PORT`).
- Only stop processes you started; never kill ones that were already running.
