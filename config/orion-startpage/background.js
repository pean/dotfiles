// Toolbar button opens the startpage, as a fallback if the newtab override is ignored.
const api = globalThis.browser ?? globalThis.chrome;
api.browserAction.onClicked.addListener(() => {
  api.tabs.create({ url: api.runtime.getURL("index.html") });
});
