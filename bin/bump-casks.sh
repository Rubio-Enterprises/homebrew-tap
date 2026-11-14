#!/bin/sh
set -eu
json=$(mktemp)
outdated=$(mktemp)
trap 'rm -f "$json" "$outdated"' EXIT HUP INT TERM
brew livecheck --tap rubio-enterprises/tap --json >"$json"
jq -r '.[] | select(.cask and .version.outdated == true) | [.cask, .version.latest] | @tsv' "$json" >"$outdated"
if [ ! -s "$outdated" ]; then
  echo 'All casks are up to date.'
  exit 0
fi
tab=$(printf '\t')
while IFS="$tab" read -r cask version; do
  test -n "$cask" && test -n "$version"
  echo "Bumping $cask to $version..."
  brew bump-cask-pr --write-only --no-audit --no-style "$@" --version "$version" "rubio-enterprises/tap/$cask"
done <"$outdated"
