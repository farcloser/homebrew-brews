#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★
# (c) 2024 Farcloser <apostasie@farcloser.world>
# Distributed under the terms of the MIT license
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★

# Installs mumbrew from this checkout, which builds terminal-notifier from
# source (the tap ships no bottles), runs both formulas' own tests, and starts
# and stops mumbrew's service. It replaces whatever the machine has of them,
# so the test recipe runs it in CI only.

root="$(cd "$(dirname "${BASH_SOURCE[0]:-$PWD}")" 2>/dev/null 1>&2 && pwd)"
readonly root

. "$root"/lib/log.sh

# brew's auto-update would rebase every tap, this checkout included through
# the symlink below, onto its remote: what is tested must be this tree.
export HOMEBREW_NO_AUTO_UPDATE=1

# The checkout becomes the farcloser/brews tap, so what is installed is this
# tree, not the published tap.
tap="$(brew --repository)"/Library/Taps/farcloser/homebrew-brews
readonly tap
if [ -e "$tap" ]; then
  [ "$(cd "$tap" && pwd -P)" == "$(cd "$root" && pwd -P)" ] || {
    log::error "farcloser/brews is already tapped from $tap, not from this checkout"
    exit 1
  }
else
  mkdir -p "$(dirname "$tap")"
  ln -s "$root" "$tap"
fi
# Homebrew refuses formulas from a tap it has not been told to trust.
brew trust farcloser/brews

log::info "Installing mumbrew, building terminal-notifier from source"
brew install farcloser/brews/mumbrew
brew test farcloser/brews/terminal-notifier
brew test farcloser/brews/mumbrew

log::info "Loading mumbrew's service"
brew services start farcloser/brews/mumbrew
brew services list | grep -E '^mumbrew\s' || {
  log::error "mumbrew's service is not listed after start"
  exit 1
}
brew services stop farcloser/brews/mumbrew
log::info "Install test successful"
