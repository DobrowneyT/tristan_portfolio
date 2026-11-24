#!/usr/bin/env bash
# Build the public résumé PDF (static/resume/) from the master CV.
#
#   scripts/build-resume.sh [path/to/main.tex]
#
# Default master: ~/Documents/Jobs/ai-job-search/documents/cv/main.tex
# Run it locally (needs latexmk + pdflatex), then commit the PDF. The VPS has no
# TeX install and never builds it.
#
# The public copy differs from the master in two ways only: the phone number is
# removed and the email becomes the domain address. The build refuses to
# publish if a phone number is still present.
#
# The web résumé (data/resume.yaml) is a hand transcription of the same
# master. The script records the master's checksum and warns when the master
# changed since the last build, as a reminder to update the YAML too.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MASTER="${1:-$HOME/Documents/Jobs/ai-job-search/documents/cv/main.tex}"
OUT="$ROOT/static/resume/Tristan-Dobrowney-Resume.pdf"
SUM_FILE="$ROOT/scripts/resume-master.sha256"
PUBLIC_EMAIL="tristan@dobrowney.com"

[ -r "$MASTER" ] || { echo "master CV not found: $MASTER" >&2; exit 1; }

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# drop "(306) 555-1234 |" style phone numbers, swap any email for the public one
sed -E \
  -e 's/ ?\(?[0-9]{3}\)?[ .-][0-9]{3}[ .-][0-9]{4} ?\|//g' \
  -e "s/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/$PUBLIC_EMAIL/g" \
  "$MASTER" > "$work/resume.tex"

if grep -qE '\(?[0-9]{3}\)?[ .-][0-9]{3}[ .-][0-9]{4}' "$work/resume.tex"; then
  echo "a phone number is still in the public copy; refusing to publish:" >&2
  grep -nE '\(?[0-9]{3}\)?[ .-][0-9]{3}[ .-][0-9]{4}' "$work/resume.tex" >&2
  exit 1
fi

(cd "$work" && latexmk -pdf -interaction=nonstopmode -halt-on-error resume.tex >/dev/null) || {
  echo "LaTeX build failed; log: $work/resume.log" >&2; trap - EXIT; exit 1; }

mkdir -p "$(dirname "$OUT")"
cp "$work/resume.pdf" "$OUT"
echo "built $OUT"

new_sum="$(sha256sum "$MASTER" | cut -d' ' -f1)"
old_sum="$(cat "$SUM_FILE" 2>/dev/null || true)"
if [ -n "$old_sum" ] && [ "$old_sum" != "$new_sum" ]; then
  echo "NOTE: the master CV changed since the last build. Update data/resume.yaml to match."
fi
echo "$new_sum" > "$SUM_FILE"
