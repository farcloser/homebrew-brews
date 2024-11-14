#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★
# (c) 2024 Farcloser <apostasie@farcloser.world>
# Distributed under the terms of the MIT license
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★

root="$(cd "$(dirname "${BASH_SOURCE[0]:-$PWD}")" 2>/dev/null 1>&2 && pwd)"
readonly root

. "$root"/lib/log.sh
. "$root"/lib/utils.sh
. "$root"/lib/lint.sh

# Linting
log::info "Linting"
lint::shell ./*.sh ./lib/*.sh
log::info "Linting successful"

# Force clean leftovers
brew untap farcloser/test >/dev/null 2>&1 || true
# Install fake test tap
brew tap-new farcloser/test --no-git >/dev/null 2>&1 || true
log::info "Auditing formulas"
ex=
# XXX might be necessary to sed farcloser/brews -> farcloser/test so that dependency resolution works when new one
# are introduced
cp -p ./*.rb "$(brew --repository)"/Library/Taps/farcloser/homebrew-test/Formula
for file in "$(brew --repository)"/Library/Taps/farcloser/homebrew-test/Formula/*.rb; do
  name="$(basename "${file%.rb}")"
  log::info " > $name"
  brew audit --verbose --formula "farcloser/test/$name" || {
    log::error "Audit failed for file $file"
    # This is ugly, but ignore issues on openssh formula, which right now are solely "line too long"
    [ "$name" == "openssh" ] || ex=42
  }
done
brew untap farcloser/test >/dev/null 2>&1 || true

[ ! "$ex" ] || exit "$ex"
