#!/bin/zsh
# Aurora: publish the website (https://aurora-report.com). Double-click this file.
#  1. Rebuilds the reference pages, 404.html and sitemap.xml from site/content/ (tools/build-pages.js)
#  2. Publishes the site folder to Cloudflare Pages (project "aurora-app")
# Needs Node.js. The first time, a browser window opens so you can log in to Cloudflare.

cd "$(dirname "$0")" || exit 1
PROJECT="aurora-app"
BRANCH="main"
WRANGLER="wrangler@4.145.0"

pause_and_exit() { echo ""; read -k 1 -s "?Press any key to close..."; exit "${1:-0}"; }

if ! command -v node >/dev/null 2>&1 || ! command -v npx >/dev/null 2>&1; then
  echo "Node.js is not installed. Install it from https://nodejs.org and double-click this file again."
  pause_and_exit 1
fi

echo "1/2  Updating the reference pages..."
node tools/build-pages.js || { echo ""; echo "The reference pages could not be built (see the message above). Nothing was published."; pause_and_exit 1; }

echo ""
echo "2/2  Publishing to Cloudflare..."
if ! npx --yes "$WRANGLER" whoami 2>/dev/null | grep -qi "associated with the email"; then
  npx --yes "$WRANGLER" login || { echo "Cloudflare login failed. Nothing was published."; pause_and_exit 1; }
fi
npx --yes "$WRANGLER" pages deploy site --project-name "$PROJECT" --branch "$BRANCH" --commit-dirty=true || {
  echo ""
  echo "Publishing failed. Alternative: Cloudflare > Workers & Pages > $PROJECT > Create deployment > drag the site folder."
  open "site"
  pause_and_exit 1
}

echo ""
echo "Published: https://aurora-report.com"
pause_and_exit 0
