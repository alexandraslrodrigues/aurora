# Runs the REPORT LOGIC OF THE SHINY APP (web/app/app.R) on every test case,
# with shiny::testServer (no browser needed), and saves the report lines
# (EN and PT) and the Excel columns.
#
# Usage (from the aurora2.0 folder):
#   Rscript tests/shiny-reference.R ../appaurora/web/app/app.R tests/out/cases.json tests/out/shiny.json
suppressPackageStartupMessages({ library(shiny); library(jsonlite); library(writexl) })

args <- commandArgs(trailingOnly = TRUE)
app_file <- args[1]; cases_file <- args[2]; out_file <- args[3]

# app.R contains accents: make sure R reads it as UTF-8
if (!l10n_info()[["UTF-8"]]) invisible(suppressWarnings(Sys.setlocale("LC_CTYPE", "C.UTF-8")))

# Load app.R without building the page (ui) or starting the app
exprs <- parse(app_file, keep.source = FALSE, encoding = "UTF-8")
for (e in exprs) {
  txt <- paste(deparse(e, nlines = 1), collapse = "")
  if (grepl("^ui <-", txt) || grepl("^shinyApp\\(", txt)) next
  eval(e, envir = globalenv())
}

cases <- fromJSON(cases_file, simplifyVector = TRUE, simplifyDataFrame = FALSE)

report_lines <- function(html) {
  inner <- sub("^<div[^>]*>", "", html)
  inner <- sub("</div>\\s*$", "", inner)
  if (!nzchar(inner)) return(character(0))
  strsplit(inner, "<br>", fixed = TRUE)[[1]]
}

results <- vector("list", length(cases))
for (i in seq_along(cases)) {
  cs <- cases[[i]]
  inputs <- cs$shiny
  inputs <- inputs[!vapply(inputs, function(v) is.null(v) || length(v) == 0, logical(1))]
  res <- NULL
  testServer(server, {
    do.call(session$setInputs, c(inputs, list(lang = "English")))
    en <- report_lines(output$final_report$html)
    session$setInputs(lang = "Português (Portugal)")
    pt <- report_lines(output$final_report$html)
    df <- report_data()
    excel <- lapply(names(df), function(n) list(n, df[[n]][1], class(df[[n]])[1]))
    if (i == 1) write_xlsx(df, file.path(dirname(out_file), "shiny_case1.xlsx"))
    res <<- list(name = cs$name, en = en, pt = pt, excel = excel)
  })
  results[[i]] <- res
}
writeLines(toJSON(results, auto_unbox = TRUE, digits = NA), out_file, useBytes = TRUE)
cat(length(results), "cases run in the Shiny logic\n")
