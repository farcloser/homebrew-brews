#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★
# (c) 2024 Farcloser <apostasie@farcloser.world>
# Distributed under the terms of the MIT license
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★

# Installs openssh from this checkout, built from source (the tap ships no
# bottles), and runs its own test. It replaces whatever openssh Homebrew has,
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

log::info "Installing openssh, built from source"
brew install farcloser/brews/openssh
brew test farcloser/brews/openssh
log::info "Install test successful"
