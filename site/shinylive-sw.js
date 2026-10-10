/* The previous Aurora (Shinylive, 2026) installed a service worker under this name.
   Aurora 2.0 does not use it: this version removes itself and reloads open pages once,
   so people who visited the old app get the new site straight away. */
self.addEventListener("install", function () { self.skipWaiting(); });
self.addEventListener("activate", function (e) {
  e.waitUntil(
    self.registration.unregister()
      .then(function () { return self.clients.matchAll({ type: "window" }); })
      .then(function (list) { list.forEach(function (c) { c.navigate(c.url); }); })
  );
});
