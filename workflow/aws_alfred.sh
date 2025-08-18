#!/usr/bin/env bash
set -euo pipefail

# Output Alfred Script Filter JSON with:
# - All windows for workspaces that have windows (window items)
# - Only workspace items for empty workspaces

QUERY="${1:-${query:-}}"
lower() { tr '[:upper:]' '[:lower:]'; }
read -r -a TOKENS <<< "${QUERY:-}"

# Build windows items (all windows across workspaces)
windows_items=$(
  aerospace list-windows --all --format "%{app-pid}|%{window-id}|%{app-name}|%{window-title}|%{workspace}|%{monitor-name}|%{monitor-id}" |
  while IFS='|' read -r appPid windowId appName windowTitle ws monitorName monitorId; do
    [[ -z "$windowId" ]] && continue
    monWord="${monitorName%% *}"; [[ -z "$monWord" ]] && monWord="M$monitorId"
    # Filtering
    if (( ${#TOKENS[@]} > 0 )); then
      haystack="$(printf "%s" "$ws $monWord $appName $windowTitle" | lower)"
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
    appPath="$(ps -o comm= -p "$appPid" 2>/dev/null || true)"
    bundlePath="${appPath%%.app*}.app"
    prefix="[$ws:$monWord]"
    jq -nc \
      --arg ws "$ws" \
      --arg title "$prefix $appName" \
      --arg subtitle "$windowTitle" \
      --arg arg "win:$windowId" \
      --arg icon "$bundlePath" \
      '{ws:$ws, title:$title, subtitle:$subtitle, arg:$arg, icon:{type:"fileicon", path:$icon}, kind:"win"}'
  done | jq -s '.'
)

# Build workspace items (all workspaces)
workspaces_items=$(
  aerospace list-workspaces --all --format "%{workspace}|%{monitor-name}|%{monitor-id}" | sort |
  while IFS='|' read -r ws wsMonitorName wsMonitorId; do
    monWord="${wsMonitorName%% *}"; [[ -z "$monWord" ]] && monWord="M$wsMonitorId"
    # Filtering
    if (( ${#TOKENS[@]} > 0 )); then
      haystack="$(printf "%s" "$ws $monWord workspace" | lower)"
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
    jq -nc \
      --arg ws "$ws" \
      --arg title "[$ws:$monWord] Workspace" \
      --arg subtitle "Focus workspace $ws" \
      --arg arg "ws:$ws" \
      '{ws:$ws, title:$title, subtitle:$subtitle, arg:$arg, kind:"ws"}'
  done | jq -s '.'
)

# Merge: keep windows for workspaces that have windows, and only empty workspaces as workspace items
jq -n --argjson W "$windows_items" --argjson S "$workspaces_items" '
  ($W | map(.ws) | unique) as $wsWithWindows
  | ($S | map(select(.ws as $w | ($wsWithWindows | index($w) | not)))) as $emptyWs
  | ($W + $emptyWs)
  | map(.wsNum = (try (.ws|tonumber) catch null))
  | sort_by((.wsNum == null), (.wsNum // 1000000000), (.ws // ""), (.title // ""))
  | map(del(.wsNum))
  | {items: .}
'


