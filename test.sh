#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

COLOR_RED=1
COLOR_GREEN=2
COLOR_YELLOW=3

# Prefix a date to a log line and output to stderr
logger::stamp(){
  local color="$1"
  local level="$2"
  local i
  shift
  shift
  [ "$TERM" ] && [ -t 2 ] && >&2 tput setaf "$color"
  for i in "$@"; do
    >&2 printf "[%s] [%s] %s\n" "$(date)" "$level" "$i"
  done
  [ "$TERM" ] && [ -t 2 ] && >&2 tput op
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
brew untap farcloser/test 2>/dev/null || true

brew tap-new farcloser/test --no-git >/dev/null 2>&1
ex=
cp -p ./*.rb "$(brew --repository)"/Library/Taps/farcloser/homebrew-test/Formula
for file in "$(brew --repository)"/Library/Taps/farcloser/homebrew-test/Formula/*.rb; do
  brew audit --formula "farcloser/test/$(basename "${file%.rb}")" || {
    logger::error "Audit failed for file $file"
    ex=42
  }
done
brew untap farcloser/test 2>/dev/null

[ ! "$ex" ] || exit "$ex"