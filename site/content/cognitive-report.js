/* =============================================================================
   AURORA REPORT (cognitive disorders) — CONTENT FILE
   -----------------------------------------------------------------------------
   Everything the report SAYS lives here: section names, button labels, the
   values exported to Excel, and every EN / PT sentence.

   How to edit (no JavaScript knowledge needed):
   - Change only the text between quotes "like this".
   - Keep the {placeholders} in curly brackets: Aurora fills them in
     (for example {left} becomes the left score).
   - Keep the commas at the end of lines, and the quotes around text.
   - A line that starts with // is a comment and is ignored.
   - After saving, reload the page. If the page goes blank, open the browser
     console (F12): it names the line with the mistake (usually a missing
     comma or quote).
   ========================================================================== */

var Aurora = globalThis.Aurora = globalThis.Aurora || {};
Aurora.content = Aurora.content || {};

Aurora.content.cognitive = {

  /* ---------------------------------------------------------------------------
     0. SECTIONS of the form (order = order in the report)
     "info"  = which ⓘ card opens (content/info-cards.js)
     "short" = name in the section list on the left (keep it short)
     --------------------------------------------------------------------------- */
  sections: [
    { id: "rsi",         title: "Recent small subcortical infarcts",        info: "rsi", short: "Recent small infarcts" },
    { id: "lacunes",     title: "Lacunes of presumed vascular origin",      info: "lacunes", short: "Lacunes" },
    { id: "wmh",         title: "White matter hyperintensities (Fazekas)",  info: "wmh", short: "White matter (Fazekas)" },
    { id: "pvs",         title: "Perivascular spaces",                      info: "pvs", short: "Perivascular spaces" },
    { id: "microbleeds", title: "Microbleeds",                              info: "microbleeds", short: "Microbleeds" },
    { id: "css",         title: "Cortical superficial siderosis",           info: "css", short: "Superficial siderosis" },
    { id: "gca",         title: "Global cortical atrophy (GCA)",            info: "gca", short: "Global cortical atrophy" },
    { id: "mta",         title: "Medial temporal atrophy (MTA)",            info: "mta", short: "Medial temporal atrophy" },
    { id: "erica",       title: "Entorhinal cortical atrophy (ERICA)",      info: "erica", short: "Entorhinal atrophy" },
    { id: "koedam",      title: "Posterior parietal atrophy (Koedam)",      info: "koedam", short: "Posterior parietal atrophy" },
    { id: "svd",         title: "Total small vessel disease score",         info: "svd", short: "Total SVD score" }
  ],

  // Labels of the status buttons shown on each section
  statusLabels: { normal: "Normal", abnormal: "Abnormal", na: "Not assessed", included: "Included" },

  /* ---------------------------------------------------------------------------
     1. CHOICES (buttons in the form)
     "export" = the exact text written to the Excel file (same as the Shiny app).
     --------------------------------------------------------------------------- */
  choices: {
    sex: [
      { value: "Female", label: "Female" },
      { value: "Male",   label: "Male" },
      { value: "NA",     label: "NA" }
    ],

    // White matter hyperintensities (Fazekas)
    pvGrade: [
      { value: 0, label: "0", hint: "absent",                           export: "0 = absent" },
      { value: 1, label: "1", hint: "“caps” or pencil-thin lining",       export: "1 = “caps” or pencil-thin lining" },
      { value: 2, label: "2", hint: "smooth “halo”",                      export: "2 = smooth “halo”" },
      { value: 3, label: "3", hint: "irregular periventricular signal extending into the deep white matter",
                                                                        export: "3 = irregular periventricular signal extending into the deep white matter" }
    ],
    pvDistribution: [
      { value: "diffuse",     label: "Diffuse" },
      { value: "frontal",     label: "Frontal" },
      { value: "occipital",   label: "Occipital" },
      { value: "temporal",    label: "Temporal" },
      { value: "peri-atrial", label: "Peri-atrial" }
    ],
    dwmGrade: [
      { value: 0, label: "0", hint: "absent",                 export: "0 = absent" },
      { value: 1, label: "1", hint: "punctate foci",          export: "1 = punctate foci" },
      { value: 2, label: "2", hint: "beginning confluence",   export: "2 = beginning confluence" },
      { value: 3, label: "3", hint: "large confluent areas",  export: "3 = large confluent areas" }
    ],
    dwmDistribution: [
      { value: "diffuse",           label: "Diffuse" },
      { value: "centrum semiovale", label: "Centrum semiovale" },
      { value: "corona radiata",    label: "Corona radiata" }
    ],
    laterality: [
      { value: "bilateral", label: "Bilateral" },
      { value: "right",     label: "Right" },
      { value: "left",      label: "Left" }
    ],

    // Perivascular spaces, basal ganglia and centrum semiovale (Potter 2015: 0–4)
    pvs: [
      { value: 0, label: "None",     sub: "0",     export: "none = 0" },
      { value: 1, label: "Mild",     sub: "1–10",  export: "mild = 1-10" },
      { value: 2, label: "Moderate", sub: "11–20", export: "moderate = 11-20" },
      { value: 3, label: "Frequent", sub: "21–40", export: "frequent = 21-40" },
      { value: 4, label: "Severe",   sub: ">40",   export: "severe = >40" }
    ],
    // Perivascular spaces, midbrain (Potter 2015: 0 none visible, 1 visible)
    pvsMes: [
      { value: 0, label: "None",    export: "none = 0" },
      { value: 1, label: "Visible", export: "visible = 1" }
    ],

    // Cortical superficial siderosis (each hemisphere)
    css: [
      { value: 0, label: "0", hint: "none", export: "0" },
      { value: 1, label: "1", hint: "1 sulcus or up to 3 immediately adjacent sulci with cSS", export: "1" },
      { value: 2, label: "2", hint: "2 or more nonadjacent sulci or more than 3 adjacent sulci with cSS", export: "2" }
    ],

    // Global cortical atrophy (each region)
    gca: [
      { value: 0, label: "0", export: "0" },
      { value: 1, label: "1", export: "1" },
      { value: 2, label: "2", export: "2" },
      { value: 3, label: "3", export: "3" }
    ],

    mta: [
      { value: 0, label: "0", hint: "no CSF is visible around the hippocampus",
        export: "0: no CSF is visible around the hippocampus" },
      { value: 1, label: "1", hint: "choroid fissure is slightly widened",
        export: "1: choroid fissure is slightly widened" },
      { value: 2, label: "2", hint: "moderate widening of the choroid fissure, mild enlargement of the temporal horn and mild loss of hippocampal height",
        export: "2: moderate widening of the choroid fissure, mild enlargement of the temporal horn and mild loss of hippocampal height" },
      { value: 3, label: "3", hint: "marked widening of the choroid fissure, moderate enlargement of the temporal horn, and moderate loss of hippocampal height",
        export: "3: marked widening of the choroid fissure, moderate enlargement of the temporal horn, and moderate loss of hippocampal height" },
      { value: 4, label: "4", hint: "marked widening of the choroid fissure, marked enlargement of the temporal horn, and the hippocampus is markedly atrophied and internal structure is lost",
        export: "4: marked widening of the choroid fissure, marked enlargement of the temporal horn, and the hippocampus is markedly atrophied and internal structure is lost" }
    ],

    erica: [
      { value: 0, label: "0", hint: "normal volume of the entorhinal cortex and parahippocampal gyrus",
        export: "0: normal volume of the entorhinal cortex and parahippocampal gyrus" },
      { value: 1, label: "1", hint: "mild atrophy of the entorhinal cortex and parahippocampal gyrus; widening of the collateral sulcus",
        export: "1: mild atrophy of the entorhinal cortex and parahippocampal gyrus; widening of the collateral sulcus" },
      { value: 2, label: "2", hint: "moderate atrophy of the entorhinal cortex and parahippocampal gyrus; elevation of the entorhinal cortex away from the adjacent cerebellar tentorium",
        export: "2: moderate atrophy of the entorhinal cortex and parahippocampal gyrus; elevation of the entorhinal cortex away from the adjacent cerebellar tentorium" },
      { value: 3, label: "3", hint: "marked atrophy of the entorhinal cortex and parahippocampal gyrus; wide cleft between the entorhinal cortex and the adjacent cerebellar tentorium",
        export: "3: marked atrophy of the entorhinal cortex and parahippocampal gyrus; wide cleft between the entorhinal cortex and the adjacent cerebellar tentorium" }
    ],

    koedam: [
      { value: 0, label: "0", hint: "closed sulci; no gyral atrophy",                  export: "0: closed sulci; no gyral atrophy" },
      { value: 1, label: "1", hint: "mild sulcal widening; mild gyral atrophy",        export: "1: mild sulcal widening; mild gyral atrophy" },
      { value: 2, label: "2", hint: "substantial sulcal widening; substantial gyral atrophy", export: "2: substantial sulcal widening; substantial gyral atrophy" },
      { value: 3, label: "3", hint: "marked sulcal widening; knife-blade gyral atrophy", export: "3: marked sulcal widening; knife-blade gyral atrophy" }
    ]
  },

  /* ---------------------------------------------------------------------------
     2. LOCATIONS for recent small subcortical infarcts and lacunes
     Each button has an "id" (the text exported to Excel, same as the Shiny app)
     and the phrase used in the EN and PT reports.
     Buttons: R = right, L = left, C = central, M = midline.
     --------------------------------------------------------------------------- */
  locationGroups: [
    { group: "Supratentorial", rows: [
      { label: "Centrum semiovale – frontal", options: [
        { btn: "R", id: "Centrum semiovale - Frontal - Right", en: "right frontal centrum semiovale", pt: "centro semioval frontal à direita" },
        { btn: "L", id: "Centrum semiovale - Frontal - Left",  en: "left frontal centrum semiovale",  pt: "centro semioval frontal à esquerda" } ] },
      { label: "Centrum semiovale – parietal", options: [
        { btn: "R", id: "Centrum semiovale - Parietal - Right", en: "right parietal centrum semiovale", pt: "centro semioval parietal à direita" },
        { btn: "L", id: "Centrum semiovale - Parietal - Left",  en: "left parietal centrum semiovale",  pt: "centro semioval parietal à esquerda" } ] },
      { label: "Corona radiata – frontal", options: [
        { btn: "R", id: "Corona radiata - Frontal - Right", en: "right frontal corona radiata", pt: "corona radiata frontal à direita" },
        { btn: "L", id: "Corona radiata - Frontal - Left",  en: "left frontal corona radiata",  pt: "corona radiata frontal à esquerda" } ] },
      { label: "Corona radiata – parietal", options: [
        { btn: "R", id: "Corona radiata - Parietal - Right", en: "right parietal corona radiata", pt: "corona radiata parietal à direita" },
        { btn: "L", id: "Corona radiata - Parietal - Left",  en: "left parietal corona radiata",  pt: "corona radiata parietal à esquerda" } ] },
      { label: "Caudate nucleus", options: [
        { btn: "R", id: "Caudate nucleus - Right", en: "right caudate nucleus", pt: "núcleo caudado à direita" },
        { btn: "L", id: "Caudate nucleus - Left",  en: "left caudate nucleus",  pt: "núcleo caudado à esquerda" } ] },
      { label: "External capsule", options: [
        { btn: "R", id: "External capsule - Right", en: "right external capsule", pt: "cápsula externa à direita" },
        { btn: "L", id: "External capsule - Left",  en: "left external capsule",  pt: "cápsula externa à esquerda" } ] },
      { label: "Internal capsule – anterior limb", options: [
        { btn: "R", id: "Internal capsule - Anterior limb - Right", en: "anterior limb of the right internal capsule", pt: "braço anterior da cápsula interna à direita" },
        { btn: "L", id: "Internal capsule - Anterior limb - Left",  en: "anterior limb of the left internal capsule",  pt: "braço anterior da cápsula interna à esquerda" } ] },
      { label: "Internal capsule – genu", options: [
        { btn: "R", id: "Internal capsule - Genu - Right", en: "genu of the right internal capsule", pt: "joelho da cápsula interna à direita" },
        { btn: "L", id: "Internal capsule - Genu - Left",  en: "genu of the left internal capsule",  pt: "joelho da cápsula interna à esquerda" } ] },
      { label: "Internal capsule – posterior limb", options: [
        { btn: "R", id: "Internal capsule - Posterior limb - Right", en: "posterior limb of the right internal capsule", pt: "braço posterior da cápsula interna à direita" },
        { btn: "L", id: "Internal capsule - Posterior limb - Left",  en: "posterior limb of the left internal capsule",  pt: "braço posterior da cápsula interna à esquerda" } ] },
      { label: "Lentiform nucleus", options: [
        { btn: "R", id: "Lentiform nucleus - Right", en: "right lentiform nucleus", pt: "núcleo lentiforme à direita" },
        { btn: "L", id: "Lentiform nucleus - Left",  en: "left lentiform nucleus",  pt: "núcleo lentiforme à esquerda" } ] },
      { label: "Thalamus – anterior", options: [
        { btn: "R", id: "Thalamus - Anterior - Right", en: "right anterior thalamus", pt: "tálamo anterior à direita" },
        { btn: "L", id: "Thalamus - Anterior - Left",  en: "left anterior thalamus",  pt: "tálamo anterior à esquerda" } ] },
      { label: "Thalamus – lateral", options: [
        { btn: "R", id: "Thalamus - Lateral - Right", en: "right lateral thalamus", pt: "tálamo lateral à direita" },
        { btn: "L", id: "Thalamus - Lateral - Left",  en: "left lateral thalamus",  pt: "tálamo lateral à esquerda" } ] },
      { label: "Thalamus – medial", options: [
        { btn: "R", id: "Thalamus - Medial - Right", en: "right medial thalamus", pt: "tálamo medial à direita" },
        { btn: "L", id: "Thalamus - Medial - Left",  en: "left medial thalamus",  pt: "tálamo medial à esquerda" } ] },
      { label: "Thalamus – posterior", options: [
        { btn: "R", id: "Thalamus - Posterior - Right", en: "right posterior thalamus", pt: "tálamo posterior à direita" },
        { btn: "L", id: "Thalamus - Posterior - Left",  en: "left posterior thalamus",  pt: "tálamo posterior à esquerda" } ] }
    ]},
    { group: "Brainstem", rows: [
      // (the former "Cerebral peduncle" row of the supratentorial group was merged here; older saved ids are converted)
      { label: "Midbrain – cerebral peduncle", options: [
        { btn: "R", id: "Midbrain - Crus cerebri - Right", en: "right cerebral peduncle", pt: "pedúnculo cerebral à direita" },
        { btn: "L", id: "Midbrain - Crus cerebri - Left",  en: "left cerebral peduncle",  pt: "pedúnculo cerebral à esquerda" } ] },
      { label: "Midbrain – tegmentum", options: [
        { btn: "R", id: "Midbrain - Tegmentum - Right",   en: "right midbrain tegmentum", pt: "tegmento do mesencéfalo à direita" },
        // Note: the Shiny app wrote "central tegmentum midbrain" (kept here so the reports match);
        // in PT the Shiny app dropped this location from the "recent infarct" sentence (bug fixed here).
        { btn: "C", id: "Midbrain - Tegmentum - Central", en: "central midbrain tegmentum",         pt: "tegmento do mesencéfalo ao centro", title: "Central" },
        { btn: "L", id: "Midbrain - Tegmentum - Left",    en: "left midbrain tegmentum",  pt: "tegmento do mesencéfalo à esquerda" } ] },
      { label: "Midbrain – tectum", options: [
        { btn: "R", id: "Midbrain - Tectum - Right",  en: "right midbrain tectum",   pt: "teto do mesencéfalo à direita" },
        { btn: "M", id: "Midbrain - Tectum - Midline", en: "midline midbrain tectum", pt: "teto do mesencéfalo na linha média", title: "Midline" },
        { btn: "L", id: "Midbrain - Tectum - Left",   en: "left midbrain tectum",    pt: "teto do mesencéfalo à esquerda" } ] },
      { label: "Pons – basis", options: [
        { btn: "R", id: "Pons - Basis - Right",   en: "right pontine base",   pt: "base da ponte à direita" },
        { btn: "M", id: "Pons - Basis - Midline", en: "midline pontine base", pt: "base da ponte na linha média", title: "Midline" },
        { btn: "L", id: "Pons - Basis - Left",    en: "left pontine base",    pt: "base da ponte à esquerda" } ] },
      { label: "Pons – tegmentum", options: [
        { btn: "R", id: "Pons - Tegmentum - Right",   en: "right pontine tegmentum",   pt: "tegmento da ponte à direita" },
        { btn: "M", id: "Pons - Tegmentum - Midline", en: "midline pontine tegmentum", pt: "tegmento da ponte na linha média", title: "Midline" },
        { btn: "L", id: "Pons - Tegmentum - Left",    en: "left pontine tegmentum",    pt: "tegmento da ponte à esquerda" } ] },
      { label: "Medulla – anterior", options: [
        { btn: "R", id: "Medulla - Anterior - Right", en: "right anterior medulla", pt: "região anterior do bulbo à direita" },
        { btn: "L", id: "Medulla - Anterior - Left",  en: "left anterior medulla",  pt: "região anterior do bulbo à esquerda" } ] },
      { label: "Medulla – posterior", options: [
        { btn: "R", id: "Medulla - Posterior - Right", en: "right posterior medulla", pt: "região posterior do bulbo à direita" },
        { btn: "L", id: "Medulla - Posterior - Left",  en: "left posterior medulla",  pt: "região posterior do bulbo à esquerda" } ] }
    ]},
    { group: "Cerebellum", rows: [
      { label: "Cerebellum", options: [
        { btn: "R", id: "Cerebellum - Right", en: "right cerebellar hemisphere", pt: "cerebelo à direita" },
        { btn: "L", id: "Cerebellum - Left",  en: "left cerebellar hemisphere",  pt: "cerebelo à esquerda" } ] }
    ]}
  ],

  /* ---------------------------------------------------------------------------
     3. MICROBLEED REGIONS (MARS)
     "excel" = start of the Excel column names (…DefiniteRight, …DefiniteLeft, …).
     --------------------------------------------------------------------------- */
  microbleedRegions: [
    { key: "brainstem",        group: "infratentorial", label: "Brainstem",        en: "brainstem",        pt: "tronco encefálico", excel: "Brainstem" },
    { key: "cerebellum",       group: "infratentorial", label: "Cerebellum",       en: "cerebellum",       pt: "cerebelo",          excel: "Cerebellum" },
    { key: "basal_ganglia",    group: "deep", label: "Basal ganglia",    en: "basal ganglia",    pt: "gânglios da base", excel: "BasalGanglia" },
    { key: "thalamus",         group: "deep", label: "Thalamus",         en: "thalamus",         pt: "tálamo",           excel: "Thalamus" },
    { key: "internal_capsule", group: "deep", label: "Internal capsule", en: "internal capsule", pt: "cápsula interna",  excel: "InternalCapsule" },
    { key: "external_capsule", group: "deep", label: "External capsule", en: "external capsule", pt: "cápsula externa",  excel: "ExternalCapsule" },
    { key: "corpus_callosum",  group: "deep", label: "Corpus callosum",  en: "corpus callosum",  pt: "corpo caloso",     excel: "CorpusCallosum" },
    { key: "deep_pvwhite",     group: "deep", label: "Deep/periventricular WM", en: "deep and periventricular white matter", pt: "substância branca profunda e periventricular", excel: "DeepPVWhite" },
    { key: "frontal",   group: "lobar", label: "Frontal",   en: "frontal",   pt: "frontal",   excel: "Frontal" },
    { key: "parietal",  group: "lobar", label: "Parietal",  en: "parietal",  pt: "parietal",  excel: "Parietal" },
    { key: "temporal",  group: "lobar", label: "Temporal",  en: "temporal",  pt: "temporal",  excel: "Temporal" },
    { key: "occipital", group: "lobar", label: "Occipital", en: "occipital", pt: "occipital", excel: "Occipital" },
    { key: "insula",    group: "lobar", label: "Insula",    en: "insula",    pt: "ínsula",    excel: "Insula" }
  ],
  microbleedGroups: [
    { key: "infratentorial", label: "Infratentorial" },
    { key: "deep",           label: "Deep" },
    { key: "lobar",          label: "Lobar" }
  ],

  /* ---------------------------------------------------------------------------
     4. CUT-OFFS used by the report
     --------------------------------------------------------------------------- */
  cutoffs: {
    mtaAge: 75,          // age limit (years) for the MTA cut-off
    mtaUnder: 2,         // abnormal if score >= 2 under mtaAge
    mtaFrom: 3,          // abnormal if score >= 3 from mtaAge
    erica: 2,            // ERICA abnormal if score >= 2
    // Summary small vessel disease score (Staals 2014): one point each
    svdPvsBasalGanglia: 2,   // basal ganglia PVS grade >= 2 (moderate or more)
    svdWmhPeriventricular: 3,// periventricular Fazekas = 3
    svdWmhDeep: 2            // deep Fazekas >= 2
  },

  /* ---------------------------------------------------------------------------
     5. REPORT SENTENCES
     --------------------------------------------------------------------------- */
  text: {

    /* ============================== ENGLISH ============================== */
    en: {
      rsi: {
        none: "No recent small subcortical infarcts identified.",
        one:  "Recent small subcortical infarct in the {regions}.",
        many: "Recent small subcortical infarcts in the {regions}.",
        and2: " and ",      // between two locations
        andLast: ", and "   // before the last of three or more locations
      },
      lacunes: {
        none: "No lacunes of presumed vascular origin identified.",
        one:  "Lacunes of presumed vascular origin in the {regions}.",
        many: "Lacunes of presumed vascular origin in the {regions}.",
        and2: " and ",
        andLast: ", and "
      },
      wmh: {
        none: "No significant T2-FLAIR hyperintensities of presumed vascular origin identified. Fazekas = 0.",
        sentence: "T2-FLAIR hyperintensities of presumed vascular origin: {regions}. Fazekas = {fazekas}.",
        join: " and ",
        severity: { 1: "mild", 2: "moderate", 3: "severe" },
        // Periventricular part: {distribution} is empty for "diffuse"
        periventricular: "{severity} in the periventricular {distribution} white matter {laterality}",
        pvDistribution: { "diffuse": "", "frontal": "frontal", "occipital": "occipital", "temporal": "temporal", "peri-atrial": "peri-atrial" },
        pvLaterality: { bilateral: "bilaterally", right: "on the right", left: "on the left" },
        // Deep white matter part, by distribution and laterality
        deep: {
          "diffuse":           { bilateral: "{severity} in the deep white matter bilaterally", right: "{severity} in the deep white matter on the right", left: "{severity} in the deep white matter on the left" },
          "centrum semiovale": { bilateral: "{severity} in the centrum semiovale bilaterally",  right: "{severity} in the right centrum semiovale",    left: "{severity} in the left centrum semiovale" },
          "corona radiata":    { bilateral: "{severity} in the corona radiata bilaterally",     right: "{severity} in the right corona radiata",       left: "{severity} in the left corona radiata" }
        }
      },
      pvs: {
        none: "No perivascular spaces identified.",
        regions: { cs: "the centrum semiovale", bg: "the basal ganglia" },
        midbrain: "Perivascular spaces visible in the midbrain.",   // midbrain: visible or not (Potter 2015)
        grade: { 1: "Mild (1-10)", 2: "Moderate (11-20)", 3: "Frequent (21-40)", 4: "Severe (>40)" },
        first: "{grade} perivascular spaces in {regions}",   // most severe grade
        other: "{grade} in {regions}",                       // other grades ({grade} in lower case)
        regionsJoin: ", ", regionsAnd: " and ",
        partsJoin: "; ",   partsAnd: "; and ", partsAnd2: " and "
      },
      microbleeds: {
        none: "No cerebral microbleeds identified.",
        sentence: "Number of definite cerebral microbleeds: {total}. [{details}].",
        onlyPossible: "No definite cerebral microbleeds. Possible microbleeds: [{details}].",
        groups: { infratentorial: "Infratentorial:", deep: "Deep:", lobar: "Lobar:" },
        right: "{n} right", left: "{n} left",
        definite: "{list} definite", possible: "{list} possible",
        region: "{region} ({entries})",
        regionsJoin: "; ", regionsAnd: " and "
      },
      css: {
        none: "No cortical superficial siderosis (cSS) identified.",
        mild: "Mild, unifocal cortical superficial siderosis (cSS), score 1 {side}. cSS total score = 1.",
        mildSide: { right: "on the right", left: "on the left" },
        severe: "Severe, multifocal cortical superficial siderosis (cSS), {location}. cSS total score = {total}.",
        both: "score {right} on both hemispheres",
        each: "score {right} on the right and {left} on the left"
      },
      gca: {
        // Line 1: one atrophy sentence (cortical + subcortical). "diffuse" = all six regions share the top score.
        severity: { 1: "Mild", 2: "Moderate", 3: "Severe" },
        none: "No cortical or subcortical atrophy.",
        cortical: "cortical", subcortical: "subcortical", both: "cortical and subcortical",
        diffuse: "{severity} diffuse {kind} atrophy",
        predominant: "{severity} {kind} atrophy predominantly in the {regions}",
        secondDiffuse: "diffuse {kind} atrophy",
        secondPredominant: "{kind} atrophy predominantly in the {regions}",
        onlyCortical: "{phrase}, without subcortical atrophy.",
        onlySubcortical: "{phrase}, without cortical atrophy.",
        area: "area", areas: "areas",
        right: "right", left: "left", bilateral: "bilateral",
        regions: { frontal: "frontal", po: "parieto-occipital", temporal: "temporal" },
        thirdVentricle: "third ventricle",
        withThird: "{regions} {area} and third ventricle",
        join2: " and ", joinLast: " and ",
        // Line 2: GCA score and values
        score: "Global cortical atrophy (GCA) score = {score}.",
        sulci: "Sulci: {list}.", ventricles: "Ventricles: {list}.",
        valueRight: "right: {n}", valueLeft: "left: {n}",
        thirdValue: "third ventricle: {n}"
      },
      mta: {
        missingAge:   "Medial Temporal Atrophy (MTA) score: {scores}; age not provided (age-adjusted cut-off: ≥2 under 75 years, ≥3 from 75 years).",
        scoresEqual:  "bilateral = {left}",
        scoresDiff:   "left = {left} and right = {right}",
        bothAbnormalEqual: "Medial Temporal Atrophy (MTA) score: bilateral = {left}; meets the age-adjusted cut-off.",
        bothAbnormalDiff:  "Medial Temporal Atrophy (MTA) score: left = {left} and right = {right}; both meet the age-adjusted cut-off.",
        oneAbnormal:  "Medial Temporal Atrophy (MTA) score: {abnSide} = {abnValue} (meets the age-adjusted cut-off) and {normSide} = {normValue} (below the cut-off).",
        normalEqual:  "Medial Temporal Atrophy (MTA) score: bilateral = {left}; below the age-adjusted cut-off.",
        normalDiff:   "Medial Temporal Atrophy (MTA) score: left = {left} and right = {right}; below the age-adjusted cut-off.",
        side: { left: "left", right: "right" }
      },
      erica: {
        bothAbnormalEqual: "Entorhinal Cortical Atrophy (ERICA) score: bilateral = {left}; meets the published cut-off (≥2).",
        bothAbnormalDiff:  "Entorhinal Cortical Atrophy (ERICA) score: right = {right} and left = {left}; both meet the published cut-off (≥2).",
        oneAbnormal: "Entorhinal Cortical Atrophy (ERICA) score: right = {right} ({rightStatus}) and left = {left} ({leftStatus}); published cut-off ≥2.",
        normalEqual: "Entorhinal Cortical Atrophy (ERICA) score: bilateral = {left}; below the published cut-off (≥2).",
        normalDiff:  "Entorhinal Cortical Atrophy (ERICA) score: right = {right} and left = {left}; below the published cut-off (≥2).",
        status: { abnormal: "meets the cut-off", normal: "below the cut-off" },
        side: { left: "left", right: "right" }
      },
      koedam: {
        equal:        "Posterior parietal atrophy (Koedam) score: bilateral = {left}.",
        leftGreater:  "Posterior parietal atrophy (Koedam) score: left = {left} and right = {right}.",
        rightGreater: "Posterior parietal atrophy (Koedam) score: right = {right} and left = {left}."
      },
      svd: {
        sentence: "Total small vessel disease (SVD) score = {score} {points}.",
        // when a part of the score was marked "Not assessed"
        incomplete: "Total small vessel disease (SVD) score = {score} {points} (incomplete: {missing} not assessed).",
        parts: { lacunes: "lacunes", microbleeds: "microbleeds", pvs: "perivascular spaces", wmh: "white matter hyperintensities" },
        and: " and ",
        point: "point", points: "points"
      }
    },

    /* ============================= PORTUGUÊS ============================= */
    pt: {
      rsi: {
        none: "Sem pequenos enfartes subcorticais recentes.",
        one:  "Pequeno enfarte subcortical recente: {regions}.",
        many: "Pequenos enfartes subcorticais recentes: {regions}.",
        and2: " e ",
        andLast: " e "
      },
      lacunes: {
        none: "Sem lacunas de presumível origem vascular.",
        one:  "Lacuna de presumível origem vascular em: {regions}.",
        many: "Lacunas de presumível origem vascular em: {regions}.",
        and2: " e ",
        andLast: " e "
      },
      wmh: {
        none: "Sem valorizável leucoencefalopatia microangiopática crónica. Fazekas = 0.",
        sentence: "Hipersinal T2-FLAIR de presumível origem microangiopática de predomínio: {regions}. Fazekas = {fazekas}.",
        join: " e ",
        severity: { 1: "discreto", 2: "moderado", 3: "marcado" },
        periventricular: "{severity} na substância branca periventricular {distribution} {laterality}",
        pvDistribution: { "diffuse": "", "frontal": "frontal", "occipital": "occipital", "temporal": "temporal", "peri-atrial": "peri-atrial" },
        pvLaterality: { bilateral: "bilateral", right: "à direita", left: "à esquerda" },
        deep: {
          "diffuse":           { bilateral: "{severity} na substância branca profunda bilateral", right: "{severity} na substância branca profunda à direita", left: "{severity} na substância branca profunda à esquerda" },
          "centrum semiovale": { bilateral: "{severity} no centro semiovale bilateral",           right: "{severity} no centro semiovale à direita",           left: "{severity} no centro semiovale à esquerda" },
          "corona radiata":    { bilateral: "{severity} na corona radiata bilateral",             right: "{severity} na corona radiata à direita",             left: "{severity} na corona radiata à esquerda" }
        }
      },
      pvs: {
        none: "Sem valorizável ectasia de espaços perivasculares.",
        sentence: "Dilatação de espaços perivasculares: {parts}",
        regions: { cs: "nos centros semiovais", bg: "nos gânglios da base" },
        midbrain: "Espaços perivasculares visíveis no mesencéfalo.",
        grade: { 1: "ligeira (1-10)", 2: "moderada (11-20)", 3: "frequente (21-40)", 4: "marcada (>40)" },
        part: "{grade} {regions}",
        regionsJoin: ", ", regionsAnd: " e ",
        partsJoin: ", ", partsAnd: " e "
      },
      microbleeds: {
        none: "Sem micro-hemorragias parenquimatosas.",
        sentence: "Número de micro-hemorragias cerebrais definitivas: {total}. [{details}].",
        onlyPossible: "Sem micro-hemorragias definitivas. Possíveis micro-hemorragias: [{details}].",
        groups: { infratentorial: "Infratentoriais:", deep: "Profundas:", lobar: "Lobares:" },
        right: "{n} à direita", left: "{n} à esquerda",
        definite: "definitivas: {list}", possible: "possíveis: {list}",
        region: "{region} ({entries})",
        regionsJoin: ", ", regionsAnd: " e "
      },
      css: {
        none: "Sem siderose superficial cortical.",
        mild: "Siderose superficial cortical (cSS) ligeira, unifocal, grau 1 {side}. cSS total = 1.",
        mildSide: { right: "no hemisfério direito", left: "no hemisfério esquerdo" },
        severe: "Siderose superficial cortical (cSS) marcada, multifocal, {location}. cSS total = {total}.",
        both: "grau {right} em ambos os hemisférios",
        each: "grau {right} no hemisfério direito e {left} no hemisfério esquerdo"
      },
      gca: {
        // Linha 1: uma frase de atrofia (cortical + subcortical). "difusa" = as seis regiões com o score máximo.
        severity: { 1: "Discreta", 2: "Moderada", 3: "Marcada" },
        none: "Sem atrofia cortical ou subcortical.",
        cortical: "cortical", subcortical: "subcortical", both: "cortical e subcortical",
        diffuse: "{severity} atrofia {kind} difusa",
        predominant: "{severity} atrofia {kind} de predomínio {regions}",
        secondDiffuse: "{kind} difusa",
        secondPredominant: "{kind} de predomínio {regions}",
        onlyCortical: "{phrase}, sem atrofia subcortical.",
        onlySubcortical: "{phrase}, sem atrofia cortical.",
        right: "direito", left: "esquerdo", bilateral: "bilateral",
        regions: { frontal: "frontal", po: "parieto-occipital", temporal: "temporal" },
        thirdVentricle: "no terceiro ventrículo",
        withThird: "{regions} e no terceiro ventrículo",
        join2: " e ", joinLast: " e ",
        // Linha 2: GCA e valores
        score: "Global cortical atrophy (GCA) = {score}.",
        sulci: "Sulcos: {list}.", ventricles: "Ventrículos: {list}.",
        valueRight: "direito: {n}", valueLeft: "esquerdo: {n}",
        thirdValue: "terceiro ventrículo: {n}"
      },
      mta: {
        missingAge:   "Medial Temporal Atrophy (MTA): {scores}; idade não indicada (valor de referência para a idade: ≥2 abaixo dos 75 anos, ≥3 a partir dos 75 anos).",
        scoresEqual:  "bilateral = {left}",
        scoresDiff:   "esquerdo = {left} e direito = {right}",
        bothAbnormalEqual: "Medial Temporal Atrophy (MTA): bilateral = {left}; igual ou superior ao valor de referência para a idade.",
        bothAbnormalDiff:  "Medial Temporal Atrophy (MTA): esquerdo = {left} e direito = {right}; ambos iguais ou superiores ao valor de referência para a idade.",
        oneAbnormal:  "Medial Temporal Atrophy (MTA): {abnSide} = {abnValue} (igual ou superior) e {normSide} = {normValue} (inferior) face ao valor de referência para a idade.",
        normalEqual:  "Medial Temporal Atrophy (MTA): bilateral = {left}; inferior ao valor de referência para a idade.",
        normalDiff:   "Medial Temporal Atrophy (MTA): esquerdo = {left} e direito = {right}; ambos inferiores ao valor de referência para a idade.",
        side: { left: "esquerdo", right: "direito" }
      },
      erica: {
        bothAbnormalEqual: "Entorhinal Cortical Atrophy (ERICA): bilateral = {left}; igual ou superior ao valor de referência (≥2).",
        bothAbnormalDiff:  "Entorhinal Cortical Atrophy (ERICA): direito = {right} e esquerdo = {left}; ambos iguais ou superiores ao valor de referência (≥2).",
        oneAbnormal: "Entorhinal Cortical Atrophy (ERICA): direito = {right} ({rightStatus}) e esquerdo = {left} ({leftStatus}) face ao valor de referência (≥2).",
        normalEqual: "Entorhinal Cortical Atrophy (ERICA): bilateral = {left}; inferior ao valor de referência (≥2).",
        normalDiff:  "Entorhinal Cortical Atrophy (ERICA): direito = {right} e esquerdo = {left}; ambos inferiores ao valor de referência (≥2).",
        status: { abnormal: "igual ou superior", normal: "inferior" },
        side: { left: "à esquerda", right: "à direita" }
      },
      koedam: {
        equal:        "Posterior parietal atrophy (Koedam): bilateral = {left}.",
        leftGreater:  "Posterior parietal atrophy (Koedam): esquerdo = {left} e direito = {right}.",
        rightGreater: "Posterior parietal atrophy (Koedam): direito = {right} e esquerdo = {left}."
      },
      svd: {
        sentence: "Score total de doença de pequenos vasos (SVD) = {score} {points}.",
        incomplete: "Score total de doença de pequenos vasos (SVD) = {score} {points} (incompleto, sem avaliação de {missing}).",
        parts: { lacunes: "lacunas", microbleeds: "micro-hemorragias", pvs: "espaços perivasculares", wmh: "hipersinal da substância branca" },
        and: " e ",
        point: "ponto", points: "pontos"
      }
    }
  },

  /* ---------------------------------------------------------------------------
     6. SINGLE CALCULATORS (English only, as in the Shiny app)
     --------------------------------------------------------------------------- */
  calculatorText: {
    gca: {
      result: "Global cortical atrophy (GCA) score = {score}.",
      sulci: "Sulci: {list}.", ventricles: "Ventricles: {list}."
    },
    mta: {
      equal: "Medial temporal atrophy (MTA) score = {score} bilaterally.",
      diff:  "Medial temporal atrophy (MTA) score = {high} on the {highSide} and {low} on the {lowSide} side.",
      interpretationTitle: "Published age-adjusted cut-offs (each side):",
      interpretation: ["Published age-adjusted cut-offs (each side): ≥2 under 75 years; ≥3 from 75 years (Torisson 2015)."]
    },
    erica: {
      equal: "Entorhinal cortical atrophy (ERICA) score = {score} bilaterally.",
      diff:  "Entorhinal cortical atrophy (ERICA) score = {high} on the {highSide} and {low} on the {lowSide} side.",
      interpretationTitle: "Published cut-off (each side):",
      interpretation: ["Published cut-off (each side): ≥2 (Enkirch 2018)."]
    },
    koedam: {
      equal: "Posterior parietal atrophy (Koedam) score = {score} bilaterally.",
      diff:  "Posterior parietal atrophy (Koedam) score = {high} on the {highSide} and {low} on the {lowSide} side.",
      interpretationTitle: "",
      interpretation: []
    }
  }
};
