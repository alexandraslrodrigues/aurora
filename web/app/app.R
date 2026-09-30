# LIBRARIES ---------------------------------------------------------------------
library(shiny)
library(bslib)
library(writexl)

# MOVEMENT CALCULATOR: published cutoffs ---------------------------------------
# One row per published cutoff. primary = TRUE marks the reference cutoff
# (original paper) shown first; the others are listed under "All published cutoffs".
# To update the literature, edit this table only.
movement_cutoffs <- data.frame(
  index = c("mrpi", "mrpi", "mrpi", "mrpi", "mrpi", "mrpi", "mrpi",
            "mrpi2", "mrpi2", "mrpi2",
            "mpa", "mpa", "mpa",
            "mida",
            "md", "md",
            "mdpd", "mdpd",
            "mcp", "mcp"),
  op = c(">=", ">=", ">", ">", "<", "<", "<",
         ">=", ">=", ">",
         "<", "<", "<",
         "<",
         "<", "<",
         "<", "<",
         "<=", "<"),
  value = c(13.55, 12.85, 15.62, 13.6, 11.14, 12.9, 12.3,
            2.18, 2.50, 2.5,
            0.18, 0.21, 0.22,
            98.1,
            9.35, 8.9,
            0.52, 0.54,
            8.0, 8.0),
  favours = c("PSP", "PSP", "PSP", "PSP", "MSA", "MSA-P", "MSA-C",
              "PSP-P", "PSP-RS", "PSP",
              "PSP", "PSP", "PSP",
              "PSP",
              "PSP", "PSP",
              "PSP", "PSP",
              "MSA", "MSA"),
  group = c("psp_pd", "psp_msap", "psp_pd", "psp_pd", "msa", "msa", "msa",
            "psp_pd", "psp_rs", "psp_pd",
            "psp", "psp", "psp",
            "psp",
            "psp", "psp",
            "psp", "psp",
            "msa", "msa"),
  versus = c("vs PD", "vs MSA-P", "vs non-PSP", "", "vs non-MSA", "", "",
             "vs PD", "vs PD", "vs PD",
             "vs non-PSP", "", "",
             "vs non-PSP",
             "vs MSA", "vs non-PSP",
             "vs MSA", "vs non-PSP",
             "vs PD", "vs non-MSA"),
  source = c("Quattrone 2008", "Quattrone 2008", "Mangesius 2018", "Chougar 2024 (reading grid)",
             "Mangesius 2018", "Chougar 2024 (reading grid)", "Chougar 2024 (reading grid)",
             "Quattrone 2018", "Quattrone 2018", "Chougar 2024 (reading grid)",
             "Mangesius 2018", "Peralta 2022 (MDS Neuroimaging Study Group)", "Chougar 2024 (reading grid)",
             "Mangesius 2018",
             "Massey 2013", "Mangesius 2018",
             "Massey 2013", "Mangesius 2018",
             "Nicoletti 2006", "Mangesius 2018"),
  note = c("1.5 T; sensitivity and specificity 100% in the original cohort", "1.5 T", "1.5 T", "",
           "1.5 T", "", "",
           "Sensitivity 100%, specificity 94.3%", "", "",
           "1.5 T; whole midbrain", "0.22 in the paper's Fig 1", "",
           "1.5 T",
           "Autopsy-confirmed PSP vs MSA; sensitivity 83%, specificity 100%", "1.5 T",
           "Autopsy-confirmed PSP vs MSA; sensitivity 67%, specificity 100%", "1.5 T",
           "1.5 T; mean MSA 6.1 mm vs PD 9.3 mm", "1.5 T"),
  # tested = cutoff derived and tested in the study (ROC analysis). FALSE for values quoted
  # from other studies or given as expected values (Chougar reading grid, Peralta review):
  # they are shown for information but do not drive the "Favours" label.
  tested = !grepl("reading grid|Peralta", c("Quattrone 2008", "Quattrone 2008", "Mangesius 2018", "Chougar 2024 (reading grid)",
             "Mangesius 2018", "Chougar 2024 (reading grid)", "Chougar 2024 (reading grid)",
             "Quattrone 2018", "Quattrone 2018", "Chougar 2024 (reading grid)",
             "Mangesius 2018", "Peralta 2022 (MDS Neuroimaging Study Group)", "Chougar 2024 (reading grid)",
             "Mangesius 2018",
             "Massey 2013", "Mangesius 2018",
             "Massey 2013", "Mangesius 2018",
             "Nicoletti 2006", "Mangesius 2018")),
  primary = c(TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
              TRUE, FALSE, FALSE,
              TRUE, FALSE, FALSE,
              TRUE,
              TRUE, FALSE,
              TRUE, FALSE,
              TRUE, FALSE),
  stringsAsFactors = FALSE
)

# DOI for each source (used to link the references in the calculator)
movement_dois <- c(
  "Quattrone 2008" = "10.1148/radiol.2453061703",
  "Quattrone 2018" = "10.1016/j.parkreldis.2018.07.016",
  "Mangesius 2018" = "10.1016/j.parkreldis.2017.10.020",
  "Chougar 2024"   = "10.1002/mds.29760",
  "Peralta 2022"   = "10.1002/mdc3.13354",
  "Massey 2013"    = "10.1212/WNL.0b013e318292a2d2",
  "Nicoletti 2006" = "10.1148/radiol.2393050459",
  "Whitwell 2017"  = "10.1002/mds.27038",
  "Oba 2005"       = "10.1212/01.WNL.0000165960.04422.D0"
)

# Source name as a link to its DOI (key = first two words, e.g. "Chougar 2024")
movement_source_link <- function(src) {
  key <- paste(strsplit(src, " ")[[1]][1:2], collapse = " ")
  doi <- movement_dois[key]
  if (is.na(doi)) return(src)
  as.character(tags$a(key, href = paste0("https://doi.org/", doi), target = "_blank", rel = "noopener",
                      style = "color: #553356;"))
}

movement_index_info <- list(
  mrpi  = list(name = "MRPI", formula = "(pons area / midbrain area) × (MCP width / SCP width)", digits = 2, unit = "", marker = "PSP",
               about = "A PSP marker: it rises with atrophy of the midbrain and superior cerebellar peduncles. Values above the cutoff are associated with PSP. Low values are found in PD and controls, and even lower values in MSA (pontine and middle cerebellar peduncle atrophy), with overlap between them.",
               low = list(op = "<", value = 11.14, source = "Mangesius 2018",
                          label = "Low MRPI",
                          text = "Nonspecific: overlaps with PD and controls; check the middle cerebellar peduncle width")),
  mrpi2 = list(name = "MRPI 2.0", formula = "MRPI × (third ventricle width / frontal horns width)", digits = 2, unit = "", marker = "PSP",
               about = "A PSP marker that adds third ventricle enlargement to the MRPI. Designed to separate PSP-P from PD. It has not been studied in MSA."),
  mpa   = list(name = "Midbrain/pons area ratio", formula = "midbrain area / pons area", digits = 3, unit = "", marker = "PSP",
               about = "A PSP marker: it falls when the midbrain is atrophic relative to the pons. Values below the cutoff are associated with PSP."),
  mida  = list(name = "Midbrain area", formula = "midsagittal", digits = 1, unit = " mm²", marker = "PSP",
               about = "A PSP marker: a small midbrain area indicates midbrain atrophy."),
  md    = list(name = "Midbrain anteroposterior diameter", formula = "midsagittal", digits = 1, unit = " mm", marker = "PSP",
               about = "A PSP marker: a short midbrain diameter indicates midbrain atrophy."),
  mdpd  = list(name = "Midbrain/pons diameter ratio", formula = "midbrain diameter / pons diameter", digits = 2, unit = "", marker = "PSP",
               about = "A PSP marker: it falls when the midbrain is atrophic relative to the pons."),
  mcp   = list(name = "Middle cerebellar peduncle width", formula = "middle cerebellar peduncle", digits = 1, unit = " mm", marker = "MSA",
               about = "An MSA marker: narrowing indicates middle cerebellar peduncle atrophy, an MRI marker in the MDS 2022 MSA criteria; the criteria use visual assessment and do not specify the quantitative cutoff used here.")
)

# Typical values in the reference groups of the original papers, so the user can
# see where a value sits (Quattrone 2008 reports medians; the others report means)
movement_typical <- list(
  mrpi  = list(vals = c("PSP" = 19.42, "PD" = 9.40, "MSA-P" = 6.53, "controls" = 9.21), stat = "median", src = "Quattrone 2008"),
  mrpi2 = list(vals = c("PSP-RS" = 5.23, "PSP-P" = 3.68, "PD" = 1.58, "controls" = 1.51), stat = "mean", src = "Quattrone 2018"),
  mpa   = list(vals = c("PSP" = 0.16, "PD" = 0.21, "MSA" = 0.27), stat = "mean", src = "Mangesius 2018"),
  mida  = list(vals = c("PSP" = 80.8, "PD" = 116.1, "MSA" = 107.7), stat = "mean", src = "Mangesius 2018"),
  md    = list(vals = c("PSP" = 7.8, "PD" = 10.2, "MSA" = 9.8), stat = "mean", src = "Mangesius 2018"),
  mdpd  = list(vals = c("PSP" = 0.47, "PD" = 0.60, "MSA" = 0.69), stat = "mean", src = "Mangesius 2018"),
  mcp   = list(vals = c("MSA" = 6.1, "PD" = 9.3, "controls" = 9.8), stat = "mean", src = "Nicoletti 2006")
)

# Plausible ranges for each measurement, wider than the ranges reported in the
# published cohorts (Quattrone 2008 and 2018, Mangesius 2018, Nicoletti 2006).
# A value outside them is flagged as a probable measurement or typing error.
movement_plausible <- list(
  input_midbrain_singlecalc = list(label = "Midbrain area", min = 30, max = 180, unit = " mm\u00b2"),
  input_pons                = list(label = "Pons area", min = 250, max = 800, unit = " mm\u00b2"),
  input_scp_singlecalc      = list(label = "Superior cerebellar peduncle width", min = 1, max = 6, unit = " mm"),
  input_mcp_singlecalc      = list(label = "Middle cerebellar peduncle width", min = 3, max = 15, unit = " mm"),
  input_v3_singlecalc       = list(label = "Third ventricle width (mean)", min = 1, max = 20, unit = " mm"),
  input_fh_singlecalc       = list(label = "Frontal horns width", min = 20, max = 60, unit = " mm"),
  input_md_singlecalc       = list(label = "Midbrain AP diameter", min = 5, max = 14, unit = " mm"),
  input_pd_singlecalc       = list(label = "Pons AP diameter", min = 10, max = 25, unit = " mm")
)

# Inputs used by each index
movement_inputs_for <- list(
  mpa   = c("input_midbrain_singlecalc", "input_pons"),
  mrpi  = c("input_midbrain_singlecalc", "input_pons", "input_scp_singlecalc", "input_mcp_singlecalc"),
  mrpi2 = c("input_midbrain_singlecalc", "input_pons", "input_scp_singlecalc", "input_mcp_singlecalc",
            "input_v3_singlecalc", "input_fh_singlecalc"),
  mdpd  = c("input_md_singlecalc", "input_pd_singlecalc"),
  mcp   = c("input_mcp_singlecalc")
)

# "PSP" + "vs PD and MSA" -> "PSP over PD and MSA"
movement_favours_text <- function(favours, versus) {
  if (nchar(versus) == 0) return(favours)
  paste(favours, versus)
}

movement_meets <- function(x, op, v) {
  switch(op, ">=" = x >= v, ">" = x > v, "<" = x < v, "<=" = x <= v)
}
movement_op_label <- function(op) {
  vapply(op, function(o) switch(o, ">=" = "≥", ">" = ">", "<" = "<", "<=" = "≤"), character(1), USE.NAMES = FALSE)
}
movement_cut_label <- function(cuts, unit = "") {
  paste0(trimws(paste(cuts$favours, cuts$versus)), " (", movement_op_label(cuts$op), " ", cuts$value, unit, "; ", cuts$source, ")")
}
movement_pill <- function(text, bg, fg) {
  tags$span(text, style = sprintf(
    "display:inline-block;padding:2px 10px;border-radius:999px;font-size:12px;font-weight:600;background:%s;color:%s;margin-left:8px;",
    bg, fg))
}

# Assess one index against all its published cutoffs.
movement_assess <- function(key, x) {
  info <- movement_index_info[[key]]
  cuts <- movement_cutoffs[movement_cutoffs$index == key, , drop = FALSE]
  cuts$met <- mapply(movement_meets, x, cuts$op, cuts$value)
  prim <- cuts[cuts$primary, , drop = FALSE][1, ]
  family <- substr(cuts$favours, 1, 3)
  same <- cuts[cuts$group == prim$group, , drop = FALSE]
  other_met <- cuts[cuts$group != prim$group & cuts$met &
                      !(prim$met & family == substr(prim$favours, 1, 3)), , drop = FALSE]
  u <- info$unit
  value_txt <- paste0(formatC(x, format = "f", digits = info$digits), info$unit)

  main <- paste0(if (prim$met) "Meets" else "Does not meet",
                 " the reference cutoff for ", movement_cut_label(prim, u), ".")
  disagree <- NULL
  opp <- same[!same$primary & same$met != prim$met, , drop = FALSE]
  if (nrow(opp) > 0) {
    disagree <- paste0("Other studies disagree: this value ",
                       if (prim$met) "would not meet" else "would meet",
                       " the cutoff of ",
                       paste0(opp$source, " (", movement_op_label(opp$op), " ", opp$value, u, ")", collapse = " and "),
                       ".")
  }
  other <- if (nrow(other_met) > 0) {
    paste0("Also meets the cutoff for ", movement_cut_label(other_met, u), ".")
  } else character(0)

  summary <- paste0(info$name, " ", value_txt, ": ",
                    if (prim$met) "meets" else "does not meet",
                    " the cutoff for ", movement_cut_label(prim, u),
                    if (!is.null(disagree)) "; other published cutoffs disagree at this value" else "",
                    ".",
                    if (length(other)) paste0(" ", paste(other, collapse = " ")) else "")

  # The label follows the reference cutoff only: each index is a marker of one disease
  low_met <- !is.null(info$low) && !prim$met && movement_meets(x, info$low$op, info$low$value)
  verdict <- paste(if (prim$met) "Meets" else "Does not meet", info$marker, "cutoff")
  verdict_family <- if (prim$met) info$marker else NA_character_
  list(key = key, info = info, value_txt = value_txt, cuts = cuts, prim = prim, opp = opp, other_met = other_met,
       verdict = verdict, verdict_met = !is.na(verdict_family), verdict_family = verdict_family, low_met = low_met,
       main = main, disagree = disagree, other = other, summary = summary)
}

# Third ventricle: Quattrone 2018 averaged three measurements (anterior, middle and
# posterior third ventricle, axial slice at the level of the AC and PC)
movement_input_v3 <- function(info_id) {
  small <- function(id, lab) tags$div(style = "width: 86px;",
    numericInput(id, tags$span(style = "font-weight: 400; font-size: 0.85em;", lab), value = NA, min = 0, max = 100, step = 0.1))
  fluidRow(
    tags$div(style = "width: 300px;",
      tags$label(class = "control-label", "Width of the third ventricle V3 (mm), 3 measurements"),
      tags$div(style = "display: flex; gap: 8px;",
               small("input_v3a_singlecalc", "Anterior"),
               small("input_v3b_singlecalc", "Middle"),
               small("input_v3c_singlecalc", "Posterior")),
      uiOutput("v3_mean_singlecalc")),
    actionButton(info_id, label = NULL, width = 60, icon = icon("circle-info"),
                 style = "border: none; background-color: transparent; box-shadow: none;")
  )
}

# How to measure: text shown with each example image (methods of the original papers)
movement_howto <- list(
  "area_mes_pon.webp" = list(
    title = "Midbrain and pons areas",
    steps = c("Midsagittal T1-weighted image.",
              "Line A: through the superior pontine notch and the inferior edge of the quadrigeminal plate.",
              "Line B: parallel to line A, through the inferior pontine notch.",
              "Midbrain area: traced around line A and the midbrain tegmentum above it.",
              "Pons area: between lines A and B, along the anterior and posterior margins of the pons."),
    method = c("Quattrone 2008", "Oba 2005")),
  "picture_scp.webp" = list(
    title = "Superior cerebellar peduncle (SCP) width",
    steps = c("Oblique coronal T1-weighted images, reformatted from a slab tangent to the floor of the fourth ventricle (red line).",
              "Starting view: the first image, moving anteroposteriorly, where the inferior colliculi and the SCPs are separated.",
              "Measure the distance between the medial and lateral borders of each SCP at the middle of its extension, on 3 consecutive sections.",
              "Enter the mean of both SCPs."),
    method = c("Quattrone 2008")),
  "picture_mcp.webp" = list(
    title = "Middle cerebellar peduncle (MCP) width",
    steps = c("Parasagittal T1-weighted image that best shows the MCP between the pons and the cerebellum.",
              "Measure the distance between the superior and inferior borders of the MCP, delimited by the cerebrospinal fluid of the pontocerebellar cisterns.",
              "Measure left and right, and enter the mean."),
    method = c("Quattrone 2008", "Nicoletti 2006")),
  "picture_3v.webp" = list(
    title = "Third ventricle width",
    steps = c("Axial T1-weighted image at the level of the anterior and posterior commissures.",
              "Measure the maximum distance between the lateral borders of the third ventricle at its anterior, middle and posterior parts.",
              "Enter the 3 measurements; Aurora uses their mean."),
    method = c("Quattrone 2018")),
  "picture_fh.webp" = list(
    title = "Frontal horns width",
    steps = c("Axial T1-weighted image showing the maximal dilatation of the frontal horns.",
              "Measure the largest left-to-right width of the frontal horns."),
    method = c("Quattrone 2018"))
)

# Abbreviations: listed under each result when they appear in it
movement_abbr <- c(
  "PSP"    = "progressive supranuclear palsy",
  "PSP-RS" = "progressive supranuclear palsy\u2013Richardson syndrome",
  "PSP-P"  = "progressive supranuclear palsy\u2013parkinsonism",
  "PD"     = "Parkinson\u2019s disease",
  "MSA"    = "multiple system atrophy",
  "MSA-P"  = "multiple system atrophy\u2013parkinsonian type",
  "MSA-C"  = "multiple system atrophy\u2013cerebellar type",
  "MCP"    = "middle cerebellar peduncle",
  "SCP"    = "superior cerebellar peduncle",
  "MDS"    = "International Parkinson and Movement Disorder Society",
  "MRI"    = "magnetic resonance imaging",
  "T"      = "tesla"
)
movement_abbr_line <- function(txt, exclude = character(0)) {
  txt <- paste(txt, collapse = " ")
  found <- vapply(names(movement_abbr), function(a) {
    pat <- if (a == "T") "\\d T\\b" else paste0("(?<![A-Za-z0-9-])", gsub("-", "\\\\-", a), "(?![A-Za-z])(?!-[A-Z])")
    grepl(pat, txt, perl = TRUE)
  }, logical(1))
  found[names(movement_abbr) %in% exclude] <- FALSE
  if (!any(found)) return(NULL)
  out <- paste0(names(movement_abbr)[found], ", ", movement_abbr[found], collapse = "; ")
  attr(out, "abbr") <- names(movement_abbr)[found]
  out
}

movement_input <- function(id, label, info_id) {
  fluidRow(
    numericInput(id, label, value = NA, min = 0, max = 1000, step = 0.1),
    actionButton(info_id, label = NULL, width = 60, icon = icon("circle-info"),
                 style = "border: none; background-color: transparent; box-shadow: none;")
  )
}

# INTERFACE ---------------------------------------------------------------------
## INTRO -------------------------------------------------
# Define UI for application that draws a histogram
ui <- tagList(
  
  # Add this custom spinner div ABOVE the UI
  tags$div(class = "shiny-load-container",
           tags$div(class = "spinner",
                    tags$div(class = "dot1"),
                    tags$div(class = "dot2")
           )
  ),
  
page_navbar(
  # Shinylive: make "Export to Excel" download reliably in the browser
  tags$script(HTML("
$(document).on('click', 'a.shiny-download-link', function(e){
  e.preventDefault(); e.stopImmediatePropagation();
  var a = this;
  fetch(a.href).then(function(r){
    var cd = r.headers.get('Content-Disposition') || '';
    var m = /filename\\*?=(?:UTF-8'')?\"?([^\";]+)\"?/i.exec(cd);
    var name = m ? decodeURIComponent(m[1]) : 'download';
    return r.blob().then(function(b){
      var u = URL.createObjectURL(b);
      var l = document.createElement('a');
      l.href = u; l.download = name;
      document.body.appendChild(l); l.click();
      setTimeout(function(){ URL.revokeObjectURL(u); l.remove(); }, 2000);
    });
  });
});
")),
  
  id = "tabs",
  underline = FALSE,
  collapsible = TRUE,
  window_title = "aurora",
  
  title = actionLink("home_link", "aurora"),
  
  theme = bs_theme(
    version = 5,
    # bootswatch = "flatly",
    # primary = "#4e5678",
    primary = "#676971",
    # secondary = "#5bc0de",
    # light = "#f7f7f7",
    # dark = "#333333",
    # success = "#5cb85c",
    # info = "#5bc0de",
    # warning = "#f0ad4e",
    # danger = "#d9534f",
    # color = "#ffffff"
    base_font = font_collection("Inter", "system-ui", "-apple-system", "Segoe UI", "Roboto", "Helvetica Neue", "Arial", "sans-serif")
  ),
  
  # # Include the favicon in the head of the document
  tags$head(
    tags$link(rel = "icon", type = "image/png", href = "picture_auroraicon.png"),
    tags$link(rel = "stylesheet", type = "text/css", href = "spinner.css"),
    # Inter font bundled with the app (no Google Fonts request)
    tags$style(HTML("
    @font-face { font-family: 'Inter'; font-style: normal; font-display: swap; font-weight: 100 900;
      src: url('fonts/inter-latin-ext-wght-normal.woff2') format('woff2');
      unicode-range: U+0100-02BA,U+02BD-02C5,U+02C7-02CC,U+02CE-02D7,U+02DD-02FF,U+0304,U+0308,U+0329,U+1D00-1DBF,U+1E00-1E9F,U+1EF2-1EFF,U+2020,U+20A0-20AB,U+20AD-20C0,U+2113,U+2C60-2C7F,U+A720-A7FF; }
    @font-face { font-family: 'Inter'; font-style: normal; font-display: swap; font-weight: 100 900;
      src: url('fonts/inter-latin-wght-normal.woff2') format('woff2');
      unicode-range: U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD; }
    ")),
    
    tags$style(HTML("
    #home_link {
      text-decoration: none !important;
      color: #676971;
      font-family: helvetica;
      font-size: 40px;
      font-weight: bold;
      letter-spacing: -3px;
      cursor: pointer;
    }
  ")),
    
    tags$script(HTML("
  $(document).on('shiny:connected', function() {
    $('.shiny-load-container').remove();
  });
")),
    
    # Report: Left/Right arrow keys go to the previous/next section
    # (not while typing in a field, and only on the Report page)
    tags$script(HTML("
  $(document).on('keydown', function(e) {
    if (e.key !== 'ArrowLeft' && e.key !== 'ArrowRight') return;
    if (e.altKey || e.ctrlKey || e.metaKey || e.shiftKey) return;
    var t = e.target, tag = ((t && t.tagName) || '').toLowerCase();
    if (tag === 'input' || tag === 'textarea' || tag === 'select' || (t && t.isContentEditable)) return;
    if (!$('#prev_report').is(':visible')) return;
    $(e.key === 'ArrowLeft' ? '#prev_report' : '#next_report').trigger('click');
  });
")),
    
    # Google Analytics scripts:
    HTML("
    <!-- Google tag (gtag.js) -->
    <script async src='https://www.googletagmanager.com/gtag/js?id=G-K8VCNK1TLC'></script>
    <script>
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
      gtag('config', 'G-K8VCNK1TLC');
    </script>
  ")
  ),
  
  tags$style(HTML("
  /* Right-align the tab titles in pill navigation */
  .nav-pills .nav-link {
    text-align: left !important;
  }
  .nav-pills .nav-item {
    width: 100%;
  }
")),
  
  tags$script(HTML(
    "$(document).on('click', '#home_link', function(){
      $('#tabs a[data-value=\"Home\"]').tab('show');
    });"
  )),
  

  nav_panel_hidden(
    "Home",
    
    div(
      class = "d-flex flex-column justify-content-center align-items-center",
      style = "min-height: 80vh;",
      
      tags$div(
        class = "d-flex justify-content-center align-items-center",
        style = "text-align: center;",
        
        # Icon on the left
        tags$img(src = "picture_auroraicon.png", style = "height: 60px; margin-right: 20px;"),
        
        # Title "aurora"
        tags$h1(
          tags$span(HTML("aurora&nbsp;&thinsp;&thinsp;&thinsp;"), style = "font-family: helvetica; font-size: 60px; font-weight: bold; letter-spacing: -3px; margin-right: 40px;")
        )
      ),
      
      tags$div(style = "padding-top: 5px;"),
      
      div(
        class = "welcome-message",
        style = "max-width: 700px; text-align: center;",
        p("clear reports, brighter outcomes"),
      ),
      
      tags$div(style = "padding-top: 30px;"),
      
      actionButton("report",
                   "Create an Aurora Report",
                   width = "400"),
      
      tags$div(style = "padding-top: 15px;"),
      
      actionButton("atrophy_calculator", "Use the Atrophy Calculator",
                   width = "400"),
      
      tags$div(style = "padding-top: 15px;"),
      
      actionButton("movement_calculator", "Use the Movement Calculator",
                   width = "400")
    )
  ),
  
  ## REPORT ------------------------
  nav_panel_hidden ("Report",
                    
                    # Hidden tabsetPanel (no visible headers)
                    tabsetPanel(id = "tabs_report", type = "hidden",
                                
                                
                                ### IDENTIFICATION -------------
                                
                                tabPanel(
                                  title = "Identification",
                                  value = "tab_identification",
                                  card(
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("identification_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;", 
                                          "Identification"
                                        )
                                      )
                                    ),
                                    card_body(
                                      selectInput("input_sex", "Sex of the patient", choices = c("Female", "Male", "NA")),
                                      numericInput("input_age", "Age of the patient", value = NA, min = 0, max = 100, step = 1)
                                    )
                                    
                                    # checkboxGroupInput(
                                    #   "clinical_symptoms",
                                    #   "Clinical symptoms:",
                                    #   choices = c("Dementia", "Movement disorder", "Other/NA")
                                    # )
                                  )
                                ),
                                
                                
                                
                                ### SMALL VESSEL DISEASE -------------------------------------------------
                                
                                #### RECENT SMALL SUBCORTICAL INFARCT -------------
                                
                                tabPanel(
                                  title = "Recent Small Subcortical Infarcts",
                                  value = "tab_recent_small_infarcts",      
                                  card(
                                    full_screen = FALSE,  
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("rsi_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",   # Text aligned left & centered vertically
                                          "Recent Small Subcortical Infarcts"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;", 
                                      fluidRow(
                                        column(5,
                                               selectizeInput(
                                                 "recentsmallinfarct", "Select all recent small subcortical infarcts",
                                                 choices = list(
                                                   "Supra-Tentorial" = c(
                                                     "Centrum semiovale - Frontal - Right",
                                                     "Centrum semiovale - Frontal - Left",
                                                     "Centrum semiovale - Parietal - Right",
                                                     "Centrum semiovale - Parietal - Left",
                                                     
                                                     "Corona radiata - Frontal - Right",
                                                     "Corona radiata - Frontal - Left",
                                                     "Corona radiata - Parietal - Right",
                                                     "Corona radiata - Parietal - Left",
                                                     
                                                     "Caudate nucleus - Right",
                                                     "Caudate nucleus - Left",
                                                     
                                                     "External capsule - Right",
                                                     "External capsule - Left",
                                                     
                                                     "Internal capsule - Anterior limb - Right",
                                                     "Internal capsule - Anterior limb - Left",
                                                     "Internal capsule - Genu - Right",
                                                     "Internal capsule - Genu - Left",
                                                     "Internal capsule - Posterior limb - Right",
                                                     "Internal capsule - Posterior limb - Left",
                                                     
                                                     "Lentiform nucleus - Right",
                                                     "Lentiform nucleus - Left",
                                                     
                                                     "Thalamus - Anterior - Right",
                                                     "Thalamus - Anterior - Left",
                                                     "Thalamus - Lateral - Right",
                                                     "Thalamus - Lateral - Left",
                                                     "Thalamus - Medial - Right",
                                                     "Thalamus - Medial - Left",
                                                     "Thalamus - Posterior - Right",
                                                     "Thalamus - Posterior - Left",
                                                     "Cerebral peduncle - Right",
                                                     "Cerebral peduncle - Left"
                                                   ), 
                                                   "Brainstem" = c(
                                                     "Midbrain - Crus cerebri - Right",
                                                     "Midbrain - Crus cerebri - Left",
                                                     "Midbrain - Tegmentum - Right",
                                                     "Midbrain - Tegmentum - Central",
                                                     "Midbrain - Tegmentum - Left",
                                                     "Midbrain - Tectum - Right",
                                                     "Midbrain - Tectum - Midline",
                                                     "Midbrain - Tectum - Left",
                                                     
                                                     "Pons - Basis - Right",
                                                     "Pons - Basis - Midline",
                                                     "Pons - Basis - Left",
                                                     "Pons - Tegmentum - Right",
                                                     "Pons - Tegmentum - Midline",
                                                     "Pons - Tegmentum - Left",
                                                     
                                                     "Medulla - Anterior - Right",
                                                     "Medulla - Anterior - Left",
                                                     "Medulla - Posterior - Right",
                                                     "Medulla - Posterior - Left"
                                                   ),
                                                   "Cerebellum" = c(
                                                     "Cerebellum - Right",
                                                     "Cerebellum - Left"
                                                   )
                                                 ),
                                                 multiple = TRUE,
                                                 options = list(placeholder = 'Search and select recent small subcortical infarcts'),
                                                 width = "90%"
                                               )
                                        ),
                                        column(
                                          width = 7, 
                                          card(
                                            full_screen = TRUE,
                                            card_body(
                                              style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                              
                                              tags$h6(
                                                class = "d-flex align-items-center",
                                                icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                tags$strong("Definition")
                                              ),
                                              
                                              tags$img(src = "picture_rsi.webp", height = "auto", width = "100%"),
                                              
                                              tags$p(
                                                "An acute infarct in the territory of a single perforating artery, as seen in MR DWI, typically associated with a corresponding focal neurological deficit. ",
                                                "The term small refers to a lesion less than 20 mm in maximum axial diameter (axial plane), though infarcts may appear slightly larger on coronal imaging. ",
                                                "No lower size limit is specified, as DWI allows distinction of very small infarcts from perivascular spaces."
                                              ),
                                              
                                              tags$p("Exclusions - do not classify as small subcortical infarcts:"),
                                              tags$ul(
                                                tags$li("Lesions >20 mm in the basal ganglia/internal capsule due to multiple penetrating arteries (striatocapsular infarcts)."),
                                                tags$li("Anterior choroidal artery infarcts (aetiologically distinct); identified by location (caudate head) and comma shape.")
                                              ),
                                              
                                              tags$div(
                                                style = "font-size: 0.85em; color: #555;",
                                                tags$p(
                                                  "Figure adapted from: Mahammedi, A. et al. (2022). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.3174/ajnr.A7302",
                                                    "Small Vessel Disease, a Marker of Brain Health: What the Radiologist Needs to Know. American Journal of Neuroradiology, 43, 650–660.",
                                                    target = "_blank"
                                                  ),
                                                  " Licensed under ",
                                                  tags$a(
                                                    href = "http://creativecommons.org/licenses/by/4.0/",
                                                    "CC BY 4.0",
                                                    target = "_blank"
                                                  ),
                                                  "."
                                                ),
                                                tags$p(
                                                  "Text adapted from: Duering, M. et al. (2023). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.1016/s1474-4422(23)00131-x",
                                                    "Neuroimaging standards for research into small vessel disease—advances since 2013.",
                                                    target = "_blank"
                                                  ),
                                                  " The Lancet Neurology."
                                                )
                                              )
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                ),             
                                
                                
                                #### LACUNAR INFARCTS -------------------------------------------------    
                                
                                tabPanel(
                                  title = "Lacunes of Presumed Vascular Origin",
                                  value = "tab_svd_lacunes",
                                  card(
                                    full_screen = FALSE,  
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("li_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;", 
                                          "Lacunes of Presumed Vascular Origin"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;", 
                                      fluidRow(
                                        column(5,
                                               selectizeInput(
                                                 "lacunar_infarcts","Select all lacunar infarcts",
                                                 choices = list(
                                                   "Supra-Tentorial" = c(
                                                     "Centrum semiovale - Frontal - Right",
                                                     "Centrum semiovale - Frontal - Left",
                                                     "Centrum semiovale - Parietal - Right",
                                                     "Centrum semiovale - Parietal - Left",
                                                     
                                                     "Corona radiata - Frontal - Right",
                                                     "Corona radiata - Frontal - Left",
                                                     "Corona radiata - Parietal - Right",
                                                     "Corona radiata - Parietal - Left",
                                                     
                                                     "Caudate nucleus - Right",
                                                     "Caudate nucleus - Left",
                                                     
                                                     "External capsule - Right",
                                                     "External capsule - Left",
                                                     
                                                     "Internal capsule - Anterior limb - Right",
                                                     "Internal capsule - Anterior limb - Left",
                                                     "Internal capsule - Genu - Right",
                                                     "Internal capsule - Genu - Left",
                                                     "Internal capsule - Posterior limb - Right",
                                                     "Internal capsule - Posterior limb - Left",
                                                     
                                                     "Lentiform nucleus - Right",
                                                     "Lentiform nucleus - Left",
                                                     
                                                     "Thalamus - Anterior - Right",
                                                     "Thalamus - Anterior - Left",
                                                     "Thalamus - Lateral - Right",
                                                     "Thalamus - Lateral - Left",
                                                     "Thalamus - Medial - Right",
                                                     "Thalamus - Medial - Left",
                                                     "Thalamus - Posterior - Right",
                                                     "Thalamus - Posterior - Left",
                                                     "Cerebral peduncle - Right",
                                                     "Cerebral peduncle - Left"
                                                   ),
                                                   "Brainstem" = c(
                                                     "Midbrain - Crus cerebri - Right",
                                                     "Midbrain - Crus cerebri - Left",
                                                     "Midbrain - Tegmentum - Right",
                                                     "Midbrain - Tegmentum - Central",
                                                     "Midbrain - Tegmentum - Left",
                                                     "Midbrain - Tectum - Right",
                                                     "Midbrain - Tectum - Midline",
                                                     "Midbrain - Tectum - Left",
                                                     
                                                     "Pons - Basis - Right",
                                                     "Pons - Basis - Midline",
                                                     "Pons - Basis - Left",
                                                     "Pons - Tegmentum - Right",
                                                     "Pons - Tegmentum - Midline",
                                                     "Pons - Tegmentum - Left",
                                                     
                                                     "Medulla - Anterior - Right",
                                                     "Medulla - Anterior - Left",
                                                     "Medulla - Posterior - Right",
                                                     "Medulla - Posterior - Left"
                                                   ),
                                                   "Cerebellum" = c(
                                                     "Cerebellum - Right",
                                                     "Cerebellum - Left"
                                                   )
                                                 ),
                                                 multiple = TRUE,
                                                 options = list(placeholder = 'Search and select lacunar infarcts'),
                                                 width = "90%"
                                               )
                                        ),
                                        column(
                                          width = 7, 
                                          card(
                                            full_screen = TRUE,
                                            card_body(
                                              style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                              
                                              tags$h6(
                                                class = "d-flex align-items-center",
                                                icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                tags$strong("Definition")
                                              ),
                                              
                                              tags$img(src = "picture_li.webp", height = "auto", width = "100%"),
                                              
                                              tags$p(
                                                "Lacunes of presumed vascular origin are round or ovoid, fluid-filled cavities in the subcortical region that mirror cerebrospinal fluid signal. They typically measure 3–15 mm, although smaller (<3 mm) cavities may represent recent small subcortical infarcts."
                                              ),
                                              tags$p(
                                                "Differentiation from enlarged perivascular spaces can be challenging, as both can be similar in size and may lack a hyperintense T2 rim. Consider cavity shape, the presence of adjacent perivascular spaces, and signal changes in surrounding tissue to improve specificity."
                                              ),
                                              tags$p(
                                                "Lacunes may arise from small subcortical infarcts, small subcortical haemorrhages, incidental DWI-positive lesions, or represent end-stage cavitation within a white matter hyperintensity."
                                              ),
                                              
                                              tags$div(
                                                style = "font-size: 0.85em; color: #555;",
                                                
                                                tags$p(
                                                  "Figure adapted from: Mahammedi, A. et al. (2022). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.3174/ajnr.A7302",
                                                    "Small Vessel Disease, a Marker of Brain Health: What the Radiologist Needs to Know. American Journal of Neuroradiology, 43, 650–660.",
                                                    target = "_blank"
                                                  ),
                                                  " Licensed under ",
                                                  tags$a(
                                                    href = "http://creativecommons.org/licenses/by/4.0/",
                                                    "CC BY 4.0",
                                                    target = "_blank"
                                                  ),
                                                  "."
                                                ),
                                                
                                                tags$p(
                                                  "Text adapted from: Duering, M. et al. (2023). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.1016/S1474-4422(23)00131-X",
                                                    "Neuroimaging standards for research into small vessel disease—advances since 2013.",
                                                    target = "_blank"
                                                  ),
                                                  " The Lancet Neurology."
                                                )
                                              )
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                ),
                                
                                #### FAZEKAS ------------------------------------------------- 
                                
                                tabPanel(
                                  title = "White Matter Hyperintensities of Presumed Vascular Origin",
                                  value = "fazekas_chk",
                                  card(
                                    full_screen = FALSE,  
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("fazekas_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",   # Text aligned left & centered vertically
                                          "White Matter Hyperintensities of Presumed Vascular Origin"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;", 
                                      fluidRow(
                                        column(6,
                                               fluidRow(
                                                 column(6,
                                                        card(
                                                          style = "height: 400px; overflow-y: auto;",
                                                          selectInput("periventricular_grade", "Periventricular White Matter", 
                                                                      choices = c("0 = absent", "1 = “caps” or pencil-thin lining", "2 = smooth “halo”", "3 = irregular periventricular signal extending into the deep white matter")),
                                                          conditionalPanel(
                                                            condition = "input.periventricular_grade != '0 = absent'", 
                                                            selectInput("periventricular_distribution", "Predominant Distribution", 
                                                                        choices = c("diffuse", "frontal", "occipital", "temporal", "peri-atrial"))
                                                          ),
                                                          conditionalPanel(
                                                            condition = "input.periventricular_grade != '0 = absent'",
                                                            selectInput("periventricular_laterality", "Laterality", 
                                                                        choices = c("bilateral", "right", "left"))
                                                          )
                                                        )
                                                 ),
                                                 column(6,
                                                        card(
                                                          style = "height: 400px; overflow-y: auto;",
                                                          selectInput("deep_white_matter_grade", "Deep White Matter", 
                                                                      choices = c("0 = absent", "1 = punctate foci", "2 = beginning confluence", "3 = large confluent areas")),
                                                          conditionalPanel(
                                                            condition = "input.deep_white_matter_grade != '0 = absent'", 
                                                            selectInput("deep_white_matter_distribution", "Predominant Distribution", 
                                                                        choices = c("diffuse", "centrum semiovale", "corona radiata"))
                                                          ),
                                                          conditionalPanel (
                                                            condition = "input.deep_white_matter_grade != '0 = absent'",
                                                            selectInput("deep_white_matter_laterality", "Laterality", 
                                                                        choices = c("bilateral", "right", "left"))
                                                          )
                                                        )
                                                 )
                                               )
                                        ),
                                        column(
                                          width = 6,
                                          card(
                                            full_screen = TRUE,
                                            card_body(
                                              style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                              
                                              tags$h6(
                                                class = "d-flex align-items-center",
                                                icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                tags$strong("Fazekas Scale")
                                              ),
                                              
                                              tags$img(src = "picture_fazekas.webp", height = "auto", width = "100%"),
                                              
                                              tags$p(
                                                "White matter hyperintensities of presumed vascular origin are characterized by hyperintense lesions on T2 FLAIR and decreased attenuation on CT in the periventricular/deep cerebral white matter, subcortical gray matter, basal ganglia, and brainstem."
                                              ),
                                              
                                              tags$div(
                                                style = "font-size: 0.85em; color: #555;",
                                                
                                                tags$p(
                                                  "Figure adapted from: Mahammedi, A. et al. (2022). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.3174/ajnr.A7302",
                                                    "Small Vessel Disease, a Marker of Brain Health: What the Radiologist Needs to Know. American Journal of Neuroradiology, 43, 650–660.",
                                                    target = "_blank"
                                                  ),
                                                  " © 2022 by American Journal of Neuroradiology. Open access to non-subscribers at ",
                                                  tags$a(href = "https://www.ajnr.org", "www.ajnr.org", target = "_blank"),
                                                  "."
                                                ),
                                                
                                                tags$p(
                                                  "Scale adapted from: Fazekas, F., Chawluk, J., Alavi, A., Hurtig, H. & Zimmerman, R. (1987). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.2214/ajr.149.2.3",
                                                    "MR signal abnormalities at 1.5 T in Alzheimer’s dementia and normal aging. American Journal of Roentgenology, 149, 351–356.",
                                                    target = "_blank"
                                                  )
                                                )
                                              )
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                ),
                                
                                
                                #### PVS ------------------------------------------
                                
                                tabPanel(
                                  title = "Perivascular Spaces",
                                  value = "pvs_chk",
                                  card(
                                    full_screen = FALSE,  
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("pvs_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",  # Text aligned left & centered vertically
                                          "Perivascular Spaces"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;", 
                                      fluidRow(
                                        column(6,
                                               fluidRow(
                                                 column(6,
                                                        selectInput("pvs_centrum_semiovale", "Centra Semiovalia", 
                                                                    choices = c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40"))
                                                 ),
                                                 column(6,
                                                        selectInput("pvs_basal_ganglia", "Basal Ganglia", 
                                                                    choices = c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40"))
                                                 )
                                               ),
                                               fluidRow(
                                                 column(6,
                                                        selectInput("pvs_mesencephalon", "Mesencephalon", 
                                                                    choices = c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40"))
                                                 )
                                               )
                                        ),
                                        column(
                                          width = 6,
                                          card(
                                            full_screen = TRUE,
                                            card_body(
                                              style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                              
                                              tags$h6(
                                                class = "d-flex align-items-center",
                                                icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                tags$strong("The Enlarged Perivascular Spaces Scale")
                                              ),
                                              
                                              tags$img(src = "picture_pvs.webp", height = "auto", width = "100%"),
                                              tags$img(src = "picture_pvs_2.webp", height = "auto", width = "100%"),
                                              
                                              tags$div(
                                                style = "text-align: justify; margin-top: 10px;",
                                                tags$p(
                                                  "Severe perivascular spaces (PVS) are demonstrated in the basal ganglia and centrum semiovale (Figure 1), with additional PVS visible in the midbrain (arrowheads). ",
                                                  "In Figure 2, the spectrum of PVS burden is illustrated: panel (a) shows grade 4 (severe) PVS in the centrum semiovale; panel (b) displays grade 2 involvement in the basal ganglia; and panel (c) highlights grade 1 (mild) PVS in the midbrain, also indicated by arrowheads."
                                                )
                                              ),
                                              
                                              tags$div(
                                                style = "font-size: 0.85em; color: #555; margin-top: 15px;",
                                                tags$p(
                                                  "Adapted from: Potter, G. M., Chappell, F. M., Morris, Z., & Wardlaw, J. M. (2015). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.1159/000375153",
                                                    "Cerebrovascular Diseases, 39(4), 224–231.",
                                                    target = "_blank"
                                                  ),
                                                  " Licensed under ",
                                                  tags$a(
                                                    href = "https://creativecommons.org/licenses/by/3.0/",
                                                    "CC BY 3.0",
                                                    target = "_blank"
                                                  ),
                                                  "."
                                                )
                                              )
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                ),
                                
                                
                                #### MICROBLEEDS ------------------------------------------------- 
                                
                                tabPanel(
                                  title = "Microbleeds",
                                  value = "microbleeds_chk",
                                  card(
                                    full_screen = FALSE,
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",
                                        tags$div(
                                          style = "flex: none; width: 35px;",
                                          input_switch("mb_switch", label = NULL, value = TRUE)
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",
                                          "Microbleeds"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;",
                                      fluidRow(
                                        column(7,
                                               fluidRow(
                                                 tags$style(HTML("
        .definite-columns {
  background-color: #ffffff; /* Pure white */
}

.possible-columns {
  background-color: rgba(85, 51, 86, 0.05); /* Soft tint of #553356 */
}
              ")),
                                                 column(4, ""),
                                                 column(4, tags$h5("Definite"), align = "center", class = "definite-columns"),
                                                 column(4, tags$h5("Possible"), align = "center", class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, ""),
                                                 column(2, "Right", align = "center", class = "definite-columns"),
                                                 column(2, "Left", align = "center", class = "definite-columns"),
                                                 column(2, "Right", align = "center", class = "possible-columns"),
                                                 column(2, "Left", align = "center", class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Brainstem", style = "background-color: rgba(161, 203, 149, 0.1);"),
                                                 column(2, numericInput("brainstem_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("brainstem_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("brainstem_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("brainstem_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Cerebellum", style = "background-color: rgba(161, 203, 149, 0.1);"),
                                                 column(2, numericInput("cerebellum_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("cerebellum_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("cerebellum_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("cerebellum_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Basal Ganglia", style = "background-color: rgba(229, 245, 217, 0.1);"),
                                                 column(2, numericInput("basal_ganglia_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("basal_ganglia_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("basal_ganglia_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("basal_ganglia_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Thalamus", style = "background-color: rgba(229, 245, 217, 0.1);"),
                                                 column(2, numericInput("thalamus_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("thalamus_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("thalamus_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("thalamus_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Internal Capsule", style = "background-color: rgba(229, 245, 217, 0.1);"),
                                                 column(2, numericInput("internal_capsule_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("internal_capsule_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("internal_capsule_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("internal_capsule_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "External Capsule", style = "background-color: rgba(229, 245, 217, 0.1);"),
                                                 column(2, numericInput("external_capsule_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("external_capsule_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("external_capsule_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("external_capsule_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Corpus Callosum", style = "background-color: rgba(229, 245, 217, 0.1);"),
                                                 column(2, numericInput("corpus_callosum_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("corpus_callosum_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("corpus_callosum_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("corpus_callosum_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Deep/PV White Matter*", style = "background-color: rgba(229, 245, 217, 0.1);"),
                                                 column(2, numericInput("deep_pvwhite_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("deep_pvwhite_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("deep_pvwhite_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("deep_pvwhite_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Frontal", style = "background-color: #ffffff;"),
                                                 column(2, numericInput("frontal_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("frontal_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("frontal_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("frontal_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Parietal", style = "background-color: #ffffff;"),
                                                 column(2, numericInput("parietal_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("parietal_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("parietal_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("parietal_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Temporal", style = "background-color: #ffffff;"),
                                                 column(2, numericInput("temporal_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("temporal_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("temporal_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2,numericInput("temporal_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Occipital", style = "background-color: #ffffff;"),
                                                 column(2, numericInput("occipital_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("occipital_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("occipital_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("occipital_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               ),
                                               fluidRow(
                                                 column(4, "Insula", style = "background-color: #ffffff;"),
                                                 column(2, numericInput("insula_definite_right", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("insula_definite_left", NULL, value = 0, min = 0, width = "100%"), class = "definite-columns"),
                                                 column(2, numericInput("insula_possible_right", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns"),
                                                 column(2, numericInput("insula_possible_left", NULL, value = 0, min = 0, width = "100%"), class = "possible-columns")
                                               )
                                        ),
                                        column(5,
                                               card(
                                                 full_screen = TRUE,
                                                 card_body(
                                                   style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                                   
                                                   tags$h6(
                                                     class = "d-flex align-items-center",
                                                     icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                     tags$strong("Microbleed Anatomical Rating Scale (MARS)")
                                                   ),
                                                   
                                                   tags$p(
                                                     "Cerebral microbleeds are small, chronic brain hemorrhages visible as focal, round, hypointense lesions on T2*-GRE or SWI sequences, reflecting hemosiderin deposits due to vascular leakage. The Microbleed Anatomical Rating Scale (MARS) provides a standardized approach for categorizing microbleeds by anatomical location and imaging characteristics."
                                                   ),
                                                   
                                                   tags$ul(
                                                     tags$li("Lobar: cortical and subcortical regions, including subcortical U-fibers."),
                                                     tags$li("Deep: basal ganglia, thalamus, internal capsule, external capsule, corpus callosum, and deep/periventricular white matter (within approximately 10 mm of the lateral ventricles)."),
                                                     tags$li("Infratentorial: brainstem and cerebellum.")
                                                   ),
                                                   
                                                   tags$p("Imaging classification (GRE T2*-weighted):"),
                                                   tags$ul(
                                                     tags$li("Definite microbleeds: small (2–10 mm), round or circular, well-defined hypointense lesions."),
                                                     tags$li("Possible microbleeds: less well-defined, less hypointense, or not strictly rounded.")
                                                   ),
                                                   
                                                   tags$div(
                                                     style = "font-size: 0.85em; color: #555;",
                                                     tags$p(
                                                       "Adapted from: Gregoire, S. M. et al. (2009). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1212/WNL.0b013e3181c34a7d",
                                                         "The Microbleed Anatomical Rating Scale (MARS). Neurology, 73, 1759–1766.",
                                                         target = "_blank"
                                                       )
                                                     )
                                                   )
                                                 )
                                               )
                                        )
                                      )
                                    )
                                  )
                                ),
                                
                                #### SUPERFICIAL SIDEROSIS ----------------------------------
                                
                                tabPanel(
                                  title = "Superficial Siderosis",
                                  value = "superficial_siderosis_chk",
                                  card(
                                    full_screen = FALSE,  
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("css_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",   # Text aligned left & centered vertically
                                          "Superficial Siderosis"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;", 
                                      fluidRow(
                                        column(6,
                                               selectizeInput(
                                                 "superficial_siderosis_right",
                                                 "Right Hemisphere",
                                                 choices = list(
                                                   "0: none" = 0,
                                                   "1: 1 sulcus or up to 3 immediately adjacent sulci with cSS" = 1,
                                                   "2: 2 or more nonadjacent sulci or more than 3 adjacent sulci with cSS" = 2
                                                 ), width = "100%"
                                               ),
                                               selectizeInput(
                                                 "superficial_siderosis_left",
                                                 "Left Hemisphere",
                                                 choices = list(
                                                   "0: none" = 0,
                                                   "1: 1 sulcus or up to 3 immediately adjacent sulci with cSS" = 1,
                                                   "2: 2 or more nonadjacent sulci or more than 3 adjacent sulci with cSS" = 2
                                                 ), width = "100%"
                                               )
                                        ),
                                        column(
                                          width = 6,
                                          card(
                                            full_screen = TRUE,
                                            card_body(
                                              style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                              
                                              tags$h6(
                                                class = "d-flex align-items-center",
                                                icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                tags$strong("Cortical Superficial Siderosis Multifocality Rating Scale")
                                              ),
                                              
                                              tags$img(src = "picture_ss.webp", height = "auto", width = "100%"),
                                              
                                              tags$p(
                                                "Cortical superficial siderosis (cSS) is identified as a well-defined, homogeneous, curvilinear hypointense signal (black) on T2*-GRE or SWI, following the outer surface of the cerebral cortex within the subarachnoid space. Do not score cSS if it is contiguous or anatomically connected to lobar intracerebral hemorrhage (ICH). To be considered separate, cSS must be ≥3 sulci away, or ≥2 sulci away on multiple axial levels without clear superficial communication."
                                              ),
                                              
                                              tags$ul(
                                                tags$li("cSS score (each hemisphere): 0 = no cSS, 1 = 1 sulcus or ≤3 adjacent sulci and 2 = ≥2 non-adjacent or >3 adjacent sulci."),
                                                tags$li("cSS total score (right + left): 0 = no cSS, 1 = mild/unifocal and ≥2 = severe/multifocal.")
                                              ),
                                              tags$div(
                                                style = "font-size: 0.85em; color: #555;",
                                                
                                                tags$p(
                                                  "Picture adapted from: Andersen, N. H., Blauenfeldt, R. A., Mikkelsen, R. & Simonsen, C. Z. (2023). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.1186/s12883-023-03300-9",
                                                    "Preceding symptoms and temporal development of cortical superficial siderosis in cerebral amyloid angiopathy: a case report. BMC Neurology, 23, 252.",
                                                    target = "_blank"
                                                  ),
                                                  " Licensed under ",
                                                  tags$a(
                                                    href = "http://creativecommons.org/licenses/by/4.0/",
                                                    "CC BY 4.0",
                                                    target = "_blank"
                                                  ),
                                                  "."
                                                ),
                                                
                                                tags$p(
                                                  "Scale cSS adapted from: Charidimou, A. et al. (2017). ",
                                                  tags$a(
                                                    href = "https://doi.org/10.1212/WNL.0000000000004665",
                                                    "Cortical superficial siderosis multifocality in cerebral amyloid angiopathy. Neurology, 89, 2128–2135.",
                                                    target = "_blank"
                                                  )
                                                )
                                              )
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                ),
                                
                                ### ATROPHY SCALES -------------------------------------------------
                                #### Global Cortical Atrophy Scale (GCA) -------
                                tabPanel(
                                  title = "Global Atrophy",
                                  value = "tab_gca_report",
                                  card(
                                    full_screen = FALSE,  # Only the main content card should be fullscreen
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("gca_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",   # Text aligned left & centered vertically
                                          "Global Atrophy"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;", 
                                      fluidRow(
                                        # Left column for the form inputs
                                        column(7, 
                                               fluidRow(
                                                 column(4, ""),
                                                 column(4, tags$h5("Right", align = "center")),
                                                 column(4, tags$h5("Left", align = "center"))
                                               ),
                                               tags$h5("Sulci"),
                                               fluidRow(
                                                 column(4, "Frontal"),
                                                 column(4, selectInput("frontal_sulci_right_report", NULL, choices = c(0, 1, 2, 3))),
                                                 column(4, selectInput("frontal_sulci_left_report", NULL, choices = c(0, 1, 2, 3)))
                                               ),
                                               fluidRow(
                                                 column(4, "Parieto-occipital"),
                                                 column(4, selectInput("parietal_sulci_right_report", NULL, choices = c(0, 1, 2, 3))),
                                                 column(4, selectInput("parietal_sulci_left_report", NULL, choices = c(0, 1, 2, 3)))
                                               ),
                                               fluidRow(
                                                 column(4, "Temporal"),
                                                 column(4, selectInput("temporal_sulci_right_report", NULL, choices = c(0, 1, 2, 3))),
                                                 column(4, selectInput("temporal_sulci_left_report", NULL, choices = c(0, 1, 2, 3)))
                                               ),
                                               tags$h5("Ventricles"),
                                               fluidRow(
                                                 column(4, "Frontal"),
                                                 column(4, selectInput("frontal_ventricles_right_report", NULL, choices = c(0, 1, 2, 3))),
                                                 column(4, selectInput("frontal_ventricles_left_report", NULL, choices = c(0, 1, 2, 3)))
                                               ),
                                               fluidRow(
                                                 column(4, "Parieto-occipital"),
                                                 column(4, selectInput("parietal_ventricles_right_report", NULL, choices = c(0, 1, 2, 3))),
                                                 column(4, selectInput("parietal_ventricles_left_report", NULL, choices = c(0, 1, 2, 3)))
                                               ),
                                               fluidRow(
                                                 column(4, "Temporal"),
                                                 column(4, selectInput("temporal_ventricles_right_report", NULL, choices = c(0, 1, 2, 3))),
                                                 column(4, selectInput("temporal_ventricles_left_report", NULL, choices = c(0, 1, 2, 3)))
                                               ),
                                               fluidRow(
                                                 column(4, "Third Ventricle"),
                                                 column(4, selectInput("third_ventricle_report", NULL, choices = c(0, 1, 2, 3))),
                                                 column(4, "")
                                               ),
                                               tags$br()
                                        ),
                                        # Right column for the sidebar with image and text (expanded width)
                                        column(5, 
                                               card(
                                                 full_screen = TRUE,
                                                 card_body(
                                                   style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                                   
                                                   tags$h6(
                                                     class = "d-flex align-items-center",
                                                     icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                     tags$strong("Global Cortical Atrophy Scale (GCA)")
                                                   ),
                                                   
                                                   tags$img(src = "picture_gca.webp", width = "100%", height = "auto"),
                                                   
                                                   tags$p(
                                                     "GCA scale 0: no atrophy; 1: mild atrophy – enlargement of sulci; 2: moderate atrophy – volume loss of gyri; 3: severe atrophy – “knife-blade” atrophy."
                                                   ),
                                                   
                                                   tags$div(
                                                     style = "font-size: 0.85em; color: #555;",
                                                     
                                                     tags$p(
                                                       "Figure adapted from: Furtner, J. & Prayer, D. (2021). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1007/s10354-021-00825-x",
                                                         "Neuroimaging in dementia. Wien Med Wochenschr, 171, 274–281.",
                                                         target = "_blank"
                                                       ),
                                                       " Licensed under ",
                                                       tags$a(
                                                         href = "http://creativecommons.org/licenses/by/4.0/",
                                                         "CC BY 4.0",
                                                         target = "_blank"
                                                       ),
                                                       "."
                                                     ),
                                                     
                                                     tags$p(
                                                       "GCA scale adapted from: Pasquier, F. et al. (2008). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1159/000117270",
                                                         "Inter- and Intraobserver Reproducibility of Cerebral Atrophy Assessment on MRI Scans with Hemispheric Infarcts. European Neurology, 36, 268–272.",
                                                         target = "_blank"
                                                       ),
                                                       "."
                                                     )
                                                   )
                                                 )
                                               )
                                        )
                                      )
                                    )
                                  )
                                ),
                                
                                
                                #### MTA -------------
                                tabPanel(
                                  title = "Medial Temporal Atrophy",
                                  value = "tab_mta_report",
                                  card(
                                    full_screen = FALSE,
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",
                                        tags$div(
                                          style = "flex: none; width: 35px;",  
                                          input_switch("mta_switch", label = NULL, value = TRUE)
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;", 
                                          "Medial Temporal Atrophy"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;",
                                      fluidRow(
                                        column(6,
                                               selectInput("mta_right_report", 
                                                           "Right Hemisphere", 
                                                           choices = c(
                                                             "0: no CSF is visible around the hippocampus",
                                                             "1: choroid fissure is slightly widened",
                                                             "2: moderate widening of the choroid fissure, mild enlargement of the temporal horn and mild loss of hippocampal height",
                                                             "3: marked widening of the choroid fissure, moderate enlargement of the temporal horn, and moderate loss of hippocampal height",
                                                             "4: marked widening of the choroid fissure, marked enlargement of the temporal horn, and the hippocampus is markedly atrophied and internal structure is lost"
                                                           ), width = "90%" ),
                                               selectInput("mta_left_report",
                                                           "Left Hemisphere", 
                                                           choices = c(
                                                             "0: no CSF is visible around the hippocampus",
                                                             "1: choroid fissure is slightly widened",
                                                             "2: moderate widening of the choroid fissure, mild enlargement of the temporal horn and mild loss of hippocampal height",
                                                             "3: marked widening of the choroid fissure, moderate enlargement of the temporal horn, and moderate loss of hippocampal height",
                                                             "4: marked widening of the choroid fissure, marked enlargement of the temporal horn, and the hippocampus is markedly atrophied and internal structure is lost"
                                                           ), width = "90%" )
                                        ),
                                        column(6,
                                               card(
                                                 full_screen = TRUE,
                                                 card_body(
                                                   style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                                   
                                                   tags$h6(
                                                     class = "d-flex align-items-center",
                                                     icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                     tags$strong("Medial Temporal Lobe Atrophy Score (MTA)")
                                                   ),
                                                   
                                                   tags$img(src = "picture_mta.webp", height = "auto", width = "100%"),
                                                   
                                                   tags$p("Medial Temporal Lobe Atrophy (MTA) score in coronal T1-weighted MRI. The score is based on qualitative evaluation of the widening of the choroid fissure, enlargement of the temporal horn, and atrophy of the hippocampus."),
                                                   
                                                   tags$ul(
                                                     tags$li("0: no CSF is visible around the hippocampus"),
                                                     tags$li("1: choroid fissure is slightly widened"),
                                                     tags$li("2: moderate widening of the choroid fissure, mild enlargement of the temporal horn and mild loss of hippocampal height"),
                                                     tags$li("3: marked widening of the choroid fissure, moderate enlargement of the temporal horn, and moderate loss of hippocampal height"),
                                                     tags$li("4: marked widening of the choroid fissure, marked enlargement of the temporal horn, and the hippocampus is markedly atrophied and internal structure is lost")
                                                   ),
                                                   
                                                   tags$div(
                                                     style = "font-size: 0.85em; color: #555;",
                                                     
                                                     tags$p(
                                                       "Figure adapted from: Håkansson, C. et al. (2022). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1007/s00330-021-08177-1",
                                                         "Inter-modality assessment of medial temporal lobe atrophy in a non-demented population: application of a visual rating scale template across radiologists with varying clinical experience. Eur Radiol, 32, 1127–1134.",
                                                         target = "_blank"
                                                       ),
                                                       " Licensed under ",
                                                       tags$a(
                                                         href = "http://creativecommons.org/licenses/by/4.0/",
                                                         "CC BY 4.0",
                                                         target = "_blank"
                                                       ),
                                                       "."
                                                     ),
                                                     
                                                     tags$p(
                                                       "MTA scale adapted from: Scheltens, P., Launer, L., Barkhof, F. et al. (1995). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1007/BF00868807",
                                                         "Visual assessment of medial temporal lobe atrophy on magnetic resonance imaging: Interobserver reliability. Journal of Neurology, 242(9), 557–560.",
                                                         target = "_blank"
                                                       )
                                                     )
                                                   )
                                                 )
                                               )
                                        )
                                      )
                                    )
                                  )
                                ),
                                #### ERICA -------------
                                tabPanel(
                                  title = "Entorhinal Atrophy",
                                  value = "tab_erica_report",
                                  card(
                                    full_screen = FALSE,
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",
                                        tags$div(
                                          style = "flex: none; width: 35px;",
                                          input_switch("erica_switch", label = NULL, value = TRUE) # The switch, aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;", 
                                          "Entorhinal Atrophy"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;",
                                      fluidRow(
                                        column(6,
                                               selectInput("erica_right_report", label = "Right Hemisphere", choices = c(
                                                 "0: normal volume of the entorhinal cortex and parahippocampal gyrus",
                                                 "1: mild atrophy of the entorhinal cortex and parahippocampal gyrus; widening of the collateral sulcus",
                                                 "2: moderate atrophy of the entorhinal cortex and parahippocampal gyrus; elevation of the entorhinal cortex away from the adjacent cerebellar tentorium",
                                                 "3: marked atrophy of the entorhinal cortex and parahippocampal gyrus; wide cleft between the entorhinal cortex and the adjacent cerebellar tentorium"
                                               ), width = "90%" ),
                                               selectInput("erica_left_report", label = "Left Hemisphere", choices = c(
                                                 "0: normal volume of the entorhinal cortex and parahippocampal gyrus",
                                                 "1: mild atrophy of the entorhinal cortex and parahippocampal gyrus; widening of the collateral sulcus",
                                                 "2: moderate atrophy of the entorhinal cortex and parahippocampal gyrus; elevation of the entorhinal cortex away from the adjacent cerebellar tentorium",
                                                 "3: marked atrophy of the entorhinal cortex and parahippocampal gyrus; wide cleft between the entorhinal cortex and the adjacent cerebellar tentorium"
                                               ), width = "90%" )
                                        ),
                                        column(6,
                                               card(
                                                 full_screen = TRUE,
                                                 card_body(
                                                   style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                                   
                                                   tags$h6(
                                                     class = "d-flex align-items-center",
                                                     icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                     tags$strong("Entorhinal Cortical Atrophy Score (ERICA)")
                                                   ),
                                                   
                                                   tags$img(src = "picture_erica1.webp", height = "auto", width = "100%"),
                                                   
                                                   tags$p(
                                                     "Orientation: coronal sections aligned to the brainstem with a section thickness of 1 mm."
                                                   ),
                                                   
                                                   tags$ul(
                                                     tags$li("0: normal volume of the entorhinal cortex and parahippocampal gyrus."),
                                                     tags$li("1: mild atrophy with widening of the collateral sulcus."),
                                                     tags$li("2: moderate atrophy with detachment of the entorhinal cortex from the cerebellar tentorium (the 'tentorial cleft sign')."),
                                                     tags$li("3: pronounced atrophy of the parahippocampal gyrus and a wide cleft between entorhinal cortex and the cerebellar tentorium.")
                                                   ),
                                                   
                                                   tags$div(
                                                     style = "font-size: 0.85em; color: #555;",
                                                     
                                                     tags$p(
                                                       "Figure adapted from: Roberge, X., Brisson, M. & Laforce, R. J. (2023). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1017/cjn.2021.253",
                                                         "Specificity of Entorhinal Atrophy MRI Scale in Predicting Alzheimer’s Disease Conversion. Canadian Journal of Neurological Sciences, 50, 112–114.",
                                                         target = "_blank"
                                                       ),
                                                       " Licensed under ",
                                                       tags$a(
                                                         href = "http://creativecommons.org/licenses/by/4.0/",
                                                         "CC BY 4.0",
                                                         target = "_blank"
                                                       ),
                                                       "."
                                                     ),
                                                     
                                                     tags$p(
                                                       "Scale adapted from: Enkirch, S. J. et al. (2018). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1148/radiol.2018171888",
                                                         "The ERICA Score: An MR Imaging–based Visual Scoring System for the Assessment of Entorhinal Cortex Atrophy in Alzheimer Disease. Radiology, 288, 226–333.",
                                                         target = "_blank"
                                                       )
                                                     )
                                                   )
                                                 )
                                               )
                                        )
                                      )
                                    )
                                  )
                                ),
                                
                                #### PCA -------------
                                tabPanel(
                                  title = "Posterior Parietal Atrophy",
                                  value = "tab_pca_report",
                                  card(
                                    full_screen = FALSE,  # Only the main content card should be fullscreen
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",  # Flex container
                                        tags$div(
                                          style = "flex: none; width: 35px;",  # Keep this for the switch, ensuring it doesn't stretch
                                          input_switch("pca_switch", label = NULL, value = TRUE)  # The switch aligned left
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",   # Text aligned left & centered vertically
                                          "Posterior Parietal Atrophy"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;", 
                                      fluidRow(
                                        column(6,
                                               selectInput("pca_right_report", "Right Hemisphere", choices = c(
                                                 "0: closed sulci; no gyral atrophy",
                                                 "1: mild sulcal widening; mild gyral atrophy",
                                                 "2: substantial sulcal widening; substantial gyral atrophy",
                                                 "3: marked sulcal widening; knife-blade gyral atrophy"
                                               ), width = "90%" ),
                                               selectInput("pca_left_report", "Left Hemisphere", choices = c(
                                                 "0: closed sulci; no gyral atrophy",
                                                 "1: mild sulcal widening; mild gyral atrophy",
                                                 "2: substantial sulcal widening; substantial gyral atrophy",
                                                 "3: marked sulcal widening; knife-blade gyral atrophy"
                                               ), width = "90%" )
                                        ),
                                        column(6,
                                               card(
                                                 full_screen = TRUE,
                                                 card_body(
                                                   style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                                   
                                                   ## Header with icon and title
                                                   tags$h6(
                                                     class = "d-flex align-items-center",
                                                     icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                     tags$strong("Koedam Score")
                                                   ),
                                                   
                                                   ## Image
                                                   tags$img(src = "picture_pca.webp", height = "auto", width = "100%"),
                                                   
                                                   ## Single-block description
                                                   tags$div(
                                                     style = "text-align: justify; margin-top: 10px;",
                                                     tags$p(
                                                       "On sagittal images, assess the posterior cingulate sulcus and parieto-occipital sulcus, and check for atrophy of the precuneus. On axial and coronal images, evaluate the widening of the posterior cingulate sulcus and look for sulcal dilatation in the parietal lobes. Atrophy should be rated on a scale from 0 to 3: 0 = no atrophy, 1 = mild, 2 = moderate, and 3 = severe."
                                                     )
                                                   ),
                                                   
                                                   ## Reference footer
                                                   tags$div(
                                                     style = "font-size: 0.85em; color: #555; margin-top: 15px;",
                                                     tags$p(
                                                       "Adapted from: Koedam, E. L. G. E. et al. (2011). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1007/s00330-011-2205-4",
                                                         "Visual assessment of posterior atrophy: development of a MRI rating scale. European Radiology, 21, 2618–2625.",
                                                         target = "_blank"
                                                       ),
                                                       " Licensed under ",
                                                       tags$a(
                                                         href = "https://creativecommons.org/licenses/by-nc/2.0/",
                                                         "CC BY-NC",
                                                         target = "_blank"
                                                       ),
                                                       "."
                                                     )
                                                   )
                                                   
                                                 )
                                               )
                                        )
                                      )
                                    )
                                  )
                                ),     
                                
                                ## SUMMARY SVD SCORE ------
                                
                                tabPanel(
                                  title = "Summary of Small Vessel Disease",
                                  value = "tab_ssvds_report",
                                  card(
                                    full_screen = FALSE,
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: flex-start; width: 100%;",
                                        tags$div(
                                          style = "flex: none; width: 35px;",
                                          input_switch("ssvds_switch", label = NULL, value = TRUE)
                                        ),
                                        tags$div(
                                          style = "margin-left: 5px; font-weight: 900; font-size: 20px; align-self: center; color: #333;",
                                          "Summary of Small Vessel Disease"
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 620px; overflow-y: auto;",
                                      fluidRow(
                                        column(5,
                                               tags$div(
                                                 style = "border: 1px solid #ccc; padding: 15px; margin: 10px 0; border-radius: 5px; background-color: #f9f9f9; font-family: Arial, sans-serif; font-size: 16px; line-height: 1.5;",
                                                 tags$p(
                                                   "Overview of small vessel disease score:",
                                                   style = "margin: 0 0 10px 0;"
                                                 ),
                                                 tags$ul(
                                                   tags$li(
                                                     tags$span(
                                                       style = "display: inline;",
                                                       tags$strong("Lacunar Infarcts: "),
                                                       textOutput("lacunarInfarctsScore", inline = TRUE)
                                                     )
                                                   ),
                                                   tags$li(
                                                     tags$span(
                                                       style = "display: inline;",
                                                       tags$strong("Cerebral Microbleeds: "),
                                                       textOutput("cerebralMicrobleedsScore", inline = TRUE)
                                                     )
                                                   ),
                                                   tags$li(
                                                     tags$span(
                                                       style = "display: inline;",
                                                       tags$strong("Perivascular Spaces: "),
                                                       textOutput("perivascularSpacesScore", inline = TRUE)
                                                     )
                                                   ),
                                                   tags$li(
                                                     tags$span(
                                                       style = "display: inline;",
                                                       tags$strong("White Matter Hyperintensities: "),
                                                       textOutput("whiteMatterHyperintensitiesScore", inline = TRUE)
                                                     )
                                                   )
                                                 )
                                               )
                                        ),
                                        column(7,
                                               card(
                                                 full_screen = TRUE,
                                                 card_body(
                                                   style = "height: 580px; overflow-y: auto; background-color: #f9f9f9; padding: 15px;",
                                                   
                                                   tags$h6(
                                                     class = "d-flex align-items-center",
                                                     icon("circle-info", class = "me-2", style = "color: #676971;"),
                                                     tags$strong("Small Vessel Disease Score")
                                                   ),
                                                   
                                                   tags$img(
                                                     src = "picture_ssvds.webp",
                                                     width = "100%",
                                                     height = "auto"
                                                   ),
                                                   
                                                   tags$div(
                                                     style = "text-align: justify; margin-top: 10px;",
                                                     tags$p(
                                                       "The total MRI burden of small vessel disease is graded from 0 to 4. Assign one point for each of the following:"
                                                     ),
                                                     tags$ul(
                                                       tags$li("Lacunes: presence of ≥1"),
                                                       tags$li("Cerebral microbleeds: any present"),
                                                       tags$li("Perivascular spaces: moderate to severe (grade 2–4) in the basal ganglia"),
                                                       tags$li("White matter hyperintensities (WMH): deep WMH (Fazekas 2–3) or irregular periventricular WMH extending into deep white matter (Fazekas 3)")
                                                     )
                                                   ),
                                                   
                                                   tags$div(
                                                     style = "font-size: 0.85em; color: #555; margin-top: 15px;",
                                                     tags$p(
                                                       "Adapted from: Staals, J., Makin, S. D. J., Doubal, F. N., Dennis, M. S. & Wardlaw, J. M. (2014). ",
                                                       tags$a(
                                                         href = "https://doi.org/10.1212/WNL.0000000000000837",
                                                         "Stroke subtype, vascular risk factors, and total MRI brain small-vessel disease burden. Neurology, 83, 1228–1234.",
                                                         target = "_blank"
                                                       )
                                                     )
                                                   )
                                                 )
                                               )
                                        )
                                      )
                                    )
                                  )
                                ),
                                # ### MOVEMENT SUB NIGRA -------------------------------------------------
                                # tabPanel(
                                #   title = "Substantia Nigra",
                                #   value = "tab_substantia_nigra",
                                #   fluidRow(
                                #     column(6, 
                                #            tags$h5("Loss of T1 signal intensity, area or simmetry"),
                                #            fluidRow(
                                #              column(6, selectInput("t1_hyperintensity_right", "Right", choices = c("yes", "no", "not sure"))),
                                #              column(6, selectInput("t1_hyperintensity_left", "Left", choices = c("yes", "no", "not sure")))
                                #            ),
                                #            tags$h5("Loss of SWI hyperintensity"),
                                #            tags$h6("(loss of 'swallow tail sign')"),
                                #            fluidRow(
                                #              column(6, selectInput("swi_hyperintensity_right", "Right", choices = c("yes", "no", "not sure"))),
                                #              column(6, selectInput("swi_hyperintensity_left", "Left", choices = c("yes", "no", "not sure")))
                                #            )
                                #     ),
                                #     column(6,
                                #            img(src = "picture_mest1swi.webp", width = "100%"),
                                #            tags$h6("Normal appearance of the substantia nigra on T1-NM and SWI. It should be evaluated in three consecutive slices."),
                                #            img(src = "picture_t1eg.webp", width = "100%"),
                                #            tags$h6(tags$a(href = "https://doi.org/10.3389/fneur.2020.00665", "doi: 10.3389/fneur.2020.00665", target = "_blank")),
                                #            img(src = "picture_swieg.webp", width = "100%"),
                                #            tags$h6(tags$a(href = "https://doi.org/10.3389/fneur.2020.00665", "doi: 10.3389/fneur.2020.00665", target = "_blank")),
                                #     )
                                #   )
                                # ),
                                # 
                                # ### MOVEMENT CALCULATOR -------------------------------------------------
                                # tabPanel(
                                #   title = HTML('Movement <i class="fa-solid fa-calculator"></i>'),
                                #   value = "tab_movement_calculator",
                                #   
                                #   page_fluid(
                                #     fluidRow(
                                #       column(6,
                                #              fluidRow(
                                #                numericInput(
                                #                  "input_midbrain_report",
                                #                  "Midbrain surface area (mm²)",
                                #                  value = 0,
                                #                  min = 0,
                                #                  max = 1000,
                                #                  step = 0.1
                                #                ),
                                #                actionButton("show_image_area_mes_pon_report", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
                                #              ),
                                #              
                                #              
                                #              fluidRow(
                                #                numericInput(
                                #                  "input_pons",
                                #                  "Pons surface area (mm²)",
                                #                  value = 0,
                                #                  min = 0,
                                #                  max = 1000,
                                #                  step = 0.1
                                #                ),
                                #                actionButton("show_image_area_mes_pon_report", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
                                #              ),
                                #              
                                #              fluidRow(
                                #                numericInput(
                                #                  "input_scp_report",
                                #                  "Width of superior cerebellar peduncles (mm)",
                                #                  value = 0,
                                #                  min = 0,
                                #                  max = 1000,
                                #                  step = 0.1
                                #                ),
                                #                actionButton("show_image_scp_report", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
                                #              ),
                                #              
                                #              fluidRow(
                                #                numericInput(
                                #                  "input_mcp_report",
                                #                  "Width of middle cerebellar peduncles (mm)",
                                #                  value = 0,
                                #                  min = 0,
                                #                  max = 1000,
                                #                  step = 0.1
                                #                ),
                                #                actionButton("show_image_mcp_report", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
                                #              ),
                                #              
                                #              fluidRow(
                                #                numericInput(
                                #                  "input_v3_report",
                                #                  "Width of the third ventricle V3 (mm)",
                                #                  value = 0,
                                #                  min = 0,
                                #                  max = 100,
                                #                  step = 0.1
                                #                ),
                                #                actionButton("show_image_v3_report", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
                                #              ),
                                #              
                                #              fluidRow(
                                #                numericInput(
                                #                  "input_fh_report",
                                #                  "Width of the frontal horn (mm)",
                                #                  value = 0,
                                #                  min = 0,
                                #                  max = 100,
                                #                  step = 0.1
                                #                ),
                                #                actionButton("show_image_fh_report", label = NULL, width = 60, icon = icon("circle-info"), style = "border: none; background-color: transparent; box-shadow: none;"),
                                #              ),
                                #              
                                #              fluidRow(
                                #                column(12, 
                                #                       fluidRow(
                                #                         actionButton("calculate_midbrain_pons_ratio_report", "Calculate Midbrain/Pons Ratio"),
                                #                         style = "margin-bottom: 10px;"
                                #                       ),
                                #                       fluidRow(
                                #                         actionButton("calculate_mrpi_1_report", "Calculate MRPI"),
                                #                         style = "margin-bottom: 10px;"
                                #                       ),
                                #                       fluidRow(
                                #                         actionButton("calculate_mrpi_2_report", "Calculate MRPI 2.0")
                                #                       )
                                #                )
                                #              ),
                                #              tags$h4(textOutput("calculation_result_report"))
                                #       ),
                                #       
                                #       
                                #       column(6,
                                #              
                                #              # imageOutput("help_image_report")
                                #              uiOutput("help_image_report")
                                #       )
                                #     )
                                #   )
                                # ),
                                
                                
                                ### GENERATE REPORT-----     
                                tabPanel(
                                  title = "Aurora Report",
                                  value = "tab_report",
                                  card(
                                    full_screen = FALSE,  
                                    card_header(
                                      tags$div(
                                        style = "display: flex; align-items: center; justify-content: space-between; width: 100%;",
                                        tags$div(
                                          style = "font-weight: 900; font-size: 20px; color: #333;",
                                          "Aurora Report"
                                        ),
                                        tags$div(
                                          style = "margin-left: auto; width: 220px;",
                                          selectInput("lang", label = NULL, 
                                                      choices = c("English", "Português (Portugal)"), 
                                                      selected = "English", 
                                                      width = "100%")
                                        ),
                                        tags$div(
                                          style = "display: inline-block;",
                                          downloadButton(
                                            "downloadData", 
                                            "Export to Excel", 
                                            style = "height: 37px; padding: 6px 12px; font-size: 16px; margin-left: 5px; vertical-align: middle;"
                                          )
                                        )
                                      )
                                    ),
                                    card_body(
                                      style = "height: 580px; overflow-y: auto;", 
                                      fluidRow(
                                        column(12,
                                               tags$div(style = "margin-top: 30px; font-size: 16px;",  
                                                        uiOutput("final_report"),
                                                        tags$br()
                                               )
                                        )
                                      )
                                    )
                                  )
                                )
                    ),
                    
                    # Navigation Panel (Buttons + Floating Dropdown)
                    fixedPanel(
                      bottom = 0,
                      left = 0,
                      right = 0,
                      style = "background-color: white; z-index: 1000; position: fixed;",  # Adjust z-index and ensure position is set
                      div(
                        style = "display: flex; justify-content: space-between; align-items: center; padding: 10px;",
                        # Previous Button
                        actionButton("prev_report", "Previous", class = "btn btn-primary"),
                        # Dropdown between buttons
                        div(
                          selectInput("tab_selector", NULL,  # No label for compactness
                                      choices = list(
                                        "Identification" = "tab_identification",
                                        "Recent Small Subcortical Infarcts" = "tab_recent_small_infarcts",
                                        "Lacunes" = "tab_svd_lacunes",
                                        "White Matter Hyperintensities" = "fazekas_chk",
                                        "Perivascular Spaces" = "pvs_chk",
                                        "Microbleeds" = "microbleeds_chk",
                                        "Superficial Siderosis" = "superficial_siderosis_chk",
                                        "Global Atrophy" = "tab_gca_report",
                                        "Medial Temporal Atrophy" = "tab_mta_report",
                                        "Entorhinal Atrophy" = "tab_erica_report",
                                        "Posterior Parietal Atrophy" = "tab_pca_report",
                                        "Summary of Small Vessel Disease" = "tab_ssvds_report",
                                        "Aurora Report" = "tab_report"
                                      ),
                                      selectize = FALSE, width = "300px", 
                          ),
                          style="background-color: white;"  # Ensure div containing selectInput has a white background
                        ),
                        # Next Button
                        actionButton("next_report", "Next", class = "btn btn-primary")
                      )
                    )
  ),
  
  ## Atrophy Calculator -----
  
  nav_panel_hidden(
    "Atrophy Calculator",
    
    navset_pill_list(
      
      #### GCA -------------
      nav_panel(
        title = "Global Atrophy Scale (GCA)",
        value = "tab_gca_singlecalc",
        page_fluid(
          fluidRow(
            column(6,
                   fluidRow(
                     column(4, ""),
                     column(4, tags$h5("Right", align = "center")),
                     column(4, tags$h5("Left", align = "center"))
                   ),
                   tags$h5("Sulci"),
                   fluidRow(
                     column(4, "Frontal"),
                     column(4, selectInput("frontal_sulci_right_singlecalc", NULL, choices = c(0, 1, 2, 3))),
                     column(4, selectInput("frontal_sulci_left_singlecalc", NULL, choices = c(0, 1, 2, 3)))
                   ),
                   fluidRow(
                     column(4, "Parieto-occipital"),
                     column(4, selectInput("parietal_sulci_right_singlecalc", NULL, choices = c(0, 1, 2, 3))),
                     column(4, selectInput("parietal_sulci_left_singlecalc", NULL, choices = c(0, 1, 2, 3)))
                   ),
                   fluidRow(
                     column(4, "Temporal"),
                     column(4, selectInput("temporal_sulci_right_singlecalc", NULL, choices = c(0, 1, 2, 3))),
                     column(4, selectInput("temporal_sulci_left_singlecalc", NULL, choices = c(0, 1, 2, 3)))
                   ),
                   tags$h5("Ventricles"),
                   fluidRow(
                     column(4, "Frontal"),
                     column(4, selectInput("frontal_ventricles_right_singlecalc", NULL, choices = c(0, 1, 2, 3))),
                     column(4, selectInput("frontal_ventricles_left_singlecalc", NULL, choices = c(0, 1, 2, 3)))
                   ),
                   fluidRow(
                     column(4, "Parieto-occipital"),
                     column(4, selectInput("parietal_ventricles_right_singlecalc", NULL, choices = c(0, 1, 2, 3))),
                     column(4, selectInput("parietal_ventricles_left_singlecalc", NULL, choices = c(0, 1, 2, 3)))
                   ),
                   fluidRow(
                     column(4, "Temporal"),
                     column(4, selectInput("temporal_ventricles_right_singlecalc", NULL, choices = c(0, 1, 2, 3))),
                     column(4, selectInput("temporal_ventricles_left_singlecalc", NULL, choices = c(0, 1, 2, 3)))
                   ),
                   fluidRow(
                     column(4, "Third Ventricle"),
                     column(4, selectInput("third_ventricle_singlecalc", "", choices = c(0, 1, 2, 3))),
                     column(4, "")
                   ),
                   actionButton("calculate_gca_singlecalc", "Calculate"),
                   textOutput("gca_score_singlecalc"),
                   tags$br()
            ),
            column(6,
                   img(src = "picture_gca.webp", width = "100%"),
                   tags$div(style = "text-align: justify;",
                            tags$h6("GCA scale 0: no atrophy; 1: mild atrophy: enlargement of sulci; 2: moderate atrophy: volume loss of gyri; 3: severe atrophy: “knife blade” atrophy.")
                   ),
                   tags$h6(
                     "Figure adapted from: Furtner, J. & Prayer, D. (2021). ",
                     tags$a(href = "https://doi.org/10.1007/s10354-021-00825-x", "Neuroimaging in dementia. Wien Med Wochenschr, 171, 274–281.", target = "_blank"),
                     " Licensed under ",
                     tags$a(href = "http://creativecommons.org/licenses/by/4.0/", "CC BY 4.0", target = "_blank"),
                     "."
                   ),
                   tags$h6(
                     "GCA scale adapted from: Pasquier, F. et al. (2008). ",
                     tags$a(href = "https://doi.org/10.1159/000117270", "Inter- and Intraobserver Reproducibility of Cerebral Atrophy Assessment on MRI Scans with Hemispheric Infarcts. European Neurology, 36, 268–272.", target = "_blank")
                   )
            )
          )
        )
      ),
      #### MTA -------------
      nav_panel(
        title = "Medial Temporal Lobe Atrophy Score (MTA)",
        value = "tab_mta_calc",
        page_fluid(
          fluidRow(
            column(6,
                   selectInput("mta_right_calc", 
                               "Right hemisphere", 
                               choices = c(
                                 "0: no CSF is visible around the hippocampus",
                                 "1: choroid fissure is slightly widened",
                                 "2: moderate widening of the choroid fissure, mild enlargement of the temporal horn and mild loss of hippocampal height",
                                 "3: marked widening of the choroid fissure, moderate enlargement of the temporal horn, and moderate loss of hippocampal height",
                                 "4: marked widening of the choroid fissure, marked enlargement of the temporal horn, and the hippocampus is markedly atrophied and internal structure is lost"
                               ),
                               width = "500px"),
                   selectInput("mta_left_calc",
                               "Left hemisphere", 
                               choices = c(
                                 "0: no CSF is visible around the hippocampus",
                                 "1: choroid fissure is slightly widened",
                                 "2: moderate widening of the choroid fissure, mild enlargement of the temporal horn and mild loss of hippocampal height",
                                 "3: marked widening of the choroid fissure, moderate enlargement of the temporal horn, and moderate loss of hippocampal height",
                                 "4: marked widening of the choroid fissure, marked enlargement of the temporal horn, and the hippocampus is markedly atrophied and internal structure is lost"
                               ),
                               width = "500px"),
                   actionButton("calculate_mta_calc", "Calculate"),
                   uiOutput("mta_result_output_calc")
            ),
            column(6,
                   img(src = "picture_mta.webp", width = "100%"),
                   tags$div(style = "text-align: justify;",
                            tags$h6("Medial Temporal Lobe Atrophy (MTA) score in coronal T1w MRI. 
                             The score is based on qualitative evaluation of the widening of the choroid fissure, enlargement of the temporal horn and atrophy of the hippocampus.
                             Ranges from 0 (no atrophy) to 4 (severe atrophy).")),
                   tags$h6(
                     "Figure adapted from: Håkansson, C. et al. (2022). ",
                     tags$a(href = "https://doi.org/10.1007/s00330-021-08177-1", "Inter-modality assessment of medial temporal lobe atrophy in a non-demented population: application of a visual rating scale template across radiologists with varying clinical experience. Eur Radiol, 32, 1127–1134.", target = "_blank"),
                     " Licensed under ",
                     tags$a(href = "http://creativecommons.org/licenses/by/4.0/", "CC BY 4.0", target = "_blank"),
                     "."
                   ),
                   tags$h6(
                     "MTA scale adapted from: Scheltens, P., Launer, L., Barkhof, F. et al. (1995). ",
                     tags$a(href = "https://doi.org/10.1007/BF00868807", "Visual assessment of medial temporal lobe atrophy on magnetic resonance imaging: Interobserver reliability. Journal of Neurology, 242(9), 557–560.", target = "_blank")
                   )
            )
          )
        )
      ),
      
      #### ERICA -------------
      erica_calc_ui <- nav_panel(
        title = "Entorhinal Cortical Atrophy Score (ERICA)",
        value = "tab_erica_singlecalc",
        page_fluid(
          fluidRow(
            column(6,
                   selectInput("erica_right_singlecalc", "Right hemisphere", choices = c(
                     "0: normal volume of the entorhinal cortex and parahippocampal gyrus",
                     "1: mild atrophy of the entorhinal cortex and parahippocampal gyrus; widening of the collateral sulcus",
                     "2: moderate atrophy of the entorhinal cortex and parahippocampal gyrus; elevation of the entorhinal cortex away from the adjacent cerebellar tentorium",
                     "3: marked atrophy of the entorhinal cortex and parahippocampal gyrus; wide cleft between the entorhinal cortex and the adjacent cerebellar tentorium"
                   )),
                   selectInput("erica_left_singlecalc", "Left hemisphere", choices = c(
                     "0: normal volume of the entorhinal cortex and parahippocampal gyrus",
                     "1: mild atrophy of the entorhinal cortex and parahippocampal gyrus; widening of the collateral sulcus",
                     "2: moderate atrophy of the entorhinal cortex and parahippocampal gyrus; elevation of the entorhinal cortex away from the adjacent cerebellar tentorium",
                     "3: marked atrophy of the entorhinal cortex and parahippocampal gyrus; wide cleft between the entorhinal cortex and the adjacent cerebellar tentorium"
                   )),
                   actionButton("calculate_erica", "Calculate"),
                   uiOutput("erica_result_output")  
            ),
            column(6,
                   img(src = "picture_erica1.webp", width = "100%"),
                   tags$div(style = "text-align: justify", 
                            tags$h6("Orientation: coronal sections aligned to the brainstem with a section thickness of 1 mm."),
                            tags$h6("0: normal volume of the entorhinal cortex and parahippocampal gyrus."),
                            tags$h6("1: mild atrophy with widening of the collateral sulcus."),
                            tags$h6("2: moderate atrophy with detachment of the entorhinal cortex from the cerebellar tentorium (the 'tentorial cleft sign')."),
                            tags$h6("3: pronounced atrophy of the parahippocampal gyrus and a wide cleft between entorhinal cortex and the cerebellar tentorium."),
                   ),
                   tags$h6(
                     "Figure adapted from: Roberge, X., Brisson, M. & Laforce, R. J. (2023). ",
                     tags$a(href = "https://doi.org/10.1017/cjn.2021.253", "Specificity of Entorhinal Atrophy MRI Scale in Predicting Alzheimer’s Disease Conversion. Canadian Journal of Neurological Sciences, 50, 112–114.", target = "_blank"),
                     " Licensed under ",
                     tags$a(href = "http://creativecommons.org/licenses/by/4.0/", "CC BY 4.0", target = "_blank"),
                     "."
                   ),
                   tags$h6(
                     "Scale adapted from: Enkirch, S. J. et al. (2018). ",
                     tags$a(href = "https://doi.org/10.1148/radiol.2018171888", "The ERICA Score: An MR Imaging–based Visual Scoring System for the Assessment of Entorhinal Cortex Atrophy in Alzheimer Disease. Radiology, 288, 226–333.", target = "_blank")
                   )
            )
          )
        )
      ),
      
      #### PCA -------------
      nav_panel(
        title = "Posterior parietal atrophy (Koedam) score",
        value = "tab_pca_singlecalc",
        page_fluid(
          fluidRow(
            column(6,
                   selectInput("pca_right_singlecalc", "Right hemisphere", choices = c(
                     "0: closed sulci; no gyral atrophy",
                     "1: mild sulcal widening; mild gyral atrophy",
                     "2: substantial sulcal widening; substantial gyral atrophy",
                     "3: marked sulcal widening; knife-blade gyral atrophy"
                   )),
                   selectInput("pca_left_singlecalc", "Left hemisphere", choices = c(
                     "0: closed sulci; no gyral atrophy",
                     "1: mild sulcal widening; mild gyral atrophy",
                     "2: substantial sulcal widening; substantial gyral atrophy",
                     "3: marked sulcal widening; knife-blade gyral atrophy"
                   )),
                   actionButton("pca_calculate", "Calculate"),
                   uiOutput("pca_result_output")  
            ),
            column(6,
                   img(src = "picture_pca.webp", width = "100%"),
                   tags$div(style = "text-align: justify", 
                            tags$h6("Sagittal: evaluate the widening of the posterior cingulate sulcus and parieto-occipital sulcus, and assess atrophy of the precuneus."),
                            tags$h6("Axial: evaluate the widening of the posterior cingulate sulcus and sulcal dilatation in the parietal lobes."),
                            tags$h6("Coronal: evaluate the widening of the posterior cingulate sulcus and sulcal dilatation in the parietal lobes."),
                            tags$h6("Rating: 0 = no atrophy, 1 = mild atrophy, 2 = moderate atrophy, 3 = severe atrophy.")
                   ),
                   tags$h6(
                     "Adapted from: Koedam, E. L. G. E. et al. (2011). ",
                     tags$a(href = "https://doi.org/10.1007/s00330-011-2205-4", "Visual assessment of posterior atrophy: development of a MRI rating scale. European Radiology, 21, 2618–2625.", target = "_blank"),
                     " Licensed under ",
                     tags$a(href = "https://creativecommons.org/licenses/by-nc/2.0/", "CC BY-NC", target = "_blank"),
                     "."
                   )
            )
          )
        )
      ),
      widths = c(2, 10)
    )
    
    
  ),
  
  ## Movement Calculator -----

  nav_panel_hidden(
    "Movement Calculator",

    page_fluid(
      fluidRow(
        column(6,
               movement_input("input_midbrain_singlecalc", "Midbrain surface area (mm²)", "show_image_area_mes_pon_singlecalc"),
               movement_input("input_pons", "Pons surface area (mm²)", "show_image_area_mes_pon2_singlecalc"),
               movement_input("input_scp_singlecalc", "Width of superior cerebellar peduncles (mm)", "show_image_scp_singlecalc"),
               movement_input("input_mcp_singlecalc", "Width of middle cerebellar peduncles (mm)", "show_image_mcp_singlecalc"),
               movement_input_v3("show_image_v3_singlecalc"),
               movement_input("input_fh_singlecalc", "Width of the frontal horn (mm)", "show_image_fh_singlecalc"),
               movement_input("input_md_singlecalc", "Midbrain anteroposterior (AP) diameter (mm)", "show_help_md_singlecalc"),
               movement_input("input_pd_singlecalc", "Pons AP diameter (mm)", "show_help_pd_singlecalc"),

               fluidRow(
                 column(12,
                        fluidRow(
                          actionButton("calculate_midbrain_pons_ratio_singlecalc", "Calculate Midbrain/Pons Ratio"),
                          style = "margin-bottom: 10px;"
                        ),
                        fluidRow(
                          actionButton("calculate_mrpi_1_singlecalc", "Calculate MRPI (Magnetic Resonance Parkinsonism Index)"),
                          style = "margin-bottom: 10px;"
                        ),
                        fluidRow(
                          actionButton("calculate_mrpi_2_singlecalc", "Calculate MRPI 2.0"),
                          style = "margin-bottom: 10px;"
                        ),
                        fluidRow(
                          actionButton("calculate_md_pd_singlecalc", "Calculate Midbrain/Pons Diameter Ratio"),
                          style = "margin-bottom: 10px;"
                        ),
                        fluidRow(
                          actionButton("calculate_mcp_singlecalc", "Assess Middle Cerebellar Peduncle Width")
                        )
                 )
               ),
               uiOutput("movement_result_singlecalc")
        ),


        column(6,
               uiOutput("help_image_singlecalc")
        )
      )
    )


  ),

  nav_spacer(), # push nav items to the right
  
  
  ## Help ------- 
  
  nav_panel(
    "Help",
    
    tags$head(tags$style(HTML("
    p, ul, li {
      font-family: Helvetica, sans-serif;
      text-align: justify;
    }
    h4, h5 {
      font-family: Helvetica, sans-serif;
    }
    .license {
      font-size: 12px;
      margin-top: 30px;
      font-family: Helvetica, sans-serif;
      text-align: center;
      color: #555;
    }
  "))),
    
    HTML("
    <h4>Frequently Asked Questions (FAQ)</h4>
    
      <p><strong>Can I use Aurora on my phone or tablet?</strong><br />
  Aurora is optimized for desktop browsers. Mobile and tablet support is limited.</p>
  
  <p><strong>Which languages are available?</strong><br />
  The interface is in English. Reports can be generated in English (US) or Portuguese (PT).</p>
  
  <p><strong>What is the Aurora Report?</strong><br />
The Aurora Report is a structured MRI report currently designed to describe small vessel disease and atrophy. It results from user inputs in selected sections with instructions and example images.</p>
  
  <p><strong>Which calculators are included?</strong><br />
    Atrophy: GCA, MTA, ERICA and Koedam scales. Movement disorders: Midbrain/Pons ratio, MRPI and MRPI 2.0.</p>
  
  <p><strong>Can I export my data?</strong><br />
  Yes. You can export all input data to Excel from the Aurora Report tab.</p>
  
  <p><strong>Are the tools validated?</strong><br />
  Yes. All scales and calculators are based on peer-reviewed publications.</p>
  
  <p><strong>Where can I find references?</strong><br />
Each section includes direct links to their respective publications.</p>
    
    <p><strong></strong><br />
    
 <h4>Feedback</h4>
    <p>Your feedback is important to us. Help improve Aurora by emailing your suggestions or comments to: <a href='mailto:feedback@aurora-report.com'>feedback@aurora-report.com</a>.</p>
    
    <div class='license'>
      Aurora © 2025 is licensed under 
      <a href='https://creativecommons.org/licenses/by-nc-sa/4.0/' target='_blank'>
        Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
      </a>.
    </div>
  ")
  ),
  
  ## About ----- 
  
  nav_panel(
    "About",
    
    tags$head(tags$style(HTML("
    p {
      font-family: Helvetica, sans-serif;
      text-align: left;
    }
    h4, h5 {
      font-family: Helvetica, sans-serif;
    }
    .license {
      font-size: 12px;
      margin-top: 30px;
      font-family: Helvetica, sans-serif;
      text-align: center;
      color: #555;
    }
  "))),
    
    HTML("
     <p><strong>Aurora</strong> is a free, open-access web application developed in R to support neuroradiologists in structured reporting. 
  It provides validated visual scales and calculators for dementia and movement disorders, along with checklists, visual guides, and reference materials to promote systematic and reproducible assessments. The code is available at 
  <a href='https://github.com/alexandraslrodrigues/aurora' target='_blank'>
  https://github.com/alexandraslrodrigues/aurora</a>.</p> </p>
  
    <p><strong>Alexandra Rodrigues, MD</strong>
  <a href='https://orcid.org/0000-0001-6241-9446' target='_blank' style='text-decoration:none; margin-left:6px;'>
    <img src='https://orcid.org/sites/default/files/images/orcid_16x16.png' alt='ORCID iD' style='vertical-align:middle;'/>
  </a><br />
  <em>Neuroradiology resident, web development, scientific research</em><br />
  Neuroradiology department, Hospital de São José, Unidade Local de Saúde São José, Lisboa, Portugal<br />
  Neuroradiology Unit, Hospital Central do Funchal, Funchal, Portugal – SESARAM<br />
  NOVA Medical School, Universidade Nova de Lisboa, Lisbon, Portugal</p>

  <p><strong>Gonçalo Gama Lobo, MD</strong>
  <a href='https://orcid.org/0000-0002-7376-9967' target='_blank' style='text-decoration:none; margin-left:6px;'>
    <img src='https://orcid.org/sites/default/files/images/orcid_16x16.png' alt='ORCID iD' style='vertical-align:middle;'/>
  </a><br />
  <em>Neuroradiologist, scientific consultant</em><br />
  Neuroradiology department, Hospital de São José, Unidade Local de Saúde São José, Lisboa, Portugal<br />
  NOVA Medical School, Universidade Nova de Lisboa, Lisbon, Portugal</p>

   <p><strong>Tiago Machado, MD</strong>
  <a href='https://orcid.org/0000-0001-8930-4382' target='_blank' style='text-decoration:none; margin-left:6px;'>
    <img src='https://orcid.org/sites/default/files/images/orcid_16x16.png' alt='ORCID iD' style='vertical-align:middle;'/>
  </a><br />
  <em>Clinical pharmacologist, web development consultant</em><br />
  Laboratory of Clinical Pharmacology and Therapeutics, Faculdade de Medicina, Universidade de Lisboa, Lisbon, Portugal</p>

  <p><strong>Daniela Jardim Pereira, MD, PhD</strong>
  <a href='https://orcid.org/0000-0002-9700-810X' target='_blank' style='text-decoration:none; margin-left:6px;'>
    <img src='https://orcid.org/sites/default/files/images/orcid_16x16.png' alt='ORCID iD' style='vertical-align:middle;'/>
  </a><br />
  <em>Neuroradiologist, scientific consultant</em><br />
  Neuroradiology Functional Unit, Imaging Department, Unidade Local de Saúde de Coimbra, Coimbra, Portugal<br />
  Faculty of Medicine, University of Coimbra, Coimbra, Portugal<br />
  Coimbra Institute for Biomedical Imaging and Translational Research (CIBIT), University of Coimbra, Coimbra, Portugal</p>
 </p>
 </p>
 </p>
 </p>
    <div class='license'>
      Aurora © 2025 is licensed under 
      <a href='https://creativecommons.org/licenses/by-nc-sa/4.0/' target='_blank'>
        Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
      </a>.
    </div>
  ")
  )
  
  
  # nav_item(
  #   input_dark_mode(id = "dark_mode", mode = "light")
  # )
  
)
)
# Define server 
server <- function(input, output, session) {

  ## Home buttons -----
  # observe the action button that jumps to report tab
  observeEvent(input$report, {
    
    nav_select(
      id = "tabs",
      selected = "Report")
    
  })
  
  # observe the action button that jumps to atrophy calculator tab
  observeEvent(input$atrophy_calculator, {
    
    nav_select(
      id = "tabs",
      selected = "Atrophy Calculator")
    
  })
  
  # observe the action button that jumps to movement calculator tab
  observeEvent(input$movement_calculator, {
    
    nav_select(
      id = "tabs",
      selected = "Movement Calculator")
    
  })
  
  ## Reactive values --------------------------
  
  image_movement <- reactiveVal(NULL)
  
  reportData <- reactiveValues()
  
  ## Atrophy calculator ----------------------
  ### Calculate GCA Score in single calculator -----------------------------
  
  observeEvent(input$calculate_gca_singlecalc, {
    
    # Reactive expression to calculate GCA score and generate interpretation for Single Calculator
    gca_interpretation_singlecalc <- reactive({
      sulci_values_singlecalc <- c(
        as.numeric(input$frontal_sulci_right_singlecalc),
        as.numeric(input$frontal_sulci_left_singlecalc),
        as.numeric(input$parietal_sulci_right_singlecalc),
        as.numeric(input$parietal_sulci_left_singlecalc),
        as.numeric(input$temporal_sulci_right_singlecalc),
        as.numeric(input$temporal_sulci_left_singlecalc)
      )
      
      ventricles_values_singlecalc <- c(
        as.numeric(input$frontal_ventricles_right_singlecalc),
        as.numeric(input$frontal_ventricles_left_singlecalc),
        as.numeric(input$parietal_ventricles_right_singlecalc),
        as.numeric(input$parietal_ventricles_left_singlecalc),
        as.numeric(input$temporal_ventricles_right_singlecalc),
        as.numeric(input$temporal_ventricles_left_singlecalc),
        as.numeric(input$third_ventricle_singlecalc)
      )
      
      gca_score_singlecalc <- sum(sulci_values_singlecalc, ventricles_values_singlecalc, na.rm = TRUE)
      
      format_value_summary <- function(name, right_value, left_value) {
        parts <- c()
        if (right_value > 0) parts <- c(parts, paste("right:", right_value))
        if (left_value > 0) parts <- c(parts, paste("left:", left_value))
        if (length(parts) > 0) return(paste(name, " (", paste(parts, collapse = "; "), ")", sep = ""))
        else return(NULL)
      }
      
      sulci_summary_singlecalc <- c(
        format_value_summary("frontal", sulci_values_singlecalc[1], sulci_values_singlecalc[2]),
        format_value_summary("parieto-occipital", sulci_values_singlecalc[3], sulci_values_singlecalc[4]),
        format_value_summary("temporal", sulci_values_singlecalc[5], sulci_values_singlecalc[6])
      )
      
      ventricles_summary_singlecalc <- c(
        format_value_summary("frontal", ventricles_values_singlecalc[1], ventricles_values_singlecalc[2]),
        format_value_summary("parieto-occipital", ventricles_values_singlecalc[3], ventricles_values_singlecalc[4]),
        format_value_summary("temporal", ventricles_values_singlecalc[5], ventricles_values_singlecalc[6])
      )
      
      if (ventricles_values_singlecalc[7] > 0) {
        ventricles_summary_singlecalc <- c(ventricles_summary_singlecalc, paste("third ventricle:", ventricles_values_singlecalc[7]))
      }
      
      sulci_summary_singlecalc <- paste(na.omit(sulci_summary_singlecalc), collapse = ", ")
      ventricles_summary_singlecalc <- paste(na.omit(ventricles_summary_singlecalc), collapse = ", ")
      
      summary_text_singlecalc <- paste0(
        "Global cortical atrophy (GCA) score = ", gca_score_singlecalc, ". ",
        ifelse(sulci_summary_singlecalc != "", paste0("Sulci: ", sulci_summary_singlecalc, ". "), ""),
        ifelse(ventricles_summary_singlecalc != "", paste0("Ventricles: ", ventricles_summary_singlecalc, "."), "")
      )
      
      return(summary_text_singlecalc)
    })
    
    output$gca_score_singlecalc <- renderText({
      gca_interpretation_singlecalc()
    })
  })
  
  ### Calculate MTA score for Single Calculator --------------------
  
  observeEvent(input$calculate_mta_calc, {
    
    # Parse input values and convert to numeric values
    mta_right <- as.numeric(substr(input$mta_right_calc, 1, 1))
    mta_left <- as.numeric(substr(input$mta_left_calc, 1, 1))
    
    # Check if the conversion to numeric resulted in NAs
    if (is.na(mta_right) | is.na(mta_left)) {
      print("Could not convert inputs to numeric.")
      return()
    }
    
    # Initialize result variable
    result_text <- ""
    
    if (mta_right == mta_left) {
      result_text <- paste("Medial temporal atrophy (MTA) score =", mta_right, "bilaterally.")
    } else {
      greater_side <- ifelse(mta_right > mta_left, "right", "left")
      lesser_side <- ifelse(mta_right > mta_left, "left", "right")
      
      result_text <- paste("Medial temporal atrophy (MTA) score =", max(mta_right, mta_left), 
                           "on the", greater_side, "and", min(mta_right, mta_left), 
                           "on the", lesser_side, "side.")
    }
    
    # Render result and MTA guidelines only after button is clicked
    output$mta_result_output_calc <- renderUI({
      tagList(
        # Display MTA result
        h6(result_text),
        
        # Adding Paragraph
        p(""),
        
        # Display MTA guideline
        tags$h6("MTA interpretation:"),
        tags$ul(
          tags$li("<75 years: ≥2 suggests abnormal findings"),
          tags$li("≥75 years: ≥3 suggests abnormal findings")
        )
      )
    })
  })
  
  ### Calculate ERICA -----------
  
  observeEvent(input$calculate_erica, {
    erica_left <- as.numeric(substr(input$erica_left_singlecalc, 1, 1))
    erica_right <- as.numeric(substr(input$erica_right_singlecalc, 1, 1))
    # Initialize result_text variable
    result_text <- ""
    
    # Check if scores are equal
    if (erica_right == erica_left) {
      result_text <- paste("Entorhinal cortical atrophy (ERICA) score =", erica_left, "bilaterally.")
    } else {
      # Determine the side with the greater score and the side with the lesser score
      greater_side <- ifelse(erica_right > erica_left, "right", "left")
      lesser_side <- ifelse(erica_right > erica_left, "left", "right")
      greater_score <- max(erica_left, erica_right)
      lesser_score <- min(erica_left, erica_right)
      
      # Construct the result text with the greater side first
      result_text <- paste("Entorhinal cortical atrophy (ERICA) score =", greater_score, "on the", greater_side, 
                           "and", lesser_score, "on the", lesser_side, "side.")
    }
    output$erica_result_output <- renderUI({
      tagList(
        h6(result_text),
        p(""),
        tags$h6("ERICA interpretation:"),
        tags$ul(
          tags$li("≥2 suggests abnormal findings")
        )
      )
    })
  })
  
  ### Calculate PCA ---------------
  
  observeEvent(input$pca_calculate, {
    pca_left <- as.numeric(substr(input$pca_left_singlecalc, 1, 1))
    pca_right <- as.numeric(substr(input$pca_right_singlecalc, 1, 1))
    
    # Initialize result_text variable
    result_text <- ""
    
    # Check if scores are equal
    if (pca_right == pca_left) {
      result_text <- paste("Posterior parietal atrophy (Koedam) score =", pca_left, "bilaterally.")
    } else {
      # Determine the side with the greater score and the side with the lesser score
      greater_side <- ifelse(pca_right > pca_left, "right", "left")
      lesser_side <- ifelse(pca_right < pca_left, "right", "left")
      greater_score <- max(pca_left, pca_right)
      lesser_score <- min(pca_left, pca_right)
      
      # Construct the result text with the greater side first
      result_text <- paste("Posterior parietal atrophy (Koedam) score =", greater_score, "on the", 
                           greater_side, "and", lesser_score, "on the", lesser_side, "side.")
    }
    output$pca_result_output <- renderUI({
      tagList(
        h6(result_text)
      )
    })
  })
  
  
  ## Movement calculator single server --------------------

  observeEvent(input$show_image_area_mes_pon_singlecalc, {
    image_movement("area_mes_pon.webp")
  })

  observeEvent(input$show_image_area_mes_pon2_singlecalc, {
    image_movement("area_mes_pon.webp")
  })

  observeEvent(input$show_image_scp_singlecalc, {
    image_movement("picture_scp.webp")
  })

  observeEvent(input$show_image_mcp_singlecalc, {
    image_movement("picture_mcp.webp")
  })

  observeEvent(input$show_image_v3_singlecalc, {
    image_movement("picture_3v.webp")
  })

  observeEvent(input$show_image_fh_singlecalc, {
    image_movement("picture_fh.webp")
  })

  observeEvent(input$show_help_md_singlecalc, {
    image_movement("help_diameters")
  })

  observeEvent(input$show_help_pd_singlecalc, {
    image_movement("help_diameters")
  })

  output$help_image_singlecalc <- renderUI({
    req(image_movement())
    key <- image_movement()
    howto_card <- function(title, img, steps, method) {
      card(
        card_header(tags$b(title)),
        card_body(
          if (!is.null(img)) tags$img(src = img, alt = title, width = "100%"),
          tags$h6(class = "d-flex align-items-center", style = "margin-top: 8px;",
                  icon("circle-info", class = "me-2", style = "color: #676971;"), tags$strong("How to measure")),
          tags$ol(style = "padding-left: 1.2em; margin-bottom: 6px;", lapply(steps, tags$li)),
          tags$p(style = "font-size: 0.85em; color: #555; margin-bottom: 0;",
                 HTML(paste0("Method: ", paste(vapply(method, movement_source_link, character(1)), collapse = "; "), ".")))
        )
      )
    }
    if (key == "help_diameters") {
      howto_card("Midbrain and pons anteroposterior diameters", NULL,
                 c("Midsagittal T1-weighted image.",
                   "Place an elliptical region over the midbrain and another over the pons.",
                   "Draw the long (oblique superior\u2013inferior) axis of each ellipse, then measure the maximal diameter perpendicular to that axis.",
                   "Exclude the collicular plate from the midbrain and the tegmentum from the pons."),
                 "Massey 2013")
    } else {
      h <- movement_howto[[key]]
      if (is.null(h)) tags$img(src = key, alt = "How to measure", width = "100%")
      else howto_card(h$title, key, h$steps, h$method)
    }
  })

  movement_positive <- function(x) {
    if (is.null(x) || length(x) == 0 || is.na(x) || x <= 0) NA_real_ else as.numeric(x)
  }

  # Third ventricle width = mean of the measurements entered (method uses 3)
  v3_parts <- reactive({
    v <- vapply(c("input_v3a_singlecalc", "input_v3b_singlecalc", "input_v3c_singlecalc"),
                function(id) movement_positive(input[[id]]), numeric(1))
    v[!is.na(v)]
  })
  v3_mean <- reactive(if (length(v3_parts()) > 0) mean(v3_parts()) else NA_real_)

  output$v3_mean_singlecalc <- renderUI({
    n <- length(v3_parts())
    req(n > 0)
    tags$div(style = "font-size: 0.85em; color: #553356; margin: -6px 0 10px;",
             tags$b(paste0("Mean ", formatC(v3_mean(), format = "f", digits = 1), " mm")),
             if (n < 3) tags$span(style = "color: #8a5a00;", paste0(" (", n, " of 3; the method uses 3)")))
  })

  movement_values <- reactive({
    m   <- movement_positive(input$input_midbrain_singlecalc)
    p   <- movement_positive(input$input_pons)
    md  <- movement_positive(input$input_md_singlecalc)
    pd  <- movement_positive(input$input_pd_singlecalc)
    scp <- movement_positive(input$input_scp_singlecalc)
    mcp <- movement_positive(input$input_mcp_singlecalc)
    v3  <- v3_mean()
    fh  <- movement_positive(input$input_fh_singlecalc)
    mrpi <- (p / m) * (mcp / scp)
    vals <- c(
      mrpi  = mrpi,
      mrpi2 = mrpi * (v3 / fh),
      mpa   = m / p,
      mida  = m,
      md    = md,
      mdpd  = md / pd,
      mcp   = mcp
    )
    vals[is.finite(vals)]
  })

  # Which calculation was requested last (set by the Calculate buttons)
  movement_selected <- reactiveVal(NULL)
  observeEvent(input$calculate_midbrain_pons_ratio_singlecalc, movement_selected("mpa"))
  observeEvent(input$calculate_mrpi_1_singlecalc, movement_selected("mrpi"))
  observeEvent(input$calculate_mrpi_2_singlecalc, movement_selected("mrpi2"))
  observeEvent(input$calculate_md_pd_singlecalc, movement_selected("mdpd"))
  observeEvent(input$calculate_mcp_singlecalc, movement_selected("mcp"))
  
  movement_needs <- list(
    mpa   = "midbrain and pons surface areas",
    mrpi  = "midbrain and pons surface areas and the widths of the superior and middle cerebellar peduncles",
    mrpi2 = "the MRPI measurements plus the third ventricle (at least one measurement) and frontal horn widths",
    mdpd  = "midbrain and pons AP diameters",
    mcp   = "width of the middle cerebellar peduncles"
  )
  
  output$movement_result_singlecalc <- renderUI({
    sel <- movement_selected()
    req(sel)
    vals <- movement_values()
    # the diameter button also reports the midbrain diameter on its own
    keys <- if (sel == "mdpd") c("md", "mdpd") else sel
    keys <- keys[keys %in% names(vals)]
    if (length(keys) == 0) {
      return(tags$p(style = "margin-top: 12px; color: #8a5a00;",
                    paste0("Please fill in the ", movement_needs[[sel]], ".")))
    }
    res <- lapply(keys, function(k) movement_assess(k, vals[[k]]))
    
    blocks <- lapply(res, function(r) {
      cut_rows <- lapply(seq_len(nrow(r$cuts)), function(i) {
        cu <- r$cuts[i, ]
        tags$tr(
          tags$td(style = "white-space: nowrap;", paste0(movement_op_label(cu$op), " ", cu$value, r$info$unit)),
          tags$td(movement_favours_text(cu$favours, cu$versus)),
          tags$td(HTML(movement_source_link(cu$source))),
          tags$td(paste(c(if (!cu$tested) "Review value, not tested in a cohort", if (nzchar(cu$note)) cu$note), collapse = "; ")),
          tags$td(style = "white-space: nowrap;", if (cu$met) tags$b(style = "color: #553356;", "met") else "not met")
        )
      })
      # Footnotes: only when something needs saying
      notes <- character(0)
      if (isTRUE(r$low_met)) notes <- c(notes, paste0("Below ", r$info$low$value, ", the value reported in MSA (",
          movement_source_link(r$info$low$source), "), but it overlaps with PD and controls"))
      if (nrow(r$opp) > 0) notes <- c(notes, paste0(
          paste0(vapply(r$opp$source, movement_source_link, character(1)), " cutoff (", movement_op_label(r$opp$op), " ", r$opp$value, r$info$unit, ")", collapse = " and "),
          if (r$prim$met) " not met" else " met"))
      marks <- if (length(notes) > 0) paste0(" ", paste(seq_along(notes), collapse = ",")) else ""
      ty <- movement_typical[[r$key]]
      # one abbreviation list for the whole card, at the end of "More"
      abbr <- movement_abbr_line(c(r$info$name, r$verdict, r$prim$favours, r$prim$versus, names(ty$vals), notes,
                                   r$info$about, r$cuts$favours, r$cuts$versus, r$cuts$note))
      small <- "font-size: 0.8em; color: #676971; margin: 0 0 4px;"
      tags$div(
        style = "margin-top: 16px; padding: 14px 16px; background: #f7f3f7; border: 1px solid #dccfdd; border-radius: 10px;",
        tags$div(style = "font-size: 12px; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: #676971;",
                 r$info$name),
        tags$div(style = "display: flex; align-items: center; flex-wrap: wrap; gap: 6px 14px; margin: 2px 0 8px;",
                 tags$span(style = "font-size: 34px; font-weight: 800; line-height: 1.15; color: #553356; font-variant-numeric: tabular-nums;",
                           r$value_txt),
                 tags$span(style = paste0("font-size: 15px; font-weight: 700; padding: 4px 12px; border-radius: 999px; ",
                                          if (r$verdict_met) "background: #553356; color: #ffffff;" else "background: #e6e6e9; color: #444;"),
                           r$verdict, if (nzchar(marks)) tags$sup(trimws(marks))),
                 if (isTRUE(r$low_met)) tags$span(style = "font-size: 14px; font-weight: 600; padding: 3px 10px; border-radius: 999px; border: 1px solid #999; color: #444;",
                                                  r$info$low$label)),
        tags$div(style = "font-size: 0.95em; margin-bottom: 6px;",
                 tags$b("Cutoff "), HTML(paste0(movement_op_label(r$prim$op), " ", r$prim$value, r$info$unit,
                                                " · ", movement_favours_text(r$prim$favours, r$prim$versus),
                                                " · ", movement_source_link(r$prim$source)))),
        if (length(notes) > 0) tags$div(style = "font-size: 0.85em; color: #555; margin-bottom: 6px;",
          lapply(seq_along(notes), function(k) tags$div(HTML(paste0("<sup>", k, "</sup> ", notes[k], "."))))),
        tags$details(
          tags$summary(style = "cursor: pointer; color: #676971; font-size: 0.9em;", "More"),
          tags$p(style = "font-size: 0.85em; color: #444; margin: 6px 0;", r$info$about),
          tags$p(style = "font-size: 0.85em; color: #444; margin: 0 0 6px;",
                 tags$b("Group values: "), HTML(paste0(paste0(names(ty$vals), " ", ty$vals, collapse = " · "),
                                                     " (", ty$stat, ", ", movement_source_link(ty$src), ")."))),
          tags$table(class = "table table-sm", style = "font-size: 0.85em;",
                     tags$thead(tags$tr(tags$th("Cutoff"), tags$th("Comparison"), tags$th("Source"), tags$th("Notes"), tags$th("This value"))),
                     tags$tbody(cut_rows)),
          tags$div(style = "border-top: 1px solid #dccfdd; padding-top: 8px; margin-top: -6px;",
            if (r$info$marker == "PSP") tags$p(style = small, HTML(paste0(
              "Above 80 years, the reliability of published thresholds is uncertain: age-related midbrain atrophy can reduce specificity (",
              movement_source_link("Chougar 2024"), "). MRPI is less age-dependent than the midbrain/pons ratio (",
              movement_source_link("Whitwell 2017"), ")."))),
            tags$p(style = small, "Published cutoffs depend on method, field strength and cohort. They support imaging assessment but are not diagnostic in isolation."),
            if (!is.null(abbr)) tags$p(style = small, tags$b("Abbreviations: "), paste0(as.character(abbr), "."))
          )
        )
      )
    })

    # 1. Measurements outside the plausible range (only those used by this calculation)
    out_of_range <- Filter(Negate(is.null), lapply(movement_inputs_for[[sel]], function(id) {
      v <- if (id == "input_v3_singlecalc") v3_mean() else movement_positive(input[[id]])
      pr <- movement_plausible[[id]]
      if (!is.na(v) && (v < pr$min || v > pr$max)) {
        paste0(pr$label, " ", v, pr$unit, " (usual ", pr$min, "\u2013", pr$max, pr$unit, ")")
      }
    }))
    range_note <- if (length(out_of_range) > 0) {
      tags$div(style = "margin-top: 14px; padding: 10px 14px; background: #fbf1dc; color: #8a5a00; border-radius: 8px;",
               tags$b("Check the measurements: "),
               paste0(paste(out_of_range, collapse = "; "), "."))
    }
    
    tagList(range_note, blocks)
  })
  
  
  
  ## Report buttons -------------------
  
  # Dropdown selection -> Switch tab
  observeEvent(input$tab_selector, {
    updateTabsetPanel(session, "tabs_report", selected = input$tab_selector)
  })
  
  # Order of the report sections (Previous/Next buttons and arrow keys)
  report_tabs <- c("tab_identification", "tab_recent_small_infarcts", "tab_svd_lacunes", "fazekas_chk", 
                   "pvs_chk", "microbleeds_chk", "superficial_siderosis_chk", "tab_gca_report", 
                   "tab_mta_report", "tab_erica_report", "tab_pca_report", "tab_ssvds_report", "tab_report")
  
  go_to_report_tab <- function(step) {
    current_index <- match(input$tabs_report, report_tabs)
    if (is.na(current_index)) return(invisible(NULL))
    new_index <- current_index + step
    if (new_index >= 1 && new_index <= length(report_tabs)) {
      updateTabsetPanel(session, "tabs_report", selected = report_tabs[new_index])
    }
  }
  
  observeEvent(input$prev_report, go_to_report_tab(-1))
  observeEvent(input$next_report, go_to_report_tab(1))
  
  # Keep the section dropdown showing the section that is on screen
  observeEvent(input$tabs_report, {
    if (!identical(input$tab_selector, input$tabs_report)) {
      updateSelectInput(session, "tab_selector", selected = input$tabs_report)
    }
  })
  
  # (The arrow-key shortcuts are in the page header script.)
  
  
  ## Fazekas ---------
  
  fazekas_report_text <- reactive({
    if (!input$fazekas_switch) {
      return("")
    }
    
    # Extract selected values
    periventricular_grade <- as.numeric(sub("^([0-9]) .*", "\\1", input$periventricular_grade))
    deep_white_matter_grade <- as.numeric(sub("^([0-9]) .*", "\\1", input$deep_white_matter_grade))
    
    # Check if both are 0
    if (periventricular_grade == 0 && deep_white_matter_grade == 0) {
      return("No significant T2-FLAIR hyperintensities of presumed vascular origin identified. Fazekas = 0.")
    }
    
    # Determine the severity
    severity_levels <- c("mild", "moderate", "severe")
    fazekas_value <- max(periventricular_grade, deep_white_matter_grade, na.rm = TRUE)
    
    # Initialize the report text
    report_text <- "T2-FLAIR hypersignal of presumed vascular origin:"
    regions_text <- c()
    
    if (periventricular_grade > 0) {
      severity <- severity_levels[periventricular_grade]
      laterality <- input$periventricular_laterality
      distribution <- input$periventricular_distribution
      distribution_text <- ifelse(distribution == "diffuse", "", distribution)
      laterality_text <- ifelse(laterality == "bilateral", "bilaterally", paste("at", laterality))
      periventricular_text <- paste(severity, "in the periventricular", distribution_text, "white matter", laterality_text)
      periventricular_text <- gsub("\\s+", " ", periventricular_text) # Clean extra spaces
      regions_text <- c(regions_text, periventricular_text)
    }
    
    if (deep_white_matter_grade > 0) {
      severity <- severity_levels[deep_white_matter_grade]
      laterality <- input$deep_white_matter_laterality
      distribution <- input$deep_white_matter_distribution
      if (distribution %in% c("corona radiata", "centrum semiovale")) {
        if (laterality == "bilateral") {
          distribution_text <- paste("in the", distribution, "bilaterally")
        } else {
          distribution_text <- paste("in the", laterality, distribution)
        }
      } else {
        laterality_text <- ifelse(laterality == "bilateral", "bilaterally", paste("at", laterality))
        distribution_text <- paste("in the deep white matter", laterality_text)
      }
      deep_text <- paste(severity, distribution_text)
      deep_text <- gsub("\\s+", " ", deep_text) # Clean extra spaces
      regions_text <- c(regions_text, deep_text)
    }
    
    report_text <- paste(report_text, paste(regions_text, collapse = " and "), ". Fazekas =", fazekas_value, ".", sep = " ")
    report_text <- gsub("\\s+\\.", ".", report_text) # Remove space before the period
    
    return(trimws(report_text))
  })
  
  
  ## Recent subcortical infarcts --------
  
  rsi_report_text <- reactive({
    if (input$rsi_switch && !is.null(input$recentsmallinfarct) && length(input$recentsmallinfarct) > 0) {
      
      format_selected_region <- function(region_string) {
        elements <- unlist(strsplit(region_string, " - "))
        structure <- tolower(elements[1])
        
        if (region_string %in% c("Midbrain - Tegmentum - Right", 
                                 "Midbrain - Tegmentum - Midline", 
                                 "Midbrain - Tegmentum - Left", 
                                 "Midbrain - Tectum - Right", 
                                 "Midbrain - Tectum - Midline", 
                                 "Midbrain - Tectum - Left", 
                                 "Pons - Basis - Right", 
                                 "Pons - Basis - Midline", 
                                 "Pons - Basis - Left", 
                                 "Pons - Tegmentum - Right", 
                                 "Pons - Tegmentum - Midline", 
                                 "Pons - Tegmentum - Left")) {
          # TYPE 2
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(topography, "of the", structure, "at", side)
        } else if (region_string %in% c("Medulla - Anterior - Right", 
                                        "Medulla - Anterior - Left", 
                                        "Medulla - Posterior - Right", 
                                        "Medulla - Posterior - Left")) {
          # TYPE 3
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(topography, structure, "at", side)
        } else if (region_string %in% c("Internal capsule - Anterior limb - Right", 
                                        "Internal capsule - Anterior limb - Left", 
                                        "Internal capsule - Genu - Right", 
                                        "Internal capsule - Genu - Left", 
                                        "Internal capsule - Posterior limb - Right", 
                                        "Internal capsule - Posterior limb - Left")) {
          # TYPE 4
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(topography, "of the", side, structure)
        } else if (region_string %in% c("Midbrain - Crus cerebri - Right", 
                                        "Midbrain - Crus cerebri - Left")) {
          # TYPE 5
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(side, topography, "of the", structure)
        } else if (region_string %in% c("Cerebellum - Right", "Cerebellum - Left")) {
          # TYPE 6 (Cerebellum handling)
          side <- tolower(gsub(" hemisphere", "", elements[2]))
          paste(structure, "at", side)
        } else {
          # TYPE 1 (Default)
          if (length(elements) == 3) {
            side <- tolower(elements[3])
            topo <- tolower(elements[2])
            paste(side, topo, structure)
          } else if (length(elements) == 2) {
            side <- tolower(elements[2])
            paste(side, structure)
          } else {
            tolower(structure)
          }
        }
      }
      
      formatted_regions <- sapply(input$recentsmallinfarct, format_selected_region)
      
      n_regions <- length(formatted_regions)
      
      if (n_regions > 1) {
        region_phrase <- paste(formatted_regions, collapse = ", ")
        separator <- ifelse(n_regions > 2, ", ", " ")
        region_phrase <- gsub(", (?!.*,)", paste(separator, "and "), region_phrase, perl = TRUE)
        final_text <- paste0("Recent small subcortical infarcts in the ", region_phrase, ".")
      } else {
        final_text <- paste0("Recent small subcortical infarct in the ", formatted_regions, ".")
      }
      
      final_text <- paste0(toupper(substr(final_text, 1, 1)), substr(final_text, 2, nchar(final_text)))
      
      return(final_text)
      
    } else {
      return("No recent small subcortical infarcts identified.") # Empty return when off or no selection
    }
  })
  
  ## Lacunar infarcts ------
  
  li_report_text <- reactive({
    if (input$li_switch && !is.null(input$lacunar_infarcts) && length(input$lacunar_infarcts) > 0) {
      
      format_selected_region <- function(region_string) {
        elements <- unlist(strsplit(region_string, " - "))
        structure <- tolower(elements[1])
        
        if (region_string %in% c("Midbrain - Tegmentum - Right", 
                                 "Midbrain - Tegmentum - Midline", 
                                 "Midbrain - Tegmentum - Left", 
                                 "Midbrain - Tectum - Right", 
                                 "Midbrain - Tectum - Midline", 
                                 "Midbrain - Tectum - Left", 
                                 "Pons - Basis - Right", 
                                 "Pons - Basis - Midline", 
                                 "Pons - Basis - Left", 
                                 "Pons - Tegmentum - Right", 
                                 "Pons - Tegmentum - Midline", 
                                 "Pons - Tegmentum - Left")) {
          # TYPE 2
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(topography, "of the", structure, "at", side)
        } else if (region_string %in% c("Medulla - Anterior - Right", 
                                        "Medulla - Anterior - Left", 
                                        "Medulla - Posterior - Right", 
                                        "Medulla - Posterior - Left")) {
          # TYPE 3
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(topography, structure, "at", side)
        } else if (region_string %in% c("Internal capsule - Anterior limb - Right", 
                                        "Internal capsule - Anterior limb - Left", 
                                        "Internal capsule - Genu - Right", 
                                        "Internal capsule - Genu - Left", 
                                        "Internal capsule - Posterior limb - Right", 
                                        "Internal capsule - Posterior limb - Left")) {
          # TYPE 4
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(topography, "of the", side, structure)
        } else if (region_string %in% c("Midbrain - Crus cerebri - Right", 
                                        "Midbrain - Crus cerebri - Left")) {
          # TYPE 5
          topography <- tolower(elements[2])
          side <- tolower(elements[3])
          paste(side, topography, "of the", structure)
        } else if (region_string %in% c("Cerebellum - Right", "Cerebellum - Left")) {
          # TYPE 6 (Cerebellum handling)
          side <- tolower(gsub(" hemisphere", "", elements[2]))
          paste(structure, "at", side)
        } else {
          # TYPE 1 (Default)
          if (length(elements) == 3) {
            side <- tolower(elements[3])
            topo <- tolower(elements[2])
            paste(side, topo, structure)
          } else if (length(elements) == 2) {
            side <- tolower(elements[2])
            paste(side, structure)
          } else {
            tolower(structure)
          }
        }
      }
      
      formatted_regions <- sapply(input$lacunar_infarcts, format_selected_region)
      
      n_regions <- length(formatted_regions)
      
      if (n_regions > 1) {
        region_phrase <- paste(formatted_regions, collapse = ", ")
        separator <- ifelse(n_regions > 2, ", ", " ")
        region_phrase <- gsub(", (?!.*,)", paste(separator, "and "), region_phrase, perl = TRUE)
        final_text_li <- paste0("Lacunes of presumed vascular origin in the ", region_phrase, ".")
      } else {
        final_text_li <- paste0("Lacunes of presumed vascular origin in the ", formatted_regions, ".")
      }
      
      final_text_li <- paste0(toupper(substr(final_text_li, 1, 1)), substr(final_text_li, 2, nchar(final_text_li)))
      
      return(final_text_li)
      
    } else {
      return("No lacunes of presumed vascular origin identified.") # Empty return when off or no selection
    }
  })
  
  ## PVS ------------
  
  pvs_report_text <- reactive({
    if (input$pvs_switch) {
      # Define severity scores based on the inputs
      severity_scores <- c(
        which(c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40") == input$pvs_centrum_semiovale) - 1,
        which(c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40") == input$pvs_basal_ganglia) - 1,
        which(c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40") == input$pvs_mesencephalon) - 1
      )
      
      regions <- c("centra semiovalia", "basal ganglia", "mesencephalon")
      severity_data <- data.frame(Region = regions, Score = severity_scores)
      
      relevant_severity_data <- severity_data[severity_data$Score > 0, ]
      
      if (nrow(relevant_severity_data) == 0) {
        return("No perivascular spaces identified.")
      }
      
      relevant_severity_data <- relevant_severity_data[order(-relevant_severity_data$Score), ]
      severity_labels <- c("none", "Mild (1-10)", "Moderate (11-20)", "Frequent (21-40)", "Severe (>40)")
      
      report_parts <- lapply(unique(relevant_severity_data$Score), function(severity) {
        current_regions <- relevant_severity_data$Region[relevant_severity_data$Score == severity]
        severity_label <- severity_labels[severity + 1]
        
        if (length(current_regions) > 1) {
          regions_string <- paste(paste(head(current_regions, -1), collapse=", "), "and", tail(current_regions, 1))
        } else {
          regions_string <- current_regions
        }
        
        if (severity == max(relevant_severity_data$Score)) {
          return(paste0(severity_label, " perivascular spaces in ", regions_string))
        } else {
          return(paste0(tolower(severity_label), " in ", regions_string))
        }
      })
      
      if (length(report_parts) > 1) {
        final_report_text <- paste(paste(head(report_parts, -1), collapse="; "), "; and ", tail(report_parts, 1), sep="")
      } else {
        final_report_text <- report_parts[[1]]
      }
      
      final_report_text <- paste0(toupper(substring(final_report_text, 1, 1)), substring(final_report_text, 2), ".")
      
      return(final_report_text)
    } else {
      return("")
    }
  })
  
  ## Microbleeds --------
  
  # All microbleed fields in the form (one shared list, used everywhere)
  mb_fields <- c(
      "brainstem_definite_right", "brainstem_definite_left", 
      "brainstem_possible_right", "brainstem_possible_left",
      "cerebellum_definite_right", "cerebellum_definite_left", 
      "cerebellum_possible_right", "cerebellum_possible_left",
      "basal_ganglia_definite_right", "basal_ganglia_definite_left", 
      "basal_ganglia_possible_right", "basal_ganglia_possible_left",
      "thalamus_definite_right", "thalamus_definite_left", 
      "thalamus_possible_right", "thalamus_possible_left",
      "internal_capsule_definite_right", "internal_capsule_definite_left", 
      "internal_capsule_possible_right", "internal_capsule_possible_left",
      "external_capsule_definite_right", "external_capsule_definite_left", 
      "external_capsule_possible_right", "external_capsule_possible_left",
      "corpus_callosum_definite_right", "corpus_callosum_definite_left", 
      "corpus_callosum_possible_right", "corpus_callosum_possible_left",
      "deep_pvwhite_definite_right", "deep_pvwhite_definite_left", 
      "deep_pvwhite_possible_right", "deep_pvwhite_possible_left",
      "frontal_definite_right", "frontal_definite_left", 
      "frontal_possible_right", "frontal_possible_left",
      "parietal_definite_right", "parietal_definite_left", 
      "parietal_possible_right", "parietal_possible_left",
      "temporal_definite_right", "temporal_definite_left", 
      "temporal_possible_right", "temporal_possible_left",
      "occipital_definite_right", "occipital_definite_left", 
      "occipital_possible_right", "occipital_possible_left",
      "insula_definite_right", "insula_definite_left", 
      "insula_possible_right", "insula_possible_left"
  )
  
  # Empty field counts as 0
  mb0 <- function(v) if (is.null(v) || length(v) == 0 || is.na(v)) 0 else as.numeric(v)
  
  # Total number of microbleeds, all regions
  mb_total <- reactive({
    sum(vapply(mb_fields, function(id) mb0(input[[id]]), numeric(1)))
  })
  
  # Empty or negative fields go back to 0
  observe({
    for (id in mb_fields) {
      val <- input[[id]]
      if (is.null(val) || is.na(val) || !is.numeric(val) || val < 0) {
        updateNumericInput(session, id, value = 0)
      }
    }
  })
  
  mb_report_text <- reactive({
    if (input$mb_switch) {
      total_microbleeds <- mb_total()
      
      if (total_microbleeds == 0) {
        return("No cerebral microbleeds identified.")
      }
      
      summarize_region <- function(region, definite_right, definite_left, possible_right, possible_left) {
        definite_right <- mb0(definite_right); definite_left <- mb0(definite_left)
        possible_right <- mb0(possible_right); possible_left <- mb0(possible_left)
        entries <- c()
        if (definite_right > 0 || definite_left > 0) {
          definite_list <- c()
          if (definite_right > 0) definite_list <- c(definite_list, paste(definite_right, "right"))
          if (definite_left > 0) definite_list <- c(definite_list, paste(definite_left, "left"))
          entries <- c(entries, paste(paste(definite_list, collapse = ", "), "definite"))
        }
        if (possible_right > 0 || possible_left > 0) {
          possible_list <- c()
          if (possible_right > 0) possible_list <- c(possible_list, paste(possible_right, "right"))
          if (possible_left > 0) possible_list <- c(possible_list, paste(possible_left, "left"))
          entries <- c(entries, paste(paste(possible_list, collapse = ", "), "possible"))
        }
        if (length(entries) > 0) {
          return(paste0(region, " (", paste(entries, collapse = "; "), ")"))
        }
        return(NULL)
      }
      
      format_section <- function(section) {
        if (length(section) > 1) {
          return(paste(paste(head(section, -1), collapse = "; "), "and", tail(section, 1)))
        } else {
          return(section)
        }
      }
      
      infratentorial <- c(
        summarize_region("brainstem", input$brainstem_definite_right, input$brainstem_definite_left, input$brainstem_possible_right, input$brainstem_possible_left),
        summarize_region("cerebellum", input$cerebellum_definite_right, input$cerebellum_definite_left, input$cerebellum_possible_right, input$cerebellum_possible_left)
      )
      
      deep <- c(
        summarize_region("basal ganglia", input$basal_ganglia_definite_right, input$basal_ganglia_definite_left, input$basal_ganglia_possible_right, input$basal_ganglia_possible_left),
        summarize_region("thalamus", input$thalamus_definite_right, input$thalamus_definite_left, input$thalamus_possible_right, input$thalamus_possible_left),
        summarize_region("internal capsule", input$internal_capsule_definite_right, input$internal_capsule_definite_left, input$internal_capsule_possible_right, input$internal_capsule_possible_left),
        summarize_region("external capsule", input$external_capsule_definite_right, input$external_capsule_definite_left, input$external_capsule_possible_right, input$external_capsule_possible_left),
        summarize_region("corpus callosum", input$corpus_callosum_definite_right, input$corpus_callosum_definite_left, input$corpus_callosum_possible_right, input$corpus_callosum_possible_left),
        summarize_region("deep and periventricular white matter", input$deep_pvwhite_definite_right, input$deep_pvwhite_definite_left, input$deep_pvwhite_possible_right, input$deep_pvwhite_possible_left)
      )
      
      lobar <- c(
        summarize_region("frontal", input$frontal_definite_right, input$frontal_definite_left, input$frontal_possible_right, input$frontal_possible_left),
        summarize_region("parietal", input$parietal_definite_right, input$parietal_definite_left, input$parietal_possible_right, input$parietal_possible_left),
        summarize_region("temporal", input$temporal_definite_right, input$temporal_definite_left, input$temporal_possible_right, input$temporal_possible_left),
        summarize_region("occipital", input$occipital_definite_right, input$occipital_definite_left, input$occipital_possible_right, input$occipital_possible_left),
        summarize_region("insula", input$insula_definite_right, input$insula_definite_left, input$insula_possible_right, input$insula_possible_left)
      )
      
      report_details <- c()
      
      if (length(infratentorial) > 0) {
        report_details <- c(report_details, paste("Infratentorial:", format_section(infratentorial)))
      }
      if (length(deep) > 0) {
        report_details <- c(report_details, paste("Deep:", format_section(deep)))
      }
      if (length(lobar) > 0) {
        report_details <- c(report_details, paste("Lobar:", format_section(lobar)))
      }
      
      # Remove any extra spaces before the closing bracket
      formatted_report <- gsub(" +\\.", ".", paste(report_details, collapse = ". "))
      report <- paste0("Number of cerebral microbleeds: ", total_microbleeds, ". [", formatted_report, "].")
      
      return(report)
    } else {
      return("")
    }
  })
  
  
  ## cSS --------
  
  css_report_text <- reactive({
    if (input$css_switch) {
      # Extract numeric value from input
      ss_right <- as.numeric(substr(input$superficial_siderosis_right, 1, 1))
      ss_left <- as.numeric(substr(input$superficial_siderosis_left, 1, 1))
      
      # Calculate total cSS score
      total_css <- ss_right + ss_left
      
      # Generate interpretation based on cSS scores
      if (total_css == 0) {
        report_text <- "No cortical superficial siderosis (cSS) identified."
      } else if (total_css == 1) {
        location <- if (ss_right == 1) {
          "on the right"
        } else {
          "on the left"
        }
        report_text <- paste0("Mild, unifocal cortical superficial siderosis (cSS), score 1 ", location, ". cSS total score = 1.")
      } else {
        location <- if (ss_right == ss_left) {
          paste0("score ", ss_right, " on both hemispheres")
        } else {
          paste0("score ", ss_right, " on the right and ", ss_left, " on the left")
        }
        report_text <- paste0("Severe, multifocal cortical superficial siderosis (cSS), ", location, ". cSS total score = ", total_css, ".")
      }
      
      return(report_text)
    } else {
      return("")  # Return an empty string if the switch is off
    }
  })
  
  ## GCA ------------
  gca_report_text <- reactive({
    if (input$gca_switch) {
      # Collect values directly instead of using reactive() inside reactive()
      sulci_values <- c(
        as.numeric(input$frontal_sulci_right_report),
        as.numeric(input$frontal_sulci_left_report),
        as.numeric(input$parietal_sulci_right_report),
        as.numeric(input$parietal_sulci_left_report),
        as.numeric(input$temporal_sulci_right_report),
        as.numeric(input$temporal_sulci_left_report)
      )
      
      ventricles_values <- c(
        as.numeric(input$frontal_ventricles_right_report),
        as.numeric(input$frontal_ventricles_left_report),
        as.numeric(input$parietal_ventricles_right_report),
        as.numeric(input$parietal_ventricles_left_report),
        as.numeric(input$temporal_ventricles_right_report),
        as.numeric(input$temporal_ventricles_left_report),
        as.numeric(input$third_ventricle_report)
      )
      
      gca_sum_report <- sum(sulci_values, ventricles_values, na.rm = TRUE)
      
      severity_levels <- c("No atrophy", "Mild", "Moderate", "Severe")
      
      sulci_regions <- c("right frontal", "left frontal", "right parieto-occipital",
                         "left parieto-occipital", "right temporal", "left temporal")
      
      ventricles_regions <- c("right frontal", "left frontal", "right parieto-occipital",
                              "left parieto-occipital", "right temporal", "left temporal", "third ventricle")
      
      highest_sulci_regions <- sulci_regions[which(sulci_values == max(sulci_values, na.rm = TRUE))]
      highest_ventricles_regions <- ventricles_regions[which(ventricles_values == max(ventricles_values, na.rm = TRUE))]
      
      # Function to format bilateral regions
      format_regions <- function(regions) {
        unique_regions <- unique(regions)
        bilateral_regions <- c()
        remaining_regions <- c()
        
        for (region in unique_regions) {
          base_region <- sub("^(right|left) ", "", region)
          if (paste("right", base_region) %in% regions && paste("left", base_region) %in% regions) {
            if (!(paste("bilateral", base_region) %in% bilateral_regions)) {
              bilateral_regions <- c(bilateral_regions, paste("bilateral", base_region))
            }
          } else {
            remaining_regions <- c(remaining_regions, region)
          }
        }
        
        final_regions <- c(bilateral_regions, remaining_regions)
        
        if (length(final_regions) == 1) {
          return(final_regions)
        } else if (length(final_regions) == 2) {
          return(paste(final_regions, collapse = " and "))
        } else {
          return(paste(paste(final_regions[-length(final_regions)], collapse = ", "), "and", final_regions[length(final_regions)]))
        }
      }
      
      # Construct sulci text
      max_sulci <- max(sulci_values, na.rm = TRUE)
      severity_index_sulci <- pmin(max_sulci + 1, length(severity_levels)) # Avoid out-of-range index
      
      sulci_text <- if (max_sulci > 0) {
        formatted_sulci <- format_regions(highest_sulci_regions)
        area_word <- ifelse(length(highest_sulci_regions) > 1, "areas", "area")
        paste(severity_levels[severity_index_sulci], "cortical atrophy predominantly in the", formatted_sulci, area_word, ".")
      } else {
        "No cortical atrophy."
      }
      
      # Construct ventricles text
      max_ventricles <- max(ventricles_values, na.rm = TRUE)
      severity_index_ventricles <- pmin(max_ventricles + 1, length(severity_levels)) # Avoid out-of-range index
      
      ventricles_text <- if (max_ventricles > 0) {
        formatted_ventricles <- format_regions(highest_ventricles_regions)
        
        if ("third ventricle" %in% highest_ventricles_regions && length(highest_ventricles_regions) > 1) {
          other_regions <- setdiff(highest_ventricles_regions, "third ventricle")
          area_word <- ifelse(length(other_regions) > 1, "areas", "area")
          formatted_ventricles <- paste(format_regions(other_regions), area_word, "and third ventricle")
        } else if ("third ventricle" %in% highest_ventricles_regions) {
          formatted_ventricles <- "third ventricle"
        } else {
          area_word <- ifelse(length(highest_ventricles_regions) > 1, "areas", "area")
          formatted_ventricles <- paste(formatted_ventricles, area_word)
        }
        
        paste(severity_levels[severity_index_ventricles], "subcortical atrophy predominantly in the", formatted_ventricles, ".")
      } else {
        "No subcortical atrophy."
      }
      
      # Construct the summary part
      format_value_summary <- function(name, right_value, left_value) {
        parts <- c()
        if (right_value > 0) parts <- c(parts, paste("right:", right_value))
        if (left_value > 0) parts <- c(parts, paste("left:", left_value))
        if (length(parts) > 0) return(paste(name, " (", paste(parts, collapse = "; "), ")", sep = ""))
        else return(NULL)
      }
      
      sulci_summary <- c(
        format_value_summary("frontal", sulci_values[1], sulci_values[2]),
        format_value_summary("parieto-occipital", sulci_values[3], sulci_values[4]),
        format_value_summary("temporal", sulci_values[5], sulci_values[6])
      )
      
      ventricles_summary <- c(
        format_value_summary("frontal", ventricles_values[1], ventricles_values[2]),
        format_value_summary("parieto-occipital", ventricles_values[3], ventricles_values[4]),
        format_value_summary("temporal", ventricles_values[5], ventricles_values[6])
      )
      
      if (ventricles_values[7] > 0) {
        ventricles_summary <- c(ventricles_summary, paste("third ventricle:", ventricles_values[7]))
      }
      
      sulci_summary <- paste(na.omit(sulci_summary), collapse = ", ")
      ventricles_summary <- paste(na.omit(ventricles_summary), collapse = ", ")
      
      summary_text <- paste0(
        "Sulci: ", sulci_summary, ". ",
        "Ventricles: ", ventricles_summary, "."
      )
      
      if (sulci_summary == "" && ventricles_summary == "") {
        summary_text <- ""
      }
      
      # Construct the summary part without "Sulci:" if empty
      summary_text_parts <- c()
      if (sulci_summary != "") {
        summary_text_parts <- c(summary_text_parts, paste0("Sulci: ", sulci_summary, "."))
      }
      if (ventricles_summary != "") {
        summary_text_parts <- c(summary_text_parts, paste0("Ventricles: ", ventricles_summary, "."))
      }
      summary_text <- paste(summary_text_parts, collapse = " ")
      
      # Construct final report text
      formatted_gca_text <- paste(
        sulci_text,
        ventricles_text,
        "Global cortical atrophy (GCA) score =", gca_sum_report, ".",
        summary_text
      )
      
      # Remove unnecessary spaces before punctuation
      cleaned_gca_text <- gsub("\\s+(?=\\.)", "", formatted_gca_text, perl = TRUE)
      
      return(cleaned_gca_text)
      
    } else {  
      # If switch is FALSE, return an empty string
      return("")
    }
  })
  
  ## MTA ---------
  
  mta_report_text <- reactive({
    if (input$mta_switch) {
      
      # Extract numeric age
      age <- input$input_age
      
      # Extract numeric MTA scores
      mta_left <- as.numeric(substr(input$mta_left_report, 1, 1))
      mta_right <- as.numeric(substr(input$mta_right_report, 1, 1))
      
      # Age not provided: report the scores with both age cut-offs
      if (is.null(age) || length(age) == 0 || is.na(age) || age <= 0) {
        scores <- if (mta_left == mta_right) {
          paste0("bilateral = ", mta_left)
        } else {
          paste0("left = ", mta_left, " and right = ", mta_right)
        }
        return(paste0("Medial Temporal Atrophy (MTA) score: ", scores,
                      "; age not provided (abnormal if ≥2 under 75 years, or ≥3 from 75 years)."))
      }
      
      # Define abnormality thresholds
      abnormal_threshold <- ifelse(age < 75, 2, 3)
      
      # Determine if left and right are abnormal
      left_abnormal <- mta_left >= abnormal_threshold
      right_abnormal <- mta_right >= abnormal_threshold
      
      # Generate interpretation based on conditions
      if (left_abnormal && right_abnormal && mta_left == mta_right) {
        report_text <- paste0("Medial Temporal Atrophy (MTA) score: bilateral = ", mta_left, 
                              "; abnormal according to the age-related normative range.")
      } else if (left_abnormal && right_abnormal && mta_left != mta_right) {
        report_text <- paste0("Medial Temporal Atrophy (MTA) score: left = ", mta_left, 
                              " (abnormal) and right = ", mta_right, " (abnormal); according to the age-related normative range.")
      } else if (left_abnormal || right_abnormal) {
        abnormal_side <- ifelse(left_abnormal, "left", "right")
        normal_side <- ifelse(left_abnormal, "right", "left")
        abnormal_value <- ifelse(left_abnormal, mta_left, mta_right)
        normal_value <- ifelse(left_abnormal, mta_right, mta_left)
        report_text <- paste0("Medial Temporal Atrophy (MTA) score: ", abnormal_side, " = ", abnormal_value, 
                              " (abnormal) and ", normal_side, " = ", normal_value, 
                              " (normal); according to the age-related normative range.")
      } else {
        if (mta_left == mta_right) {
          report_text <- paste0("Medial Temporal Atrophy (MTA) score: bilateral = ", mta_left, 
                                "; normal according to the age-related normative range.")
        } else {
          report_text <- paste0("Medial Temporal Atrophy (MTA) score: left = ", mta_left, 
                                " and right = ", mta_right, 
                                "; normal according to the age-related normative range.")
        }
      }
      
      return(report_text)
    } else {
      return("")
    }
  })
  
  
  
  ## ERICA ---------
  erica_report_text <- reactive({
    if (input$erica_switch) {
      # Extract ERICA scores
      erica_left <- as.numeric(substr(input$erica_left_report, 1, 1))
      erica_right <- as.numeric(substr(input$erica_right_report, 1, 1))
      
      # Generate clean interpretation
      if (erica_left >= 2 && erica_right >= 2) {
        if (erica_left == erica_right) {
          report_text <- paste0("Entorhinal Cortical Atrophy (ERICA) score: bilateral = ", erica_left, 
                                " (abnormal); may suggest a neurodegenerative condition rather than subjective cognitive decline.")
        } else {
          report_text <- paste0(
            "Entorhinal Cortical Atrophy (ERICA) score: right = ", erica_right, " (", ifelse(erica_right >= 2, "abnormal", "normal"), ") and ",
            "left = ", erica_left, " (", ifelse(erica_left >= 2, "abnormal", "normal"), "); ",
            "may suggest a neurodegenerative condition rather than subjective cognitive decline."
          )
        }
      } else if (erica_left >= 2 || erica_right >= 2) {
        report_text <- paste0(
          "Entorhinal Cortical Atrophy (ERICA) score: right = ", erica_right, " (", ifelse(erica_right >= 2, "abnormal", "normal"), ") and ",
          "left = ", erica_left, " (", ifelse(erica_left >= 2, "abnormal", "normal"), "); ",
          ifelse(erica_left >= 2, "left", "right"), " may suggest a neurodegenerative condition, while ",
          ifelse(erica_left >= 2, "right", "left"), " does not support neurodegenerative pathology over subjective cognitive decline."
        )
      } else {
        if (erica_left == erica_right) {
          report_text <- paste0("Entorhinal Cortical Atrophy (ERICA) score: bilateral = ", erica_left, 
                                " (normal); do not support neurodegenerative pathology over subjective cognitive decline.")
        } else {
          report_text <- paste0(
            "Entorhinal Cortical Atrophy (ERICA) score: right = ", erica_right, " (normal) and ",
            "left = ", erica_left, " (normal); do not support neurodegenerative pathology over subjective cognitive decline."
          )
        }
      }
      
      return(report_text)
    } else {
      return("")
    }
  })
  
  ## PCA (koedam) ----------
  pca_report_text <- reactive({
    # Check if the PCA section switch is on
    if (input$pca_switch) {  # If switch is TRUE, proceed to generate content
      # Extract the numeric part of the PCA scores
      pca_left <- as.numeric(substr(input$pca_left_report, 1, 1))
      pca_right <- as.numeric(substr(input$pca_right_report, 1, 1))
      
      # Initialize the report text variable
      report_text <- ""
      
      # Check if the PCA scores are the same or different and generate text accordingly
      if (pca_left == pca_right) {
        report_text <- paste0("Posterior parietal atrophy (Koedam) score: ", "bilateral = ", pca_left, ".")
      } else {
        if (pca_left > pca_right) {
          report_text <- paste0("Posterior parietal atrophy (Koedam) score: ", "left = ", pca_left, " and right = ", pca_right, ".")
        } else {
          report_text <- paste0("Posterior parietal atrophy (Koedam) score: ", "right = ", pca_right, " and left = ", pca_left, ".")
        }
      }
      
      return(report_text)
    } else {  # If switch is FALSE, do not generate or return an empty string
      return("")
    }
  })
  
  ## summary svd score ----
  
  lacunar_infarcts_score <- reactive({
    if (!is.null(input$lacunar_infarcts) && length(input$lacunar_infarcts) > 0) {
      return(1)  # 1 point if one or more selected
    } else {
      return(0)  # 0 points if none selected
    }
  })
  
  cerebral_microbleeds_score <- reactive({
    total_microbleeds <- mb_total()
    
    if (total_microbleeds > 0) {
      return(1)  # 1 point if any microbleeds are present
    } else {
      return(0)  # 0 points if none
    }
  })
  
  perivascular_spaces_score <- reactive({
    severity_map <- c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40")
    selected_severity <- input$pvs_basal_ganglia
    
    if (selected_severity %in% severity_map[3:5]) {
      return(1)  # 1 point if moderate, frequent, or severe
    } else {
      return(0)  # 0 points if none or mild
    }
  })
  
  white_matter_hyperintensities_score <- reactive({
    periventricular_grade <- as.numeric(sub("^([0-9]) .*", "\\1", input$periventricular_grade))
    deep_white_matter_grade <- as.numeric(sub("^([0-9]) .*", "\\1", input$deep_white_matter_grade))
    
    if (periventricular_grade == 3 || deep_white_matter_grade >= 2) {
      return(1)  # 1 point for the specified conditions
    } else {
      return(0)  # 0 points for other cases
    }
  })
  
  ssvds_report_text <- reactive({
    total_score <- lacunar_infarcts_score() + 
      cerebral_microbleeds_score() + 
      perivascular_spaces_score() + 
      white_matter_hyperintensities_score()
    
    paste0("Summary small vessel disease (SVD) score = ", total_score, 
           ifelse(total_score == 1, " point.", " points."))
  })
  
  
  # Output for summary svd Score
  output$lacunarInfarctsScore <- renderText({
    score <- lacunar_infarcts_score()
    paste(score, ifelse(score == 1, "point", "points"))
  })
  
  output$cerebralMicrobleedsScore <- renderText({
    score <- cerebral_microbleeds_score()
    paste(score, ifelse(score == 1, "point", "points"))
  })
  
  output$perivascularSpacesScore <- renderText({
    score <- perivascular_spaces_score()
    paste(score, ifelse(score == 1, "point", "points"))
  })
  
  output$whiteMatterHyperintensitiesScore <- renderText({
    score <- white_matter_hyperintensities_score()
    paste(score, ifelse(score == 1, "point", "points"))
  })
  
  ## portuguese report -----------
  
  ## pRecent Subcortical Infarcts ---------
  
  rsi_report_text_pt <- reactive({
    if (input$rsi_switch && !is.null(input$recentsmallinfarct) && length(input$recentsmallinfarct) > 0) {
      
      translate_region <- function(region_string) {
        translation_map <- list(
          "Midbrain - Tegmentum - Right" = "tegmento do mesencéfalo à direita",
          "Midbrain - Tegmentum - Midline" = "tegmento do mesencéfalo na linha média",
          "Midbrain - Tegmentum - Left" = "tegmento do mesencéfalo à esquerda",
          "Midbrain - Tectum - Right" = "tecto do mesencéfalo à direita",
          "Midbrain - Tectum - Midline" = "tecto do mesencéfalo na linha média",
          "Midbrain - Tectum - Left" = "tecto do mesencéfalo à esquerda",
          "Pons - Basis - Right" = "base da ponte à direita",
          "Pons - Basis - Midline" = "base da ponte na linha média",
          "Pons - Basis - Left" = "base da ponte à esquerda",
          "Pons - Tegmentum - Right" = "tegmento da ponte à direita",
          "Pons - Tegmentum - Midline" = "tegmento da ponte na linha média",
          "Pons - Tegmentum - Left" = "tegmento da ponte à esquerda",
          "Medulla - Anterior - Right" = "medula anterior à direita",
          "Medulla - Anterior - Left" = "medula anterior à esquerda",
          "Medulla - Posterior - Right" = "medula posterior à direita",
          "Medulla - Posterior - Left" = "medula posterior à esquerda",
          "Internal capsule - Anterior limb - Right" = "braço anterior da cápsula interna à direita",
          "Internal capsule - Anterior limb - Left" = "braço anterior da cápsula interna à esquerda",
          "Internal capsule - Genu - Right" = "joelho da cápsula interna à direita",
          "Internal capsule - Genu - Left" = "joelho da cápsula interna à esquerda",
          "Internal capsule - Posterior limb - Right" = "braço posterior da cápsula interna à direita",
          "Internal capsule - Posterior limb - Left" = "braço posterior da cápsula interna à esquerda",
          "Midbrain - Crus cerebri - Right" = "crus cerebri do mesencéfalo à direita",
          "Midbrain - Crus cerebri - Left" = "crus cerebri do mesencéfalo à esquerda",
          "Cerebellum - Right" = "cerebelo à direita",
          "Cerebellum - Left" = "cerebelo à esquerda",
          "Centrum semiovale - Frontal - Left" = "centro semioval frontal à esquerda",
          "Centrum semiovale - Frontal - Right" = "centro semioval frontal à direita",
          "Centrum semiovale - Parietal - Left" = "centro semioval parietal à esquerda",
          "Centrum semiovale - Parietal - Right" = "centro semioval parietal à direita",
          "Corona radiata - Frontal - Left" = "corona radiata frontal à esquerda",
          "Corona radiata - Frontal - Right" = "corona radiata frontal à direita",
          "Corona radiata - Parietal - Left" = "corona radiata parietal à esquerda",
          "Corona radiata - Parietal - Right" = "corona radiata parietal à direita",
          "Caudate nucleus - Left" = "núcleo caudado à esquerda",
          "Caudate nucleus - Right" = "núcleo caudado à direita",
          "Thalamus - Anterior - Left" = "tálamo anterior à esquerda",
          "Thalamus - Anterior - Right" = "tálamo anterior à direita",
          "Thalamus - Medial - Left" = "tálamo medial à esquerda",
          "Thalamus - Medial - Right" = "tálamo medial à direita",
          "Thalamus - Lateral - Left" = "tálamo lateral à esquerda",
          "Thalamus - Lateral - Right" = "tálamo lateral à direita",
          "Thalamus - Posterior - Left" = "tálamo posterior à esquerda",
          "Thalamus - Posterior - Right" = "tálamo posterior à direita",
          "Lentiform nucleus - Left" = "núcleo lentiforme à esquerda",
          "Lentiform nucleus - Right" = "núcleo lentiforme à direita",
          "Cerebral peduncle - Left" = "pedúnculo cerebral à esquerda",
          "Cerebral peduncle - Right" = "pedúnculo cerebral à direita",
          "Central tegmentum midbrain" = "tegmento central do mesencéfalo",
          "External capsule - Left" = "cápsula externa à esquerda",
          "External capsule - Right" = "cápsula externa à direita"
        )
        translated <- translation_map[[region_string]]
        if (is.null(translated)) {
          print(paste("Missing translation for:", region_string)) # Debugging
        }
        return(translated)
      }
      
      formatted_regions <- lapply(input$recentsmallinfarct, translate_region)
      formatted_regions <- formatted_regions[!sapply(formatted_regions, is.null)] # Remove NULLs
      
      n_regions <- length(formatted_regions)
      
      if (n_regions > 1) {
        region_phrase <- paste(formatted_regions, collapse = ", ")
        region_phrase <- sub(", ([^,]+)$", " e \\1", region_phrase) # Ensures no comma before "e"
        texto_final <- paste0("Pequenos enfartes subcorticais recentes: ", region_phrase, ".")
      } else if (n_regions == 1) {
        texto_final <- paste0("Pequeno enfarte subcortical recente: ", formatted_regions, ".")
      } else {
        texto_final <- "Sem pequenos enfartes subcorticais recentes."
      }
      
      texto_final <- paste0(toupper(substr(texto_final, 1, 1)), substr(texto_final, 2, nchar(texto_final)))
      
      return(texto_final)
      
    } else {
      return("Sem pequenos enfartes subcorticais recentes.")
    }
  })
  
  ## pLi -----
  
  li_report_text_pt <- reactive({
    if (input$li_switch && !is.null(input$lacunar_infarcts) && length(input$lacunar_infarcts) > 0) {
      
      translate_li_region <- function(region_string) {
        translation_map_li <- list(
          "Centrum semiovale - Frontal - Right" = "centro semioval frontal à direita",
          "Centrum semiovale - Frontal - Left" = "centro semioval frontal à esquerda",
          "Centrum semiovale - Parietal - Right" = "centro semioval parietal à direita",
          "Centrum semiovale - Parietal - Left" = "centro semioval parietal à esquerda",
          "Corona radiata - Frontal - Right" = "corona radiata frontal à direita",
          "Corona radiata - Frontal - Left" = "corona radiata frontal à esquerda",
          "Corona radiata - Parietal - Right" = "corona radiata parietal à direita",
          "Corona radiata - Parietal - Left" = "corona radiata parietal à esquerda",
          "Caudate nucleus - Right" = "núcleo caudado à direita",
          "Caudate nucleus - Left" = "núcleo caudado à esquerda",
          "External capsule - Right" = "cápsula externa à direita",
          "External capsule - Left" = "cápsula externa à esquerda",
          "Internal capsule - Anterior limb - Right" = "braço anterior da cápsula interna à direita",
          "Internal capsule - Anterior limb - Left" = "braço anterior da cápsula interna à esquerda",
          "Internal capsule - Genu - Right" = "joelho da cápsula interna à direita",
          "Internal capsule - Genu - Left" = "joelho da cápsula interna à esquerda",
          "Internal capsule - Posterior limb - Right" = "braço posterior da cápsula interna à direita",
          "Internal capsule - Posterior limb - Left" = "braço posterior da cápsula interna à esquerda",
          "Lentiform nucleus - Right" = "núcleo lentiforme à direita",
          "Lentiform nucleus - Left" = "núcleo lentiforme à esquerda",
          "Thalamus - Anterior - Right" = "tálamo anterior à direita",
          "Thalamus - Anterior - Left" = "tálamo anterior à esquerda",
          "Thalamus - Lateral - Right" = "tálamo lateral à direita",
          "Thalamus - Lateral - Left" = "tálamo lateral à esquerda",
          "Thalamus - Medial - Right" = "tálamo medial à direita",
          "Thalamus - Medial - Left" = "tálamo medial à esquerda",
          "Thalamus - Posterior - Right" = "tálamo posterior à direita",
          "Thalamus - Posterior - Left" = "tálamo posterior à esquerda",
          "Cerebral peduncle - Right" = "pedúnculo cerebral à direita",
          "Cerebral peduncle - Left" = "pedúnculo cerebral à esquerda",
          "Midbrain - Crus cerebri - Right" = "crus cerebri do mesencéfalo à direita",
          "Midbrain - Crus cerebri - Left" = "crus cerebri do mesencéfalo à esquerda",
          "Midbrain - Tegmentum - Right" = "tegmento do mesencéfalo à direita",
          "Midbrain - Tegmentum - Central" = "tegmento do mesencéfalo ao centro",
          "Midbrain - Tegmentum - Left" = "tegmento do mesencéfalo à esquerda",
          "Midbrain - Tectum - Right" = "tecto do mesencéfalo à direita",
          "Midbrain - Tectum - Midline" = "tecto do mesencéfalo na linha média",
          "Midbrain - Tectum - Left" = "tecto do mesencéfalo à esquerda",
          "Pons - Basis - Right" = "base da ponte à direita",
          "Pons - Basis - Midline" = "base da ponte na linha média",
          "Pons - Basis - Left" = "base da ponte à esquerda",
          "Pons - Tegmentum - Right" = "tegmento da ponte à direita",
          "Pons - Tegmentum - Midline" = "tegmento da ponte na linha média",
          "Pons - Tegmentum - Left" = "tegmento da ponte à esquerda",
          "Medulla - Anterior - Right" = "medula anterior à direita",
          "Medulla - Anterior - Left" = "medula anterior à esquerda",
          "Medulla - Posterior - Right" = "medula posterior à direita",
          "Medulla - Posterior - Left" = "medula posterior à esquerda",
          "Cerebellum - Right" = "cerebelo à direita",
          "Cerebellum - Left" = "cerebelo à esquerda"
        )
        translated <- translation_map_li[[region_string]]
        return(translated)
      }
      
      regioes_formatadas <- lapply(input$lacunar_infarcts, translate_li_region)
      regioes_formatadas <- regioes_formatadas[!sapply(regioes_formatadas, is.null)] # Remove NULLs
      
      n_regioes <- length(regioes_formatadas)
      
      if (n_regioes > 1) {
        frase_regiao <- paste(regioes_formatadas, collapse = ", ")
        frase_regiao <- sub(", ([^,]+)$", " e \\1", frase_regiao) # Ensures no comma before "e"
        texto_final_li <- paste0("Lacunas de origem vascular presumida em: ", frase_regiao, ".")
      } else if (n_regioes == 1) {
        texto_final_li <- paste0("Lacuna de origem vascular presumida em: ", regioes_formatadas, ".")
      } else {
        texto_final_li <- "Sem lacunas de origem vascular presumida."
      }
      
      texto_final_li <- paste0(toupper(substr(texto_final_li, 1, 1)), substr(texto_final_li, 2, nchar(texto_final_li)))
      
      return(texto_final_li)
      
    } else {
      return("Sem lacunas de origem vascular presumida.")
    }
  })
  
  ## pFazekas ---------
  
  fazekas_report_text_pt <- reactive({
    if (!input$fazekas_switch) {
      return("")
    }
    
    # Extrair valores selecionados
    periventricular_grade <- as.numeric(sub("^([0-9]) .*", "\\1", input$periventricular_grade))
    deep_white_matter_grade <- as.numeric(sub("^([0-9]) .*", "\\1", input$deep_white_matter_grade))
    
    # Verificar se ambos são 0
    if (periventricular_grade == 0 && deep_white_matter_grade == 0) {
      return("Sem valorizável leucoencefalopatia microangiopática crónica. Fazekas = 0.")
    }
    
    # Determinar a severidade
    severity_levels <- c("leve", "moderado", "marcado")
    fazekas_value <- max(periventricular_grade, deep_white_matter_grade, na.rm = TRUE)
    
    # Inicializar o texto do relatório
    report_text <- "Hipersinal T2-FLAIR de presumível origem microangiopática de predomínio:"
    regions_text <- c()
    
    translate_laterality <- function(laterality) {
      if (laterality == "bilateral") {
        return("bilateral")
      } else if (laterality == "left") {
        return("à esquerda")
      } else if (laterality == "right") {
        return("à direita")
      }
    }
    
    if (periventricular_grade > 0) {
      severity <- severity_levels[periventricular_grade]
      laterality <- translate_laterality(input$periventricular_laterality)
      distribution <- input$periventricular_distribution
      distribution_text <- ifelse(distribution == "diffuse", "", distribution)
      periventricular_text <- paste(severity, "na substância branca periventricular", distribution_text, laterality)
      periventricular_text <- gsub("\\s+", " ", periventricular_text)  # Limpar espaços extras
      regions_text <- c(regions_text, periventricular_text)
    }
    
    if (deep_white_matter_grade > 0) {
      severity <- severity_levels[deep_white_matter_grade]
      laterality <- translate_laterality(input$deep_white_matter_laterality)
      distribution <- input$deep_white_matter_distribution
      if (distribution == "centrum semiovale") {
        distribution_text <- "no centro semiovale"
      } else if (distribution == "corona radiata") {
        distribution_text <- "na coroa radiata"
      } else if (distribution == "diffuse") {
        distribution_text <- "na substância branca profunda"
      } else {
        distribution_text <- ""
      }
      deep_text <- paste(severity, distribution_text, laterality)
      deep_text <- gsub("\\s+", " ", deep_text)  # Limpar espaços extras
      regions_text <- c(regions_text, deep_text)
    }
    
    report_text <- paste0(report_text, " ", paste(regions_text, collapse = " e "), ". Fazekas = ", fazekas_value, ".")
    
    return(trimws(report_text))
  })
  
  ## pPVS ------
  
  pvs_report_text_pt <- reactive({
    if (input$pvs_switch) {
      categories_eng <- c("none = 0", "mild = 1-10", "moderate = 11-20", "frequent = 21-40", "severe = >40")
      categories_pt <- c("nenhum = 0", "ligeiro = 1-10", "moderado = 11-20", "frequente = 21-40", "grave >40")
      
      # Capture inputs
      selected_eng <- c(input$pvs_centrum_semiovale, input$pvs_basal_ganglia, input$pvs_mesencephalon)
      severity_scores <- sapply(selected_eng, function(x) match(x, categories_eng) - 1)
      
      regions <- c("centra semiovalia", "gânglios da base", "mesencéfalo")
      prepositions <- c("nos", "nos", "no")
      severity_data <- data.frame(Região = regions, Pontuação = severity_scores, Preposição = prepositions)
      
      relevant_severity_data <- severity_data[severity_data$Pontuação > 0, ]
      
      if (nrow(relevant_severity_data) == 0) {
        return("Sem valorizável ectasia de espaços perivasculares.")
      }
      
      # Sort by severity level
      relevant_severity_data <- relevant_severity_data[order(-relevant_severity_data$Pontuação), ]
      severity_labels_pt <- c("nenhum", "ligeira", "moderada", "frequente", "marcada")
      
      report_parts <- lapply(unique(relevant_severity_data$Pontuação), function(severity) {
        current_regions <- relevant_severity_data$Região[relevant_severity_data$Pontuação == severity]
        prepositions <- relevant_severity_data$Preposição[relevant_severity_data$Pontuação == severity]
        severity_label <- severity_labels_pt[severity + 1]
        
        regions_with_prepositions <- mapply(function(region, prep) {
          paste(prep, region)
        }, current_regions, prepositions)
        
        regions_string <- if (length(regions_with_prepositions) > 1) {
          paste(paste(head(regions_with_prepositions, -1), collapse=", "), "e", tail(regions_with_prepositions, 1))
        } else {
          regions_with_prepositions
        }
        
        return(paste0(severity_label, " ", regions_string))
      })
      
      final_report_text <- paste("Dilatação de espaços perivasculares:", 
                                 paste(report_parts, collapse=", "))
      
      # Replace last ", " with " e "
      final_report_text <- sub(",([^,]*)$", " e\\1", final_report_text)
      
      final_report_text <- paste0(toupper(substring(final_report_text, 1, 1)), substring(final_report_text, 2), ".")
      
      return(final_report_text)
    } else {
      return("")
    }
  })
  
  ## pmicrobleeds ------
  
  mb_report_text_pt <- reactive({
    if (input$mb_switch) {
      
      total_microbleeds <- mb_total()
      
      if (total_microbleeds == 0) {
        return("Sem microhemorragias parenquimatosas.")
      }
      
      summarize_region <- function(region, definite_right, definite_left, possible_right, possible_left) {
        definite_right <- mb0(definite_right); definite_left <- mb0(definite_left)
        possible_right <- mb0(possible_right); possible_left <- mb0(possible_left)
        entries <- c()
        if (definite_right > 0 || definite_left > 0) {
          definite_list <- c()
          if (definite_right > 0) definite_list <- c(definite_list, paste(definite_right, "direita"))
          if (definite_left > 0) definite_list <- c(definite_list, paste(definite_left, "esquerda"))
          entries <- c(entries, paste(paste(definite_list, collapse = ", "), "definitivas"))
        }
        if (possible_right > 0 || possible_left > 0) {
          possible_list <- c()
          if (possible_right > 0) possible_list <- c(possible_list, paste(possible_right, "direita"))
          if (possible_left > 0) possible_list <- c(possible_list, paste(possible_left, "esquerda"))
          entries <- c(entries, paste(paste(possible_list, collapse = ", "), "possíveis"))
        }
        if (length(entries) > 0) {
          return(paste(region, " (", paste(entries, collapse = "; "), ")", sep = ""))
        }
        return(NULL)
      }
      
      format_section <- function(section) {
        if (length(section) > 1) {
          return(paste(paste(head(section, -1), collapse = ", "), "e", tail(section, 1), sep = " "))
        } else {
          return(section)
        }
      }
      
      infratentorial <- c(
        summarize_region("tronco encefálico", input$brainstem_definite_right, input$brainstem_definite_left, input$brainstem_possible_right, input$brainstem_possible_left),
        summarize_region("cerebelo", input$cerebellum_definite_right, input$cerebellum_definite_left, input$cerebellum_possible_right, input$cerebellum_possible_left)
      )
      
      deep <- c(
        summarize_region("gânglios da base", input$basal_ganglia_definite_right, input$basal_ganglia_definite_left, input$basal_ganglia_possible_right, input$basal_ganglia_possible_left),
        summarize_region("tálamo", input$thalamus_definite_right, input$thalamus_definite_left, input$thalamus_possible_right, input$thalamus_possible_left),
        summarize_region("cápsula interna", input$internal_capsule_definite_right, input$internal_capsule_definite_left, input$internal_capsule_possible_right, input$internal_capsule_possible_left),
        summarize_region("cápsula externa", input$external_capsule_definite_right, input$external_capsule_definite_left, input$external_capsule_possible_right, input$external_capsule_possible_left),
        summarize_region("corpo caloso", input$corpus_callosum_definite_right, input$corpus_callosum_definite_left, input$corpus_callosum_possible_right, input$corpus_callosum_possible_left),
        summarize_region("substância branca profunda e periventricular", input$deep_pvwhite_definite_right, input$deep_pvwhite_definite_left, input$deep_pvwhite_possible_right, input$deep_pvwhite_possible_left)
      )
      
      lobar <- c(
        summarize_region("frontal", input$frontal_definite_right, input$frontal_definite_left, input$frontal_possible_right, input$frontal_possible_left),
        summarize_region("parietal", input$parietal_definite_right, input$parietal_definite_left, input$parietal_possible_right, input$parietal_possible_left),
        summarize_region("temporal", input$temporal_definite_right, input$temporal_definite_left, input$temporal_possible_right, input$temporal_possible_left),
        summarize_region("occipital", input$occipital_definite_right, input$occipital_definite_left, input$occipital_possible_right, input$occipital_possible_left),
        summarize_region("ínsula", input$insula_definite_right, input$insula_definite_left, input$insula_possible_right, input$insula_possible_left)
      )
      
      report_details <- c()
      
      if (length(infratentorial) > 0) {
        report_details <- c(report_details, paste("Infratentoriais:", format_section(infratentorial)))
      }
      if (length(deep) > 0) {
        report_details <- c(report_details, paste("Profundas:", format_section(deep)))
      }
      if (length(lobar) > 0) {
        report_details <- c(report_details, paste("Lobares:", format_section(lobar)))
      }
      
      formatted_report <- paste(report_details, collapse = ". ")
      return(paste0("Número de micro-hemorragias cerebrais: ", total_microbleeds, ". [", formatted_report, "]."))
    } else {
      return("")
    }
  })
  
  ### pcSS ---------
  
  css_report_text_pt <- reactive({
    if (input$css_switch) {
      # Extrair valor numérico do input
      ss_right <- as.numeric(substr(input$superficial_siderosis_right, 1, 1))
      ss_left <- as.numeric(substr(input$superficial_siderosis_left, 1, 1))
      
      # Calcular pontuação total de cSS
      total_css <- ss_right + ss_left
      
      # Gerar interpretação com base nas pontuações de cSS
      if (total_css == 0) {
        report_text <- "Sem siderose superficial cortical."
      } else if (total_css == 1) {
        location <- if (ss_right == 1) {
          "no hemisfério direito"
        } else {
          "no hemisfério esquerdo"
        }
        report_text <- paste0("Siderose superficial cortical (cSS) ligeira, unifocal, grau 1 ", location, ". cSS total = 1.")
      } else {
        location <- if (ss_right == ss_left) {
          paste0("grau ", ss_right, " em ambos os hemisférios")
        } else {
          paste0("grau ", ss_right, " no hemisfério direito e ", ss_left, " no hemisfério esquerdo")
        }
        report_text <- paste0("Siderose superficial cortical (cSS) marcada, multifocal, ", location, ". cSS total = ", total_css, ".")
      }
      
      return(report_text)
    } else {
      return("")  # Retornar uma string vazia se a chave estiver desligada
    }
  })
  
  ### pGCA -----
  
  # GCA Server Portuguese
  gca_report_text_pt <- reactive({
    if (input$gca_switch) {
      # Capture values
      sulci_values <- c(
        as.numeric(input$frontal_sulci_right_report),
        as.numeric(input$frontal_sulci_left_report),
        as.numeric(input$parietal_sulci_right_report),
        as.numeric(input$parietal_sulci_left_report),
        as.numeric(input$temporal_sulci_right_report),
        as.numeric(input$temporal_sulci_left_report)
      )
      
      ventricles_values <- c(
        as.numeric(input$frontal_ventricles_right_report),
        as.numeric(input$frontal_ventricles_left_report),
        as.numeric(input$parietal_ventricles_right_report),
        as.numeric(input$parietal_ventricles_left_report),
        as.numeric(input$temporal_ventricles_right_report),
        as.numeric(input$temporal_ventricles_left_report),
        as.numeric(input$third_ventricle_report)
      )
      
      gca_sum_report <- sum(sulci_values, ventricles_values, na.rm = TRUE)
      
      severity_levels <- c("Sem atrofia", "Leve", "Moderada", "Marcada")
      
      # Regions for naming
      base_regions <- c("frontal", "parieto-occipital", "temporal")
      sulci_reg_map <- c("frontal direito", "frontal esquerdo", 
                         "parieto-occipital direito", "parieto-occipital esquerdo", 
                         "temporal direito", "temporal esquerdo")
      ventricles_reg_map <- c("frontal direito", "frontal esquerdo", 
                              "parieto-occipital direito", "parieto-occipital esquerdo", 
                              "temporal direito", "temporal esquerdo", "terceiro ventrículo")
      
      # Get max values
      max_sulci <- max(sulci_values, na.rm = TRUE)
      max_ventricles <- max(ventricles_values, na.rm = TRUE)
      severity_index_sulci <- pmin(max_sulci + 1, length(severity_levels))
      severity_index_ventricles <- pmin(max_ventricles + 1, length(severity_levels))
      
      # Helper for region phrasing for "predomínio" sentence
      get_predominant_regions_bilateral <- function(values, max_val, reg_names, add_terceiro=FALSE) {
        regs <- c()
        # Only three bilateral regions (frontal, parieto-occipital, temporal)
        for (i in 1:3) {
          idxR <- 2*(i-1)+1
          idxL <- 2*(i-1)+2
          if (values[idxR]==max_val && values[idxL]==max_val && max_val>0) {
            regs <- c(regs, paste(reg_names[i],"bilateral"))
          } else if (values[idxR]==max_val && values[idxL]!=max_val && max_val>0) {
            regs <- c(regs, paste(reg_names[i],"direito"))
          } else if (values[idxR]!=max_val && values[idxL]==max_val && max_val>0) {
            regs <- c(regs, paste(reg_names[i],"esquerdo"))
          }
        }
        if(add_terceiro && values[7]==max_val && max_val>0) {
          regs <- c(regs, "no terceiro ventrículo")
        }
        regs
      }
      
      # Returns a string of regions joined by commas, handling "e" before the last
      join_regions_for_predom <- function(regions) {
        n <- length(regions)
        if (n==0) return("")
        if (n==1) return(regions[1])
        if (n==2) return(paste(regions, collapse=" e "))
        # more than 2
        paste(paste(regions[1:(n-1)], collapse=", "), "e", regions[n])
      }
      
      # SULCI PHRASE
      if (max_sulci == 0) {
        sulci_text <- "Sem atrofia cortical."
      } else {
        sulci_predom_regs <- get_predominant_regions_bilateral(sulci_values, max_sulci, base_regions, add_terceiro=FALSE)
        sulci_predom <- join_regions_for_predom(sulci_predom_regs)
        sulci_text <- paste0(severity_levels[severity_index_sulci], " atrofia cortical de predomínio ", sulci_predom, ".")
      }
      
      # VENTRICLES PHRASE
      if (max_ventricles == 0) {
        ventricles_text <- "Sem atrofia subcortical."
      } else {
        vent_predom_regs <- get_predominant_regions_bilateral(ventricles_values, max_ventricles, base_regions, add_terceiro=TRUE)
        base_regs_predom <- vent_predom_regs[!grepl("^no terceiro ventrículo$", vent_predom_regs)]
        terceiro_present <- "no terceiro ventrículo" %in% vent_predom_regs
        if (length(base_regs_predom) == 0 && terceiro_present) {
          vent_predom <- "no terceiro ventrículo"
        } else if (length(base_regs_predom) == 1 && terceiro_present) {
          vent_predom <- paste(base_regs_predom, "e no terceiro ventrículo")
        } else if (length(base_regs_predom) > 1 && terceiro_present) {
          vent_predom <- paste(
            paste(base_regs_predom, collapse = ", "),
            "e no terceiro ventrículo"
          )
        } else {
          vent_predom <- join_regions_for_predom(base_regs_predom)
        }
        ventricles_text <- paste0(severity_levels[severity_index_ventricles], " atrofia subcortical de predomínio ", vent_predom, ".")
      }
      
      # -- Summary part, keep same ----
      format_value_summary <- function(name, right_value, left_value) {
        parts <- c()
        if (right_value > 0) parts <- c(parts, paste("direito:", right_value))
        if (left_value > 0) parts <- c(parts, paste("esquerdo:", left_value))
        if (length(parts) > 0) return(paste(name, " (", paste(parts, collapse = "; "), ")", sep = ""))
        else return(NULL)
      }
      
      sulci_summary <- c(
        format_value_summary("frontal", sulci_values[1], sulci_values[2]),
        format_value_summary("parieto-occipital", sulci_values[3], sulci_values[4]),
        format_value_summary("temporal", sulci_values[5], sulci_values[6])
      )
      
      ventricles_summary <- c(
        format_value_summary("frontal", ventricles_values[1], ventricles_values[2]),
        format_value_summary("parieto-occipital", ventricles_values[3], ventricles_values[4]),
        format_value_summary("temporal", ventricles_values[5], ventricles_values[6])
      )
      if (ventricles_values[7] > 0) {
        ventricles_summary <- c(ventricles_summary, paste("terceiro ventrículo:", ventricles_values[7]))
      }
      sulci_summary <- paste(na.omit(sulci_summary), collapse = ", ")
      ventricles_summary <- paste(na.omit(ventricles_summary), collapse = ", ")
      
      summary_text_parts <- c()
      if (sulci_summary != "") {
        summary_text_parts <- c(summary_text_parts, paste0("Sulcos: ", sulci_summary, "."))
      }
      if (ventricles_summary != "") {
        summary_text_parts <- c(summary_text_parts, paste0("Ventrículos: ", ventricles_summary, "."))
      }
      summary_text <- paste(summary_text_parts, collapse = " ")
      
      formatted_gca_text <- paste(
        sulci_text,
        ventricles_text,
        "Global cortical atrophy (GCA) =", gca_sum_report, ".",
        summary_text
      )
      
      # Remove unnecessary spaces before punctuation
      cleaned_gca_text <- gsub("\\s+(?=\\.)", "", formatted_gca_text, perl = TRUE)
      return(cleaned_gca_text)
    } else {
      return("")
    }
  })
  
  ### pMTA ----
  
  mta_report_text_pt <- reactive({
    if (input$mta_switch) {
      
      idade <- input$input_age
      
      mta_esquerda <- as.numeric(substr(input$mta_left_report, 1, 1))
      mta_direita <- as.numeric(substr(input$mta_right_report, 1, 1))
      
      # Idade não indicada: indicar os scores com os dois limiares de idade
      if (is.null(idade) || length(idade) == 0 || is.na(idade) || idade <= 0) {
        valores <- if (mta_esquerda == mta_direita) {
          paste0("bilateral = ", mta_esquerda)
        } else {
          paste0("esquerdo = ", mta_esquerda, " e direito = ", mta_direita)
        }
        return(paste0("Medial Temporal Atrophy (MTA): ", valores,
                      "; idade não indicada (alterado se ≥2 abaixo dos 75 anos, ou ≥3 a partir dos 75 anos)."))
      }
      
      limiar_anormal <- ifelse(idade < 75, 2, 3)
      
      esquerda_anormal <- mta_esquerda >= limiar_anormal
      direita_anormal <- mta_direita >= limiar_anormal
      
      if (esquerda_anormal && direita_anormal && mta_esquerda == mta_direita) {
        texto_relatorio <- paste0(
          "Medial Temporal Atrophy (MTA): bilateral = ", mta_esquerda,
          "; alterado face aos valores de referência para a idade."
        )
      } else if (esquerda_anormal && direita_anormal && mta_esquerda != mta_direita) {
        texto_relatorio <- paste0(
          "Medial Temporal Atrophy (MTA): esquerdo = ", mta_esquerda,
          " e direito = ", mta_direita,
          "; alterados face aos valores de referência para a idade."
        )
      } else if (esquerda_anormal || direita_anormal) {
        lado_anormal <- ifelse(esquerda_anormal, "à esquerda", "à direita")
        lado_normal <- ifelse(esquerda_anormal, "à direita", "à esquerda")
        valor_anormal <- ifelse(esquerda_anormal, mta_esquerda, mta_direita)
        valor_normal <- ifelse(esquerda_anormal, mta_direita, mta_esquerda)
        
        texto_relatorio <- paste0(
          "Medial Temporal Atrophy (MTA): ", lado_anormal, " = ", valor_anormal,
          " e ", lado_normal, " = ", valor_normal,
          "; ", lado_anormal, " alterado e ", lado_normal, " adequado face aos valores de referência para a idade."
        )
      } else {
        if (mta_esquerda == mta_direita) {
          texto_relatorio <- paste0(
            "Medial Temporal Atrophy (MTA): bilateral = ", mta_esquerda,
            "; adequado face aos valores de referência para a idade."
          )
        } else {
          texto_relatorio <- paste0(
            "Medial Temporal Atrophy (MTA): esquerdo = ", mta_esquerda,
            " e direito = ", mta_direita,
            "; adequado face aos valores de referência para a idade."
          )
        }
      }
      
      return(texto_relatorio)
    } else {
      return("")
    }
  })
  
  ### pERICA (Escala de Atrofia Cortical Entorrinal) ---------
  erica_report_text_pt <- reactive({
    if (input$erica_switch) {
      erica_esquerda <- as.numeric(substr(input$erica_left_report, 1, 1))
      erica_direita <- as.numeric(substr(input$erica_right_report, 1, 1))
      
      if (erica_esquerda >= 2 && erica_direita >= 2) {
        if (erica_esquerda == erica_direita) {
          texto_relatorio <- paste0(
            "Entorhinal Cortical Atrophy (ERICA): bilateral = ", erica_esquerda,
            "; pode sugerir patologia neurodegenerativa em detrimento de declínio cognitivo subjetivo."
          )
        } else {
          texto_relatorio <- paste0(
            "Entorhinal Cortical Atrophy (ERICA): direito = ", erica_direita,
            " e esquerdo = ", erica_esquerda,
            "; pode sugerir patologia neurodegenerativa em detrimento de declínio cognitivo subjetivo."
          )
        }
      } else if (erica_esquerda >= 2 || erica_direita >= 2) {
        texto_relatorio <- paste0(
          "Entorhinal Cortical Atrophy (ERICA): direito = ", erica_direita,
          " e esquerdo = ", erica_esquerda,
          "; ", ifelse(erica_esquerda >= 2, "à esquerda", "à direita"),
          " pode sugerir patologia neurodegenerativa, enquanto ",
          ifelse(erica_esquerda >= 2, "à direita", "à esquerda"),
          " não apoia patologia neurodegenerativa em detrimento de declínio cognitivo subjetivo."
        )
      } else {
        if (erica_esquerda == erica_direita) {
          texto_relatorio <- paste0(
            "Entorhinal Cortical Atrophy (ERICA): bilateral = ", erica_esquerda,
            "; não apoia patologia neurodegenerativa em detrimento de declínio cognitivo subjetivo."
          )
        } else {
          texto_relatorio <- paste0(
            "Entorhinal Cortical Atrophy (ERICA): direito = ", erica_direita,
            " e esquerdo = ", erica_esquerda,
            "; não apoia patologia neurodegenerativa em detrimento de declínio cognitivo subjetivo."
          )
        }
      }
      
      return(texto_relatorio)
    }
  })
  
  ### PCA (Escala de Atrofia Parietal Posterior - Koedam) ---------
  pca_report_text_pt <- reactive({
    if (input$pca_switch) {
      pca_esquerda <- as.numeric(substr(input$pca_left_report, 1, 1))
      pca_direita <- as.numeric(substr(input$pca_right_report, 1, 1))
      
      texto_relatorio <- ""
      
      if (pca_esquerda == pca_direita) {
        texto_relatorio <- paste0("Posterior parietal atrophy (Koedam): bilateral = ", pca_esquerda, ".")
      } else {
        if (pca_esquerda > pca_direita) {
          texto_relatorio <- paste0("Posterior parietal atrophy (Koedam): esquerdo = ", pca_esquerda, " e direito = ", pca_direita, ".")
        } else {
          texto_relatorio <- paste0("Posterior parietal atrophy (Koedam): direito = ", pca_direita, " e esquerdo = ", pca_esquerda, ".")
        }
      }
      
      return(texto_relatorio)
    } else {
      return("")
    }
  })
  
  ### psSVDs ------
  
  ssvds_report_text_pt <- reactive({
    total_score <- lacunar_infarcts_score() + 
      cerebral_microbleeds_score() + 
      perivascular_spaces_score() + 
      white_matter_hyperintensities_score()
    
    points_text <- ifelse(total_score == 1, "ponto", "pontos")
    
    paste0("Resumo do score da doença de pequenos vasos (SVD) = ", total_score, " ", points_text, ".")
  })
  
  ## final report ------
  
  createStyledBlock <- function(content) {
    return(HTML(paste0(
      '<div style="border: 1px solid #ccc; padding: 15px; margin: 10px 0; border-radius: 5px; background-color: #f9f9f9; font-family: Arial, sans-serif; font-size: 17px; line-height: 2 !important;">',
      content,
      '</div>'
    )))
  }
  
  
  output$final_report <- renderUI({
    lang <- input$lang
    report_content <- NULL
    
    if (lang == "English") {
      if (!is.null(input$rsi_switch) && input$rsi_switch) {
        rsi_content <- rsi_report_text()
        report_content <- ifelse(is.null(report_content), rsi_content, paste(report_content, rsi_content, sep="<br>"))
      }
      if (!is.null(input$li_switch) && input$li_switch) {
        li_content <- li_report_text()
        report_content <- ifelse(is.null(report_content), li_content, paste(report_content, li_content, sep="<br>"))
      }
      if (!is.null(input$fazekas_switch) && input$fazekas_switch) {
        fazekas_content <- fazekas_report_text()
        report_content <- ifelse(is.null(report_content), fazekas_content, paste(report_content, fazekas_content, sep="<br>"))
      }
      if (!is.null(input$pvs_switch) && input$pvs_switch) {
        pvs_content <- pvs_report_text()
        report_content <- ifelse(is.null(report_content), pvs_content, paste(report_content, pvs_content, sep="<br>"))
      }
      if (!is.null(input$mb_switch) && input$mb_switch) {
        mb_content <- mb_report_text()
        report_content <- ifelse(is.null(report_content), mb_content, paste(report_content, mb_content, sep="<br>"))
      }
      if (!is.null(input$css_switch) && input$css_switch) {
        css_content <- css_report_text()
        report_content <- ifelse(is.null(report_content), css_content, paste(report_content, css_content, sep="<br>"))
      }
      if (!is.null(input$gca_switch) && input$gca_switch) {
        gca_content <- gca_report_text()
        report_content <- ifelse(is.null(report_content), gca_content, paste(report_content, gca_content, sep="<br>"))
      }
      if (!is.null(input$mta_switch) && input$mta_switch) {
        mta_content <- mta_report_text()
        report_content <- ifelse(is.null(report_content), mta_content, paste(report_content, mta_content, sep="<br>"))
      }
      if (!is.null(input$erica_switch) && input$erica_switch) {
        erica_content <- erica_report_text()
        report_content <- ifelse(is.null(report_content), erica_content, paste(report_content, erica_content, sep="<br>"))
      }
      if (!is.null(input$pca_switch) && input$pca_switch) {
        pca_content <- pca_report_text()
        report_content <- ifelse(is.null(report_content), pca_content, paste(report_content, pca_content, sep="<br>"))
      }
      if (!is.null(input$ssvds_switch) && input$ssvds_switch) {
        ssvds_content <- ssvds_report_text()
        report_content <- ifelse(is.null(report_content), ssvds_content, paste(report_content, ssvds_content, sep="<br>"))
      }
    } else if (lang == "Português (Portugal)") {
      if (!is.null(input$rsi_switch) && input$rsi_switch) {
        rsi_content <- rsi_report_text_pt()
        report_content <- ifelse(is.null(report_content), rsi_content, paste(report_content, rsi_content, sep="<br>"))
      }
      if (!is.null(input$li_switch) && input$li_switch) {
        li_content <- li_report_text_pt()
        report_content <- ifelse(is.null(report_content), li_content, paste(report_content, li_content, sep="<br>"))
      }
      if (!is.null(input$fazekas_switch) && input$fazekas_switch) {
        fazekas_content <- fazekas_report_text_pt()
        report_content <- ifelse(is.null(report_content), fazekas_content, paste(report_content, fazekas_content, sep="<br>"))
      }
      if (!is.null(input$pvs_switch) && input$pvs_switch) {
        pvs_content <- pvs_report_text_pt()
        report_content <- ifelse(is.null(report_content), pvs_content, paste(report_content, pvs_content, sep="<br>"))
      }
      if (!is.null(input$mb_switch) && input$mb_switch) {
        mb_content <- mb_report_text_pt()
        report_content <- ifelse(is.null(report_content), mb_content, paste(report_content, mb_content, sep="<br>"))
      }
      if (!is.null(input$css_switch) && input$css_switch) {
        css_content <- css_report_text_pt()
        report_content <- ifelse(is.null(report_content), css_content, paste(report_content, css_content, sep="<br>"))
      }
      if (!is.null(input$gca_switch) && input$gca_switch) {
        gca_content <- gca_report_text_pt()
        report_content <- ifelse(is.null(report_content), gca_content, paste(report_content, gca_content, sep="<br>"))
      }
      if (!is.null(input$mta_switch) && input$mta_switch) {
        mta_content <- mta_report_text_pt()
        report_content <- ifelse(is.null(report_content), mta_content, paste(report_content, mta_content, sep="<br>"))
      }
      if (!is.null(input$erica_switch) && input$erica_switch) {
        erica_content <- erica_report_text_pt()
        report_content <- ifelse(is.null(report_content), erica_content, paste(report_content, erica_content, sep="<br>"))
      }
      if (!is.null(input$pca_switch) && input$pca_switch) {
        pca_content <- pca_report_text_pt()
        report_content <- ifelse(is.null(report_content), pca_content, paste(report_content, pca_content, sep="<br>"))
      }
      if (!is.null(input$ssvds_switch) && input$ssvds_switch) {
        ssvds_content <- ssvds_report_text_pt()
        report_content <- ifelse(is.null(report_content), ssvds_content, paste(report_content, ssvds_content, sep="<br>"))
      }
    }
    
    HTML(createStyledBlock(report_content))
  })
  
  ## export to excel -----
  # Reactive expression to gather data
  # Turn any input into a single text value (empty -> "", several -> "a, b")
  val <- function(x) {
    if (is.null(x) || length(x) == 0) return("")
    x <- x[!is.na(x)]
    if (length(x) == 0) return("")
    if (length(x) == 1) return(x)
    paste(as.character(x), collapse = ", ")
  }

  report_data <- reactive({
    data.frame(
      PatientInfo = data.frame(
        Sex = val(input$input_sex),
        Age = val(input$input_age)
      ),
      RSI = data.frame(
        RecentSmallInfarcts = paste(input$recentsmallinfarct, collapse = ", ")
      ),
      LI = data.frame(
        LacunarInfarcts = paste(input$lacunar_infarcts, collapse = ", ")
      ),
      Fazekas = data.frame(
        PeriventricularGrade = val(input$periventricular_grade),
        PeriventricularDistribution = val(input$periventricular_distribution),
        PeriventricularLaterality = val(input$periventricular_laterality),
        DeepWhiteMatterGrade = val(input$deep_white_matter_grade),
        DeepWhiteMatterDistribution = val(input$deep_white_matter_distribution),
        DeepWhiteMatterLaterality = val(input$deep_white_matter_laterality)
      ),
      PVS = data.frame(
        CentrumSemiovale = val(input$pvs_centrum_semiovale),
        BasalGanglia = val(input$pvs_basal_ganglia),
        Mesencephalon = val(input$pvs_mesencephalon)
      ),
      Microbleeds = data.frame(
        BrainstemDefiniteRight = val(input$brainstem_definite_right),
        BrainstemDefiniteLeft = val(input$brainstem_definite_left),
        BrainstemPossibleRight = val(input$brainstem_possible_right),
        BrainstemPossibleLeft = val(input$brainstem_possible_left),
        CerebellumDefiniteRight = val(input$cerebellum_definite_right),
        CerebellumDefiniteLeft = val(input$cerebellum_definite_left),
        CerebellumPossibleRight = val(input$cerebellum_possible_right),
        CerebellumPossibleLeft = val(input$cerebellum_possible_left),
        BasalGangliaDefiniteRight = val(input$basal_ganglia_definite_right),
        BasalGangliaDefiniteLeft = val(input$basal_ganglia_definite_left),
        BasalGangliaPossibleRight = val(input$basal_ganglia_possible_right),
        BasalGangliaPossibleLeft = val(input$basal_ganglia_possible_left),
        ThalamusDefiniteRight = val(input$thalamus_definite_right),
        ThalamusDefiniteLeft = val(input$thalamus_definite_left),
        ThalamusPossibleRight = val(input$thalamus_possible_right),
        ThalamusPossibleLeft = val(input$thalamus_possible_left),
        InternalCapsuleDefiniteRight = val(input$internal_capsule_definite_right),
        InternalCapsuleDefiniteLeft = val(input$internal_capsule_definite_left),
        InternalCapsulePossibleRight = val(input$internal_capsule_possible_right),
        InternalCapsulePossibleLeft = val(input$internal_capsule_possible_left),
        ExternalCapsuleDefiniteRight = val(input$external_capsule_definite_right),
        ExternalCapsuleDefiniteLeft = val(input$external_capsule_definite_left),
        ExternalCapsulePossibleRight = val(input$external_capsule_possible_right),
        ExternalCapsulePossibleLeft = val(input$external_capsule_possible_left),
        CorpusCallosumDefiniteRight = val(input$corpus_callosum_definite_right),
        CorpusCallosumDefiniteLeft = val(input$corpus_callosum_definite_left),
        CorpusCallosumPossibleRight = val(input$corpus_callosum_possible_right),
        CorpusCallosumPossibleLeft = val(input$corpus_callosum_possible_left),
        DeepPVWhiteDefiniteRight = val(input$deep_pvwhite_definite_right),
        DeepPVWhiteDefiniteLeft = val(input$deep_pvwhite_definite_left),
        DeepPVWhitePossibleRight = val(input$deep_pvwhite_possible_right),
        DeepPVWhitePossibleLeft = val(input$deep_pvwhite_possible_left),
        FrontalDefiniteRight = val(input$frontal_definite_right),
        FrontalDefiniteLeft = val(input$frontal_definite_left),
        FrontalPossibleRight = val(input$frontal_possible_right),
        FrontalPossibleLeft = val(input$frontal_possible_left),
        ParietalDefiniteRight = val(input$parietal_definite_right),
        ParietalDefiniteLeft = val(input$parietal_definite_left),
        ParietalPossibleRight = val(input$parietal_possible_right),
        ParietalPossibleLeft = val(input$parietal_possible_left),
        TemporalDefiniteRight = val(input$temporal_definite_right),
        TemporalDefiniteLeft = val(input$temporal_definite_left),
        TemporalPossibleRight = val(input$temporal_possible_right),
        TemporalPossibleLeft = val(input$temporal_possible_left),
        OccipitalDefiniteRight = val(input$occipital_definite_right),
        OccipitalDefiniteLeft = val(input$occipital_definite_left),
        OccipitalPossibleRight = val(input$occipital_possible_right),
        OccipitalPossibleLeft = val(input$occipital_possible_left),
        InsulaDefiniteRight = val(input$insula_definite_right),
        InsulaDefiniteLeft = val(input$insula_definite_left),
        InsulaPossibleRight = val(input$insula_possible_right),
        InsulaPossibleLeft = val(input$insula_possible_left)
      ),
      CSS = data.frame(
        SuperficialSiderosisRight = val(input$superficial_siderosis_right),
        SuperficialSiderosisLeft = val(input$superficial_siderosis_left)
      ),
      GCA = data.frame(
        FrontalSulciRight = val(input$frontal_sulci_right_report),
        FrontalSulciLeft = val(input$frontal_sulci_left_report),
        FrontalVentriclesRight = val(input$frontal_ventricles_right_report),
        FrontalVentriclesLeft = val(input$frontal_ventricles_left_report),
        ParietoSulciRight = val(input$parietal_sulci_right_report),
        ParietoSulciLeft = val(input$parietal_sulci_left_report),
        ParietoVentriclesRight = val(input$parietal_ventricles_right_report),
        ParietoVentriclesLeft = val(input$parietal_ventricles_left_report),
        TemporalSulciRight = val(input$temporal_sulci_right_report),
        TemporalSulciLeft = val(input$temporal_sulci_left_report),
        TemporalVentriclesRight = val(input$temporal_ventricles_right_report),
        TemporalVentriclesLeft = val(input$temporal_ventricles_left_report),
        ThirdVentricle = val(input$third_ventricle_report)
      ),
      MTA = data.frame(
        MTARight = val(input$mta_right_report),
        MTALeft = val(input$mta_left_report)
      ),
      ERICA = data.frame(
        ERICARight = val(input$erica_right_report),
        ERICALeft = val(input$erica_left_report)
      ),
      PCA = data.frame(
        PCARight = val(input$pca_right_report),
        PCALeft = val(input$pca_left_report)
      ),
      SSVDSummary = data.frame(
        SSVDSReport = val(ssvds_report_text())
      )
    )
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("aurorareport_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), ".xlsx", sep = "")
    },
    content = function(file) {
      write_xlsx(report_data(), path = file)
    }
  )
} 

# Run the application 
shinyApp(ui = ui, server = server)
