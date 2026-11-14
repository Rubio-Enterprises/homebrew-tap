#!/bin/sh
set -eu
bin/tap-bind.sh
ruby scripts/check-source-transports.rb
brew audit --formula --tap rubio-enterprises/tap
brew audit --cask --tap rubio-enterprises/tap
tap=$(brew --repo rubio-enterprises/tap)
test "$(git -C "$tap" rev-parse HEAD)" = "$(git rev-parse HEAD)"
brew style "$tap/Formula" "$tap/Casks"
brew livecheck --cask --tap rubio-enterprises/tap
bin/bump-casks.sh --dry-run
