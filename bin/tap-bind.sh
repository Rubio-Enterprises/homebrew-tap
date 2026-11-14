#!/bin/sh
set -eu

if [ "${CI:-}" != true ] && [ "${HOMEBREW_TAP_BIND:-}" != 1 ]; then
  echo 'Set HOMEBREW_TAP_BIND=1 to bind the tap on this machine.' >&2
  exit 1
fi
checkout=$(git rev-parse --show-toplevel)
tap="$(brew --repository)/Library/Taps/rubio-enterprises/homebrew-tap"
mkdir -p "$(dirname "$tap")"
if [ -L "$tap" ]; then
  [ "$(readlink "$tap")" = "$checkout" ] || {
    echo "Tap already points elsewhere: $tap" >&2
    exit 1
  }
elif [ -e "$tap" ]; then
  echo "Tap already exists: $tap" >&2
  exit 1
else
  ln -s "$checkout" "$tap"
fi
