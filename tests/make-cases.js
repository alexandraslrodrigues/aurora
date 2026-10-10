// Builds the test cases: hand-written ones + random ones.
// Output: tests/out/cases.json  (each case = HTML-version state + the equivalent Shiny inputs)
// Run:  node tests/make-cases.js
"use strict";
const fs = require("fs");
const path = require("path");
const site = path.join(__dirname, "..", "site");
require(path.join(site, "content", "cognitive-report.js"));
require(path.join(site, "js", "cognitive-engine.js"));
const A = globalThis.Aurora, E = A.engine, C = A.content.cognitive;

function clone(x) { return JSON.parse(JSON.stringify(x)); }
function base() { return E.defaultState(); }
function exp(list, v) { return list.find(o => String(o.value) === String(v)).export; }

// HTML-version state -> Shiny input list
function toShiny(s) {
  const ch = C.choices, inp = {};
  inp.input_sex = s.sex;
  inp.input_age = (s.age === null || s.age === "") ? null : s.age;
  inp.identification_switch = true;
  const sw = { rsi: "rsi_switch", lacunes: "li_switch", wmh: "fazekas_switch", pvs: "pvs_switch", microbleeds: "mb_switch",
               css: "css_switch", gca: "gca_switch", mta: "mta_switch", erica: "erica_switch", koedam: "pca_switch", svd: "ssvds_switch" };
  for (const k in sw) inp[sw[k]] = !!s.include[k];
  inp.recentsmallinfarct = s.rsi;
  inp.lacunar_infarcts = s.lacunes;
  inp.periventricular_grade = exp(ch.pvGrade, s.wmh.pvGrade);
  inp.periventricular_distribution = s.wmh.pvDist;
  inp.periventricular_laterality = s.wmh.pvLat;
  inp.deep_white_matter_grade = exp(ch.dwmGrade, s.wmh.dwmGrade);
  inp.deep_white_matter_distribution = s.wmh.dwmDist;
  inp.deep_white_matter_laterality = s.wmh.dwmLat;
  inp.pvs_centrum_semiovale = exp(ch.pvs, s.pvs.cs);
  inp.pvs_basal_ganglia = exp(ch.pvs, s.pvs.bg);
  inp.pvs_mesencephalon = exp(ch.pvs, s.pvs.mes);
  for (const r of C.microbleedRegions) {
    const m = s.mb[r.key];
    inp[r.key + "_definite_right"] = m.dr; inp[r.key + "_definite_left"] = m.dl;
    inp[r.key + "_possible_right"] = m.pr; inp[r.key + "_possible_left"] = m.pl;
  }
  inp.superficial_siderosis_right = String(s.css.right);
  inp.superficial_siderosis_left = String(s.css.left);
  const g = s.gca;
  const gmap = { frontal: "frontal", po: "parietal", temporal: "temporal" };
  for (const k in gmap) {
    inp[gmap[k] + "_sulci_right_report"] = String(g.sulci[k][0]);
    inp[gmap[k] + "_sulci_left_report"] = String(g.sulci[k][1]);
    inp[gmap[k] + "_ventricles_right_report"] = String(g.ventricles[k][0]);
    inp[gmap[k] + "_ventricles_left_report"] = String(g.ventricles[k][1]);
  }
  inp.third_ventricle_report = String(g.third);
  inp.mta_right_report = exp(ch.mta, s.mta.right);   inp.mta_left_report = exp(ch.mta, s.mta.left);
  inp.erica_right_report = exp(ch.erica, s.erica.right); inp.erica_left_report = exp(ch.erica, s.erica.left);
  inp.pca_right_report = exp(ch.koedam, s.koedam.right); inp.pca_left_report = exp(ch.koedam, s.koedam.left);
  return inp;
}

const cases = [];
function add(name, mutate) { const s = base(); mutate(s); cases.push({ name, state: s }); }

// ---- hand-written cases ----
add("defaults", s => {});
add("age 70 defaults", s => { s.age = 70; });
add("all sections off", s => { for (const k in s.include) s.include[k] = false; });
add("only SVD on", s => { for (const k in s.include) s.include[k] = false; s.include.svd = true; s.lacunes = ["Thalamus - Anterior - Right"]; });

// Recent infarcts / lacunes: 1, 2, 3, 4 locations and every phrase type
const allLoc = Object.keys(E.locations());
add("rsi 1", s => { s.rsi = ["Pons - Basis - Midline"]; });
add("rsi 2", s => { s.rsi = ["Internal capsule - Genu - Left", "Cerebellum - Right"]; });
add("rsi 3", s => { s.rsi = ["Medulla - Anterior - Right", "Midbrain - Crus cerebri - Left", "Thalamus - Medial - Right"]; });
add("rsi 4", s => { s.rsi = ["Centrum semiovale - Frontal - Right", "Caudate nucleus - Left", "Pons - Tegmentum - Left", "Midbrain - Tectum - Midline"]; });
add("lacunes 1", s => { s.lacunes = ["External capsule - Left"]; });
add("lacunes 2", s => { s.lacunes = ["Lentiform nucleus - Right", "Midbrain - Tegmentum - Central"]; });
add("lacunes 3", s => { s.lacunes = ["Corona radiata - Parietal - Left", "Cerebral peduncle - Right", "Medulla - Posterior - Left"]; });
for (let i = 0; i < allLoc.length; i++) {
  add("rsi each " + allLoc[i], s => { s.rsi = [allLoc[i]]; s.lacunes = [allLoc[(i + 7) % allLoc.length], allLoc[i]]; });
}
add("rsi off but selected", s => { s.rsi = ["Pons - Basis - Right"]; s.include.rsi = false; });
add("lacunes off but selected (SVD still counts)", s => { s.lacunes = ["Pons - Basis - Right"]; s.include.lacunes = false; });

// WMH: every grade / distribution / laterality
const pvD = ["diffuse", "frontal", "occipital", "temporal", "peri-atrial"], dD = ["diffuse", "centrum semiovale", "corona radiata"], lat = ["bilateral", "right", "left"];
for (let g = 0; g <= 3; g++) for (const d of pvD) for (const l of lat) add(`wmh pv ${g} ${d} ${l}`, s => { s.wmh.pvGrade = g; s.wmh.pvDist = d; s.wmh.pvLat = l; s.wmh.dwmGrade = (g + 1) % 4; });
for (let g = 1; g <= 3; g++) for (const d of dD) for (const l of lat) add(`wmh deep ${g} ${d} ${l}`, s => { s.wmh.dwmGrade = g; s.wmh.dwmDist = d; s.wmh.dwmLat = l; });

// PVS: all 125 combinations
for (let a = 0; a <= 4; a++) for (let b = 0; b <= 4; b++) for (let c = 0; c <= 4; c++) add(`pvs ${a}${b}${c}`, s => { s.pvs = { cs: a, bg: b, mes: c }; });

// Microbleeds: each region alone, and mixes
C.microbleedRegions.forEach((r, i) => {
  add("mb only " + r.key, s => { s.mb[r.key] = { dr: 3, dl: 0, pr: 0, pl: 0 }; });
  add("mb mix " + r.key, s => { s.mb[r.key] = { dr: 1, dl: 2, pr: 0, pl: 1 }; s.mb.thalamus.dl = 1; s.mb.frontal.pr = 2; });
});
add("mb corpus callosum 3 + thalamus 1 (review item 1)", s => { s.mb.corpus_callosum.dr = 3; s.mb.thalamus.dl = 1; });
add("mb many", s => { for (const r of C.microbleedRegions) s.mb[r.key] = { dr: 1, dl: 1, pr: 1, pl: 1 }; });

// cSS: all 9
for (let r = 0; r <= 2; r++) for (let l = 0; l <= 2; l++) add(`css ${r}${l}`, s => { s.css = { right: r, left: l }; });

// GCA
add("gca third only", s => { s.gca.third = 2; });
add("gca third + frontal", s => { s.gca.third = 2; s.gca.ventricles.frontal = [2, 2]; });
add("gca third + 2 regions", s => { s.gca.third = 1; s.gca.ventricles.frontal = [1, 0]; s.gca.ventricles.temporal = [0, 1]; });
add("gca bilateral + single", s => { s.gca.sulci.frontal = [2, 2]; s.gca.sulci.temporal = [2, 1]; s.gca.ventricles.po = [3, 3]; });
add("gca all 1", s => { for (const k of ["frontal", "po", "temporal"]) { s.gca.sulci[k] = [1, 1]; s.gca.ventricles[k] = [1, 1]; } s.gca.third = 1; });
add("gca left only", s => { s.gca.sulci.po = [0, 3]; s.gca.ventricles.temporal = [0, 2]; });

// MTA: ages and scores
const ages = [null, 0, 50, 70, 74.9, 75, 80, 95];
for (const a of ages) for (let r = 0; r <= 4; r++) for (let l = 0; l <= 4; l++) add(`mta age ${a} R${r} L${l}`, s => { s.age = a; s.mta = { right: r, left: l }; });

// ERICA and Koedam
for (let r = 0; r <= 3; r++) for (let l = 0; l <= 3; l++) add(`erica/koedam R${r} L${l}`, s => { s.erica = { right: r, left: l }; s.koedam = { right: l, left: r }; });

// SVD score 0..4
add("svd 4", s => { s.lacunes = ["Thalamus - Lateral - Left"]; s.mb.frontal.dr = 1; s.pvs.bg = 2; s.wmh.pvGrade = 3; });
add("svd deep wmh 2", s => { s.wmh.dwmGrade = 2; });
add("sex male, age 81", s => { s.sex = "Male"; s.age = 81; });
add("sex NA", s => { s.sex = "NA"; });

// ---- random cases ----
let seed = 12345;
function rnd() { seed = (seed * 1103515245 + 12345) % 2147483648; return seed / 2147483648; }
function ri(n) { return Math.floor(rnd() * n); }
function pick(a) { return a[ri(a.length)]; }
function sample(a, k) { const c = a.slice(), out = []; while (out.length < k && c.length) out.push(c.splice(ri(c.length), 1)[0]); return out; }
for (let i = 0; i < 300; i++) {
  add("random " + i, s => {
    s.sex = pick(["Female", "Male", "NA"]);
    s.age = pick([null, 45, 68, 74, 75, 77, 90]);
    for (const k in s.include) s.include[k] = rnd() > 0.15;
    s.rsi = sample(allLoc, pick([0, 0, 1, 2, 3, 5]));
    s.lacunes = sample(allLoc, pick([0, 0, 1, 2, 3, 4]));
    s.wmh = { pvGrade: ri(4), pvDist: pick(pvD), pvLat: pick(lat), dwmGrade: ri(4), dwmDist: pick(dD), dwmLat: pick(lat) };
    s.pvs = { cs: ri(5), bg: ri(5), mes: ri(5) };
    for (const r of C.microbleedRegions) if (rnd() < 0.2) s.mb[r.key] = { dr: ri(3), dl: ri(3), pr: ri(2), pl: ri(4) };
    s.css = { right: ri(3), left: ri(3) };
    for (const k of ["frontal", "po", "temporal"]) { s.gca.sulci[k] = [ri(4), ri(4)]; s.gca.ventricles[k] = [ri(4), ri(4)]; }
    s.gca.third = ri(4);
    s.mta = { right: ri(5), left: ri(5) };
    s.erica = { right: ri(4), left: ri(4) };
    s.koedam = { right: ri(4), left: ri(4) };
  });
}

const out = cases.map(c => ({
  name: c.name,
  state: c.state,
  shiny: toShiny(c.state),
  js: { en: E.report(c.state, "en").map(x => x.text), pt: E.report(c.state, "pt").map(x => x.text), excel: E.excelColumns(c.state) }
}));
fs.mkdirSync(path.join(__dirname, "out"), { recursive: true });
fs.writeFileSync(path.join(__dirname, "out", "cases.json"), JSON.stringify(out));
console.log(out.length + " cases written");
