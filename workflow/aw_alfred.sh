#!/usr/bin/env bash
set -euo pipefail

# Output Alfred Script Filter JSON with all Aerospace windows
# Fields used:
# - title: App name
# - subtitle: Window title
# - match: App name + window title (for fuzzy search)
# - arg: window-id (passed to next action)
# - icon: fileicon for the app bundle

aerospace list-windows --all --format "%{app-pid}|%{window-id}|%{app-name}|%{window-title}" |
while IFS='|' read -r appPid windowId appName windowTitle; do
    if [[ -z "$windowId" ]]; then
        continue
    fi
    # Resolve app bundle path via process path
    appPath="$(ps -o comm= -p "$appPid" 2>/dev/null || true)"
    bundlePath="${appPath%%.app*}.app"

    # Emit one JSON item per window
    jq -nc \
        --arg title "$appName" \
        --arg subtitle "$windowTitle" \
        --arg match "$appName | $windowTitle" \
        --arg arg "$windowId" \
        --arg icon "$bundlePath" \
        '{title:$title, subtitle:$subtitle, match:$match, arg:$arg, icon:{type:"fileicon", path:$icon}}'
done | jq -s '{items: .}'


