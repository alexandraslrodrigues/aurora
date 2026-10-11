/* Movement calculators (MRPI, MRPI 2.0, midbrain/pons ratios, MCP width).
   Port of the "Movement calculator" of the Shiny app (movement_assess and the
   result cards). Cutoffs and texts: content/movement-calculator.js */
(function (root) {
  "use strict";
  var A = root.Aurora = root.Aurora || {};
  var M = function () { return A.content.movement; };

  /* ------------------------------------------------------------ logic (no page code) */
  function meets(x, op, v) {
    switch (op) { case ">=": return x >= v; case ">": return x > v; case "<": return x < v; case "<=": return x <= v; }
    return false;
  }
  function opLabel(op) { return { ">=": "≥", ">": ">", "<": "<", "<=": "≤" }[op] || op; }
  function favoursText(f, v) { return v ? f + " " + v : f; }   // "PSP vs PD"
  function cutLabel(c, unit) { return (c.favours + " " + c.versus).trim() + " (" + opLabel(c.op) + " " + (c.shown || c.value) + unit + "; " + c.source + ")"; }
  // a cutoff as written in the paper (2.50, 8.0): at least the decimals given in "cutDigits" for the index
  // round half up as on paper (12.95 -> 13.0); toFixed alone gives 12.9 because 12.95 is stored as 12.9499…
  // (12 significant digits first removes that binary noise)
  function roundTo(x, d) { var f = Math.pow(10, d); return Math.round(Number((x * f).toPrecision(12))) / f; }
  function fixed(x, d) { return roundTo(x, d).toFixed(d); }
  function fmtCut(v, info) { var own = (String(v).split(".")[1] || "").length; return v.toFixed(Math.max(own, info.cutDigits || 0)); }
  function positive(x) { var n = Number(x); return (x === null || x === "" || !isFinite(n) || n <= 0) ? NaN : n; }

  function assess(key, x) {
    var info = M().indices[key];
    // compare the value as it is shown (rounded), so the number on screen and the verdict always agree
    x = roundTo(x, info.digits);
    var cuts = M().cutoffs.filter(function (c) { return c.index === key; })
                          .map(function (c) { return Object.assign({}, c, { met: meets(x, c.op, c.value), shown: fmtCut(c.value, info) }); });
    var prim = cuts.filter(function (c) { return c.primary; })[0];
    var fam = function (f) { return f.slice(0, 3); };
    var otherMet = cuts.filter(function (c) { return c.group !== prim.group && c.met && !(prim.met && fam(c.favours) === fam(prim.favours)); });
    // other listed cutoffs for the same disease that give the opposite result (shown under the main sentence)
    var opp = cuts.filter(function (c) { return !c.primary && fam(c.favours) === fam(prim.favours) && c.met !== prim.met; });
    return {
      key: key, info: info, cuts: cuts, prim: prim, opp: opp, otherMet: otherMet,
      valueTxt: x.toFixed(info.digits) + info.unit,
      verdict: prim.met ? "Meets the published cutoff" : "Does not meet the published cutoff",
      verdictMet: prim.met
    };
  }

  function values(m) {
    var mid = measure(m, "midbrain"), p = measure(m, "pons"), md = measure(m, "md"), pd = measure(m, "pd");
    var scp = measure(m, "scp"), mcp = measure(m, "mcp"), fh = measure(m, "fh"), v3 = measure(m, "v3");
    var mrpi = (p / mid) * (mcp / scp);
    var v = { mrpi: mrpi, mrpi2: mrpi * (v3 / fh), mpa: mid / p, md: md, mdpd: md / pd, mcp: mcp };
    Object.keys(v).forEach(function (k) { if (!isFinite(v[k])) delete v[k]; });
    return v;
  }
  // A measurement is one number, or several (third ventricle: 3 parts; peduncles: right and left): Aurora uses the mean
  // of those entered. parts(m, id) = the valid numbers entered; measure(m, id) = their mean.
  function parts(m, id) { var x = m[id]; return (Array.isArray(x) ? x : [x]).map(positive).filter(function (v) { return !isNaN(v); }); }
  function measure(m, id) { var p = parts(m, id); return p.length ? p.reduce(function (a, b) { return a + b; }, 0) / p.length : NaN; }
  function v3Parts(m) { return parts(m, "v3"); }
  function v3Mean(m) { return measure(m, "v3"); }

  // Abbreviations found in a text (same rule as the Shiny app, without look-behind for older Safari)
  function abbrLine(txt, exclude) {
    var ab = M().abbreviations, found = [];
    Object.keys(ab).forEach(function (a) {
      if (exclude && exclude.indexOf(a) >= 0) return;
      var hit = false;
      if (a === "T") hit = /\d T\b/.test(txt);
      else {
        var i = -1;
        while ((i = txt.indexOf(a, i + 1)) >= 0) {
          var before = i > 0 ? txt.charAt(i - 1) : "", after = txt.charAt(i + a.length), after2 = txt.charAt(i + a.length + 1);
          if (/[A-Za-z0-9-]/.test(before)) continue;
          if (/[A-Za-z]/.test(after)) continue;
          if (after === "-" && /[A-Z]/.test(after2)) continue;
          hit = true; break;
        }
      }
      if (hit) found.push(a);
    });
    return found.length ? found.map(function (a) { return a + ", " + ab[a]; }).join("; ") : null;
  }

  A.movementEngine = { roundTo: roundTo, assess: assess, values: values, parts: parts, measure: measure, v3Parts: v3Parts, v3Mean: v3Mean, abbrLine: abbrLine, opLabel: opLabel, cutLabel: cutLabel };

  if (typeof document === "undefined") return;     // tests: logic only

  /* ------------------------------------------------------------ page */
  var ui = A.ui, h = ui.h, t = A.t, tn = A.i18n.tn, N = A.i18n.num;
  var KEY = "aurora.movement.v1";
  var EMPTY = function () { return { midbrain: null, pons: null, scp: [null, null], mcp: [null, null], v3: [null, null, null], fh: null, md: null, pd: null }; };
  var meas = ui.session.get(KEY) || EMPTY();
  // values saved before the peduncles had a right and a left field
  ["scp", "mcp"].forEach(function (id) { if (!Array.isArray(meas[id])) meas[id] = [meas[id] === undefined ? null : meas[id], null]; });
  function isParts(id) { return !!(M().measurements[id] && M().measurements[id].parts); }
  // the mean as written: third ventricle with 1 decimal (6.0 mm), the peduncles with up to 2 (3.15 mm)
  function meanText(id) { var x = measure(meas, id); return id === "v3" ? fixed(x, 1) : String(roundTo(x, 2)); }

  function srcLink(src) {
    if (src.indexOf(";") > 0) {                        // several sources: "Peralta 2022; Chougar 2024"
      var out = h("span");
      src.split(";").forEach(function (one, i) { if (i) out.appendChild(document.createTextNode("; ")); out.appendChild(srcLink(one.trim())); });
      return out;
    }
    var key = src.split(" ").slice(0, 2).join(" ");
    var doi = M().dois[key];
    if (!doi) return document.createTextNode(src);
    return h("a", { href: "https://doi.org/" + doi, target: "_blank", rel: "noopener" }, key);
  }
  // text with {Source Year} placeholders -> nodes with links
  function withLinks(text) {
    var out = [], re = /\{([^}]+)\}/g, last = 0, m;
    while ((m = re.exec(text))) { out.push(text.slice(last, m.index)); out.push(srcLink(m[1])); last = re.lastIndex; }
    out.push(text.slice(last));
    return out;
  }

  // How to measure one measurement: title, example image, steps, method
  function howtoCard(key) {
    var hw = M().howto[key];
    if (!hw) return h("img", { src: "img/" + key, alt: t("How to measure") });
    var img = key.indexOf(".") > 0 ? h("img", { src: "img/" + key, alt: hw.title }) : null;
    var methods = [];
    hw.method.forEach(function (s, i) { if (i) methods.push("; "); methods.push(srcLink(s)); });
    return h("section", { class: "howto info-content", "data-help": key }, h("h3", null, hw.title), img,
      h("ol", null, hw.steps.map(function (s) { return h("li", null, s); })),
      h("p", { class: "credits" }, t("Method:") + " ", methods, "."));
  }

  // Result box, the same as the cognitive calculators: the name and value (the only large text), Copy result,
  // one sentence (dot as in the report: filled = meets the cutoff), short notes, and everything else folded away.
  // Three sizes only: value, sentence (15px), small grey text (13px).
  // measured: "Midbrain area = 100 mm²; pons area = 500 mm²" (added to Copy result only; the inputs are on screen)
  function cutText(c, unit) { return opLabel(c.op) + " " + N(c.shown) + unit; }
  function resultBlock(r, measured) {
    var cut = cutText(r.prim, r.info.unit);
    var cmp = favoursText(r.prim.favours, r.prim.versus);
    // "Meets the published cutoff (≥ 13.55 for PSP vs PD; Quattrone 2008)." States the comparison only, no diagnosis.
    var verdict = r.verdictMet ? t("Meets the published cutoff") : t("Does not meet the published cutoff");
    var sentence = tn("{verdict} ({cut} for {cmp}; {source}).", { verdict: verdict, cut: cut, cmp: cmp, source: srcLink(r.prim.source) });
    var copyText = r.info.name + " = " + N(r.valueTxt.trim()) + ". " + t("{verdict} ({cut} for {cmp}; {source}).", { verdict: verdict, cut: cut, cmp: cmp, source: r.prim.source }) +
                   (measured ? " " + measured + "." : "");

    var notes = [];
    // "Meets the ≥ 12.85 cutoff for PSP rather than MSA-P (Quattrone 2008)." / "Meets the proposed values < 0.21 (Peralta 2022) and …"
    var tested = r.opp.filter(function (c) { return c.tested; }), review = r.opp.filter(function (c) { return !c.tested; });
    tested.forEach(function (c) {
      var v = { cut: cutText(c, r.info.unit), cmp: favoursText(c.favours, c.versus), source: srcLink(c.source) };
      notes.push(r.prim.met ? tn("Does not meet the {cut} cutoff for {cmp} ({source}).", v) : tn("Meets the {cut} cutoff for {cmp} ({source}).", v));
    });
    if (review.length) {
      var list = [];
      review.forEach(function (c, i) {
        if (i) list.push(i === review.length - 1 ? " " + t("and") + " " : ", ");
        list.push(cutText(c, r.info.unit) + " (", srcLink(c.source), ")");
      });
      var one = review.length === 1, v2 = { list: h("span", null, list) };
      notes.push(r.prim.met
        ? (one ? tn("Does not meet the proposed value {list}, which was not tested in a cohort.", v2) : tn("Does not meet the proposed values {list}, which were not tested in a cohort.", v2))
        : (one ? tn("Meets the proposed value {list}, which was not tested in a cohort.", v2) : tn("Meets the proposed values {list}, which were not tested in a cohort.", v2)));
    }
    var notesText = notes.map(function (n) { return n.map(function (x) { return typeof x === "string" ? x : x.textContent; }).join(""); });
    var abbr = abbrLine([r.info.name, verdict, cmp, notesText.join(" "), r.info.about.replace(/[{}]/g, ""),
                         r.cuts.map(function (c) { return c.favours + " " + c.versus + " " + c.note; }).join(" ")].join(" "));

    // all cutoffs: the note of each one goes under its comparison (four columns)
    var rows = r.cuts.map(function (c) {
      var n = [];
      if (!c.tested && !c.note) n.push(t("Proposed from the literature, not tested in a cohort"));
      if (c.note) n.push(c.note);
      return h("tr", null,
        h("td", { class: "nw" }, cutText(c, r.info.unit)),
        h("td", null, favoursText(c.favours, c.versus), n.length ? h("span", { class: "mv-tn" }, n.join("; ")) : null),
        h("td", { class: "nw" }, srcLink(c.source)),
        h("td", { class: "nw" + (c.met ? " met" : "") }, c.met ? [h("span", { class: "rr-dot", "aria-hidden": "true" }), t("Met")] : t("Not met")));
    });

    return h("div", { class: "calc-result mv-result" },
      h("div", { class: "cr-top" },
        h("button", { type: "button", class: "btn sm cr-copy", onclick: function () {
          ui.copyText(copyText).then(function (ok) { ui.toast(ok ? t("Result copied") : t("Copy failed")); });
        } }, t("Copy result")),
        // the dot goes with the value: filled = meets the published cutoff (as Abnormal in the report)
        h("p", { class: "cr-head mv-head" + (r.verdictMet ? " met" : "") }, h("span", { class: "rr-dot", "aria-hidden": "true" }),
          h("span", null, r.info.name + " = ", h("b", null, N(r.valueTxt))))),
      h("p", { class: "cr-text mv-verdict" }, sentence),
      notes.length ? h("div", { class: "cr-note" }, notes.map(function (n) { return h("p", null, n); })) : null,
      h("details", { class: "mv-more" },
        h("summary", null, t("All cutoffs and sources")),
        h("div", { class: "mv-more-body" },
          h("p", null, withLinks(r.info.about)),
          h("div", { class: "mv-table-wrap" }, h("table", { class: "mv-table" },
            h("thead", null, h("tr", null, h("th", null, t("Cutoff")), h("th", null, t("Reported for")), h("th", null, t("Source")), h("th", null, t("This value")))),
            h("tbody", null, rows))),
          h("div", { class: "mv-foot" },
            r.info.marker === "PSP" ? h("p", null, withLinks(M().notes.pspAge)) : null,
            h("p", null, M().notes.general),
            abbr ? h("p", null, t("Abbreviations: {list}.", { list: abbr })) : null))));
  }

  // One calculator per page (same frame as the cognitive calculators).
  // The measurements are kept while the tab is open, so a value typed in one
  // calculator is already there in the others.
  function renderCalc(page, slug, headSlot) {
    var calc = M().calculators.filter(function (c) { return c.slug === slug; })[0];
    if (!calc) return false;
    var results = h("div", { class: "mv-results", "aria-live": "polite" });
    var inputs = [], partUpdaters = [];
    // Info (ⓘ next to the title): how to measure each measurement of this calculator, one after the other
    var keys = [];
    calc.inputs.forEach(function (id) { var k = M().measurements[id].help; if (keys.indexOf(k) < 0) keys.push(k); });
    var f = A.calcFrame(page, headSlot, "movement", slug, {
      title: calc.title,
      sub: M().indices[calc.index].formula,
      ref: function () { return { title: t("How to measure"), node: h("div", { class: "howto-list" }, keys.map(howtoCard)) }; },
      onClear: function () {
        meas = EMPTY(); ui.session.set(KEY, meas);
        inputs.forEach(function (inp) { inp.value = ""; });
        partUpdaters.forEach(function (f) { f(); });
        update();
      }
    });

    // moving to another field: the open Info box scrolls to how to measure it
    function follow(key) {
      if (!f.isOpen() || keys.length < 2) return;
      var box = page.querySelector(".calc-shell > .ref-panel"), card = box && box.querySelector('[data-help="' + key + '"]');
      if (!card) return;
      var top = card.previousElementSibling ? box.scrollTop + card.getBoundingClientRect().top - box.getBoundingClientRect().top - 16 : 0;
      box.scrollTo({ top: top, behavior: "smooth" });
    }

    function update() {
      ui.session.set(KEY, meas);
      results.innerHTML = "";
      var vals = values(meas);
      var shown = calc.shows.filter(function (k) { return vals[k] !== undefined; });
      // warnings: a value that is not a number above 0, or outside the usual range
      var out = [];
      function typed(x) { return x !== null && x !== undefined && x !== ""; }
      calc.inputs.forEach(function (id) {
        var pr = M().measurements[id];
        var raw = Array.isArray(meas[id]) ? meas[id] : [meas[id]];
        if (raw.some(function (x) { return typed(x) && isNaN(positive(x)); })) { out.push(t("{name}: enter a number above 0", { name: pr.short })); return; }
        var v = measure(meas, id);
        if (!isNaN(v) && (v < pr.min || v > pr.max)) out.push(t("{name} {value} (usual {range})", { name: pr.short, value: N(+v.toFixed(10)) + pr.unit, range: N(pr.min) + "–" + N(pr.max) + pr.unit }));
      });
      if (out.length) results.appendChild(h("div", { class: "note-warn" }, t("Check the measurements: {list}.", { list: out.join("; ") })));
      if (!shown.length) return;          // no result until the measurements are entered
      // the measurements behind each result, for Copy result: "Midbrain area = 100 mm²; pons area = 500 mm²"
      function measured(k) {
        return (M().indices[k].uses || []).map(function (id, i) {
          var pr = M().measurements[id], name = pr.copy || pr.short, txt;
          if (isParts(id)) { var n = parts(meas, id).length; txt = N(meanText(id)) + pr.unit + (n > 1 ? " " + t("(mean of {n})", { n: n }) : ""); }
          else txt = N(String(positive(meas[id]))) + pr.unit;
          return (i ? name.charAt(0).toLowerCase() + name.slice(1) : name) + " = " + txt;
        }).join("; ");
      }
      shown.forEach(function (k) { results.appendChild(resultBlock(assess(k, vals[k]), measured(k))); });
    }

    function numInput(id, label, get, set) {
      // a text box with the decimal keypad: "9.5" and "9,5" both work; anything else is flagged
      var inp = h("input", { type: "text", inputmode: "decimal", autocomplete: "off", maxlength: "8", id: id, "aria-label": label });
      var v = get();
      inp.value = v === null || v === undefined ? "" : String(v);
      inp.addEventListener("input", function () {
        var t = inp.value.trim().replace(",", ".");
        set(t === "" ? null : (/^\d*\.?\d+$|^\d+\.$/.test(t) ? Number(t) : t));
        update();
      });
      inputs.push(inp);
      return inp;
    }
    function numField(id) {
      var pr = M().measurements[id];
      var inp = numInput("mv-" + id, pr.label, function () { return meas[id]; }, function (v) { meas[id] = v; });
      inp.addEventListener("focus", function () { follow(pr.help); });
      return h("div", { class: "field mv-field" }, h("label", { class: "label", for: "mv-" + id }, pr.label),
        h("div", { class: "mv-row" }, inp));
    }
    // a measurement in parts: one box per part (third ventricle: anterior, middle, posterior; peduncles: right, left)
    // and, under them, the mean Aurora uses
    function partsField(id) {
      var pr = M().measurements[id], total = pr.parts.length;
      var mean = h("div", { class: "v3-mean" });
      function upd() {
        var n = parts(meas, id).length;
        mean.innerHTML = "";
        if (n) {
          mean.appendChild(document.createTextNode(t("Mean {value}", { value: N(meanText(id)) + pr.unit })));
          if (n < total) mean.appendChild(h("span", { class: "warn" }, " " + t("({n} of {total}; the method uses {total})", { n: n, total: total })));
        }
      }
      partUpdaters.push(upd);
      var boxes = pr.parts.map(function (lab, i) {
        var inp = numInput("mv-" + id + "-" + i, t("{name}, {part}", { name: pr.copy || pr.short, part: lab.toLowerCase() }),
                           function () { return meas[id][i]; }, function (v) { meas[id][i] = v; upd(); });
        inp.addEventListener("focus", function () { follow(pr.help); });
        return h("div", null, h("label", { for: "mv-" + id + "-" + i }, lab), inp);
      });
      upd();
      return h("div", { class: "field mv-field" + (total > 2 ? " wide" : "") }, h("span", { class: "label" }, pr.label),
        h("div", { class: "mv-row" }, h("div", { class: "v3-parts" }, boxes)), mean);
    }

    f.body.appendChild(h("div", { class: "mv-group-fields" }, calc.inputs.map(function (id) { return isParts(id) ? partsField(id) : numField(id); })));
    f.body.appendChild(results);
    update();
    return true;
  }

  A.movementCalcs = { render: renderCalc };
})(typeof window !== "undefined" ? window : globalThis);
