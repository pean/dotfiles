// Defaults that are safe to publish. Anything specific to a workspace or an employer
// goes in config.local.js (gitignored), which replaces whole top-level keys of CONFIG.
// See config.local.example.js.
const CONFIG = {
  // Local helper, see helper/ports.rb.
  helper: "http://127.0.0.1:47821",

  // Background services of a Docker Compose project, shown as one status row on the
  // localhost list. `prefix` is dropped from compose project names and groups them.
  services: {
    project: "",
    prefix: "",
    names: [],
  },

  // Foldable link list under the frequent sites. The helper reads the links from a
  // markdown file (~/.config/startpage/urls.md, or STARTPAGE_URLS_FILE).
  urls: {
    title: "URLs",
  },

  // `<TEAM>-<number>` in the prompt opens that issue. Only these team keys are recognised.
  linear: {
    workspace: "",
    teams: [],
  },

  // `<prefix><name>` in the prompt completes to a repository in the org.
  github: {
    org: "",
    prefix: "gh/",
  },

  // Window used for both the frequent list and prompt search. Smaller is faster.
  history: {
    days: 30,
    max: 5000,
    halfLife: 7, // days after the last visit for a page's visits to count half
  },

  top: {
    limit: 10, // hosts
    paths: 3, // max sub-rows per host
    share: 0.15, // a path needs this share of its host's visits to get a row
    ports: 8, // max localhost ports listed when falling back to history
    ignore: ["accounts.google.com"], // hostname suffixes
  },

  // Everything that is not a URL goes to `default`. Kagi handles !bangs itself
  // (`!gh foo`). Add `keyword: "https://…?q=%s"` to `engines` for `keyword foo`.
  search: {
    default: "https://kagi.com/search?q=%s",
    // Shown under the search field. Text in `backticks` is highlighted.
    hint: "`maps <place>` Google Maps · `!<bang> <query>` Kagi bang · `↑↓` select · `⌘↵` new tab",
    engines: {
      maps: "https://www.google.com/maps/search/%s",
    },
  },

  bookmarks: {
    github: [
      ["Github", "https://github.com/pean"],
      ["Pulls", "https://github.com/pulls"],
      ["Review request", "https://github.com/pulls/reviews"],
      ["Notifications", "https://github.com/notifications"],
    ],
    work: [["Calendar", "https://calendar.google.com"]],
    misc: [["kagi", "https://kagi.com"]],
  },
};
