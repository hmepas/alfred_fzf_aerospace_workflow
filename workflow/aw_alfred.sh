#!/usr/bin/env bash
set -euo pipefail

# Output Alfred Script Filter JSON with all Aerospace windows
# Fields used:
# - title: App name
# - subtitle: Window title
# - match: App name + window title (for fuzzy search)
# - arg: window-id (passed to next action)
# - icon: fileicon for the app bundle

QUERY="${1:-${query:-}}"
lower() { tr '[:upper:]' '[:lower:]'; }
read -r -a TOKENS <<< "${QUERY:-}"

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

    # Query filtering (case-insensitive, all tokens must match)
    if (( ${#TOKENS[@]} > 0 )); then
        haystack="$(printf "%s" "$workspace $displayMonitorWord $appName $windowTitle" | lower)"
        pass=1
        for t in "${TOKENS[@]}"; do
            [[ -z "$t" ]] && continue
            tl="$(printf "%s" "$t" | lower)"
            case "$haystack" in
                *"$tl"*) ;;
                *) pass=0; break ;;
            esac
        done
        [[ $pass -eq 1 ]] || continue
    fi

    # Emit one JSON item per window
    jq -nc \
        --arg title "$prefix $appName" \
        --arg subtitle "$windowTitle" \
        --arg match "$workspace $displayMonitorWord $appName | $windowTitle" \
        --arg arg "$windowId" \
        --arg icon "$bundlePath" \
        --arg ws "$workspace" \
        '{title:$title, subtitle:$subtitle, match:$match, arg:$arg, icon:{type:"fileicon", path:$icon}, ws:$ws}'
done | jq -s 'sort_by(.ws, .title) | map(del(.ws)) | {items: .}'


