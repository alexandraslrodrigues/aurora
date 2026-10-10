/* Aurora Report page (cognitive disorders): one page, sections on the left,
   live report on the right (phone: bottom bar + full-screen report). */
(function (root) {
  "use strict";
  var A = root.Aurora, ui = A.ui, h = ui.h, E = A.engine;
  var KEY = "aurora.cognitive.report.v1";
  var C = function () { return A.content.cognitive; };

  // Which part of the state each section edits
  var STATE_KEY = { rsi: "rsi", lacunes: "lacunes", wmh: "wmh", pvs: "pvs", microbleeds: "mb", css: "css",
                    gca: "gca", mta: "mta", erica: "erica", koedam: "koedam" };

  var S = null;           // { state, pending: {}, open: {}, lang }
  var syncers = [];       // functions that refresh controls from the state
  var els = {};           // page elements updated on each change

  function clone(x) { return JSON.parse(JSON.stringify(x)); }

  function load() {
    if (S) return;
    var saved = ui.session.get(KEY);
    var st = E.defaultState();
    if (saved && saved.state) {
      // merge saved values onto a fresh default (tolerates older saved versions)
      Object.keys(st).forEach(function (k) { if (saved.state[k] !== undefined) st[k] = saved.state[k]; });
      // the "Cerebral peduncle" row was merged into "Midbrain – cerebral peduncle"
      var merged = { "Cerebral peduncle - Right": "Midbrain - Crus cerebri - Right", "Cerebral peduncle - Left": "Midbrain - Crus cerebri - Left" };
      ["rsi", "lacunes"].forEach(function (k) {
        st[k] = (st[k] || []).map(function (id) { return merged[id] || id; })
                             .filter(function (id, i, a) { return a.indexOf(id) === i; });
      });
    }
    // the step you were on is kept too, so a reload does not send you back to Age and sex
    var step = saved && saved.step && steps().indexOf(saved.step) >= 0 ? saved.step : "patient";
    S = { state: st, pending: (saved && saved.pending) || {}, step: step, info: false, lang: ui.local.get("aurora.lang") || "en" };
  }
  function save() {
    ui.session.set(KEY, { state: S.state, pending: S.pending, step: S.step });
    ui.local.set("aurora.lang", S.lang);
  }

  function statusOf(id) {
    if (!S.state.include[id]) return "na";
    if (id === "svd") return "included";
    return (!E.isDefault(id, S.state) || S.pending[id]) ? "abnormal" : "normal";
  }

  // The middle column shows one step at a time: "patient" (age and sex), each section in order, then "report"
  function steps() { return ["patient"].concat(C().sections.map(function (s) { return s.id; }), ["report"]); }
  function stepIndex() { var i = steps().indexOf(S.step); return i < 0 ? 0 : i; }
  function goStep(i) {
    var list = steps();
    if (i < 0) return;
    if (i >= list.length) return;
    S.step = list[i];
    refresh();
    root.scrollTo({ top: 0, behavior: "smooth" });
  }
  function goToStep(id) { goStep(steps().indexOf(id)); }

  function excludeSection(id) { S.state.include[id] = false; S.pending[id] = false; refresh(); }
  function includeSection(id) { S.state.include[id] = true; refresh(); }
  function clearSection(id) {
    S.state[STATE_KEY[id]] = clone(E.defaultState()[STATE_KEY[id]]);
    S.state.include[id] = true; S.pending[id] = false;
    refresh();
  }

  // Every change goes through here (editing a section puts it back in the report)
  function change(sectionId, fn) {
    fn(S.state);
    if (sectionId && sectionId !== "patient") S.state.include[sectionId] = true;
    refresh();
  }

  function titleOf(id) { var s = C().sections.filter(function (x) { return x.id === id; })[0]; return s ? s.title : id; }

  function refresh() {
    syncers.forEach(function (f) { f(); });
    updateReport();
    updateReference();
    save();
  }

  /* ------------------------------------------------------------------ controls */

  function segFor(getter, setter, options, cls, label) {
    var el = ui.seg({ options: options, get: getter, set: setter, cls: cls, label: label });
    syncers.push(el.sync);
    return el;
  }
  // A graded field with a hint line showing the meaning of the selected grade
  function gradeField(label, options, getter, setter, cls) {
    var hint = h("div", { class: "hint" });
    var s = segFor(getter, setter, options, cls, label);
    syncers.push(function () {
      var cur = options.filter(function (o) { return String(o.value) === String(getter()); })[0];
      hint.textContent = cur && cur.hint ? cur.label + ": " + cur.hint : "";
    });
    return h("div", { class: "field" }, h("span", { class: "label" }, label), s, hint);
  }

  function buildLocations(id) {
    var key = STATE_KEY[id];
    var selected = h("div", { class: "loc-selected", "aria-live": "polite" });
    var display = {};
    C().locationGroups.forEach(function (g) { g.rows.forEach(function (row) { row.options.forEach(function (o) {
      display[o.id] = row.label + " · " + (o.title || (o.btn === "R" ? "right" : o.btn === "L" ? "left" : o.btn));
    }); }); });
    syncers.push(function () {
      selected.innerHTML = "";
      var list = S.state[key];
      selected.hidden = !list.length;
      list.forEach(function (lid) {
        var label = display[lid] || lid;
        selected.appendChild(h("span", { class: "chip" }, label,
          h("button", { type: "button", "aria-label": "Remove " + label,
                        onclick: function () { change(id, function (st) { st[key] = st[key].filter(function (x) { return x !== lid; }); }); } }, "✕")));
      });
    });
    var groups = C().locationGroups.map(function (g) {
      return h("div", { class: "loc-group" },
        h("div", { class: "subhead" }, g.group),
        h("div", { class: "loc-rows" }, g.rows.map(function (row) {
          var btns = row.options.map(function (o) {
            var b = h("button", { type: "button", title: o.title || (o.btn === "R" ? "Right" : o.btn === "L" ? "Left" : o.btn), "aria-label": row.label + " " + (o.title || (o.btn === "R" ? "right" : o.btn === "L" ? "left" : o.btn)).toLowerCase(),
              onclick: function () {
                change(id, function (st) {
                  var i = st[key].indexOf(o.id);
                  if (i >= 0) st[key].splice(i, 1); else st[key].push(o.id);     // keeps the order of selection
                });
              } }, o.btn);
            syncers.push(function () { b.setAttribute("aria-pressed", S.state[key].indexOf(o.id) >= 0 ? "true" : "false"); });
            return b;
          });
          return h("div", { class: "loc-row" }, h("span", { class: "loc-label" }, row.label), h("div", { class: "seg compact" }, btns));
        })));
    });
    // what the letters on the buttons mean
    var legend = h("p", { class: "loc-legend" }, [["R", "right"], ["L", "left"], ["C", "central"], ["M", "midline"]].map(function (x) {
      return h("span", null, h("b", null, x[0]), " " + x[1]);
    }));
    return h("div", null, selected, groups, legend);
  }

  function buildWmh() {
    var ch = C().choices, w = function () { return S.state.wmh; };
    function part(title, gradeKey, distKey, latKey, gradeCh, distCh) {
      var extra = h("div", null,
        h("div", { class: "field" }, h("span", { class: "label" }, "Predominant distribution"),
          segFor(function () { return w()[distKey]; }, function (v) { change("wmh", function (st) { st.wmh[distKey] = v; }); }, distCh, "compact")),
        h("div", { class: "field" }, h("span", { class: "label" }, "Laterality"),
          segFor(function () { return w()[latKey]; }, function (v) { change("wmh", function (st) { st.wmh[latKey] = v; }); }, ch.laterality, "compact")));
      syncers.push(function () { extra.hidden = Number(w()[gradeKey]) === 0; });
      return h("div", null,
        gradeField(title, gradeCh, function () { return w()[gradeKey]; },
                   function (v) { change("wmh", function (st) { st.wmh[gradeKey] = v; }); }),
        extra);
    }
    return h("div", { class: "field-row" },
      part("Periventricular white matter", "pvGrade", "pvDist", "pvLat", ch.pvGrade, ch.pvDistribution),
      part("Deep white matter", "dwmGrade", "dwmDist", "dwmLat", ch.dwmGrade, ch.dwmDistribution));
  }

  function buildPvs() {
    var ch = C().choices;
    // basal ganglia and centrum semiovale: 0–4; midbrain: visible or not (Potter 2015)
    var rows = [["cs", "Centrum semiovale", ch.pvs], ["bg", "Basal ganglia", ch.pvs], ["mes", "Midbrain", ch.pvsMes]];
    return h("div", null, rows.map(function (r) {
      return h("div", { class: "field" }, h("span", { class: "label" }, r[1]),
        segFor(function () { return r[0] === "mes" ? (Number(S.state.pvs.mes) >= 1 ? 1 : 0) : S.state.pvs[r[0]]; },
               function (v) { change("pvs", function (st) { st.pvs[r[0]] = v; }); }, r[2]));
    }));
  }

  function numberInput(getter, setter, label) {
    // whole numbers only (a text box, so a typed comma or letter is simply removed)
    var inp = h("input", { type: "text", inputmode: "numeric", pattern: "[0-9]*", maxlength: "3", autocomplete: "off", placeholder: "0", "aria-label": label });
    inp.addEventListener("input", function () {
      var clean = inp.value.split(/[.,]/)[0].replace(/\D/g, "");   // "1.5" → 1, letters and signs are removed
      if (clean !== inp.value) inp.value = clean;
      setter(clean === "" ? 0 : parseInt(clean, 10));
    });
    inp.addEventListener("keydown", function (e) {                     // ↑ / ↓ change the count, as in a number box
      if (e.key === "ArrowUp" || e.key === "ArrowDown") { e.preventDefault(); step(e.key === "ArrowUp" ? 1 : -1); }
    });
    inp.addEventListener("blur", function () { var v = getter(); inp.value = v ? String(v) : ""; });
    inp.addEventListener("focus", function () { inp.select(); });
    syncers.push(function () { if (document.activeElement !== inp) { var v = getter(); inp.value = v ? String(v) : ""; } });
    // − and + appear above the box that is being edited
    function step(d) {
      var v = Math.max(0, (Number(getter()) || 0) + d);
      inp.value = v ? String(v) : "";
      setter(v);
    }
    function stepBtn(txt, d, name) {
      return h("button", { type: "button", tabindex: "-1", "aria-label": name + " " + label,
        onmousedown: function (e) { e.preventDefault(); },        // keep the box selected
        onclick: function () { step(d); inp.focus(); } }, txt);
    }
    return h("div", { class: "num-cell" }, inp, h("div", { class: "stepper" }, stepBtn("−", -1, "One less:"), stepBtn("+", 1, "One more:")));
  }

  function buildMb() {
    var c = C();
    var thead = h("thead", null,
      h("tr", null, h("th"), h("th", { colspan: 2, class: "mb-head-def" }, "Definite"), h("th", { colspan: 2, class: "mb-head-pos poss" }, "Possible")),
      h("tr", null, h("th"), h("th", null, "Right"), h("th", null, "Left"), h("th", { class: "poss" }, "Right"), h("th", { class: "poss" }, "Left")));
    var tbody = h("tbody");
    c.microbleedGroups.forEach(function (g) {
      tbody.appendChild(h("tr", null, h("th", { class: "grp", colspan: 5 }, g.label)));
      c.microbleedRegions.filter(function (r) { return r.group === g.key; }).forEach(function (r) {
        function cell(f, poss, name) {
          return h("td", { class: poss ? "poss" : null }, numberInput(
            function () { return E.mbValue(S.state.mb[r.key][f]); },
            function (v) { change("microbleeds", function (st) { st.mb[r.key][f] = v; }); },
            r.label + " " + name));
        }
        tbody.appendChild(h("tr", null, h("td", { class: "rl" }, r.label),
          cell("dr", false, "definite right"), cell("dl", false, "definite left"),
          cell("pr", true, "possible right"), cell("pl", true, "possible left")));
      });
    });
    return h("div", null, h("table", { class: "mb-table" }, thead, tbody));
  }

  function buildCss() {
    var ch = C().choices.css;
    return h("div", { class: "field-row" },
      gradeField("Right hemisphere", ch, function () { return S.state.css.right; }, function (v) { change("css", function (st) { st.css.right = v; }); }),
      gradeField("Left hemisphere", ch, function () { return S.state.css.left; }, function (v) { change("css", function (st) { st.css.left = v; }); }));
  }

  function buildGca() {
    var ch = C().choices.gca;
    var regions = [["frontal", "Frontal"], ["po", "Parieto-occipital"], ["temporal", "Temporal"]];
    function sideSeg(part, reg, i, label) {
      return segFor(function () { return S.state.gca[part][reg][i]; },
                    function (v) { change("gca", function (st) { st.gca[part][reg][i] = v; }); }, ch, "compact", label);
    }
    var tbody = h("tbody");
    [["sulci", "Sulci"], ["ventricles", "Ventricles"]].forEach(function (p) {
      tbody.appendChild(h("tr", { class: "grp" }, h("th", { colspan: 3 }, p[1])));
      regions.forEach(function (r) {
        tbody.appendChild(h("tr", null, h("td", { class: "rl" }, r[1]),
          h("td", { "data-side": "Right" }, sideSeg(p[0], r[0], 0, p[1] + " " + r[1] + " right")),
          h("td", { "data-side": "Left" }, sideSeg(p[0], r[0], 1, p[1] + " " + r[1] + " left"))));
      });
    });
    tbody.appendChild(h("tr", null, h("td", { class: "rl" }, "Third ventricle"),
      h("td", { "data-side": " " }, segFor(function () { return S.state.gca.third; },
        function (v) { change("gca", function (st) { st.gca.third = v; }); }, ch, "compact", "Third ventricle")), h("td")));
    return h("table", { class: "rl-table" }, h("thead", null, h("tr", null, h("th"), h("th", null, "Right"), h("th", null, "Left"))), tbody);
  }

  function buildSides(id, choices) {
    return h("div", null,
      h("div", { class: "field-row" },
        gradeField("Right hemisphere", choices, function () { return S.state[id].right; }, function (v) { change(id, function (st) { st[id].right = v; }); }),
        gradeField("Left hemisphere", choices, function () { return S.state[id].left; }, function (v) { change(id, function (st) { st[id].left = v; }); })));
  }

  function buildSvd() {
    var items = [["lacunes", "Lacunes (≥1)"], ["microbleeds", "Cerebral microbleeds (≥1 definite)"],
                 ["pvs", "Perivascular spaces, basal ganglia (moderate or more)"], ["wmh", "White matter hyperintensities (deep Fazekas 2–3 or periventricular 3)"]];
    var list = h("ul", { class: "svd-list" });
    syncers.push(function () {
      var sc = E.svdScore(S.state);
      list.innerHTML = "";
      items.forEach(function (it) {
        var na = sc.missing.indexOf(it[0]) >= 0;          // section marked "Not assessed"
        list.appendChild(h("li", { class: na ? "na" : null }, h("span", null, it[1]),
          h("span", { class: "pts" + (sc[it[0]] ? " on" : "") }, na ? "Not assessed" : sc[it[0]] + (sc[it[0]] === 1 ? " point" : " points"))));
      });
      list.appendChild(h("li", null, h("span", null, sc.missing.length ? "Total (incomplete)" : "Total"), h("span", null, sc.total + " / 4")));
    });
    return list;
  }

  function buildBody(id) {
    var ch = C().choices;
    switch (id) {
      case "rsi": case "lacunes": return buildLocations(id);
      case "wmh": return buildWmh();
      case "pvs": return buildPvs();
      case "microbleeds": return buildMb();
      case "css": return buildCss();
      case "gca": return buildGca();
      case "mta": return buildSides("mta", ch.mta);
      case "erica": return buildSides("erica", ch.erica);
      case "koedam": return buildSides("koedam", ch.koedam);
      case "svd": return buildSvd();
    }
  }

  var ICON_NEXT = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"/></svg>';
  var ICON_PREV = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m15 6-6 6 6 6"/></svg>';
  var ICON_X    = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"/></svg>';
  var ICON_INFO = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 11v6"/><circle cx="12" cy="7.6" r=".6" fill="currentColor"/></svg>';
  var ICON_UNDO = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 9h11a5 5 0 0 1 0 10h-4"/><path d="m8 5-4 4 4 4"/></svg>';

  /* --------------------------------------------- moving between steps
     Large screens: list on the left with Previous / Next under it.
     Smaller screens: Previous | step picker | Next under the form. */
  function shortOf(id) {
    if (id === "patient") return "Age and sex";
    if (id === "report") return "Aurora Report";
    var s = C().sections.filter(function (x) { return x.id === id; })[0];
    return s ? (s.short || s.title) : id;
  }
  function navButtons() {
    var prev = h("button", { type: "button", class: "btn nb-prev", "aria-label": "Previous", onclick: function () { goStep(stepIndex() - 1); } },
      h("span", { class: "tab-ic", html: ICON_PREV }), h("span", { class: "nb-lbl" }, "Previous"));
    var rep = h("button", { type: "button", class: "btn nb-report", "aria-label": "Aurora Report", onclick: function () { goToStep("report"); } },
      h("span", { class: "tab-ic", html: ICON_R }), h("span", { class: "nb-lbl" }, "Report"));
    var next = h("button", { type: "button", class: "btn primary nb-next", onclick: function () { goStep(stepIndex() + 1); } },
      h("span", { class: "nb-lbl" }, "Next"), h("span", { class: "tab-ic", html: ICON_NEXT }));
    syncers.push(function () {
      var i = stepIndex(), last = i === steps().length - 1;
      prev.disabled = i === 0;
      next.disabled = last;
      next.setAttribute("aria-label", last ? "Next" : "Next: " + shortOf(steps()[i + 1]));
      rep.setAttribute("aria-pressed", S.step === "report" ? "true" : "false");
    });
    return [prev, rep, next];
  }

  function buildRail() {
    var items = steps().map(function (id) {
      var isSec = id !== "patient" && id !== "report";
      var mark = id === "report" ? h("span", { class: "rr-ic", html: ICON_R }) : h("span", { class: "rr-dot", "aria-hidden": "true" });
      var name = h("button", { type: "button", class: "rr-name", onclick: function () { goToStep(id); } },
        mark, h("span", { class: "rr-t" }, shortOf(id)));
      var x = isSec ? h("button", { type: "button", class: "rr-x", onclick: function () {
        if (statusOf(id) === "na") includeSection(id); else excludeSection(id);
      } }) : null;
      var li = h("li", null, name, x);
      syncers.push(function () {
        var cur = S.step === id;
        var st = isSec ? statusOf(id) : id === "report" ? "report" : (S.state.age === null || S.state.age === undefined ? "na-soft" : "normal");
        li.className = "st-" + st + (cur ? " cur" : "") + (id === "patient" ? " rr-first" : id === "report" ? " rr-report" : "");
        if (cur) name.setAttribute("aria-current", "step"); else name.removeAttribute("aria-current");
        if (x) {
          var excluded = st === "na";
          x.innerHTML = excluded ? ICON_UNDO : ICON_X;
          x.title = excluded ? "Include in report" : "Exclude from report";
          x.setAttribute("aria-label", x.title + ": " + titleOf(id));
        }
      });
      return li;
    });
    return h("nav", { class: "rp-rail", "aria-label": "Steps" },
      h("ol", null, items),
      h("p", { class: "rr-legend" },
        h("span", { class: "st-normal" }, h("span", { class: "rr-dot" }), "Normal"),
        h("span", { class: "st-abnormal" }, h("span", { class: "rr-dot" }), "Abnormal"),
        h("span", { class: "st-na", title: "Not assessed" }, h("span", { class: "rr-dot" }), "NA")));
  }

  function buildBar() {
    var pick = h("select", { class: "rb-pick", "aria-label": "Go to", onchange: function () { goToStep(pick.value); } },
      steps().map(function (id) { return h("option", { value: id }, shortOf(id)); }));
    syncers.push(function () { pick.value = S.step; });
    var b = navButtons();
    return h("div", { class: "rp-bar" }, b[0], h("div", { class: "rb-mid" }, pick), b[1], b[2]);
  }

  // One section = one step: title, its controls and, when it has findings, "Clear findings"
  function buildSection(sec) {
    var id = sec.id;
    var scoreBadge = h("span", { class: "sec-score" });
    // ⓘ opens the definition and images: a box on the right (larger screens) or a pop-up (phones)
    var info = h("button", { type: "button", class: "info-link", title: "Definition, reference images and source", "aria-label": "Info: " + sec.title,
                             onclick: function () {
                               if (root.innerWidth < 1024) ui.openInfo(sec.info);   // phones and tablets: a pop-up
                               else { S.info = !S.info; refresh(); }
                             } }, h("span", { class: "tab-ic", html: ICON_INFO }));
    var excl = h("button", { type: "button", class: "btn sm sec-excl", onclick: function () { excludeSection(id); } },
      h("span", { class: "tab-ic", html: ICON_X }), "Exclude from report");                  // screens without the list on the left
    var note = h("div", { class: "sec-note" }, h("span", null, "Not included in the report."),
      h("button", { type: "button", class: "btn sm", onclick: function () { includeSection(id); } }, "Include"));
    var clear = id === "svd" ? null :
      h("button", { type: "button", class: "btn sm ghost sec-clear", onclick: function () { clearSection(id); } }, "Clear findings");
    var el = h("section", { class: "sec step", "data-id": id, "aria-label": sec.title },
      h("div", { class: "step-head" }, h("div", { class: "step-title" }, h("h2", null, sec.title), scoreBadge, info),
        h("div", { class: "step-actions" }, excl)),
      note,
      h("div", { class: "sec-body" }, buildBody(id)),
      clear ? h("div", { class: "sec-foot" }, clear) : null);
    syncers.push(function () {
      var st = statusOf(id);
      el.setAttribute("data-status", st);
      el.hidden = S.step !== id;
      info.setAttribute("aria-pressed", S.info ? "true" : "false");
      note.hidden = st !== "na";
      excl.hidden = st === "na";
      if (clear) clear.hidden = st !== "abnormal";
      if (id === "svd") scoreBadge.textContent = st === "na" ? "" : E.svdScore(S.state).total + " / 4";
    });
    return el;
  }

  // small ⓘ after "years": the note shows when the mouse is over it (or it has keyboard focus); nothing to click
  function ageTip() {
    return h("span", { class: "tip-wrap" },
      h("span", { class: "tip", tabindex: "0", role: "img", "aria-label": "About the age", "aria-describedby": "age-tip" }, h("span", { class: "tab-ic", html: ICON_INFO })),
      h("span", { class: "tip-text", role: "tooltip", id: "age-tip" }, "Used for the age-adjusted MTA cut-off."));
  }

  function buildPatient() {
    // a text box that accepts "74", "74.5" or "74,5"; anything outside 1–120 years counts as not given
    var ageInput = h("input", { type: "text", inputmode: "decimal", maxlength: "5", autocomplete: "off", id: "age-input", placeholder: "—", "aria-label": "Age of the patient, in years" });
    ageInput.addEventListener("input", function () {
      var v = ageInput.value.trim().replace(",", "."), n = Number(v);
      var ok = v !== "" && /^\d+(\.\d*)?$/.test(v) && n > 0 && n <= 120;
      ageInput.setAttribute("aria-invalid", v !== "" && !ok ? "true" : "false");
      change("patient", function (st) { st.age = ok ? n : null; });
    });

    syncers.push(function () { if (document.activeElement !== ageInput) ageInput.value = S.state.age === null || S.state.age === undefined ? "" : String(S.state.age); });
    var el = h("section", { class: "step step-patient", "aria-label": "Age and sex" },
      h("div", { class: "step-head" }, h("div", { class: "step-title" }, h("h2", null, "Age and sex"))),
      h("div", { class: "pf" },
        h("div", { class: "pf-row" }, h("span", { class: "pf-label" }, "Sex"),
          segFor(function () { return S.state.sex; }, function (v) { change("patient", function (st) { st.sex = v; }); }, C().choices.sex, "pf-seg", "Sex")),
        h("div", { class: "pf-row" }, h("label", { class: "pf-label", for: "age-input" }, "Age"),
          h("div", { class: "pf-age" }, ageInput, h("span", null, "years"), ageTip()))));
    syncers.push(function () { el.hidden = S.step !== "patient"; });
    return el;
  }

  /* ------------------------------------------------------------------ report panel */

  // Last step: the report itself, with language, copy and download (click a line to go back to its section)
  function buildReportStep() {
    var body = h("div", { class: "rp-body", id: "report-text", "aria-live": "polite" });
    var lang = segFor(function () { return S.lang; }, function (v) { S.lang = v; refresh(); },
                      [{ value: "en", label: "EN", title: "English (US)" }, { value: "pt", label: "PT", title: "Português (Portugal)" }], "lang compact", "Report language");
    els.reportBody = body;
    // language, copy and download sit in the title line of the page (next to New report), only on this step
    els.reportActions = h("div", { class: "rp-report-actions" }, lang,
      h("button", { type: "button", class: "btn primary", onclick: copyReport }, "Copy report"),
      h("button", { type: "button", class: "btn", onclick: exportExcel }, "Download Excel"));
    var el = h("section", { class: "step step-report", "aria-label": "Aurora Report" },
      body,
      h("p", { class: "rv-foot" }, A.content.pages.disclaimer));
    syncers.push(function () { el.hidden = S.step !== "report"; els.reportActions.hidden = S.step !== "report"; });
    return el;
  }

  // Right column: image, definition and references of the section being edited
  var shownRef;            // undefined = nothing drawn yet
  function updateReference() {
    var id = (S.step === "patient" || S.step === "report") ? null : S.step;
    if (!els.ref || shownRef === id) return;
    shownRef = id;
    els.ref.innerHTML = "";
    var sec = id && C().sections.filter(function (x) { return x.id === id; })[0];
    els.ref.classList.toggle("empty", !sec);   // age and sex: no box
    if (!sec) return;
    var info = A.content.info[sec.info];
    var close = h("button", { type: "button", class: "icon-btn ref-close", "aria-label": "Close", title: "Close", html: ICON_X,
                              onclick: function () { S.info = false; refresh(); } });
    els.ref.appendChild(h("div", { class: "ref-head" }, h("h2", null, info ? info.title : sec.title), close));
    els.ref.appendChild(ui.infoCard(sec.info));
    els.ref.scrollTop = 0;
  }

  function updateReport() {
    if (!els.reportBody) return;
    var lines = E.report(S.state, S.lang);
    els.reportBody.innerHTML = "";
    if (!lines.length) els.reportBody.appendChild(h("p", { class: "empty" }, "All sections are marked “Not assessed”."));
    // each line takes you back to its section (by mouse, or Enter / Space on the keyboard)
    lines.forEach(function (l) {
      els.reportBody.appendChild(h("p", { title: "Go to section", tabindex: "0", role: "link", "aria-label": l.text + " (go to section)",
        onclick: function () { goToSection(l.id); },
        onkeydown: function (e) { if (e.key === "Enter" || e.key === " ") { e.preventDefault(); goToSection(l.id); } } }, l.text));
    });
  }

  function goToSection(id) { goToStep(id); }

  function copyReport() {
    var text = E.reportText(S.state, S.lang);
    if (!text) { ui.toast("Nothing to copy: every section is marked “Not assessed”"); return; }
    ui.copyText(text).then(function (ok) {
      ui.toast(ok ? "Report copied" : "Copy failed: select the text and copy it");
    });
  }

  function pad(n) { return (n < 10 ? "0" : "") + n; }
  function exportExcel() {
    try {
      var cols = E.excelColumns(S.state);
      var bytes = A.xlsx.build([cols.map(function (c) { return c[0]; }), cols.map(function (c) { return c[1]; })]);
      var d = new Date();
      var name = "aurorareport_" + d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate()) + "_" +
                 pad(d.getHours()) + "-" + pad(d.getMinutes()) + "-" + pad(d.getSeconds()) + ".xlsx";
      A.xlsx.download(bytes, name);
      ui.toast("Excel file saved");
    } catch (e) {
      ui.toast("Export failed");
      if (root.console) console.error(e);
    }
  }

  function newReport() {
    if (!root.confirm("Start a new report? All values will be cleared.")) return;
    S.state = E.defaultState(); S.pending = {}; S.step = "patient";   // start again from Age and sex
    refresh();
    root.scrollTo(0, 0);
    ui.toast("New report");
  }

  /* ------------------------------------------------------------------ page */

  var ICON_NEW = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3.5 12a8.5 8.5 0 1 0 2.6-6.1"/><path d="M3.5 4v4.5H8"/></svg>';
  var ICON_R = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"/><path d="M14 3v5h5M9 13h6M9 17h6"/></svg>';

  // container = page; headSlot = place in the page title line for the New report button
  function render(container, headSlot) {
    load();
    container.classList.add("report-page");
    syncers = []; els = {}; shownRef = undefined;
    // the explanation box is shown only after ⓘ; without it the page is narrower and centred
    syncers.push(function () {
      container.classList.toggle("ref-open", !!S.info && S.step !== "patient" && S.step !== "report");
      container.classList.toggle("rp-wide", S.step === "report");          // the report itself gets a wider page
    });
    var sections = C().sections.map(buildSection);
    var form = h("div", { class: "form-col" }, buildPatient(), h("div", { class: "sec-list" }, sections), buildReportStep(), buildBar());
    els.ref = h("aside", { class: "ref-panel", "aria-label": "Image and definition" });
    var layout = h("div", { class: "report-layout" }, buildRail(), form, els.ref);
    // title line: New report (always in view)
    var newBtn = h("button", { type: "button", class: "btn new-report", onclick: newReport, "aria-label": "New report", title: "New report" },
      h("span", { class: "tab-ic", html: ICON_NEW }), h("span", { class: "nr-label" }, "New report"));
    (headSlot || container).appendChild(h("div", { class: "rp-head-actions" }, els.reportActions, newBtn));
    container.appendChild(layout);
    refresh();
  }

  A.reportPage = { render: render, _state: function () { load(); return S; } };
})(window);
