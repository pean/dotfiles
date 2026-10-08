// Copy to config.local.js (gitignored). Loaded after config.js; each key replaces the
// default of the same name, so spread `...CONFIG.x` to extend instead.
Object.assign(CONFIG, {
  services: { project: "myapp-compose", prefix: "myapp-", names: ["postgres", "redis"] },
  urls: { title: "Team URLs" },
  linear: { workspace: "my-workspace", teams: ["ENG"] },
  github: { org: "my-org", prefix: "org/" },
  search: {
    ...CONFIG.search,
    engines: { ...CONFIG.search.engines, org: "https://github.com/search?q=org%3Amy-org+%s&type=code" },
  },
});
