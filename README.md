Alfred: AeroSpace Windows Switcher

Fast fuzzy search and focus of AeroSpace windows via Alfred 5.

Installation
1) Install dependencies: AeroSpace (CLI in $PATH) and jq
2) Import from dist/*.alfredworkflow (double‑click the file)
3) Grant Accessibility permission to Alfred (System Settings → Privacy & Security → Accessibility)

Usage
- Keyword: aw
- Type to fuzzy‑search by app name and window title; press Enter to focus the window

Build
./build.zsh

Project structure
- workflow/ (info.plist, aw_alfred.sh, aw_focus.sh)
- dist/ (built .alfredworkflow packages)
- build.zsh (rebuilds the package)

License: MIT


