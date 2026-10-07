#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★
# (c) 2024 Farcloser <apostasie@farcloser.world>
# Distributed under the terms of the MIT license
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★

# Installs ssh-agent from this checkout, which builds openssh from source (the
# tap ships no bottles), runs openssh's own test, and starts and stops the
# agent's service. It replaces whatever openssh and ssh-agent Homebrew has, so
# the test recipe runs it in CI only.

root="$(cd "$(dirname "${BASH_SOURCE[0]:-$PWD}")" 2>/dev/null 1>&2 && pwd)"
readonly root

. "$root"/lib/log.sh

# brew's auto-update would rebase every tap, this checkout included through
# the symlink below, onto its remote: what is tested must be this tree.
export HOMEBREW_NO_AUTO_UPDATE=1

# The checkout becomes the farcloser/brews tap, so ssh-agent's dependency on
# farcloser/brews/openssh resolves here too, not to the published tap.
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

log::info "Installing ssh-agent, building openssh from source"
brew install farcloser/brews/ssh-agent
brew test farcloser/brews/openssh

log::info "Starting the agent's service"
brew services start farcloser/brews/ssh-agent
for _ in 1 2 3 4 5 6 7 8 9 10; do
  ! pgrep -f "ssh-agent.*agent.sock" >/dev/null || break
  sleep 1
done
pgrep -f "ssh-agent.*agent.sock" >/dev/null || {
  log::error "No ssh-agent listening on agent.sock"
  exit 1
}
brew services stop farcloser/brews/ssh-agent
log::info "Install test successful"
