#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

readonly COLOR_RED=1
readonly COLOR_GREEN=2
readonly COLOR_YELLOW=3

# Prefix a date to a log line and output to stderr
logger::stamp(){
  local color="$1"
  local level="$2"
  local i
  shift
  shift

  [ ! "$TERM" ] || [ ! -t 2 ] || >&2 tput setaf "$color" 2>/dev/null || true
  for i in "$@"; do
    >&2 printf "[%s] [%s] %s\n" "$(date 2>/dev/null || true)" "$level" "$i"
  done
  [ ! "$TERM" ] || [ ! -t 2 ] || >&2 tput op 2>/dev/null || true
}

logger::info(){
  logger::stamp "$COLOR_GREEN" "INFO" "$@"
}

logger::warning(){
  logger::stamp "$COLOR_YELLOW" "WARNING" "$@"
}

logger::error(){
  logger::stamp "$COLOR_RED" "ERROR" "$@"
}

lint::dockerfile(){
  >&2 printf " > %s\n" "$@"
  if ! hadolint "$@"; then
    logger::error "Failed linting Dockerfile\n"
    exit 1
  fi
}

lint::shell(){
  >&2 printf " > Shellchecking %s\n" "$@"
  shellcheck -a -x "$@" || {
    logger::error "Failed shellchecking shell script\n"
    return 1
  }
}

# Linting
logger::info "Linting"
lint::shell ./*.sh
logger::info "Linting successful"

# Force clean leftovers
brew untap farcloser/test >/dev/null 2>&1 || true
# Install fake test tap
brew tap-new farcloser/test --no-git >/dev/null 2>&1 || true
logger::info "Auditing formulas"
ex=
# XXX might be necessary to sed farcloser/brews -> farcloser/test so that dependency resolution works when new one
# are introduced
cp -p ./*.rb "$(brew --repository)"/Library/Taps/farcloser/homebrew-test/Formula
for file in "$(brew --repository)"/Library/Taps/farcloser/homebrew-test/Formula/*.rb; do
  name="$(basename "${file%.rb}")"
  logger::info " > $name"
  brew audit --verbose --formula "farcloser/test/$name" || {
    logger::error "Audit failed for file $file"
    # This is ugly, but ignore issues on openssh formula, which right now are solely "line too long"
    [ "$name" == "openssh" ] || ex=42
  }
done
brew untap farcloser/test >/dev/null 2>&1 || true

[ ! "$ex" ] || exit "$ex"
