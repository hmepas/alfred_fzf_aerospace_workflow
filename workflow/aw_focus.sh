#!/usr/bin/env bash
set -euo pipefail

window_id="${1:-}"
if [[ -z "$window_id" ]]; then
  echo "No window id provided" >&2
  exit 2
fi

aerospace focus --window-id "$window_id"


