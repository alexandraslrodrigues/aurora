#!/bin/zsh
# Aurora: save all changes in this folder to GitHub (github.com/alexandraslrodrigues/aurora).
# Double-click this file. It commits everything that changed and pushes it.
# Files listed in .gitignore (tests/, .wrangler/, .DS_Store) are never sent.

cd "$(dirname "$0")" || exit 1
pause_and_exit() { echo ""; read -k 1 -s "?Press any key to close..."; exit "${1:-0}"; }

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Changes to save:"
  git status --short
  echo ""
  MSG="Update Aurora ($(date +%Y-%m-%d))"
  git add -A || pause_and_exit 1
  git commit -q -m "$MSG" -m "Changed: $(git diff --cached --name-only | sed 's|/.*||' | sort -u | tr '\n' ' ')" || { echo "Commit failed."; pause_and_exit 1; }
else
  echo "No new changes in the folder."
fi

# Send everything saved on this computer that GitHub does not have yet (also earlier saves)
git push -u origin main || { echo ""; echo "The changes are saved on this computer, but sending them to GitHub failed (check the internet connection and double-click again)."; pause_and_exit 1; }

echo ""
echo "Saved to GitHub: https://github.com/alexandraslrodrigues/aurora"
pause_and_exit 0
