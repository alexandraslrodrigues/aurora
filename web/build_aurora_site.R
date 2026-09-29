# Build the Shinylive (browser) version of Aurora
# -------------------------------------------------
# Run the whole file in RStudio (open it and click "Source"), or in the Console:
#   source("/Users/alexandrarodrigues/Documents/Documents - Alexandra R/NR/Internato/works/appaurora/appaurora/web/build_aurora_site.R")
#
# It will:
#   1. export web/app/ (app.R + www/) into ../../aurora_site/
#   2. set the page title and icon, and add the "can't start" help message
#   3. start a local test server (press Esc in the Console to stop it)

base    <- "/Users/alexandrarodrigues/Documents/Documents - Alexandra R/NR/Internato/works/appaurora"
web     <- file.path(base, "appaurora", "web")   # inside the GitHub repository
app_dir <- file.path(web, "app")                 # the Shinylive app (app.R + www/): keep ONLY app files here
extras  <- file.path(web, "site_extras")         # loading screen + help message
site    <- file.path(base, "aurora_site")        # build output to upload to Cloudflare (not saved in GitHub)

# 1. Export (start from an empty folder, so no old files are left behind)
if (dir.exists(site)) unlink(site, recursive = TRUE)
shinylive::export(app_dir, site)

# 2. Patch index.html
index <- file.path(site, "index.html")
html  <- paste(readLines(index, warn = FALSE, encoding = "UTF-8"), collapse = "\n")

html <- sub("<title>Shiny App</title>", "<title>Aurora</title>", html, fixed = TRUE)

file.copy(file.path(app_dir, "www", "picture_auroraicon.png"),
          file.path(site, "favicon.png"), overwrite = TRUE)
html <- sub("</head>",
            '  <link rel="icon" type="image/png" href="./favicon.png" />\n  </head>',
            html, fixed = TRUE)

help_html <- paste(readLines(file.path(extras, "loading_help.html"),
                             warn = FALSE, encoding = "UTF-8"), collapse = "\n")
html <- sub("</body>", paste0(help_html, "\n  </body>"), html, fixed = TRUE)

writeLines(html, index, useBytes = TRUE)

# Check Cloudflare Pages drag & drop limits (max 1,000 files, max 25 MiB per file)
files   <- list.files(site, recursive = TRUE, full.names = TRUE)
too_big <- files[file.info(files)$size > 25 * 1024^2]
if (length(files) > 1000) warning("More than 1,000 files: too many for Cloudflare drag & drop upload.")
if (length(too_big) > 0) warning("Files over 25 MB (Cloudflare limit): ", paste(basename(too_big), collapse = ", "))
message(sprintf("\nAurora site built in: %s (%d files, %.0f MB)", site, length(files), sum(file.info(files)$size) / 1e6))

# 3. Test locally
httpuv::runStaticServer(site)
