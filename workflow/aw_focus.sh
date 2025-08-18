#!/usr/bin/env bash
set -euo pipefail

target="${1:-}"
if [[ -z "$target" ]]; then
  echo "No argument provided" >&2
  exit 2
fi

case "$target" in
  win:*)
    window_id="${target#win:}"
    aerospace focus --window-id "$window_id"
    ;;
  ws:*)
    ws_name="${target#ws:}"
    aerospace workspace "$ws_name"
    ;;
  *)
    # Backward compatibility: treat as window id
    aerospace focus --window-id "$target"
    ;;
esac


