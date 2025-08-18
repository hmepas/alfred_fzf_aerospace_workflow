#!/usr/bin/env bash
set -euo pipefail

# Output Alfred Script Filter JSON with all Aerospace windows
# Fields used:
# - title: App name
# - subtitle: Window title
# - match: App name + window title (for fuzzy search)
# - arg: window-id (passed to next action)
# - icon: fileicon for the app bundle

aerospace list-windows --all --format "%{app-pid}|%{window-id}|%{app-name}|%{window-title}|%{workspace}|%{monitor-name}|%{monitor-id}" |
while IFS='|' read -r appPid windowId appName windowTitle workspace monitorName monitorId; do
    if [[ -z "$windowId" ]]; then
        continue
    fi
    # Resolve app bundle path via process path
    appPath="$(ps -o comm= -p "$appPid" 2>/dev/null || true)"
    bundlePath="${appPath%%.app*}.app"

    # Compose compact prefix: [N:D] where N = workspace, D = first word of monitor name
    displayMonitorWord="${monitorName%% *}"
    if [[ -z "$displayMonitorWord" ]]; then
        displayMonitorWord="M$monitorId"
    fi
    prefix="[$workspace:$displayMonitorWord]"

    # Emit one JSON item per window
    jq -nc \
        --arg title "$prefix $appName" \
        --arg subtitle "$windowTitle" \
        --arg match "$workspace $displayMonitorWord $appName | $windowTitle" \
        --arg arg "$windowId" \
        --arg icon "$bundlePath" \
        '{title:$title, subtitle:$subtitle, match:$match, arg:$arg, icon:{type:"fileicon", path:$icon}}'
done | jq -s '{items: .}'


