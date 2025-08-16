#!/usr/bin/env zsh
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "$0")" && pwd -P)"
WF_DIR="$ROOT/workflow"
DIST_DIR="$ROOT/dist"

if [[ ! -d "$WF_DIR" ]]; then
  echo "Workflow directory not found: $WF_DIR" >&2
  exit 1
fi

# Validate plist
plutil -lint "$WF_DIR/info.plist" >/dev/null

# Ensure scripts are executable if they exist
[[ -f "$WF_DIR/aw_alfred.sh" ]] && chmod +x "$WF_DIR/aw_alfred.sh"
[[ -f "$WF_DIR/aw_focus.sh" ]] && chmod +x "$WF_DIR/aw_focus.sh"

# Read name and version from info.plist
wf_name=$(/usr/libexec/PlistBuddy -c 'Print :name' "$WF_DIR/info.plist" 2>/dev/null || echo 'Workflow')
wf_version=$(/usr/libexec/PlistBuddy -c 'Print :version' "$WF_DIR/info.plist" 2>/dev/null || echo '')

# Sanitize filename
sanitized_name=$(echo "$wf_name" | tr ' ' '-' | tr -cd '[:alnum:]-_.')
outfile_name="$sanitized_name"
if [[ -n "$wf_version" ]]; then
  outfile_name="$sanitized_name-$wf_version"
fi

mkdir -p "$DIST_DIR"
outfile="$DIST_DIR/$outfile_name.alfredworkflow"
rm -f "$outfile"

# Package workflow contents (rooted at workflow/)
(
  cd "$WF_DIR"
  /usr/bin/zip -r -q "$outfile" . -x '*.DS_Store' -x '*/.git/*' -x '*/.DS_Store'
)

echo "Built: $outfile"


