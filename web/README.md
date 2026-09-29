# Aurora 2.0 — web version

Aurora running entirely in the browser (Shinylive/webR), published at **https://app.aurora-report.com**
(Cloudflare Pages project `aurora-app`). `aurora-report.com` forwards to it (project `auroralanding`, folder `landing_redirect`).

## Folders
- `app/` — the Shiny app (`app.R` + `www/`). Keep only app files here: everything in it is bundled.
- `site_extras/loading_help.html` — loading screen (animated icon + bar) and help message, added to the page by the build script.
- `build_aurora_site.R` — builds the website into `../../aurora_site` (outside this repository) and starts a local test server.
- `landing_redirect/` — tiny site that forwards aurora-report.com to the app.

## Update the app
1. Edit `app/app.R` (or `app/www/`).
2. In RStudio, open `build_aurora_site.R` → **Source**. Check the local address it prints, then press **Esc**.
3. Cloudflare → Workers & Pages → `aurora-app` → **Create deployment** → drag `aurora_site` → deploy.
4. Commit and push to the `aurora2.0` branch.

The previous server version (shinyapps.io) is `aurora130625.R` at the top of this repository.
