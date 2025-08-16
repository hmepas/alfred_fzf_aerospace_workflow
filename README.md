# Alfred: AeroSpace Windows Switcher

Fast fuzzy search and focus of AeroSpace windows via Alfred 5.

## Installation
1) Install dependencies: AeroSpace (CLI in $PATH) and jq
2) Download latest release version form releases on GitHub and install it
3) Grant Accessibility permission to Alfred (System Settings → Privacy & Security → Accessibility)

## Usage
- Keyword: aw
- Type to fuzzy‑search by app name and window title; press Enter to focus the window

## Build Locally
./build.zsh

### Project structure
- workflow/ (info.plist, aw_alfred.sh, aw_focus.sh)
- dist/ (built .alfredworkflow packages for installation)
- build.zsh (rebuilds the package)

License: MIT


