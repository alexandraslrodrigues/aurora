/* =============================================================================
   PAGES — home, help, about and protocol texts (HTML)
   The Portuguese texts are in content/lang-pt.js (same names as here).
   ========================================================================== */

var Aurora = globalThis.Aurora = globalThis.Aurora || {};
Aurora.content = Aurora.content || {};

Aurora.content.pages = {

  tagline: "clear reports, brighter outcomes",

  categories: {
    cognitive: {
      title: "Cognitive disorders",
      subtitle: "Small vessel disease and atrophy",
      home: "Aurora Report · GCA · MTA · ERICA · Koedam",
      // the three buttons after clicking the category
      tiles: { report: "Structure your findings", protocol: "MRI protocols", calculators: "GCA · MTA · ERICA · Koedam" }
    },
    movement: {
      title: "Movement disorders",
      subtitle: "Parkinsonism",
      home: "MRPI · MRPI 2.0 · Midbrain/pons ratios · MCP width",
      soon: ["report"],     // shown greyed out, not clickable
      tiles: { report: "Work in progress", protocol: "MRI protocols", calculators: "MRPI · MRPI 2.0 · ratios · MCP width" }
    }
  },

  disclaimer: "Aurora gathers published scales and cutoffs to support structured reporting. It is not a certified medical device and does not give a diagnosis.",

  protocol: {
    cognitive:
      "<p class='muted'>Coming soon.</p>",
    movement:
      "<p class='muted'>Coming soon.</p>"
  },

  movementReport:
    "<p class='muted'>Work in progress.</p>",

  /* HELP — the page is built from the pieces below (builder at the end of this file).
     helpTools: [title, text] · helpSteps: one line per step · helpFaq: [question, answer] */
  helpTools: [
    ["Aurora Report", "A structured report for small vessel disease and brain atrophy. The movement disorders report is a work in progress."],
    ["Protocol", "Recommended MRI protocols for a suspected cognitive disorder and for parkinsonism, from published guidelines."],
    ["Calculators", "Visual atrophy scales (GCA, MTA, ERICA, Koedam) and midbrain and pons measurements for parkinsonism (MRPI, MRPI 2.0, ratios, middle cerebellar peduncle width)."]
  ],

  helpSteps: [
    "Start with <strong>Age and sex</strong>. The age is used for the age-adjusted MTA cutoff.",
    "Go through the sections with <strong>Next</strong> and <strong>Previous</strong>, or choose one from the list. Every section starts as normal: change only what you see.",
    "To leave out a section you did not assess, press <strong>×</strong> next to it in the list (or <strong>Exclude from report</strong>).",
    "Press <strong>ⓘ</strong> next to a title to see the definition, reference images and source.",
    "The last step is the <strong>Aurora Report</strong>, written in the language of the website: copy the text or download an Excel file. Click a sentence to go back to its section.",
    "<strong>New report</strong> clears everything and starts again."
  ],

  helpFaq: [
    ["Is what I enter saved or sent anywhere?",
     "Nothing you enter in a report or calculator is sent anywhere: it stays in this browser tab until you close it or press New report. " +
     "Aurora counts page visits with Google Analytics, which does not see what you enter. Only messages you send with the message button reach us."],
    ["Can I use Aurora on my phone, or without internet?",
     "Yes. Aurora works on phones, tablets and computers. After the first visit it also works offline, " +
     "and you can install it from the browser menu (“Add to Home Screen” or “Install app”)."],
    ["Which languages are available?",
     "The website and the reports are in English (US) and Portuguese (Portugal): choose the language at the top right of the app. " +
     "More languages are planned, and help with translations is welcome."],
    ["Where do the scales and cutoffs come from?",
     "From peer-reviewed publications. Press ⓘ next to a section, calculator or protocol to see its sources."],
    ["Can Aurora make a diagnosis?",
     "No. Aurora is not a certified medical device. It helps you report what you see, and the interpretation stays with you."]
  ],

  helpFeedback: "Found a problem, or have a suggestion? Use the message button at the bottom right of every page, or write to us.",

  /* ABOUT — the page is built from the pieces below (builder at the end of this file).
     People are credited by contribution. To credit someone, add a { name: … } entry
     to the right group, or add a new group. A group with no people is not shown.
     Affiliations: "Place, City" on one line, or ["Department", "University"] on two lines. */
  // Title: each part is one line on larger screens
  aboutTitle: ["Structured neuroradiology reporting,", "built on published evidence"],

  aboutIntro:
    "Aurora brings together visual rating scales, calculators and reference images to support the systematic, " +
    "reproducible assessment of brain MRI findings. It includes tools for cognitive and movement disorders, " +
    "with new modules in development.",

  aboutPrinciples: [
    ["Built on published evidence", "Every scale, cutoff and reference image comes from peer-reviewed literature, with a link to the original source."],
    ["A reporting aid, not a diagnosis", "Aurora is not a certified medical device and does not make diagnoses. Interpretation stays with the radiologist."],
    ["Data privacy", "Data entered in the report and calculators is processed locally in your browser and is not sent to any server."],
    ["Free and openly licensed", "Aurora is free to use, and its code is on <a href='https://github.com/alexandraslrodrigues/aurora'>GitHub</a> (CC BY-NC-SA 4.0)."]
  ],

  team: [
    { heading: "Project lead", people: [
      { name: "Alexandra S. L. Rodrigues, MD", orcid: "0000-0001-6241-9446",
        affiliations: [["Department of Physics and CIBIT", "University of Coimbra"], "Hospital Lusíadas, Lisbon", "NOVA Medical School, Lisbon"] }
    ] },

    { heading: "Scientific advisors", people: [
      { name: "Gonçalo Gama Lobo, MD", orcid: "0000-0002-7376-9967",
        affiliations: ["Hospital Lusíadas, Lisbon"] },
      { name: "Daniela Jardim Pereira, MD, PhD", orcid: "0000-0002-9700-810X",
        affiliations: ["ULS Coimbra", ["Faculty of Medicine and CIBIT", "University of Coimbra"]] }
    ] },

    { heading: "Web development advisor", people: [
      { name: "Tiago Machado, MD", orcid: "0000-0001-8930-4382",
        affiliations: [["Faculty of Medicine", "University of Lisbon"]] }
    ] },

    { heading: "Clinical module editors", people: [
      // { name: "Name, MD", orcid: "0000-0000-0000-0000", contribution: "Module name", affiliations: ["…"] }
    ] }
  ],

  cite:
    "Rodrigues ASL, Lobo GG, Machado T, Pereira DJ. Aurora: Open-Access Web Application for Structured Neuroradiology Report and Score Calculation. " +
    "<em>AJNR Am J Neuroradiol</em> 2026;47(2):419–423. <a href='https://doi.org/10.3174/ajnr.A8940'>doi:10.3174/ajnr.A8940</a>",

  // Version shown under "How to cite". Change it when you make a new GitHub release (Zenodo gives each release a DOI).
  version: "2.0.1",
  softwareDoi: "10.5281/zenodo.23285019",   // all versions: always opens the latest one

  getInvolved:
    "Aurora is non-commercial, developed and maintained on a voluntary basis. " +
    "Scientific and technical contributions are welcome, including proposals for new clinical modules or reviews of existing ones.",

  contactEmail: "feedback@aurora-report.com",

  // Message button (bottom right of every page). With a Web3Forms access key (free, web3forms.com:
  // enter the email that should receive the messages, then paste the key here) messages are sent
  // straight to that email. Without a key, the button opens the user's email app instead.
  feedbackKey: "329fe5b4-d40e-41fd-b3df-3d22da82a4a2",   // Web3Forms, sends to feedback@aurora-report.com

  // Google Analytics (same property as the Shiny app). Leave "" to switch it off.
  // It only runs on the published site (https), not when you open index.html from your computer.
  analyticsId: "G-K8VCNK1TLC",

  license: "Aurora © 2025–2026 is licensed under <a href='https://creativecommons.org/licenses/by-nc-sa/4.0/'>Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International</a>."
};

/* Build the About and Help pages (P.about, P.help) from the pieces above.
   t() translates the headings and labels when the site is in another language (js/i18n.js). */
Aurora.content.pages.build = function (t) {
  var P = this;
  t = t || function (s, v) { return v ? String(s).replace(/\{(\w+)\}/g, function (m, k) { return k in v ? v[k] : m; }) : s; };
  var mailIcon = "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.8' stroke-linecap='round' " +
    "stroke-linejoin='round' aria-hidden='true'><rect x='3' y='5' width='18' height='14' rx='2'/><path d='m3 7 9 6 9-6'/></svg>";

  function person(p) {
    var parts = p.name.split(", ");   // "Name, MD, PhD" → name + small degrees; degrees and ORCID icon stay on one line
    return "<div class='ab-person'>" +
      "<p class='ab-name'>" + parts[0] + " <span class='nw'>" +
        (parts.length > 1 ? "<span class='ab-deg'>" + parts.slice(1).join(", ") + "</span>" : "") +
        (p.orcid ? "<a class='orcid' href='https://orcid.org/" + p.orcid + "' aria-label='" + t("ORCID iD of {name}", { name: p.name }) + "'></a>" : "") +
      "</span></p>" +
      (p.contribution ? "<p class='ab-contrib'>" + t(p.contribution) + "</p>" : "") +
      ((p.affiliations && p.affiliations.length) ? "<p class='ab-aff'>" + p.affiliations.map(function (a) {
        // ["Department", "University"] = one affiliation on two lines
        return "<span class='ab-aff-i'>" + [].concat(a).map(function (x) { return t(x); }).join("<br>") + "</span>";
      }).join("") + "</p>" : "") +
      "</div>";
  }
  function group(g) { return "<div class='ab-group'><h3>" + t(g.heading) + "</h3><div class='ab-list'>" + g.people.map(person).join("") + "</div></div>"; }

  var groups = P.team.filter(function (g) { return g.people.length; });

  P.about =
    "<header class='ab-head'>" +
      "<h1>" + P.aboutTitle.map(function (x) { return "<span>" + x + "</span>"; }).join(" ") + "</h1>" +
      "<p class='ab-intro'>" + P.aboutIntro + "</p>" +
    "</header>" +

    "<section class='ab-sec'><h2>" + t("Principles") + "</h2><dl class='ab-grid'>" +
      P.aboutPrinciples.map(function (x) { return "<div><dt>" + x[0] + "</dt><dd>" + x[1] + "</dd></div>"; }).join("") +
    "</dl></section>" +

    "<section class='ab-sec'><h2>" + t("Who we are") + "</h2>" +
      "<div class='ab-people'>" + groups.map(group).join("") + "</div>" +
    "</section>" +

    "<div class='ab-grid ab-sec'>" +
      "<section><h2>" + t("How to cite") + "</h2>" +
        "<p class='cite-text'>" + P.cite + "</p>" +
        (P.version ? "<p class='cite-soft'>" + t("Software: Aurora {version}", { version: P.version }) +
          (P.softwareDoi ? ", Zenodo. <a href='https://doi.org/" + P.softwareDoi + "'>doi:" + P.softwareDoi + "</a>" : "") + "</p>" : "") +
        "<button type='button' class='btn sm' data-copy-cite>" + t("Copy citation") + "</button></section>" +
      "<section><h2>" + t("Get involved") + "</h2>" +
        "<p>" + P.getInvolved + "</p>" +
        // in the app: a button that opens the message form on "Collaboration" (the reference page keeps only the email)
        "<p class='ab-contact'><span class='app-only'><button type='button' class='btn sm' data-open-feedback='Involved'>" +
          t("Propose a collaboration") + "</button> " + t("or") + "</span> " +
          "<a href='mailto:" + P.contactEmail + "'>" + P.contactEmail + "</a></p></section>" +
    "</div>";

  P.help =
    "<header class='ab-head'><h1>" + t("Help") + "</h1></header>" +

    "<section class='ab-sec'><h2>" + t("How Aurora works") + "</h2>" +
      "<p class='ab-intro hp-lead'>" + t("On the home page, select Cognitive disorders or Movement disorders. Each area includes three tools:") + "</p>" +
      "<dl class='hp-cols'>" +
        P.helpTools.map(function (x) { return "<div><dt>" + x[0] + "</dt><dd>" + x[1] + "</dd></div>"; }).join("") +
      "</dl></section>" +

    "<section class='ab-sec'><h2>" + t("Writing a report") + "</h2><ol class='hp-steps'>" +
      P.helpSteps.map(function (x) { return "<li>" + x + "</li>"; }).join("") +
    "</ol></section>" +

    "<section class='ab-sec'><h2>" + t("Frequently asked questions") + "</h2><dl class='hp-faq'>" +
      P.helpFaq.map(function (x) { return "<div><dt>" + x[0] + "</dt><dd>" + x[1] + "</dd></div>"; }).join("") +
    "</dl></section>" +

    "<section class='ab-sec'><h2>" + t("Feedback") + "</h2>" +
      "<p>" + P.helpFeedback + "</p>" +
      "<a class='btn sm' href='mailto:" + P.contactEmail + "'>" + mailIcon + P.contactEmail + "</a>" +
    "</section>";
};
Aurora.content.pages.build();
