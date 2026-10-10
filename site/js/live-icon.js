/* The live Aurora icon on the home page: the real icon, turning, its colours flowing in slow folds
   (same animation as the old loading screen). Light on the computer: small image (96 px), at most
   30 frames per second, paused when the tab is hidden, and off for people who ask their device
   for "reduced motion". If anything fails, the normal still image stays. */
(function (root) {
  "use strict";
  var A = root.Aurora = root.Aurora || {};
  var SPIN = 1.1;          // turning speed (same as the old loading screen)

  A.liveIcon = function (img, src) {
    if (!img || !root.requestAnimationFrame) return;
    if (root.matchMedia && root.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    src = src || "icons/icon-192.png";
    var im = new Image();
    im.onload = function () {
      var tex, TW, TH, TS, tcx, tcy;
      try {
        var c = document.createElement("canvas"); c.width = TW = im.naturalWidth; c.height = TH = im.naturalHeight;
        var cx = c.getContext("2d"); cx.drawImage(im, 0, 0);
        tex = cx.getImageData(0, 0, TW, TH).data;          // fails when opened as a local file …
      } catch (e) {                                        // … so load the embedded copy of the icon and start again
        if (src.slice(0, 5) === "data:") return;           // (if that fails too, the still image stays)
        var sc = document.createElement("script");
        sc.src = "js/live-icon-local.js";
        sc.onload = function () { if (A.liveIconData) A.liveIcon(img, A.liveIconData); };
        document.head.appendChild(sc);
        return;
      }
      TS = Math.min(TW, TH) / 2; tcx = TW / 2; tcy = TH / 2;

      var size = img.clientWidth || 56, dpr = root.devicePixelRatio || 1;
      var canvas = document.createElement("canvas");
      canvas.width = canvas.height = Math.round(size * dpr);
      canvas.setAttribute("aria-hidden", "true");
      var out = canvas.getContext("2d");
      var N = 96, buf = document.createElement("canvas"); buf.width = buf.height = N;
      var bctx = buf.getContext("2d"), frameImg = bctx.createImageData(N, N), d = frameImg.data;
      var px = [0, 0, 0, 0], pa2 = [0, 0, 0, 0];

      function sample(u, v, o) {                       // bilinear sample of the icon, u,v in [-1,1]
        var X = tcx + u * TS - 0.5, Y = tcy + v * TS - 0.5;
        var x0 = Math.floor(X), y0 = Math.floor(Y), fx = X - x0, fy = Y - y0;
        o[0] = o[1] = o[2] = o[3] = 0;
        for (var dy = 0; dy < 2; dy++) for (var dx = 0; dx < 2; dx++) {
          var xx = x0 + dx, yy = y0 + dy, w = (dx ? fx : 1 - fx) * (dy ? fy : 1 - fy);
          if (xx < 0 || yy < 0 || xx >= TW || yy >= TH) continue;
          var p = (yy * TW + xx) * 4;
          o[0] += tex[p] * w; o[1] += tex[p + 1] * w; o[2] += tex[p + 2] * w; o[3] += tex[p + 3] * w;
        }
      }
      function draw(t) {
        var k = 0;
        for (var j = 0; j < N; j++) {
          for (var i = 0; i < N; i++, k += 4) {
            var x = (i + 0.5) / N * 2 - 1, y = (j + 0.5) / N * 2 - 1, r2 = x * x + y * y;
            if (r2 >= 1) { d[k + 3] = 0; continue; }
            var z = Math.sqrt(1 - r2);
            var fx = x + 0.17 * Math.sin(3 * y + 2 * z + t * 0.55) + 0.06 * Math.sin(5 * z - 4 * y - t * 0.8),
                fy = y + 0.17 * Math.sin(3 * z - 2 * x - t * 0.45) + 0.06 * Math.sin(5 * x + 3 * z + t * 0.7),
                fz = z + 0.10 * Math.sin(3 * x + 2 * y + t * 0.35);
            var pr = Math.sqrt(fx * fx + fy * fy), pa = Math.atan2(fy, fx) + 0.25 * Math.sin(2.3 * fx + 1.7 * fy - 1.1 * fz + t * 0.3) * pr;
            pa -= t * SPIN;
            if (pr > 0.74) pr = 0.74 + 0.12 * Math.tanh((pr - 0.74) / 0.12);
            sample(Math.cos(pa) * pr, Math.sin(pa) * pr, px);
            d[k] = px[0]; d[k + 1] = px[1]; d[k + 2] = px[2];
            sample(x, y, pa2);                          // outline and soft edge exactly as in the icon
            d[k + 3] = pa2[3];
          }
        }
        bctx.putImageData(frameImg, 0, 0);
        out.clearRect(0, 0, canvas.width, canvas.height);
        out.imageSmoothingEnabled = true; out.imageSmoothingQuality = "high";
        out.drawImage(buf, 0, 0, canvas.width, canvas.height);
      }

      draw(0);
      if (!img.isConnected) return;
      img.replaceWith(canvas);
      var last = 0;
      function frame(ms) {
        if (!canvas.isConnected) return;                // left the home page: stop
        requestAnimationFrame(frame);
        if (document.hidden || ms - last < 33) return;  // at most ~30 frames per second
        last = ms;
        draw(ms / 1000);
      }
      requestAnimationFrame(frame);
    };
    im.src = src;
  };
})(window);
