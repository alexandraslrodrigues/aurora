// Compares the movement calculator logic with the Shiny app (movement_assess, movement_abbr_line).
// Run from the aurora2.0 folder:  node tests/movement-compare.js [path to app.R, default ../appaurora/web/app/app.R]
"use strict";
const fs = require("fs"), path = require("path"), { execFileSync } = require("child_process");
const site = path.join(__dirname, "..", "site");
require(path.join(site, "content", "movement-calculator.js"));
require(path.join(site, "js", "movement.js"));
const ME = globalThis.Aurora.movementEngine;
const vals = { mrpi: [5, 9.4, 11.1, 11.14, 12, 12.85, 13, 13.55, 13.6, 15.62, 16, 20], mrpi2: [1, 2.18, 2.3, 2.5, 2.6, 5],
  mpa: [0.15, 0.18, 0.2, 0.21, 0.215, 0.22, 0.3], mida: [80, 98.1, 120], md: [7, 8.9, 9, 9.35, 10], mdpd: [0.4, 0.52, 0.53, 0.54, 0.6], mcp: [6, 8, 8.5] };
const APP = path.resolve(process.argv[2] || path.join(__dirname, "..", "..", "appaurora", "web", "app", "app.R"));
const cases = [];
for (const k in vals) for (const x of vals[k]) cases.push({ k, x });
fs.writeFileSync(path.join(__dirname, "out", "mv_cases.json"), JSON.stringify(cases));
const r = `
suppressPackageStartupMessages({library(shiny); library(jsonlite)})
exprs <- parse("${APP}", keep.source = FALSE, encoding = "UTF-8")
for (e in exprs) { t <- paste(deparse(e, nlines=1), collapse=""); if (grepl("^ui <-", t) || grepl("^shinyApp\\\\(", t) || grepl("^server <-", t)) next; eval(e, globalenv()) }
cs <- fromJSON("${path.join(__dirname, "out", "mv_cases.json")}")
out <- lapply(seq_len(nrow(cs)), function(i) { a <- movement_assess(cs$k[i], cs$x[i])
  ty <- movement_typical[[a$key]]
  notes <- character(0)
  if (isTRUE(a$low_met)) notes <- c(notes, paste0("Below ", a$info$low$value, ", the value reported in MSA (", a$info$low$source, "), but it overlaps with PD and controls"))
  if (nrow(a$opp) > 0) notes <- c(notes, paste0(paste0(a$opp$source, " cutoff (", movement_op_label(a$opp$op), " ", a$opp$value, a$info$unit, ")", collapse = " and "), if (a$prim$met) " not met" else " met"))
  ab <- movement_abbr_line(c(a$info$name, a$verdict, a$prim$favours, a$prim$versus, names(ty$vals), notes, a$info$about, a$cuts$favours, a$cuts$versus, a$cuts$note))
  list(value = a$value_txt, verdict = a$verdict, low = a$low_met, opp = as.list(a$opp$source), met = as.list(a$cuts$met), notes = as.list(notes), abbr = if (is.null(ab)) "" else as.character(ab)) })
cat(toJSON(out, auto_unbox = TRUE))`;
const R = JSON.parse(execFileSync("Rscript", ["-e", r], { env: { ...process.env, LANG: "C.UTF-8", LC_ALL: "C.UTF-8" } }).toString());
let bad = 0;
cases.forEach((c, i) => {
  const a = ME.assess(c.k, c.x), e = R[i];
  const ty = globalThis.Aurora.content.movement.typical[c.k];
  const notes = [];
  if (a.lowMet) notes.push(`Below ${a.info.low.value}, the value reported in MSA (${a.info.low.source}), but it overlaps with PD and controls`);
  if (a.opp.length) notes.push(a.opp.map(o => `${o.source} cutoff (${ME.opLabel(o.op)} ${o.value}${a.info.unit})`).join(" and ") + (a.prim.met ? " not met" : " met"));
  const abbr = ME.abbrLine([a.info.name, a.verdict, a.prim.favours, a.prim.versus, Object.keys(ty.vals).join(" "), notes.join(" "), a.info.about,
    a.cuts.map(x => x.favours + " " + x.versus + " " + x.note).join(" ")].join(" ")) || "";
  const js = { value: a.valueTxt, verdict: a.verdict, low: a.lowMet, opp: a.opp.map(o => o.source), met: a.cuts.map(x => x.met), notes, abbr };
  const eq = JSON.stringify(js) === JSON.stringify({ ...e, opp: [].concat(e.opp), met: [].concat(e.met), notes: [].concat(e.notes) });
  if (!eq) { bad++; console.log(c.k, c.x, "\n JS:", JSON.stringify(js), "\n R :", JSON.stringify(e)); }
});
console.log(`${cases.length} movement cases, ${bad} differences`);
