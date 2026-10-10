/* Atrophy calculators (GCA, MTA, ERICA, Koedam). Results update as you click. */
(function (root) {
  "use strict";
  var A = root.Aurora, ui = A.ui, h = ui.h, E = A.engine;
  var C = function () { return A.content.cognitive; };

  // rail = name in the list on the left (the same names as in the Aurora Report)
  var CALCS = [
    { slug: "gca",    title: "Global Cortical Atrophy (GCA)",            rail: "Global cortical atrophy",    desc: "Sulci and ventricles, 0–3 per region", info: "gca" },
    { slug: "mta",    title: "Medial Temporal Atrophy (MTA)",            rail: "Medial temporal atrophy",    desc: "Scheltens score, 0–4 per side",        info: "mta" },
    { slug: "erica",  title: "Entorhinal Cortical Atrophy (ERICA)",      rail: "Entorhinal atrophy",         desc: "Enkirch score, 0–3 per side",          info: "erica" },
    { slug: "koedam", title: "Posterior Parietal Atrophy (Koedam)",      rail: "Posterior parietal atrophy", desc: "Koedam score, 0–3 per side",           info: "koedam" }
  ];

  // values kept for the open tab (sessionStorage, like the report and the movement calculators)
  var VKEY = "aurora.atrophycalcs.v1";
  var V = {
    gca: E.defaultState().gca,
    mta: { right: 0, left: 0 }, erica: { right: 0, left: 0 }, koedam: { right: 0, left: 0 }
  };
  (function () { var saved = ui.session.get(VKEY); if (saved) Object.keys(V).forEach(function (k) { if (saved[k]) V[k] = saved[k]; }); })();

  /* ------------------------------------------------------------------ page frame shared by all calculators
     Like the Aurora Report: the calculators of the category in a list on the left (large screens) or a row of
     names above (smaller screens), one calculator in the middle, and ⓘ opens the Info box on the right.
     o = { title, sub (line under the title), ref() -> { title, node } for the Info box, onClear } */
  var ICON_INFO = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 11v6"/><circle cx="12" cy="7.6" r=".6" fill="currentColor"/></svg>';
  var ICON_X    = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"/></svg>';
  var ICON_CLEAR = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3.5 12a8.5 8.5 0 1 0 2.6-6.1"/><path d="M3.5 4v4.5H8"/></svg>';
  var infoOpen = false;     // the Info box stays open (or closed) when moving to another calculator

  function frame(page, headSlot, category, slug, o) {
    var links = A.calculatorLinks(category);
    page.classList.add("calc-page");
    var rail = h("nav", { class: "rp-rail calc-rail", "aria-label": "Calculators" },
      h("ol", null, links.map(function (l) {
        var cur = l.slug === slug;
        return h("li", { class: cur ? "cur" : null },
          h("a", { class: "rr-name", href: l.href, "aria-current": cur ? "page" : null }, h("span", { class: "rr-t" }, l.rail || l.short)));
      })));
    var tabs = h("nav", { class: "calc-nav", "aria-label": "Calculators" }, links.map(function (l) {
      return h("a", { href: l.href, class: l.slug === slug ? "active" : null, "aria-current": l.slug === slug ? "page" : null }, l.short || l.title);
    }));
    var ref = h("aside", { class: "ref-panel", "aria-label": "Info" });
    var infoBtn = h("button", { type: "button", class: "info-link", title: "Definition, reference images and source", "aria-label": "Info: " + o.title,
      onclick: function () {
        if (root.innerWidth < 1024) { var c = o.ref(); ui.openModal(c.title, c.node); }   // phones and tablets: a pop-up
        else { if (!infoOpen) fill(); setOpen(!infoOpen, true); }
      } }, h("span", { class: "tab-ic", html: ICON_INFO }));
    function setOpen(open, animate) {
      infoOpen = open;
      page.classList.toggle("ref-open", open);
      page.classList.toggle("ref-anim", !!(open && animate));    // slide in only when opened, not when changing calculator
      infoBtn.setAttribute("aria-pressed", open ? "true" : "false");
    }
    function fill() {
      var c = o.ref();
      ref.innerHTML = "";
      ref.appendChild(h("div", { class: "ref-head" }, h("h2", null, c.title),
        h("button", { type: "button", class: "icon-btn ref-close", "aria-label": "Close", title: "Close", html: ICON_X, onclick: function () { setOpen(false); } })));
      ref.appendChild(ui.externalLinks(c.node));
      ref.scrollTop = 0;
    }
    var body = h("div", { class: "calc-body" });
    var main = h("div", { class: "calc-main" }, tabs,
      h("div", { class: "step-head" }, h("div", { class: "step-title" }, h("h2", null, o.title), infoBtn)),
      o.sub ? h("p", { class: "calc-sub" }, o.sub) : null,
      body);
    page.appendChild(h("div", { class: "calc-shell" }, rail, main, ref));
    // phones: the row of names starts with the current calculator in view
    var act = tabs.querySelector(".active");
    if (act && tabs.scrollWidth > tabs.clientWidth) tabs.scrollLeft = Math.max(0, act.offsetLeft - tabs.offsetLeft - 16);
    if (headSlot) headSlot.appendChild(h("div", { class: "rp-head-actions" },
      h("button", { type: "button", class: "btn new-report", onclick: o.onClear },
        h("span", { class: "tab-ic", html: ICON_CLEAR }), h("span", { class: "nr-label" }, "Clear values"))));
    fill();
    setOpen(infoOpen, false);
    return {
      body: body,
      refresh: fill,                                         // show other content in the Info box
      open: function () { fill(); if (!infoOpen) setOpen(true, true); },
      isOpen: function () { return infoOpen; }
    };
  }
  A.calcFrame = frame;

  // Result card: big numbers first, then the sentence (the same text as before)
  // Result box (grey, like the list and Info boxes): the numbers, the sentence for the report, what it means
  // The result is the report sentence itself: its first sentence (with the score) a little larger, the scores in
  // semi-bold, and the details after it in normal text. Copy result copies the plain sentence.
  // build(mark) returns the sentence; mark(v) wraps a score.
  function resultCard(result, build, notes) {
    var text = build(String), marked = build(function (v) { return "\u0001" + v + "\u0002"; });
    var cut = marked.indexOf(". ");                     // GCA: "… score = 10. Sulci: …" -> headline + details
    var head = cut > 0 ? marked.slice(0, cut + 1) : marked, rest = cut > 0 ? marked.slice(cut + 2) : "";
    function rich(t) { return t.split(/\u0001|\u0002/).map(function (x, i) { return i % 2 ? h("b", null, x) : x; }); }
    result.innerHTML = "";
    result.appendChild(h("div", { class: "cr-top" },
      h("button", { type: "button", class: "btn sm cr-copy", onclick: function () {
        ui.copyText(text).then(function (ok) { ui.toast(ok ? "Result copied" : "Copy failed"); });
      } }, "Copy result"),
      h("p", { class: "cr-head" }, rich(head))));
    if (rest) result.appendChild(h("p", { class: "cr-text cr-detail" }, rich(rest)));
    if (notes && notes.length) result.appendChild(h("div", { class: "cr-note" }, notes.map(function (t) { return h("p", null, t); })));
  }

  function renderGca(pane, result) {
    var ch = C().choices.gca, syncers = [];
    function update() {
      ui.session.set(VKEY, V);
      syncers.forEach(function (f) { f(); });
      var g = V.gca, total = [g.sulci, g.ventricles].reduce(function (t, part) {
        return t + ["frontal", "po", "temporal"].reduce(function (u, k) { return u + Number(part[k][0]) + Number(part[k][1]); }, 0);
      }, 0) + Number(g.third);
      resultCard(result, function (mark) { return E.calcGCA(V.gca, mark); });
    }
    function sg(get, set, label) {
      var s = ui.seg({ options: ch, get: get, set: function (v) { set(v); update(); }, cls: "compact", label: label });
      syncers.push(s.sync); return s;
    }
    var tbody = h("tbody");
    [["sulci", "Sulci"], ["ventricles", "Ventricles"]].forEach(function (p) {
      tbody.appendChild(h("tr", { class: "grp" }, h("th", { colspan: 3 }, p[1])));
      [["frontal", "Frontal"], ["po", "Parieto-occipital"], ["temporal", "Temporal"]].forEach(function (r) {
        tbody.appendChild(h("tr", null, h("td", { class: "rl" }, r[1]),
          h("td", { "data-side": "Right" }, sg(function () { return V.gca[p[0]][r[0]][0]; }, function (v) { V.gca[p[0]][r[0]][0] = v; }, p[1] + " " + r[1] + " right")),
          h("td", { "data-side": "Left" }, sg(function () { return V.gca[p[0]][r[0]][1]; }, function (v) { V.gca[p[0]][r[0]][1] = v; }, p[1] + " " + r[1] + " left"))));
      });
    });
    tbody.appendChild(h("tr", null, h("td", { class: "rl" }, "Third ventricle"),
      h("td", { "data-side": " " }, sg(function () { return V.gca.third; }, function (v) { V.gca.third = v; }, "Third ventricle")), h("td")));
    pane.appendChild(h("table", { class: "rl-table" }, h("thead", null, h("tr", null, h("th"), h("th", null, "Right"), h("th", null, "Left"))), tbody));
    update();
    return function () { V.gca = E.defaultState().gca; update(); };
  }

  function renderSides(key, choices, pane, result) {
    var syncers = [], T = C().calculatorText[key], row = h("div", { class: "field-row" });
    function update() {
      ui.session.set(VKEY, V);
      syncers.forEach(function (f) { f(); });
      resultCard(result, function (mark) { return E.calcSides(key, V[key].right, V[key].left, mark); }, T.interpretation);
    }
    [["right", "Right hemisphere"], ["left", "Left hemisphere"]].forEach(function (side) {
      var hint = h("div", { class: "hint" });
      var s = ui.seg({ options: choices, get: function () { return V[key][side[0]]; }, set: function (v) { V[key][side[0]] = v; update(); }, label: side[1] });
      syncers.push(s.sync);
      syncers.push(function () {
        var cur = choices.filter(function (o) { return String(o.value) === String(V[key][side[0]]); })[0];
        hint.textContent = cur ? cur.label + ": " + cur.hint : "";
      });
      row.appendChild(h("div", { class: "field" }, h("span", { class: "label" }, side[1]), s, hint));
    });
    pane.appendChild(row);
    update();
    return function () { V[key] = { right: 0, left: 0 }; update(); };
  }

  function renderCalc(page, slug, category, headSlot) {
    var calc = CALCS.filter(function (c) { return c.slug === slug; })[0];
    if (!calc) return false;
    var clear;
    var f = frame(page, headSlot, category, slug, {
      title: calc.title,
      ref: function () { var c = A.content.info[calc.info]; return { title: c ? c.title : calc.title, node: ui.infoCard(calc.info) }; },
      onClear: function () { if (clear) clear(); }
    });
    var result = h("div", { class: "calc-result", "aria-live": "polite" });
    clear = slug === "gca" ? renderGca(f.body, result) : renderSides(slug, C().choices[slug], f.body, result);
    f.body.appendChild(result);          // result under the inputs; it stays in view while scrolling (sticky)
    return true;
  }

  A.atrophyCalcs = { list: CALCS, render: renderCalc };
})(window);
