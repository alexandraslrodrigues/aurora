/* =============================================================================
   Aurora — reference pages for search engines and AI tools
   -----------------------------------------------------------------------------
   The app uses addresses like #/movement/calculators/mrpi-2, which search
   engines treat as one single page. This script writes a plain HTML page with
   its own address for each calculator, protocol and text page
   (aurora-report.com/mrpi-2-calculator/ ...), built from the same content files
   as the app, so the texts, cutoffs and references never differ from the app.

   It writes:
     site/<page>/index.html      one page each (same look as About and Help)
     site/404.html               "Page not found"
     site/sitemap.xml            the list of pages for search engines
     site/index.html             only the list of links between the
                                 reference-pages markers (hidden summary)

   Run it from the aurora2.0 folder after editing anything in site/content/,
   then publish the site folder as usual:

       node tools/build-pages.js

   No packages needed (Node.js only). The app itself is not changed.
   ========================================================================== */
"use strict";
const fs = require("fs");
const path = require("path");

const SITE = path.join(__dirname, "..", "site");
const BASE = "https://aurora-report.com";

// The content files set globalThis.Aurora (the same files the app loads)
["content/pages.js", "content/info-cards.js", "content/movement-calculator.js",
 "content/protocols.js", "content/cognitive-report.js", "js/movement.js"].forEach(function (f) {
  require(path.join(SITE, f));
});
const A = globalThis.Aurora;
const P = A.content.pages, INFO = A.content.info, MV = A.content.movement,
      PR = A.content.protocols, COG = A.content.cognitive, ME = A.movementEngine;

/* ------------------------------------------------------------------ pages and their addresses
   path = the address (aurora-report.com/<path>/); app = where "Open" goes in the app.
   title = browser tab and search result title; description = the line under it in search results. */

const ATROPHY = [
  { key: "gca", path: "gca-scale", app: "#/cognitive/calculators/gca",
    title: "Global cortical atrophy (GCA) scale",
    lead: "Visual rating of global cortical atrophy on brain MRI (Pasquier scale): sulci and ventricles, graded 0–3 per region.",
    description: "Global cortical atrophy (GCA, Pasquier) scale on brain MRI: grades 0–3, reference image and sources, with a free calculator for structured reports." },
  { key: "mta", path: "mta-score", app: "#/cognitive/calculators/mta",
    title: "Medial temporal atrophy (MTA) score",
    lead: "Visual rating of medial temporal lobe atrophy on coronal T1-weighted MRI (Scheltens score): 0–4 per side, with age-adjusted cut-offs.",
    description: "MTA score (Scheltens) on coronal T1 MRI: grades 0–4, age-adjusted cut-offs, reference image and sources, with a free calculator." },
  { key: "erica", path: "erica-score", app: "#/cognitive/calculators/erica",
    title: "Entorhinal cortical atrophy (ERICA) score",
    lead: "Visual rating of entorhinal cortex atrophy on coronal MRI (Enkirch score): 0–3 per side.",
    description: "ERICA score for entorhinal cortex atrophy on MRI: grades 0–3, cut-off, reference image and sources, with a free calculator." },
  { key: "koedam", path: "koedam-score", app: "#/cognitive/calculators/koedam",
    title: "Posterior parietal atrophy (Koedam) score",
    lead: "Visual rating of posterior parietal atrophy on brain MRI (Koedam score): 0–3 per side.",
    description: "Koedam score for posterior parietal atrophy on brain MRI: grades 0–3, reference image and source, with a free calculator." }
];

const MOVEMENT = {
  "midbrain-pons-ratio": { path: "midbrain-pons-ratio", title: "Midbrain/pons area ratio calculator",
    description: "Midbrain/pons area ratio for parkinsonism on MRI: formula, published cutoffs for PSP with sources, how to measure, and a free calculator." },
  "mrpi": { path: "mrpi-calculator", title: "MRPI calculator (Magnetic Resonance Parkinsonism Index)",
    description: "MRPI (magnetic resonance parkinsonism index): formula, published cutoffs for PSP vs PD and MSA-P, how to measure on MRI, and a free calculator." },
  "mrpi-2": { path: "mrpi-2-calculator", title: "MRPI 2.0 calculator",
    description: "MRPI 2.0: formula, published cutoffs for PSP-P and PSP-RS vs Parkinson’s disease, how to measure on MRI, and a free online calculator." },
  "diameter-ratio": { path: "midbrain-pons-diameter-ratio", title: "Midbrain/pons diameter ratio calculator",
    description: "Midbrain/pons diameter ratio and midbrain diameter on MRI: published cutoffs for PSP with sources, how to measure, and a free calculator." },
  "mcp-width": { path: "mcp-width", title: "Middle cerebellar peduncle (MCP) width",
    description: "Middle cerebellar peduncle width on MRI: published cutoffs for MSA with sources, how to measure, and a free calculator." }
};

const PROTOCOLS = {
  "diagnosis": { path: "mri-protocol-dementia", title: "MRI protocol for a suspected cognitive disorder",
    description: "Recommended brain MRI protocol for a suspected cognitive disorder or dementia: core and optional sequences, planes, slice thickness and what to look for." },
  "parkinsonism": { path: "mri-protocol-parkinsonism", title: "MRI protocol for suspected parkinsonism",
    description: "Recommended brain MRI protocol for suspected parkinsonism: core and optional sequences, planes, slice thickness and what to look for, with sources." }
};

const REPORT = { path: "cognitive-report", app: "#/cognitive/report",
  title: "Structured MRI report for cognitive disorders",
  lead: "A step-by-step structured report of small vessel disease and brain atrophy on brain MRI, written in English (US) or Portuguese (Portugal), with copy and Excel export.",
  description: "Structured brain MRI report for small vessel disease (STRIVE-2, Fazekas, MARS, SVD score) and atrophy (GCA, MTA, ERICA, Koedam), in English or Portuguese." };

const ABOUT = { path: "about", title: "About",
  description: "Aurora is a free, open-access tool for structured neuroradiology reporting, built on published evidence. Team, principles and how to cite (AJNR 2026)." };
const HELP = { path: "help", title: "Help",
  description: "How to use Aurora: the structured MRI report, recommended protocols and calculators, privacy, offline use, languages and the sources of each scale." };

/* ------------------------------------------------------------------ small helpers */
function esc(s) { return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;"); }
function url(p) { return BASE + "/" + (p ? p + "/" : ""); }
function nb(t) { return String(t).replace(/(\d) (?=(T|mm|ms)\b)/g, "$1 "); }          // "3 T" on one line
function opLabel(op) { return ME.opLabel(op); }
function favoursText(f, v) { return v ? f + " " + v : f; }                                    // "PSP vs PD", as in the app
function srcLink(src) {                                                                     // "Quattrone 2008" -> link to its DOI
  if (src.indexOf(";") > 0) return src.split(";").map(function (s) { return srcLink(s.trim()); }).join("; ");
  const key = src.split(" ").slice(0, 2).join(" "), doi = MV.dois[key];
  return doi ? "<a href='https://doi.org/" + doi + "'>" + esc(key) + "</a>" : esc(src);
}
function withLinks(text) { return esc(text).replace(/\{([^}]+)\}/g, function (m, s) { return srcLink(s); }); }
function plain(html) { return String(html).replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim(); }
function figure(img, alt) {
  return "<figure><img src='/img/" + img + "' alt='" + esc(alt) + "' loading='lazy'></figure>";
}
function infoBlock(key, withImages) {          // definition, images and credits of an ⓘ card
  const c = INFO[key];
  if (!c) return "";
  return (withImages ? (c.images || []).map(function (i) { return figure(i, c.title); }).join("") : "") +
    "<div class='ref-body'>" + c.body + "</div>" +
    "<div class='credits'>" + c.credits + "</div>";
}

/* ------------------------------------------------------------------ the page frame (same look as About and Help) */
const ALL = [];                                 // every page, for the sitemap and the "More in Aurora" list
function moreList(current) {
  const groups = [
    ["Cognitive disorders", ALL.filter(function (p) { return p.group === "cognitive"; })],
    ["Movement disorders", ALL.filter(function (p) { return p.group === "movement"; })],
    ["Aurora", ALL.filter(function (p) { return p.group === "aurora"; })]
  ];
  return "<nav class='ab-sec ref-more' aria-label='Reference pages'><h2>More in Aurora</h2><div class='ref-more-cols'>" +
    groups.map(function (g) {
      return "<div><h3>" + g[0] + "</h3><ul>" + g[1].map(function (p) {
        return "<li>" + (p.path === current ? "<span aria-current='page'>" + esc(p.title) + "</span>"
                                             : "<a href='/" + p.path + "/'>" + esc(p.title) + "</a>") + "</li>";
      }).join("") + "</ul></div>";
    }).join("") + "</div></nav>";
}

function aboutAurora() {
  return "<section class='ab-sec ref-aurora'><h2>About Aurora</h2>" +
    "<p>" + esc(P.disclaimer) + "</p>" +
    "<p>Aurora is described in: " + P.cite + ".</p></section>";
}

function frame(pg) {
  const u = url(pg.path);
  const dois = [];
  (pg.body.match(/https:\/\/doi\.org\/[^'"\s<]+/g) || []).forEach(function (d) { if (dois.indexOf(d) < 0) dois.push(d); });
  const ld = {
    "@context": "https://schema.org",
    "@type": "WebPage",
    "@id": u,
    "url": u,
    "name": pg.title,
    "description": pg.description,
    "inLanguage": "en",
    "isPartOf": { "@type": "WebSite", "@id": BASE + "/#website", "name": "Aurora", "url": BASE + "/" }
  };
  if (dois.length) ld.citation = dois;
  return "<!doctype html>\n" +
"<html lang=\"en\">\n" +
"<head>\n" +
"  <meta charset=\"utf-8\">\n" +
"  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, viewport-fit=cover\">\n" +
"  <title>" + esc(pg.title) + " · Aurora</title>\n" +
"  <meta name=\"description\" content=\"" + esc(pg.description) + "\">\n" +
"  <link rel=\"canonical\" href=\"" + u + "\">\n" +
"  <meta name=\"theme-color\" content=\"#ffffff\">\n" +
"  <script>try { if (localStorage.getItem(\"aurora.theme\") === \"dark\") document.documentElement.setAttribute(\"data-theme\", \"dark\"); } catch (e) {}</script>\n" +
"  <link rel=\"icon\" type=\"image/png\" href=\"/icons/icon-192.png\">\n" +
"  <link rel=\"apple-touch-icon\" href=\"/icons/apple-touch-icon.png\">\n" +
"  <link rel=\"stylesheet\" href=\"/css/aurora.css\">\n" +
"  <meta property=\"og:type\" content=\"article\">\n" +
"  <meta property=\"og:site_name\" content=\"Aurora\">\n" +
"  <meta property=\"og:url\" content=\"" + u + "\">\n" +
"  <meta property=\"og:title\" content=\"" + esc(pg.title) + "\">\n" +
"  <meta property=\"og:description\" content=\"" + esc(pg.description) + "\">\n" +
"  <meta property=\"og:image\" content=\"" + BASE + "/img/og-aurora.png\">\n" +
"  <meta name=\"twitter:card\" content=\"summary_large_image\">\n" +
"  <script type=\"application/ld+json\">" + JSON.stringify(ld) + "</script>\n" +
"</head>\n" +
"<body>\n" +
"  <!-- Written by tools/build-pages.js from site/content/. Edit the content files, not this page. -->\n" +
"  <a class=\"skip\" href=\"#main\">Skip to content</a>\n" +
"  <header class=\"topbar\">\n" +
"    <a class=\"brand\" href=\"/\" aria-label=\"Aurora home\"><img src=\"/icons/icon-128.png\" alt=\"\" width=\"30\" height=\"30\"><span class=\"wordmark\">aurora</span></a>\n" +
"    <nav class=\"mainnav\" aria-label=\"Main\"><a href=\"/help/\"" + (pg.path === "help" ? " class=\"active\"" : "") + ">Help</a><a href=\"/about/\"" + (pg.path === "about" ? " class=\"active\"" : "") + ">About</a></nav>\n" +
"  </header>\n" +
"  <main id=\"main\" tabindex=\"-1\">\n" +
"    <div class=\"page about ref-page\">\n" +
"      <article class=\"prose about-page" + (pg.articleClass ? " " + pg.articleClass : "") + "\">\n" +
pg.body + "\n" +
(pg.noMore ? "" : moreList(pg.path) + "\n") +
"      </article>\n" +
"      <p class=\"license\">" + P.license + "</p>\n" +
"    </div>\n" +
"  </main>\n" +
"</body>\n" +
"</html>\n";
}

function head(title, lead, appHref, appLabel) {
  return "<header class='ab-head'><h1>" + esc(title) + "</h1>" + (lead ? "<p class='ab-intro'>" + lead + "</p>" : "") + "</header>" +
    (appHref ? "<p class='ref-open'><a class='btn primary' href='/" + appHref + "'>" + esc(appLabel) + "</a></p>" : "");
}

/* ------------------------------------------------------------------ page builders */
function atrophyPage(d) {
  const body = head(d.title, esc(d.lead), d.app, "Open the calculator") +
    "<section class='ab-sec'><h2>Definition and grades</h2>" + infoBlock(d.key, true) + "</section>" +
    "<section class='ab-sec'><h2>In the structured report</h2><p>The same scale is part of the " +
    "<a href='/" + REPORT.path + "/'>Aurora Report for cognitive disorders</a>, which adds the result to a structured report in English or Portuguese.</p></section>" +
    aboutAurora();
  return { body: body };
}

function movementPage(calc, d) {
  const idxs = calc.shows;
  const main = MV.indices[calc.index];
  let text = [];                                                    // plain text, for the abbreviations line

  const formulas = idxs.map(function (k) {
    const i = MV.indices[k];
    const f = i.formula === "midsagittal" ? i.name + ": measured on the midsagittal T1-weighted image" : i.name + " = " + i.formula;
    text.push(f);
    return esc(f);
  });
  const formula = formulas.length > 1 ? "<ul>" + formulas.map(function (f) { return "<li>" + f + "</li>"; }).join("") + "</ul>"
                                      : "<p>" + formulas[0] + "</p>";

  const measures = "<ul>" + calc.inputs.map(function (id) { return "<li>" + esc(MV.measurements[id].label) + "</li>"; }).join("") + "</ul>";

  const cutoffs = idxs.map(function (k) {
    const i = MV.indices[k];
    const cuts = ME.assess(k, 1).cuts;                              // "shown" = the cutoff as written in the paper
    const rows = cuts.map(function (c) {
      const n = [];
      if (c.primary) n.push("Reference cutoff in Aurora");
      if (!c.tested && !c.note) n.push("Proposed from the literature, not tested in a cohort");
      if (c.note) n.push(c.note);
      text.push(c.favours + " " + c.versus + " " + n.join(" "));
      return "<tr><td class='nw'>" + esc(opLabel(c.op) + " " + c.shown + i.unit) + "</td>" +
        "<td>" + esc(favoursText(c.favours, c.versus)) + (n.length ? "<span class='mv-tn'>" + esc(n.join("; ")) + "</span>" : "") + "</td>" +
        "<td class='nw'>" + srcLink(c.source) + "</td></tr>";
    }).join("");
    return (idxs.length > 1 ? "<h3>" + esc(i.name) + "</h3>" : "") +
      "<div class='mv-table-wrap'><table class='mv-table'><thead><tr><th>Cutoff</th><th>Reported for</th><th>Source</th></tr></thead><tbody>" +
      rows + "</tbody></table></div>";
  }).join("");

  const notes = (main.marker === "PSP" ? "<p class='ref-note'>" + withLinks(MV.notes.pspAge) + "</p>" : "") +
    "<p class='ref-note'>" + esc(MV.notes.general) + "</p>";

  const helpKeys = [];
  calc.inputs.forEach(function (id) { const k = MV.measurements[id].help; if (helpKeys.indexOf(k) < 0) helpKeys.push(k); });
  const howto = helpKeys.map(function (k) {
    const hw = MV.howto[k];
    if (!hw) return "";
    text.push(hw.steps.join(" "));
    return "<div class='howto'><h3>" + esc(hw.title) + "</h3>" +
      (k.indexOf(".") > 0 ? figure(k, hw.title) : "") +
      "<ol>" + hw.steps.map(function (s) { return "<li>" + esc(s) + "</li>"; }).join("") + "</ol>" +
      "<p class='credits'>Method: " + hw.method.map(srcLink).join("; ") + ".</p></div>";
  }).join("");

  text.push(main.about.replace(/[{}]/g, ""), MV.notes.general, main.marker === "PSP" ? MV.notes.pspAge.replace(/[{}]/g, "") : "");
  const abbr = ME.abbrLine(text.join(" "));

  const body = head(d.title, withLinks(main.about), "#/movement/calculators/" + calc.slug, "Open the calculator") +
    "<section class='ab-sec'><h2>Formula</h2>" + formula + "<p>Measurements needed:</p>" + measures + "</section>" +
    "<section class='ab-sec'><h2>Published cutoffs</h2>" + cutoffs + notes + "</section>" +
    "<section class='ab-sec'><h2>How to measure</h2>" + howto + "</section>" +
    (abbr ? "<p class='ref-note'>Abbreviations: " + esc(abbr) + ".</p>" : "") +
    aboutAurora();
  return { body: body };
}

function protocolPage(cat, pr, d) {
  const tables = [];                                                // sections with the same columns share one table (as in the app)
  pr.sections.forEach(function (sec) {
    const last = tables[tables.length - 1];
    if (last && last.cols.join("|") === sec.cols.join("|")) last.sections.push(sec);
    else tables.push({ cols: sec.cols, sections: [sec] });
  });
  const box = "<div class='pr-box'>" + tables.map(function (t) {
    return "<table class='pr-table cols-" + t.cols.length + "'><thead><tr>" +
      t.cols.map(function (c) { return "<th scope='col'>" + esc(c) + "</th>"; }).join("") + "</tr></thead>" +
      t.sections.map(function (sec) {
        return "<tbody><tr class='pr-group'><th colspan='" + t.cols.length + "' scope='rowgroup'>" + esc(sec.title) + "</th></tr>" +
          sec.rows.map(function (r) {
            return "<tr>" + r.map(function (v, i) {
              return i === 0 ? "<th scope='row'>" + esc(nb(v)) + "</th>"
                             : "<td data-col='" + esc(t.cols[i]) + "'" + (t.cols[i] === "Look for" ? " class='look'" : "") + ">" + esc(nb(v)) + "</td>";
            }).join("") + "</tr>";
          }).join("") + "</tbody>";
      }).join("") + "</table>";
  }).join("") +
    (pr.field ? "<div class='pr-end'><h3>Field strength</h3><p>" + esc(nb(pr.field)) + "</p></div>" : "") +
    (pr.abbreviations ? "<p class='pr-abbr'>Abbreviations: " + esc(pr.abbreviations) + ".</p>" : "") + "</div>";
  const notes = (pr.notes || []).map(function (n) { return "<p class='ref-note'>" + esc(nb(n)) + "</p>"; }).join("");
  const refs = "<ul>" + (pr.refs || []).map(function (r) { return "<li><a href='" + esc(r[1]) + "'>" + esc(r[0]) + "</a></li>"; }).join("") + "</ul>" +
    (PR.updated ? "<p class='ref-note'>Updated " + esc(PR.updated) + "</p>" : "");
  const body = head(d.title, "Recommended clinical brain MRI protocol from published guidelines.", "#/" + cat + "/protocol/" + pr.id, "Open in Aurora") +
    "<section class='ab-sec'><h2>Recommended protocol</h2>" + box + notes + "</section>" +
    "<section class='ab-sec'><h2>References</h2>" + refs + "</section>" +
    aboutAurora();
  return { body: body };
}

function reportPage() {
  const atrophy = {};
  ATROPHY.forEach(function (a) { atrophy[a.key] = a; });
  const sections = COG.sections.map(function (s) {
    if (atrophy[s.info]) {
      const a = atrophy[s.info];
      return "<h3>" + esc(s.title) + "</h3><p>" + esc(a.lead) + " See <a href='/" + a.path + "/'>" + esc(a.title) + "</a>.</p>";
    }
    return "<h3>" + esc(s.title) + "</h3>" + infoBlock(s.info, true);
  }).join("");
  const body = head(REPORT.title, esc(REPORT.lead), REPORT.app, "Open the Aurora Report") +
    "<section class='ab-sec'><h2>How it works</h2><ol class='hp-steps'>" +
      P.helpSteps.map(function (t) { return "<li>" + t + "</li>"; }).join("") + "</ol></section>" +
    "<section class='ab-sec'><h2>Sections of the report</h2>" + sections + "</section>" +
    aboutAurora();
  return { body: body };
}

/* ------------------------------------------------------------------ collect the pages */
function add(group, d, build) { ALL.push({ group: group, path: d.path, title: d.title, description: d.description, build: build, articleClass: d.articleClass, noMore: d.noMore }); }

add("cognitive", REPORT, reportPage);
PR.cognitive.filter(function (p) { return !p.hidden; }).forEach(function (pr) {
  const d = PROTOCOLS[pr.id] || { path: "mri-protocol-" + pr.id, title: "MRI protocol: " + pr.title, description: "Recommended brain MRI protocol: " + pr.title + "." };
  add("cognitive", d, function () { return protocolPage("cognitive", pr, d); });
});
ATROPHY.forEach(function (d) { add("cognitive", d, function () { return atrophyPage(d); }); });

PR.movement.filter(function (p) { return !p.hidden; }).forEach(function (pr) {
  const d = PROTOCOLS[pr.id] || { path: "mri-protocol-" + pr.id, title: "MRI protocol: " + pr.title, description: "Recommended brain MRI protocol: " + pr.title + "." };
  add("movement", d, function () { return protocolPage("movement", pr, d); });
});
MV.calculators.forEach(function (calc) {
  const d = MOVEMENT[calc.slug] || { path: calc.slug, title: calc.title, description: calc.title + ": formula, published cutoffs and how to measure." };
  add("movement", d, function () { return movementPage(calc, d); });
});

add("aurora", { path: ABOUT.path, title: ABOUT.title, description: ABOUT.description }, function () {
  return { body: P.about.replace(/<button[^>]*data-copy-cite[^>]*>[\s\S]*?<\/button>/, "") };
});
add("aurora", { path: HELP.path, title: HELP.title, description: HELP.description, articleClass: "help-page" }, function () {
  // the static page has no message button: point to the email address instead
  return { body: P.help.replace(P.helpFeedback, "Found a problem, or have a suggestion? Write to us, or use the message button in the app.") };
});

/* ------------------------------------------------------------------ write */
function write(rel, content) {
  const f = path.join(SITE, rel);
  fs.mkdirSync(path.dirname(f), { recursive: true });
  const old = fs.existsSync(f) ? fs.readFileSync(f, "utf8") : null;
  if (old !== content) fs.writeFileSync(f, content);
  return old === content ? "unchanged" : (old === null ? "new" : "updated");
}

const report = [];
ALL.forEach(function (p) {
  const built = p.build();
  const html = frame({ path: p.path, title: p.title, description: p.description, body: built.body, articleClass: p.articleClass, noMore: p.noMore });
  report.push(p.path + "/ " + write(p.path + "/index.html", html));
});

// 404 page (a real 404 for unknown addresses; Cloudflare Pages uses it automatically)
report.push("404.html " + write("404.html", frame({ path: "404", title: "Page not found",
  description: "This page does not exist on Aurora.", noMore: true,
  body: "<header class='ab-head'><h1>Page not found</h1><p class='ab-intro'>This address does not exist on Aurora.</p></header>" +
        "<p class='ref-open'><a class='btn primary' href='/'>Go to Aurora</a></p>" }).replace(/<link rel="canonical"[^>]*>\n/, "").replace(/  <meta property="og:[\s\S]*?<meta name="twitter:card"[^>]*>\n/, "").replace(/  <script type="application\/ld\+json">[^\n]*\n/, "")));

// sitemap: the home page and every reference page. lastmod = when its source files last changed
function day(files) {
  const t = Math.max.apply(null, files.map(function (f) { return fs.statSync(path.join(SITE, f)).mtimeMs; }));
  return new Date(t).toISOString().slice(0, 10);
}
const contentDay = day(["content/pages.js", "content/info-cards.js", "content/movement-calculator.js", "content/protocols.js", "content/cognitive-report.js"]);
const sitemap = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n" +
  "  <url><loc>" + url("") + "</loc><lastmod>" + day(["index.html"]) + "</lastmod></url>\n" +
  ALL.map(function (p) { return "  <url><loc>" + url(p.path) + "</loc><lastmod>" + contentDay + "</lastmod></url>\n"; }).join("") +
  "</urlset>\n";
report.push("sitemap.xml " + write("sitemap.xml", sitemap));

// the list of links in the hidden summary of index.html (between the reference-pages markers)
const indexFile = path.join(SITE, "index.html");
const index = fs.readFileSync(indexFile, "utf8");
const START = "<!-- reference-pages:start -->", END = "<!-- reference-pages:end -->";
const a = index.indexOf(START), b = index.indexOf(END);
if (a < 0 || b < a) {
  report.push("index.html: reference-pages markers not found, list not written");
} else {
  const indent = index.slice(index.lastIndexOf("\n", a) + 1, a);
  const list = "\n" + indent + "<ul>\n" + ALL.map(function (p) {
    return indent + "  <li><a href=\"/" + p.path + "/\">" + esc(p.title) + "</a></li>\n";
  }).join("") + indent + "</ul>\n" + indent;
  const next = index.slice(0, a + START.length) + list + index.slice(b);
  if (next !== index) fs.writeFileSync(indexFile, next);
  report.push("index.html " + (next !== index ? "updated (list of links)" : "unchanged"));
}

console.log("Aurora reference pages:\n  " + report.join("\n  "));
