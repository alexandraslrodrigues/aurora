/* Aurora service worker: makes the site work offline and installable.
   Pages, code and content: network first (so edits show at once), cached copy when offline.
   Images and fonts: cached first (they rarely change).
   If you add or rename files, add them to FILES and change VERSION. */
var VERSION = "aurora-2.0.3";
var FILES = [
  "./", "index.html", "manifest.webmanifest", "css/aurora.css",
  "content/pages.js", "content/cognitive-report.js", "content/info-cards.js", "content/movement-calculator.js", "content/protocols.js",
  "js/ui.js", "js/xlsx.js", "js/cognitive-engine.js", "js/report-page.js", "js/calculators.js", "js/movement.js", "js/live-icon.js", "js/app.js",
  "fonts/inter-latin-wght-normal.woff2", "fonts/inter-latin-ext-wght-normal.woff2",
  "icons/icon-128.png", "icons/icon-192.png", "icons/icon-512.png", "icons/icon-maskable-512.png", "icons/apple-touch-icon.png",
  "img/area_mes_pon.webp", "img/picture_3v.webp", "img/picture_erica1.webp", "img/picture_fazekas.webp",
  "img/picture_fh.webp", "img/picture_gca.webp", "img/picture_li.webp", "img/picture_mcp.webp",
  "img/picture_mta.webp", "img/picture_pca.webp", "img/picture_pvs.webp", "img/picture_pvs_2.webp",
  "img/picture_rsi.webp", "img/picture_scp.webp", "img/picture_ss.webp", "img/picture_ssvds.webp"
];

self.addEventListener("install", function (e) {
  e.waitUntil(caches.open(VERSION).then(function (c) { return c.addAll(FILES); }).then(function () { return self.skipWaiting(); }));
});
self.addEventListener("activate", function (e) {
  e.waitUntil(caches.keys().then(function (keys) {
    return Promise.all(keys.filter(function (k) { return k !== VERSION; }).map(function (k) { return caches.delete(k); }));
  }).then(function () { return self.clients.claim(); }));
});
self.addEventListener("fetch", function (e) {
  var req = e.request;
  if (req.method !== "GET" || new URL(req.url).origin !== self.location.origin) return;
  var isStatic = /\.(webp|png|woff2)$/.test(new URL(req.url).pathname);
  if (isStatic) {
    e.respondWith(caches.match(req).then(function (hit) {
      return hit || fetch(req).then(function (res) {
        var copy = res.clone(); caches.open(VERSION).then(function (c) { c.put(req, copy); }); return res;
      });
    }));
  } else {
    e.respondWith(fetch(req).then(function (res) {
      if (res.ok) { var copy = res.clone(); caches.open(VERSION).then(function (c) { c.put(req, copy); }); }
      return res;
    }).catch(function () {
      return caches.match(req, { ignoreSearch: true }).then(function (hit) { return hit || caches.match("index.html"); });
    }));
  }
});
