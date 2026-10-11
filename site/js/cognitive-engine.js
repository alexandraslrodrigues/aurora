/* =============================================================================
   AURORA REPORT ENGINE (cognitive disorders)
   -----------------------------------------------------------------------------
   Turns the form values ("state") into report sentences. It is a line-by-line
   port of the report functions of the Shiny app (web/app/app.R, branch
   aurora2.0): rsi_report_text, li_report_text, fazekas_report_text,
   pvs_report_text, mb_report_text, css_report_text, gca_report_text,
   mta_report_text, erica_report_text, pca_report_text, ssvds_report_text
   and their _pt versions.
   The words themselves come from content/cognitive-report.js.
   No page code here, so the same file runs in the browser and in the tests.
   ========================================================================== */

(function (root) {
  "use strict";
  var Aurora = root.Aurora = root.Aurora || {};
  var C = function () { return Aurora.content.cognitive; };

  var SECTION_ORDER = ["rsi", "lacunes", "wmh", "pvs", "microbleeds", "css", "gca", "mta", "erica", "koedam", "svd"];

  /* ---------- small helpers ---------- */

  // "{left} and {right}" + {left: 1, right: 2} -> "1 and 2"
  function fill(tpl, vars) {
    return String(tpl).replace(/\{(\w+)\}/g, function (m, k) {
      return Object.prototype.hasOwnProperty.call(vars, k) ? String(vars[k]) : m;
    });
  }
  function squish(s) { return String(s).replace(/\s+/g, " ").trim(); }
  function capFirst(s) { return s.charAt(0).toUpperCase() + s.slice(1); }
  function num(x) {                         // R's paste() of a number
    var n = Number(x);
    return String(n);
  }
  // Join a list: ["a","b","c"] -> "a, b" + last + "c"
  function joinList(items, sep, and2, andLast) {
    if (items.length <= 1) return items.join("");
    if (items.length === 2) return items[0] + and2 + items[1];
    return items.slice(0, -1).join(sep) + andLast + items[items.length - 1];
  }

  /* ---------- default state (what a new report starts with) ---------- */

  function defaultState() {
    var mb = {};
    C().microbleedRegions.forEach(function (r) { mb[r.key] = { dr: 0, dl: 0, pr: 0, pl: 0 }; });
    return {
      sex: "Female",
      age: null,
      include: { rsi: true, lacunes: true, wmh: true, pvs: true, microbleeds: true, css: true,
                 gca: true, mta: true, erica: true, koedam: true, svd: true },
      rsi: [],
      lacunes: [],
      wmh: { pvGrade: 0, pvDist: "diffuse", pvLat: "bilateral", dwmGrade: 0, dwmDist: "diffuse", dwmLat: "bilateral" },
      pvs: { cs: 0, bg: 0, mes: 0 },
      mb: mb,
      css: { right: 0, left: 0 },
      gca: { sulci: { frontal: [0, 0], po: [0, 0], temporal: [0, 0] },
             ventricles: { frontal: [0, 0], po: [0, 0], temporal: [0, 0] }, third: 0 },
      mta: { right: 0, left: 0 },
      erica: { right: 0, left: 0 },
      koedam: { right: 0, left: 0 }
    };
  }

  /* ---------- location lookup ---------- */
  var _loc = null;
  function locations() {
    if (_loc) return _loc;
    _loc = {};
    C().locationGroups.forEach(function (g) {
      g.rows.forEach(function (row) {
        row.options.forEach(function (o) { _loc[o.id] = o; });
      });
    });
    return _loc;
  }

  /* ---------- 1-2. Recent small subcortical infarcts / lacunes ---------- */
  function locationsText(state, lang, key) {
    var T = C().text[lang][key];
    var loc = locations();
    var phrases = (state[key] || []).map(function (id) { return loc[id] && loc[id][lang]; })
                                   .filter(function (p) { return !!p; });
    if (phrases.length === 0) return T.none;
    var regions = joinList(phrases, ", ", T.and2, T.andLast);
    return capFirst(fill(phrases.length > 1 ? T.many : T.one, { regions: regions }));
  }

  /* ---------- 3. White matter hyperintensities (Fazekas) ---------- */
  function wmhText(state, lang) {
    var T = C().text[lang].wmh, w = state.wmh;
    var pv = Number(w.pvGrade), dwm = Number(w.dwmGrade);
    if (pv === 0 && dwm === 0) return T.none;
    var parts = [];
    if (pv > 0) {
      parts.push(squish(fill(T.periventricular, {
        severity: T.severity[pv],
        distribution: T.pvDistribution[w.pvDist],
        laterality: T.pvLaterality[w.pvLat]
      })));
    }
    if (dwm > 0) {
      parts.push(squish(fill(T.deep[w.dwmDist][w.dwmLat], { severity: T.severity[dwm] })));
    }
    return fill(T.sentence, { regions: parts.join(T.join), fazekas: Math.max(pv, dwm) });
  }

  /* ---------- 4. Perivascular spaces ---------- */
  function pvsText(state, lang) {
    var T = C().text[lang].pvs, p = state.pvs;
    // basal ganglia and centrum semiovale are graded 0–4; the midbrain is only "visible" or not (Potter 2015)
    var mes = Number(p.mes) >= 1 ? T.midbrain : "";
    var rows = [["cs", p.cs], ["bg", p.bg]]
      .map(function (r) { return { region: r[0], score: Number(r[1]) }; })
      .filter(function (r) { return r.score > 0; });
    if (rows.length === 0) return mes || T.none;
    rows.sort(function (a, b) { return b.score - a.score; });      // stable, like R's order()
    var max = rows[0].score;
    var scores = [];
    rows.forEach(function (r) { if (scores.indexOf(r.score) < 0) scores.push(r.score); });

    var parts = scores.map(function (s) {
      var regs = rows.filter(function (r) { return r.score === s; })
                     .map(function (r) { return T.regions[r.region]; });
      var regStr = regs.length > 1 ? regs.slice(0, -1).join(T.regionsJoin) + T.regionsAnd + regs[regs.length - 1] : regs[0];
      if (lang === "pt") return fill(T.part, { grade: T.grade[s], regions: regStr });
      return s === max ? fill(T.first, { grade: T.grade[s], regions: regStr })
                       : fill(T.other, { grade: T.grade[s].toLowerCase(), regions: regStr });
    });

    var out;
    if (lang === "pt") {
      var joined = parts.length > 1 ? parts.slice(0, -1).join(T.partsJoin) + T.partsAnd + parts[parts.length - 1] : parts[0];
      out = fill(T.sentence, { parts: joined });
    } else {
      out = parts.length === 2 && T.partsAnd2 ? parts.join(T.partsAnd2)
          : parts.length > 1 ? parts.slice(0, -1).join(T.partsJoin) + T.partsAnd + parts[parts.length - 1] : parts[0];
    }
    return capFirst(out) + "." + (mes ? " " + mes : "");
  }

  /* ---------- 5. Microbleeds (MARS) ---------- */
  function mbValue(v) { var n = Number(v); return (v === null || v === "" || !isFinite(n) || n < 0) ? 0 : Math.floor(n); }   // counts: whole numbers
  function mbTotal(state) {
    var t = 0;
    C().microbleedRegions.forEach(function (r) {
      var m = state.mb[r.key] || {};
      t += mbValue(m.dr) + mbValue(m.dl) + mbValue(m.pr) + mbValue(m.pl);
    });
    return t;
  }
  // definite microbleeds only: the number in the report and the SVD point ("possible" ones are only described)
  function mbDefinite(state) {
    var t = 0;
    C().microbleedRegions.forEach(function (r) { var m = state.mb[r.key] || {}; t += mbValue(m.dr) + mbValue(m.dl); });
    return t;
  }
  function mbText(state, lang) {
    var T = C().text[lang].microbleeds;
    if (mbTotal(state) === 0) return T.none;
    var total = mbDefinite(state);
    function region(r) {
      var m = state.mb[r.key] || {};
      var dr = mbValue(m.dr), dl = mbValue(m.dl), pr = mbValue(m.pr), pl = mbValue(m.pl);
      var entries = [];
      if (dr > 0 || dl > 0) {
        var d = [];
        if (dr > 0) d.push(fill(T.right, { n: num(dr) }));
        if (dl > 0) d.push(fill(T.left, { n: num(dl) }));
        entries.push(fill(T.definite, { list: d.join(", ") }));
      }
      if (pr > 0 || pl > 0) {
        var p = [];
        if (pr > 0) p.push(fill(T.right, { n: num(pr) }));
        if (pl > 0) p.push(fill(T.left, { n: num(pl) }));
        entries.push(fill(T.possible, { list: p.join(", ") }));
      }
      return entries.length ? fill(T.region, { region: r[lang], entries: entries.join("; ") }) : null;
    }
    var details = [];
    C().microbleedGroups.forEach(function (g) {
      var items = C().microbleedRegions.filter(function (r) { return r.group === g.key; })
                                       .map(region).filter(function (x) { return x; });
      if (items.length) {
        var s = items.length > 1 ? items.slice(0, -1).join(T.regionsJoin) + T.regionsAnd + items[items.length - 1] : items[0];
        details.push(T.groups[g.key] + " " + s);
      }
    });
    var formatted = details.join(". ").replace(/ +\./g, ".");
    return fill(total === 0 ? T.onlyPossible : T.sentence, { total: num(total), details: formatted });
  }

  /* ---------- 6. Cortical superficial siderosis ---------- */
  function cssText(state, lang) {
    var T = C().text[lang].css;
    var r = Number(state.css.right), l = Number(state.css.left), total = r + l;
    if (total === 0) return T.none;
    if (total === 1) return fill(T.mild, { side: r === 1 ? T.mildSide.right : T.mildSide.left });
    var location = r === l ? fill(T.both, { right: r }) : fill(T.each, { right: r, left: l });
    return fill(T.severe, { location: location, total: total });
  }

  /* ---------- 7. Global cortical atrophy (GCA) ---------- */
  function gcaValues(g) {
    return {
      sulci: [g.sulci.frontal[0], g.sulci.frontal[1], g.sulci.po[0], g.sulci.po[1], g.sulci.temporal[0], g.sulci.temporal[1]].map(Number),
      ventricles: [g.ventricles.frontal[0], g.ventricles.frontal[1], g.ventricles.po[0], g.ventricles.po[1],
                   g.ventricles.temporal[0], g.ventricles.temporal[1], Number(g.third)].map(Number)
    };
  }
  function gcaSummary(T, s, v) {
    function summ(name, rv, lv) {
      var parts = [];
      if (rv > 0) parts.push(fill(T.valueRight, { n: rv }));
      if (lv > 0) parts.push(fill(T.valueLeft, { n: lv }));
      return parts.length ? name + " (" + parts.join("; ") + ")" : null;
    }
    var R = T.regions;
    var sulci = [summ(R.frontal, s[0], s[1]), summ(R.po, s[2], s[3]), summ(R.temporal, s[4], s[5])].filter(Boolean).join(", ");
    var vent = [summ(R.frontal, v[0], v[1]), summ(R.po, v[2], v[3]), summ(R.temporal, v[4], v[5])];
    if (v[6] > 0) vent.push(fill(T.thirdValue, { n: v[6] }));
    vent = vent.filter(Boolean).join(", ");
    return { sulci: sulci, ventricles: vent };
  }
  function sum(a) { return a.reduce(function (x, y) { return x + y; }, 0); }
  function max(a) { return Math.max.apply(null, a); }

  // Regions at the top score, as a phrase ("bilateral frontal areas" / "frontal bilateral"), or diffuse.
  // Same rules as gca_atrophy_sentence() in app.R.
  function gcaPattern(T, lang, vals, mx, third) {
    var lobar = vals.slice(0, 6);
    if (lobar.every(function (x) { return x === mx; })) return { diffuse: true, key: "diffuse", text: "" };
    var R = T.regions, base = [R.frontal, R.po, R.temporal];
    var pt = [], bil = [], uni = [];
    for (var i = 0; i < 3; i++) {
      var r = lobar[2 * i] === mx, l = lobar[2 * i + 1] === mx;
      if (r && l) { pt.push(base[i] + " " + T.bilateral); bil.push(T.bilateral + " " + base[i]); }
      else if (r) { pt.push(base[i] + " " + T.right); uni.push(T.right + " " + base[i]); }
      else if (l) { pt.push(base[i] + " " + T.left); uni.push(T.left + " " + base[i]); }
    }
    var hasThird = third !== undefined && third === mx;
    var text;
    if (lang === "pt") {
      if (!pt.length) text = T.thirdVentricle;
      else if (hasThird) text = fill(T.withThird, { regions: pt.join(", ") });
      else text = joinList(pt, ", ", T.join2, T.joinLast);
    } else {
      var en = bil.concat(uni);
      var area = lobar.filter(function (x) { return x === mx; }).length > 1 ? T.areas : T.area;
      if (!en.length) text = T.thirdVentricle;
      else if (hasThird) text = fill(T.withThird, { regions: joinList(en, ", ", T.join2, T.joinLast), area: area });
      else text = joinList(en, ", ", T.join2, T.joinLast) + " " + area;
    }
    return { diffuse: false, key: pt.concat(hasThird ? ["3v"] : []).join("|"), text: text };
  }

  function gcaSentence(T, lang, s, v) {
    function phrase(kind, p, sev) {
      return squish(fill(p.diffuse ? T.diffuse : T.predominant, { severity: sev, kind: kind, regions: p.text }));
    }
    function second(kind, p) {
      return fill(p.diffuse ? T.secondDiffuse : T.secondPredominant, { kind: kind, regions: p.text });
    }
    function lowerFirst(x) { return x.charAt(0).toLowerCase() + x.slice(1); }
    var maxS = max(s), maxV = max(v);
    if (maxS === 0 && maxV === 0) return T.none;
    if (maxV === 0) return fill(T.onlyCortical, { phrase: phrase(T.cortical, gcaPattern(T, lang, s, maxS), T.severity[maxS]) });
    var pv = gcaPattern(T, lang, v, maxV, v[6]);
    if (maxS === 0) return fill(T.onlySubcortical, { phrase: phrase(T.subcortical, pv, T.severity[maxV]) });
    var ps = gcaPattern(T, lang, s, maxS);
    if (maxS === maxV && ps.key === pv.key) return phrase(T.both, ps, T.severity[maxS]) + ".";
    if (maxS === maxV) return phrase(T.cortical, ps, T.severity[maxS]) + T.join2 + second(T.subcortical, pv) + ".";
    return phrase(T.cortical, ps, T.severity[maxS]) + T.join2 + phrase(T.subcortical, pv, lowerFirst(T.severity[maxV])) + ".";
  }

  // Two report lines: the atrophy sentence, then the GCA score with the values
  function gcaText(state, lang) {
    var T = C().text[lang].gca, vals = gcaValues(state.gca), s = vals.sulci, v = vals.ventricles;
    var sm = gcaSummary(T, s, v), parts = [fill(T.score, { score: sum(s) + sum(v) })];
    if (sm.sulci) parts.push(fill(T.sulci, { list: sm.sulci }));
    if (sm.ventricles) parts.push(fill(T.ventricles, { list: sm.ventricles }));
    return [gcaSentence(T, lang, s, v), parts.join(" ").replace(/\s+(?=\.)/g, "").trim()];
  }

  /* ---------- 8. Medial temporal atrophy (MTA) ---------- */
  function ageMissing(age) {
    return age === null || age === undefined || age === "" || !isFinite(Number(age)) || Number(age) <= 0 || Number(age) > 120;
  }
  function mtaText(state, lang) {
    var T = C().text[lang].mta, cut = C().cutoffs;
    var l = Number(state.mta.left), r = Number(state.mta.right);
    var v = { left: l, right: r };
    if (ageMissing(state.age)) {
      return fill(T.missingAge, { scores: fill(l === r ? T.scoresEqual : T.scoresDiff, v) });
    }
    var thr = Number(state.age) < cut.mtaAge ? cut.mtaUnder : cut.mtaFrom;
    var la = l >= thr, ra = r >= thr;
    if (la && ra && l === r) return fill(T.bothAbnormalEqual, v);
    if (la && ra) return fill(T.bothAbnormalDiff, v);
    if (la || ra) {
      return fill(T.oneAbnormal, {
        abnSide: la ? T.side.left : T.side.right, normSide: la ? T.side.right : T.side.left,
        abnValue: la ? l : r, normValue: la ? r : l
      });
    }
    return fill(l === r ? T.normalEqual : T.normalDiff, v);
  }

  /* ---------- 9. Entorhinal cortical atrophy (ERICA) ---------- */
  function ericaText(state, lang) {
    var T = C().text[lang].erica, thr = C().cutoffs.erica;
    var l = Number(state.erica.left), r = Number(state.erica.right);
    var la = l >= thr, ra = r >= thr;
    var v = { left: l, right: r,
              leftStatus: la ? T.status.abnormal : T.status.normal,
              rightStatus: ra ? T.status.abnormal : T.status.normal };
    if (la && ra) return fill(l === r ? T.bothAbnormalEqual : T.bothAbnormalDiff, v);
    if (la || ra) {
      v.abnSide = la ? T.side.left : T.side.right;
      v.normSide = la ? T.side.right : T.side.left;
      return fill(T.oneAbnormal, v);
    }
    return fill(l === r ? T.normalEqual : T.normalDiff, v);
  }

  /* ---------- 10. Posterior parietal atrophy (Koedam) ---------- */
  function koedamText(state, lang) {
    var T = C().text[lang].koedam;
    var l = Number(state.koedam.left), r = Number(state.koedam.right), v = { left: l, right: r };
    if (l === r) return fill(T.equal, v);
    return fill(l > r ? T.leftGreater : T.rightGreater, v);
  }

  /* ---------- 11. Summary small vessel disease score ---------- */
  // A section marked "Not assessed" gives no point, and the score is then reported as incomplete.
  function included(state, id) { return !state.include || state.include[id] !== false; }
  function svdScore(state) {
    var cut = C().cutoffs;
    var parts = {
      lacunes: (state.lacunes && state.lacunes.length > 0) ? 1 : 0,
      microbleeds: mbDefinite(state) > 0 ? 1 : 0,          // definite microbleeds (Staals 2014: "any CMB")
      pvs: Number(state.pvs.bg) >= cut.svdPvsBasalGanglia ? 1 : 0,
      wmh: (Number(state.wmh.pvGrade) === cut.svdWmhPeriventricular || Number(state.wmh.dwmGrade) >= cut.svdWmhDeep) ? 1 : 0
    };
    parts.missing = ["lacunes", "microbleeds", "pvs", "wmh"].filter(function (k) {
      return !included(state, k);
    });
    parts.missing.forEach(function (k) { parts[k] = 0; });
    parts.total = parts.lacunes + parts.microbleeds + parts.pvs + parts.wmh;
    return parts;
  }
  function svdText(state, lang) {
    var T = C().text[lang].svd, sc = svdScore(state), t = sc.total;
    var v = { score: t, points: t === 1 ? T.point : T.points };
    if (!sc.missing.length) return fill(T.sentence, v);
    var names = sc.missing.map(function (k) { return T.parts[k]; });
    v.missing = names.length > 1 ? names.slice(0, -1).join(", ") + T.and + names[names.length - 1] : names[0];
    return fill(T.incomplete, v);
  }

  /* ---------- the whole report ---------- */
  function sectionText(id, state, lang) {
    switch (id) {
      case "rsi": return locationsText(state, lang, "rsi");
      case "lacunes": return locationsText(state, lang, "lacunes");
      case "wmh": return wmhText(state, lang);
      case "pvs": return pvsText(state, lang);
      case "microbleeds": return mbText(state, lang);
      case "css": return cssText(state, lang);
      case "gca": return gcaText(state, lang);
      case "mta": return mtaText(state, lang);
      case "erica": return ericaText(state, lang);
      case "koedam": return koedamText(state, lang);
      case "svd": return svdText(state, lang);
    }
    return "";
  }

  function report(state, lang) {
    return SECTION_ORDER.filter(function (id) { return state.include[id]; })
      .reduce(function (out, id) {          // a section can give more than one line (GCA gives two)
        [].concat(sectionText(id, state, lang)).forEach(function (t) { out.push({ id: id, text: t }); });
        return out;
      }, []);
  }

  // Is the section still at its starting (normal) values?
  function isDefault(id, state) {
    switch (id) {
      case "rsi": return state.rsi.length === 0;
      case "lacunes": return state.lacunes.length === 0;
      case "wmh": return Number(state.wmh.pvGrade) === 0 && Number(state.wmh.dwmGrade) === 0;
      case "pvs": return !(Number(state.pvs.cs) || Number(state.pvs.bg) || Number(state.pvs.mes));
      case "microbleeds": return mbTotal(state) === 0;
      case "css": return !(Number(state.css.right) || Number(state.css.left));
      case "gca": var g = gcaValues(state.gca); return sum(g.sulci) + sum(g.ventricles) === 0;
      case "mta": case "erica": case "koedam":
        return !(Number(state[id].right) || Number(state[id].left));
    }
    return true;
  }

  /* ---------- Excel export: same columns and values as the Shiny app ---------- */
  function choiceExport(list, value) {
    for (var i = 0; i < list.length; i++) if (String(list[i].value) === String(value)) return list[i].export || String(list[i].value);
    return "";
  }
  // A section marked "Not assessed" exports "NA" in its columns (it is not in the report either)
  var EXCEL_SECTION = [["RecentSmallInfarcts", "rsi"], ["LacunarInfarcts", "lacunes"], ["Fazekas.", "wmh"], ["PVS.", "pvs"],
    ["Microbleeds.", "microbleeds"], ["CSS.", "css"], ["GCA.", "gca"], ["MTA.", "mta"], ["ERICA.", "erica"], ["PCA.", "koedam"], ["SSVDSReport", "svd"]];
  function excelColumns(state) {
    var ch = C().choices, cols = [];
    function add(name, value) {
      var sec = EXCEL_SECTION.filter(function (e) { return name.indexOf(e[0]) === 0; })[0];
      cols.push([name, sec && !included(state, sec[1]) ? "NA" : value]);
    }
    add("PatientInfo.Sex", state.sex);
    add("PatientInfo.Age", ageMissing(state.age) ? "" : Number(state.age));
    add("RecentSmallInfarcts", state.rsi.join(", "));
    add("LacunarInfarcts", state.lacunes.join(", "));
    var w = state.wmh;
    add("Fazekas.PeriventricularGrade", choiceExport(ch.pvGrade, w.pvGrade));
    add("Fazekas.PeriventricularDistribution", w.pvDist);
    add("Fazekas.PeriventricularLaterality", w.pvLat);
    add("Fazekas.DeepWhiteMatterGrade", choiceExport(ch.dwmGrade, w.dwmGrade));
    add("Fazekas.DeepWhiteMatterDistribution", w.dwmDist);
    add("Fazekas.DeepWhiteMatterLaterality", w.dwmLat);
    add("PVS.CentrumSemiovale", choiceExport(ch.pvs, state.pvs.cs));
    add("PVS.BasalGanglia", choiceExport(ch.pvs, state.pvs.bg));
    add("PVS.Mesencephalon", choiceExport(ch.pvsMes, Number(state.pvs.mes) >= 1 ? 1 : 0));
    C().microbleedRegions.forEach(function (r) {
      var m = state.mb[r.key];
      add("Microbleeds." + r.excel + "DefiniteRight", mbValue(m.dr));
      add("Microbleeds." + r.excel + "DefiniteLeft", mbValue(m.dl));
      add("Microbleeds." + r.excel + "PossibleRight", mbValue(m.pr));
      add("Microbleeds." + r.excel + "PossibleLeft", mbValue(m.pl));
    });
    add("CSS.SuperficialSiderosisRight", choiceExport(ch.css, state.css.right));
    add("CSS.SuperficialSiderosisLeft", choiceExport(ch.css, state.css.left));
    var g = state.gca;
    add("GCA.FrontalSulciRight", String(g.sulci.frontal[0]));
    add("GCA.FrontalSulciLeft", String(g.sulci.frontal[1]));
    add("GCA.FrontalVentriclesRight", String(g.ventricles.frontal[0]));
    add("GCA.FrontalVentriclesLeft", String(g.ventricles.frontal[1]));
    add("GCA.ParietoSulciRight", String(g.sulci.po[0]));
    add("GCA.ParietoSulciLeft", String(g.sulci.po[1]));
    add("GCA.ParietoVentriclesRight", String(g.ventricles.po[0]));
    add("GCA.ParietoVentriclesLeft", String(g.ventricles.po[1]));
    add("GCA.TemporalSulciRight", String(g.sulci.temporal[0]));
    add("GCA.TemporalSulciLeft", String(g.sulci.temporal[1]));
    add("GCA.TemporalVentriclesRight", String(g.ventricles.temporal[0]));
    add("GCA.TemporalVentriclesLeft", String(g.ventricles.temporal[1]));
    add("GCA.ThirdVentricle", String(g.third));
    add("MTA.MTARight", choiceExport(ch.mta, state.mta.right));
    add("MTA.MTALeft", choiceExport(ch.mta, state.mta.left));
    add("ERICA.ERICARight", choiceExport(ch.erica, state.erica.right));
    add("ERICA.ERICALeft", choiceExport(ch.erica, state.erica.left));
    add("PCA.PCARight", choiceExport(ch.koedam, state.koedam.right));
    add("PCA.PCALeft", choiceExport(ch.koedam, state.koedam.left));
    add("SSVDSReport", svdText(state, "en"));
    return cols;
  }

  /* ---------- single calculators (in the language of the site; English by default) ---------- */
  // mark (optional): wraps the scores, so the calculator page can show them in semi-bold
  function calcLang(lang) { var CT = C().calculatorText; return CT[lang] && C().text[lang] ? lang : "en"; }
  function calcGCA(g, mark, lang) {
    lang = calcLang(lang);
    var T = C().calculatorText[lang].gca, TT = C().text[lang].gca, vals = gcaValues(g);
    var total = sum(vals.sulci) + sum(vals.ventricles);
    var sm = gcaSummary(TT, vals.sulci, vals.ventricles);
    mark = mark || String;
    var out = fill(T.result, { score: mark(total) }) + " ";
    if (sm.sulci) out += fill(T.sulci, { list: sm.sulci }) + " ";
    if (sm.ventricles) out += fill(T.ventricles, { list: sm.ventricles });
    return out.trim();
  }
  function calcSides(key, right, left, mark, lang) {
    lang = calcLang(lang);
    var CT = C().calculatorText[lang], T = CT[key];
    right = Number(right); left = Number(left); mark = mark || String;
    if (right === left) return fill(T.equal, { score: mark(right) });
    var rHigh = right > left;
    return fill(T.diff, { high: mark(Math.max(right, left)), low: mark(Math.min(right, left)),
                          highSide: rHigh ? CT.side.right : CT.side.left, lowSide: rHigh ? CT.side.left : CT.side.right });
  }

  Aurora.engine = {
    SECTION_ORDER: SECTION_ORDER,
    fill: fill,
    defaultState: defaultState,
    sectionText: sectionText,
    report: report,
    reportText: function (state, lang) { return report(state, lang).map(function (s) { return s.text; }).join("\n"); },
    isDefault: isDefault,
    svdScore: svdScore,
    mbTotal: mbTotal,
    mbDefinite: mbDefinite,
    mbValue: mbValue,
    ageMissing: ageMissing,
    locations: locations,
    excelColumns: excelColumns,
    calcGCA: calcGCA,
    calcSides: calcSides,
    calcLang: calcLang
  };
})(typeof window !== "undefined" ? window : globalThis);
