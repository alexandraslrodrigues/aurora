// Compares the HTML version with the Shiny app, sentence by sentence (EN and PT) and Excel columns.
// Run after make-cases.js and shiny-reference.R:   node tests/compare.js
"use strict";
const fs = require("fs");
const path = require("path");
const out = path.join(__dirname, "out");
const cases = JSON.parse(fs.readFileSync(path.join(out, "cases.json"), "utf8"));
const shiny = JSON.parse(fs.readFileSync(path.join(out, "shiny.json"), "utf8"));

// The page shows HTML, where repeated spaces collapse: compare what the user sees.
const norm = s => String(s).replace(/\s+/g, " ").trim();
const arr = x => x == null ? [] : Array.isArray(x) ? x : [x];

// Known, intentional differences (documented in README):
// 1. PT "recent small subcortical infarct" sentence: the Shiny app drops "Midbrain - Tegmentum - Central"
//    (missing translation); the HTML version reports it.
// 2. PT Fazekas sentence: "discreto" in the HTML version, "leve" in the Shiny app (changed 9 Oct 2026).
function expectedDifference(c, lang, i, a, b) {
  if (lang === "pt" && a !== undefined && b !== undefined && a !== b &&
      a.replace(/\bdiscreto\b/g, "leve") === b) return true;
  return lang === "pt" && c.state.include.rsi && c.state.rsi.includes("Midbrain - Tegmentum - Central") &&
         /enfarte|enfartes/.test(arr(c.js.pt)[i] || "");
}

let sentences = 0, fails = 0, expected = 0, excelFails = 0;
const report = [];
cases.forEach((c, k) => {
  const r = shiny[k];
  if (r.name !== c.name) throw new Error("case order mismatch at " + k);
  for (const lang of ["en", "pt"]) {
    const a = arr(c.js[lang]).map(norm), b = arr(r[lang]).map(norm);
    const n = Math.max(a.length, b.length);
    for (let i = 0; i < n; i++) {
      sentences++;
      if (a[i] !== b[i]) {
        if (expectedDifference(c, lang, i, a[i], b[i])) { expected++; continue; }
        fails++;
        if (report.length < 40) report.push(`[${c.name}] ${lang.toUpperCase()} line ${i + 1}\n  HTML : ${a[i]}\n  Shiny: ${b[i]}`);
      }
    }
  }
  // Excel: same column names, same order, same values, same type (text vs number)
  const je = c.js.excel, se = r.excel;
  const names1 = je.map(x => x[0]).join("|"), names2 = se.map(x => x[0]).join("|");
  if (names1 !== names2) { excelFails++; if (report.length < 40) report.push(`[${c.name}] Excel columns differ\n  HTML : ${names1}\n  Shiny: ${names2}`); return; }
  je.forEach((col, i) => {
    const sv = se[i][1] == null ? "" : se[i][1], cls = se[i][2];
    const jsType = typeof col[1] === "number" ? "numeric" : "character";
    const svType = (cls === "numeric" || cls === "integer") ? "numeric" : "character";
    if (String(col[1]) !== String(sv) || jsType !== svType) {
      excelFails++;
      if (report.length < 40) report.push(`[${c.name}] Excel ${col[0]}: HTML ${JSON.stringify(col[1])} (${jsType}) vs Shiny ${JSON.stringify(sv)} (${svType})`);
    }
  });
});

console.log(report.join("\n"));
console.log(`\n${cases.length} cases, ${sentences} sentences compared (EN + PT)`);
console.log(`Report text: ${fails} differences, ${expected} known/intentional (PT central tegmentum fix)`);
console.log(`Excel: ${excelFails} differences (${cases[0].js.excel.length} columns)`);
process.exit(fails || excelFails ? 1 : 0);
