/* =============================================================================
   MOVEMENT CALCULATOR — CONTENT FILE (published cutoffs and help texts)
   -----------------------------------------------------------------------------
   To update the literature, edit the "cutoffs" table only: one line per
   published cutoff.
     index    : mrpi, mrpi2, mpa (midbrain/pons area ratio),
                md (midbrain AP diameter), mdpd (midbrain/pons diameter ratio),
                mcp (middle cerebellar peduncle width)
     op       : ">=", ">", "<" or "<="
     favours  : the diagnosis the cutoff points to
     group    : cutoffs in the same group answer the same question (used to
                say "Other studies disagree")
     versus   : comparison group, "vs PD" (shown as "PSP rather than PD")
     source   : one or more, separated by ";" ("Peralta 2022; Chougar 2024"), each linked by its DOI below
     tested   : true = derived and tested in patients in the study (ROC analysis);
                false = proposed value (from a review or reading grid, not tested in a cohort);
                it never drives the result
     primary  : true = the reference cutoff shown first (one per index)
   ========================================================================== */

var Aurora = globalThis.Aurora = globalThis.Aurora || {};
Aurora.content = Aurora.content || {};

Aurora.content.movement = {

  cutoffs: [
    { index: "mrpi",  op: ">=", value: 13.55, favours: "PSP",    group: "psp_pd",   versus: "vs PD",      source: "Quattrone 2008", note: "1.5 T; sensitivity and specificity 100%", tested: true,  primary: true },
    { index: "mrpi",  op: ">=", value: 12.85, favours: "PSP",    group: "psp_msap", versus: "vs MSA-P",   source: "Quattrone 2008", note: "1.5 T; sensitivity and specificity 100%", tested: true,  primary: false },
    { index: "mrpi",  op: ">",  value: 15.62, favours: "PSP",    group: "psp_pd",   versus: "vs PD and MSA", source: "Mangesius 2018", note: "1.5 T; sensitivity 82.9%, specificity 86.2%", tested: true,  primary: false },

    { index: "mrpi2", op: ">=", value: 2.18,  favours: "PSP-P",  group: "psp_pd",   versus: "vs PD",      source: "Quattrone 2018", note: "3 T; sensitivity 100%, specificity 94.3%", tested: true,  primary: true },
    { index: "mrpi2", op: ">=", value: 2.50,  favours: "PSP-RS", group: "psp_rs",   versus: "vs PD",      source: "Quattrone 2018", note: "3 T; sensitivity and specificity 100%", tested: true,  primary: false },

    { index: "mpa",   op: "<",  value: 0.18,  favours: "PSP",    group: "psp",      versus: "vs PD and MSA", source: "Mangesius 2018", note: "1.5 T; sensitivity 81.4%, specificity 87.1%", tested: true,  primary: true },
    { index: "mpa",   op: "<",  value: 0.22,  favours: "PSP",    group: "psp",      versus: "",           source: "Peralta 2022; Chougar 2024", note: "Proposed from the literature, not tested in a cohort", tested: false, primary: false },


    { index: "md",    op: "<",  value: 9.35,  favours: "PSP",    group: "psp",      versus: "vs MSA",     source: "Massey 2013",    note: "Autopsy cohort, 1.5 T: sensitivity 83%, specificity 100%; clinical cohort, 3 T: 90.5% and 100%", tested: true, primary: true },
    { index: "md",    op: "<",  value: 8.9,   favours: "PSP",    group: "psp",      versus: "vs PD and MSA", source: "Mangesius 2018", note: "1.5 T; sensitivity 90.0%, specificity 90.2%", tested: true,  primary: false },

    { index: "mdpd",  op: "<",  value: 0.52,  favours: "PSP",    group: "psp",      versus: "vs MSA",     source: "Massey 2013",    note: "Autopsy cohort, 1.5 T: sensitivity 67%, specificity 100%; clinical cohort, 3 T: 85.7% and 100%", tested: true, primary: true },
    { index: "mdpd",  op: "<",  value: 0.54,  favours: "PSP",    group: "psp",      versus: "vs PD and MSA", source: "Mangesius 2018", note: "1.5 T; sensitivity 88.6%, specificity 89.0%", tested: true,  primary: false },

    { index: "mcp",   op: "<=", value: 8.0,   favours: "MSA",    group: "msa",      versus: "vs PD",      source: "Nicoletti 2006", note: "1.5 T; 16 MSA vs 26 PD; sensitivity and specificity 100%", tested: true, primary: true },
    { index: "mcp",   op: "<",  value: 8.0,   favours: "MSA",    group: "msa",      versus: "vs PD and PSP", source: "Mangesius 2018", note: "1.5 T; sensitivity 69.3%, specificity 88.8%", tested: true,  primary: false }
  ],

  // DOI of each source (key = first two words of the source, e.g. "Chougar 2024")
  dois: {
    "Quattrone 2008": "10.1148/radiol.2453061703",
    "Quattrone 2018": "10.1016/j.parkreldis.2018.07.016",
    "Mangesius 2018": "10.1016/j.parkreldis.2017.10.020",
    "Chougar 2024":   "10.1002/mds.29760",
    "Peralta 2022":   "10.1002/mdc3.13354",
    "Massey 2013":    "10.1212/WNL.0b013e318292a2d2",
    "Nicoletti 2006": "10.1148/radiol.2393050459",
    "Morelli 2014":   "10.1002/mds.25821",
    "Oba 2005":       "10.1212/01.WNL.0000165960.04422.D0",
    "Madetko 2022":   "10.3390/jcm11102701"
  },

  // One entry per index. "digits" = decimals shown for the value; "cutDigits" = minimum decimals for the cutoffs (2.50, 8.0);
  // "uses" = measurements listed in Copy result (none when the index is itself the measurement).
  indices: {
    mrpi:  { name: "MRPI", formula: "(pons area / midbrain area) × (MCP width / SCP width)", uses: ["midbrain", "pons", "scp", "mcp"], digits: 2, unit: "", marker: "PSP",
             about: "A PSP marker: it rises with atrophy of the midbrain and superior cerebellar peduncles. Values above the cutoff are associated with PSP. Low values are found in PD and controls, and even lower values in MSA (pontine and middle cerebellar peduncle atrophy), with overlap between them." },
    mrpi2: { name: "MRPI 2.0", formula: "MRPI × (third ventricle width / frontal horns width)", uses: ["midbrain", "pons", "scp", "mcp", "v3", "fh"], digits: 2, cutDigits: 2, unit: "", marker: "PSP",
             about: "A PSP marker that adds third ventricle enlargement to the MRPI. Designed to separate PSP-P from PD. The original study did not include MSA; in a later 3 T study, the difference between PSP-P and MSA-P was not significant after correction for multiple comparisons ({Madetko 2022})." },
    mpa:   { name: "Midbrain/pons area ratio", formula: "midbrain area / pons area", uses: ["midbrain", "pons"], digits: 3, unit: "", marker: "PSP",
             about: "A PSP marker: it falls when the midbrain is atrophic relative to the pons. Values below the cutoff are associated with PSP." },
    md:    { name: "Midbrain anteroposterior diameter", formula: "midsagittal", digits: 2, unit: " mm", marker: "PSP",
             about: "A PSP marker: a short midbrain diameter indicates midbrain atrophy." },
    mdpd:  { name: "Midbrain/pons diameter ratio", formula: "midbrain diameter / pontine base diameter", uses: ["md", "pd"], digits: 2, unit: "", marker: "PSP",
             about: "A PSP marker: it falls when the midbrain is atrophic relative to the pons." },
    mcp:   { name: "Middle cerebellar peduncle width", formula: "mean of the right and left peduncles", digits: 1, cutDigits: 1, unit: " mm", marker: "MSA",
             about: "An MSA marker: narrowing indicates middle cerebellar peduncle atrophy, an MRI marker in the MDS 2022 MSA criteria; the criteria use visual assessment and do not specify the quantitative cutoff used here." }
  },

  // Measurements (form fields). "plausible" = wider than the ranges reported in the
  // published cohorts; a value outside it is flagged as a probable measurement/typing error.
  // "short" = name in warnings and in Copy result ("copy" replaces it in Copy result when given).
  measurements: {
    midbrain: { label: "Midbrain surface area (mm²)",                   short: "Midbrain area",                       unit: " mm²", min: 30,  max: 180, help: "area_mes_pon.webp" },
    pons:     { label: "Pons surface area (mm²)",                       short: "Pons area",                           unit: " mm²", min: 250, max: 800, help: "area_mes_pon.webp" },
    scp:      { label: "Width of superior cerebellar peduncles (mm)",   short: "Superior cerebellar peduncle width",  unit: " mm",  min: 1,   max: 6,   help: "picture_scp.webp" },
    mcp:      { label: "Width of middle cerebellar peduncles (mm)",     short: "Middle cerebellar peduncle width",    unit: " mm",  min: 3,   max: 15,  help: "picture_mcp.webp" },
    v3:       { label: "Width of the third ventricle V3 (mm), 3 measurements", short: "Third ventricle width (mean)", copy: "Third ventricle width", unit: " mm",  min: 1,   max: 20,  help: "picture_3v.webp" },
    fh:       { label: "Frontal horns width, maximal left-to-right (mm)", short: "Frontal horns width",                 unit: " mm",  min: 20,  max: 60,  help: "picture_fh.webp" },
    md:       { label: "Midbrain AP diameter, collicular plate excluded (mm)", short: "Midbrain AP diameter",                unit: " mm",  min: 5,   max: 14,  help: "help_diameters" },
    pd:       { label: "Pontine base AP diameter, tegmentum excluded (mm)", short: "Pontine base AP diameter",                    unit: " mm",  min: 10,  max: 25,  help: "help_diameters" }
  },
  v3Parts: ["Anterior", "Middle", "Posterior"],

  // The calculators, in the order shown (each has its own page/URL). "shows" = indices reported.
  calculators: [
    { slug: "midbrain-pons-ratio",  rail: "Midbrain/pons ratio", index: "mpa",   title: "Midbrain/Pons Ratio", inputs: ["midbrain", "pons"], shows: ["mpa"] },
    { slug: "mrpi",                 rail: "MRPI", index: "mrpi",  title: "MRPI (Magnetic Resonance Parkinsonism Index)", inputs: ["midbrain", "pons", "scp", "mcp"], shows: ["mrpi"] },
    { slug: "mrpi-2",               rail: "MRPI 2.0", index: "mrpi2", title: "MRPI 2.0", inputs: ["midbrain", "pons", "scp", "mcp", "v3", "fh"], shows: ["mrpi2"] },
    { slug: "diameter-ratio",       rail: "Midbrain/pons diameter ratio", index: "mdpd",  title: "Midbrain/Pons Diameter Ratio", inputs: ["md", "pd"], shows: ["md", "mdpd"] },
    { slug: "mcp-width",            rail: "MCP width", index: "mcp",   title: "Middle Cerebellar Peduncle Width", inputs: ["mcp"], shows: ["mcp"] }
  ],


  // How to measure: text shown with each example image (methods of the original papers)
  howto: {
    "area_mes_pon.webp": {
      title: "Midbrain and pons areas",
      steps: ["True midsagittal T1-weighted image (through the aqueduct and the interpeduncular cistern).",
              "Line A: through the superior pontine notch and the inferior edge of the quadrigeminal plate.",
              "Line B: parallel to line A, through the inferior pontine notch.",
              "Midbrain area: the delta-shaped midbrain tegmentum above line A, closed by line A; the tectum (quadrigeminal plate) is excluded.",
              "Pons area: between lines A and B, bounded by the anterior and posterior margins of the pons."],
      method: ["Quattrone 2008", "Oba 2005"] },
    "picture_scp.webp": {
      title: "Superior cerebellar peduncle (SCP) width",
      steps: ["Oblique coronal T1-weighted images, reformatted from a slab tangent to the floor of the fourth ventricle (red line).",
              "Starting view: the first image, moving anteroposteriorly, where the inferior colliculi and the SCPs are separated.",
              "Measure the distance between the medial and lateral borders of each SCP at the middle of its extension, on 3 consecutive sections.",
              "Enter the mean of both SCPs."],
      method: ["Quattrone 2008"] },
    "picture_mcp.webp": {
      title: "Middle cerebellar peduncle (MCP) width",
      steps: ["Parasagittal T1-weighted image that best shows the MCP between the pons and the cerebellum.",
              "Measure the distance between the superior and inferior borders of the MCP, delimited by the cerebrospinal fluid of the pontocerebellar cisterns.",
              "Measure left and right, and enter the mean."],
      method: ["Quattrone 2008", "Nicoletti 2006"] },
    "picture_3v.webp": {
      title: "Third ventricle width",
      steps: ["Axial T1-weighted image at the level of the anterior and posterior commissures.",
              "Measure the maximum distance between the lateral borders of the third ventricle at its anterior, middle and posterior parts.",
              "Enter the 3 measurements; Aurora uses the mean of those entered."],
      method: ["Quattrone 2018"] },
    "picture_fh.webp": {
      title: "Frontal horns width",
      steps: ["Axial T1-weighted image showing the maximal dilatation of the frontal horns.",
              "Measure the largest left-to-right width of the frontal horns."],
      method: ["Quattrone 2018"] },
    "help_diameters": {
      title: "Midbrain and pons anteroposterior diameters",
      image: null,
      steps: ["Midsagittal T1-weighted image.",
              "Place an elliptical region over the midbrain and another over the pons.",
              "Draw the long (oblique superior–inferior) axis of each ellipse, then measure the maximal diameter perpendicular to that axis.",
              "The midbrain measurement excludes the collicular plate; the pons measurement is the pontine base (pontine tegmentum excluded)."],
      method: ["Massey 2013"] }
  },

  // Abbreviations: listed under each result when they appear in it
  abbreviations: {
    "PSP":    "progressive supranuclear palsy",
    "PSP-RS": "progressive supranuclear palsy with Richardson’s syndrome",
    "PSP-P":  "progressive supranuclear palsy with predominant parkinsonism",
    "PD":     "Parkinson’s disease",
    "MSA":    "multiple system atrophy",
    "MSA-P":  "multiple system atrophy–parkinsonian type",
    "MSA-C":  "multiple system atrophy–cerebellar type",
    "MCP":    "middle cerebellar peduncle",
    "SCP":    "superior cerebellar peduncle",
    "MDS":    "International Parkinson and Movement Disorder Society",
    "MRI":    "magnetic resonance imaging",
    "T":      "tesla"
  },

  // Footnotes shown under every result
  notes: {
    pspAge: "Above 80 years, the reliability of published thresholds is uncertain: age-related midbrain atrophy can reduce specificity ({Chougar 2024}). MRPI is less affected by age than the midbrain/pons area ratio ({Morelli 2014}).",
    general: "Published cutoffs depend on method, field strength and cohort. They support imaging assessment but are not diagnostic in isolation."
  }
};
