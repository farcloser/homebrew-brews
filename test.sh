#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★
# (c) 2024 Farcloser <apostasie@farcloser.world>
# Distributed under the terms of the MIT license
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★

root="$(cd "$(dirname "${BASH_SOURCE[0]:-$PWD}")" 2>/dev/null 1>&2 && pwd)"
readonly root

. "$root"/lib/log.sh

brew untap farcloser/test >/dev/null 2>&1 || true
brew tap-new farcloser/test --no-git >/dev/null 2>&1 || true
log::info "Auditing formulas"
ex=
# Formulas depending on farcloser/brews/* resolve against the REAL tap, not this fake one — sed the prefix if that
# breaks.
cp -p ./Formula/*.rb "$(brew --repository)"/Library/Taps/farcloser/homebrew-test/Formula
for file in "$(brew --repository)"/Library/Taps/farcloser/homebrew-test/Formula/*.rb; do
  name="$(basename "${file%.rb}")"
  log::info " > $name"
  brew audit --verbose --formula "farcloser/test/$name" || {
    log::error "Audit failed for file $file"
    # openssh is upstream's formula; its audit noise (line length) is not ours.
    [ "$name" == "openssh" ] || ex=42
  }
done
brew untap farcloser/test >/dev/null 2>&1 || true

[ ! -n "$ex" ] || exit "$ex"
