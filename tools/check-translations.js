/* =============================================================================
   Aurora — check the translations of the interface
   -----------------------------------------------------------------------------
   Lists, for each language file in site/content/ (lang-pt.js, …):
     - texts of the interface that have no translation yet (they show in English)
     - translations that are no longer used (the English text changed or was removed)

       node tools/check-translations.js          all languages
       node tools/check-translations.js pt       one language
       node tools/check-translations.js --list   every English text to translate (for a new language)

   No packages needed (Node.js only).
   ========================================================================== */
"use strict";
const fs = require("fs");
const path = require("path");
const SITE = path.join(__dirname, "..", "site");

["content/pages.js", "content/info-cards.js", "content/movement-calculator.js", "content/protocols.js",
 "content/cognitive-report.js"].forEach(function (f) { require(path.join(SITE, f)); });
fs.readdirSync(path.join(SITE, "content")).filter(function (f) { return /^lang-[a-z]{2}\.js$/.test(f); })
  .forEach(function (f) { require(path.join(SITE, "content", f)); });
const A = globalThis.Aurora, C = A.content;

/* ------------------------------------------------------------------ 1. short texts (translated by "labels") */
const labels = new Map();             // English text -> where it is used
const LETTERS = ["R", "L", "C", "M"];   // the location buttons (right, left, central, midline): other letters in other languages
function add(s, where) {
  if (typeof s !== "string" || !s.trim()) return;
  if (!/[a-z]{2}/.test(s) && LETTERS.indexOf(s) < 0) return;    // codes and numbers ("3D T1", "FLAIR", "1–10") need no translation
  if (!labels.has(s)) labels.set(s, where);
}

// in the code: t("…"), tn("…"), A.t("…") with the text written between quotes
fs.readdirSync(path.join(SITE, "js")).filter(function (f) { return /\.js$/.test(f); }).forEach(function (f) {
  const src = fs.readFileSync(path.join(SITE, "js", f), "utf8").replace(/^\s*\/\/.*$/gm, "");
  const re = /\b(?:t|tn|A\.t|A\.i18n\.tn)\(\s*"((?:[^"\\]|\\.)*)"/g;
  let m;
  while ((m = re.exec(src))) add(JSON.parse('"' + m[1] + '"'), "js/" + f);
});
// in index.html: data-i18n (text) and data-i18n-label (aria-label), and the page title
const index = fs.readFileSync(path.join(SITE, "index.html"), "utf8");
(index.match(/<[^>]+data-i18n[^>]*>[^<]*/g) || []).forEach(function (tag) {
  const label = /aria-label="([^"]*)"[^>]*data-i18n-label/.exec(tag) || /data-i18n-label[^>]*aria-label="([^"]*)"/.exec(tag);
  if (label) add(label[1], "index.html");
  if (/data-i18n[\s>]/.test(tag)) add(tag.replace(/^<[^>]+>/, "").trim(), "index.html");
});
add(/<title>([^<]*)<\/title>/.exec(index)[1].replace(/&amp;/g, "&"), "index.html");

// in the content files: the fields that js/i18n.js translates
const CO = C.cognitive;
CO.sections.forEach(function (s) { add(s.title, "cognitive-report.js"); add(s.short, "cognitive-report.js"); });
Object.keys(CO.choices).forEach(function (k) { CO.choices[k].forEach(function (o) { add(o.label, "cognitive-report.js"); add(o.hint, "cognitive-report.js"); add(o.title, "cognitive-report.js"); }); });
CO.locationGroups.forEach(function (g) {
  add(g.group, "cognitive-report.js");
  g.rows.forEach(function (r) { add(r.label, "cognitive-report.js"); r.options.forEach(function (o) { add(o.title, "cognitive-report.js"); }); });
});
CO.microbleedRegions.forEach(function (r) { add(r.label, "cognitive-report.js"); });
CO.microbleedGroups.forEach(function (g) { add(g.label, "cognitive-report.js"); });

const MV = C.movement;
MV.cutoffs.forEach(function (c) { add(c.versus, "movement-calculator.js"); add(c.note, "movement-calculator.js"); });
Object.keys(MV.indices).forEach(function (k) { add(MV.indices[k].name, "movement-calculator.js"); add(MV.indices[k].formula, "movement-calculator.js"); });
Object.keys(MV.measurements).forEach(function (k) {
  ["label", "short", "copy"].forEach(function (f) { add(MV.measurements[k][f], "movement-calculator.js"); });
  (MV.measurements[k].parts || []).forEach(function (x) { add(x, "movement-calculator.js"); });
});
MV.calculators.forEach(function (c) { add(c.rail, "movement-calculator.js"); add(c.title, "movement-calculator.js"); });
Object.keys(MV.howto).forEach(function (k) { add(MV.howto[k].title, "movement-calculator.js"); });

const PR = C.protocols;
["cognitive", "movement"].forEach(function (cat) {
  PR[cat].filter(function (p) { return !p.hidden; }).forEach(function (p) {
    ["tab", "title", "field"].forEach(function (f) { add(p[f], "protocols.js"); });
    p.sections.forEach(function (sec) {
      add(sec.title, "protocols.js");
      sec.cols.forEach(function (c) { add(c, "protocols.js"); });
      sec.rows.forEach(function (r) { r.forEach(function (v) { add(v, "protocols.js"); }); });
    });
    (p.notes || []).forEach(function (n) { add(n, "protocols.js"); });
  });
});

const PG = C.pages;
Object.keys(PG.categories).forEach(function (k) { ["title", "subtitle", "home"].forEach(function (f) { add(PG.categories[k][f], "pages.js"); }); });
PG.team.forEach(function (g) {
  if (!g.people.length) return;
  add(g.heading, "pages.js");
  g.people.forEach(function (p) { add(p.contribution, "pages.js"); (p.affiliations || []).forEach(function (a) { [].concat(a).forEach(function (x) { add(x, "pages.js"); }); }); });
});
// headings of the About and Help pages (pages.js, P.build)
const pagesSrc = fs.readFileSync(path.join(SITE, "content/pages.js"), "utf8");
(pagesSrc.match(/\bt\(\s*"((?:[^"\\]|\\.)*)"/g) || []).forEach(function (x) { add(JSON.parse(x.replace(/^t\(\s*/, "")), "pages.js"); });

/* ------------------------------------------------------------------ 2. longer texts (translated by name, same structure as the content files) */
const longTexts = [];                 // each: a list of names, e.g. ["info", "mta", "body"]
function long() { longTexts.push([].slice.call(arguments)); }
["disclaimer", "protocol", "movementReport", "helpTools", "helpSteps", "helpFaq", "helpFeedback", "aboutTitle", "aboutIntro",
 "aboutPrinciples", "getInvolved", "license"].forEach(function (k) { long("pages", k); });
Object.keys(PG.categories).forEach(function (k) { long("pages", "categories", k, "tiles"); });
Object.keys(C.info).forEach(function (k) { long("info", k, "title"); long("info", k, "body"); });
Object.keys(C.infoAbbreviations || {}).forEach(function (k) { long("infoAbbreviations", k); });
Object.keys(MV.indices).forEach(function (k) { long("movement", "indices", k, "about"); });
Object.keys(MV.howto).forEach(function (k) { long("movement", "howto", k, "steps"); });
Object.keys(MV.abbreviations).forEach(function (k) { long("movement", "abbreviations", k); });
Object.keys(MV.notes).forEach(function (k) { long("movement", "notes", k); });
["cognitive", "movement"].forEach(function (cat) {
  PR[cat].filter(function (p) { return !p.hidden && p.abbreviations; }).forEach(function (p) { long("protocols", cat, p.id, "abbreviations"); });
});
function get(obj, keys) {
  return keys.reduce(function (o, k) { return o === undefined || o === null ? undefined : o[k]; }, obj);
}
function name(keys) { return keys.map(function (k) { return /^[A-Za-z_]\w*$/.test(k) ? k : JSON.stringify(k); }).join("."); }

/* ------------------------------------------------------------------ report */
const args = process.argv.slice(2);
if (args.indexOf("--list") >= 0) {
  console.log("Short texts (" + labels.size + "), English: where it is used");
  labels.forEach(function (where, s) { console.log("  " + JSON.stringify(s) + "   // " + where); });
  console.log("\nLonger texts (" + longTexts.length + "), translated by name:");
  longTexts.forEach(function (p) { console.log("  " + name(p)); });
  process.exit(0);
}
const langs = Object.keys(C.languages || {}).filter(function (k) { return !args.length || args.indexOf(k) >= 0; });
if (!langs.length) { console.log("No language files found (site/content/lang-xx.js)."); process.exit(0); }
let problems = 0;
langs.forEach(function (k) {
  const L = C.languages[k], have = L.labels || {};
  const missing = [], unused = [], missingLong = [];
  labels.forEach(function (where, s) { if (!Object.prototype.hasOwnProperty.call(have, s)) missing.push([s, where]); });
  Object.keys(have).forEach(function (s) { if (!labels.has(s)) unused.push(s); });
  longTexts.forEach(function (p) { if (get(L, p) === undefined) missingLong.push(p); });
  // report sentences and calculator sentences (content/cognitive-report.js)
  const reportOk = !!(CO.text && CO.text[k]), calcOk = !!(CO.calculatorText && CO.calculatorText[k]);
  console.log("\n" + (L.name || k) + " (content/lang-" + k + ".js)");
  console.log("  short texts: " + (labels.size - missing.length) + " of " + labels.size + " translated");
  console.log("  longer texts: " + (longTexts.length - missingLong.length) + " of " + longTexts.length + " translated");
  console.log("  report sentences (cognitive-report.js, text." + k + "): " + (reportOk ? "yes" : "not yet: reports stay in English"));
  console.log("  calculator sentences (cognitive-report.js, calculatorText." + k + "): " + (calcOk ? "yes" : "not yet: calculator results stay in English"));
  if (missing.length) { console.log("\n  Missing short texts (shown in English):"); missing.forEach(function (x) { console.log("    " + JSON.stringify(x[0]) + "   // " + x[1]); }); }
  if (missingLong.length) { console.log("\n  Missing longer texts (shown in English):"); missingLong.forEach(function (p) { console.log("    " + name(p)); }); }
  if (unused.length) { console.log("\n  Translations no longer used (the English text changed or was removed):"); unused.forEach(function (s) { console.log("    " + JSON.stringify(s)); }); }
  problems += missing.length + missingLong.length + unused.length;
});
console.log(problems ? "" : "\nAll translated.");
