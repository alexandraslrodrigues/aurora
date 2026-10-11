/* Aurora — interface languages.
   The texts are in English in the content files; each other language has its own file
   (content/lang-pt.js, …) with the translations. This file picks the language and, when it is not
   English, puts the translated texts in place before the pages are drawn. Report sentences are
   separate: they are in content/cognitive-report.js (text.en, text.pt, …).

   The language is chosen with the button at the top right and remembered in the browser.
   A link can also open Aurora in a language: aurora-report.com/?lang=pt
   Changing the language reloads the page; what was typed is kept (it is saved in the tab). */
(function (root) {
  "use strict";
  var A = root.Aurora = root.Aurora || {};
  A.content = A.content || {};
  var LANGS = A.content.languages || {};
  var EN = { name: "English", code: "EN", htmlLang: "en", decimal: "." };
  function meta(k) { return k === "en" ? EN : LANGS[k]; }
  var available = ["en"].concat(Object.keys(LANGS).filter(function (k) { return k !== "en" && LANGS[k] && LANGS[k].labels; }));

  var KEY = "aurora.uilang";
  function getStored() { try { return root.localStorage.getItem(KEY); } catch (e) { return null; } }
  function setStored(k) { try { root.localStorage.setItem(KEY, k); } catch (e) { /* ignore */ } }

  // ?lang=pt in the address: use it, remember it, and tidy the address
  var fromLink = null;
  try {
    var m = /[?&]lang=([a-z]{2})\b/i.exec(root.location.search);
    if (m) {
      fromLink = m[1].toLowerCase();
      var rest = root.location.search.replace(/([?&])lang=[a-z]{2}\b&?/i, "$1").replace(/[?&]$/, "");
      root.history.replaceState(null, "", root.location.pathname + rest + root.location.hash);
    }
  } catch (e) { /* ignore */ }
  // Before the language button, the report alone had a language (EN / PT on the report). Whoever chose
  // Portuguese reports there gets the site in Portuguese, so their reports stay in Portuguese.
  function oldReportLanguage() { try { return JSON.parse(root.localStorage.getItem("aurora.lang")); } catch (e) { return null; } }
  var lang = [fromLink, getStored(), oldReportLanguage()].filter(function (k) { return k && available.indexOf(k) >= 0; })[0] || "en";
  if (fromLink === lang || (!getStored() && lang !== "en")) setStored(lang);
  var L = meta(lang), labels = (lang !== "en" && L.labels) || {};

  /* ------------------------------------------------------------ text lookup */
  // fill("{n} points", {n: 3}) -> "3 points"
  function fill(s, vars) {
    if (!vars) return s;
    return String(s).replace(/\{(\w+)\}/g, function (all, k) { return Object.prototype.hasOwnProperty.call(vars, k) ? String(vars[k]) : all; });
  }
  // t("Next") -> "Seguinte" (the English text when there is no translation)
  function t(s, vars) {
    if (s === null || s === undefined || s === "") return s;
    var out = Object.prototype.hasOwnProperty.call(labels, s) ? labels[s] : s;
    return fill(out, vars);
  }
  // Like t(), for texts that contain links or other elements: returns a list of text and elements
  function tn(s, vars) {
    var out = [], tpl = t(s), re = /\{(\w+)\}/g, last = 0, m;
    while ((m = re.exec(tpl))) {
      out.push(tpl.slice(last, m.index));
      out.push(vars && Object.prototype.hasOwnProperty.call(vars, m[1]) ? vars[m[1]] : m[0]);
      last = re.lastIndex;
    }
    out.push(tpl.slice(last));
    return out.filter(function (x) { return x !== ""; });
  }
  // Decimal comma where the language uses it: "13.55" -> "13,55"
  function num(x) {
    var s = String(x);
    return L.decimal && L.decimal !== "." ? s.replace(/(\d)\.(\d)/g, "$1" + L.decimal + "$2") : s;
  }

  /* ------------------------------------------------------------ changing the language (the report follows it) */
  function setLang(k) {
    if (available.indexOf(k) < 0 || k === lang) return;
    setStored(k);
    root.location.reload();
  }

  /* ------------------------------------------------------------ putting the translated content in place */
  // Copies the translated texts over the English ones. Lists are replaced whole, except lists of items
  // with an "id" (protocols), where the translation is given by id: { diagnosis: { abbreviations: "…" } }.
  function merge(base, over) {
    if (!over || typeof over !== "object") return base;
    Object.keys(over).forEach(function (k) {
      var b = base[k], o = over[k];
      if (Array.isArray(b) && o && !Array.isArray(o) && typeof o === "object") {
        b.forEach(function (item) { if (item && item.id && o[item.id]) merge(item, o[item.id]); });
      } else if (b && o && typeof b === "object" && typeof o === "object" && !Array.isArray(b) && !Array.isArray(o)) {
        merge(b, o);
      } else {
        base[k] = o;
      }
    });
    return base;
  }

  // Short labels in the content files (names of sections, buttons, regions…): translated through t()
  function each(list, fn) { (list || []).forEach(fn); }
  function tr(obj, keys) { keys.forEach(function (k) { if (typeof obj[k] === "string") obj[k] = t(obj[k]); }); }

  function localizeCognitive(C) {
    if (!C) return;
    each(C.sections, function (s) { tr(s, ["title", "short"]); });
    if (C.statusLabels) Object.keys(C.statusLabels).forEach(function (k) { C.statusLabels[k] = t(C.statusLabels[k]); });
    Object.keys(C.choices || {}).forEach(function (k) { each(C.choices[k], function (o) { tr(o, ["label", "hint", "title"]); }); });
    each(C.locationGroups, function (g) {
      tr(g, ["group"]);
      each(g.rows, function (r) { tr(r, ["label"]); each(r.options, function (o) { tr(o, ["title"]); }); });
    });
    each(C.microbleedRegions, function (r) { tr(r, ["label"]); });
    each(C.microbleedGroups, function (g) { tr(g, ["label"]); });
  }

  function localizeMovement(M) {
    if (!M) return;
    each(M.cutoffs, function (c) { tr(c, ["versus", "note"]); });
    Object.keys(M.indices || {}).forEach(function (k) { tr(M.indices[k], ["name", "formula"]); });
    Object.keys(M.measurements || {}).forEach(function (k) {
      var m = M.measurements[k];
      tr(m, ["label", "short", "copy"]);
      if (m.parts) m.parts = m.parts.map(function (x) { return t(x); });
    });
    each(M.calculators, function (c) { tr(c, ["rail", "title"]); });
    Object.keys(M.howto || {}).forEach(function (k) { tr(M.howto[k], ["title"]); });
  }

  var MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  function localizeProtocols(PR) {
    if (!PR) return;
    // "Sep 2026" -> the month in the language of the page
    var mm = /^([A-Z][a-z]{2}) (\d{4})$/.exec(PR.updated || "");
    if (mm && MONTHS.indexOf(mm[1]) >= 0) {
      try { PR.updated = new Intl.DateTimeFormat(L.htmlLang, { month: "long", year: "numeric" }).format(new Date(Number(mm[2]), MONTHS.indexOf(mm[1]), 1)); }
      catch (e) { /* keep it as written */ }
    }
    ["cognitive", "movement"].forEach(function (cat) {
      each(PR[cat], function (p) {
        tr(p, ["tab", "title", "field"]);
        each(p.sections, function (sec) {
          sec.colsEn = sec.cols.slice();          // the app finds the "Look for" column by its English name
          tr(sec, ["title"]);
          sec.cols = sec.cols.map(function (c) { return t(c); });
          sec.rows = sec.rows.map(function (r) { return r.map(function (v) { return t(v); }); });
        });
        if (p.notes) p.notes = p.notes.map(function (n) { return t(n); });
      });
    });
  }

  if (lang !== "en") {
    var C = A.content;
    merge(C.pages, L.pages);
    merge(C.info, L.info);
    merge(C.infoAbbreviations, L.infoAbbreviations);
    merge(C.movement, L.movement);
    merge(C.protocols, L.protocols);
    localizeCognitive(C.cognitive);
    localizeMovement(C.movement);
    localizeProtocols(C.protocols);
    if (C.pages) {
      var P = C.pages;
      if (P.categories) Object.keys(P.categories).forEach(function (k) { tr(P.categories[k], ["title", "subtitle", "home"]); });
      if (typeof P.build === "function") P.build(t);         // About and Help pages, in this language
    }
  }

  // Texts written in index.html: data-i18n (the text) and data-i18n-label (aria-label)
  document.documentElement.setAttribute("lang", L.htmlLang);
  if (lang !== "en") {
    document.querySelectorAll("[data-i18n]").forEach(function (el) { el.textContent = t(el.textContent.trim()); });
    document.querySelectorAll("[data-i18n-label]").forEach(function (el) { el.setAttribute("aria-label", t(el.getAttribute("aria-label"))); });
  }

  A.lang = lang;
  A.t = t;
  A.i18n = {
    lang: lang, t: t, tn: tn, num: num, fill: fill, setLang: setLang,
    meta: function (k) { return meta(k || lang); },
    languages: available.map(function (k) { var x = meta(k); return { id: k, name: x.name, code: x.code }; })
  };
})(window);
