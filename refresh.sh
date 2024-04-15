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

net::download(){
  local url="$1"
  local destination="${2:-/dev/stdout}"
  local no_cache="${3:-}"
  local args=(--tlsv1.2 -sSfL --proto "=https" --http2-prior-knowledge)
  # shellcheck disable=SC2015
  [ "$destination" != /dev/stdout ] && [ -e "$destination" ] && [ ! "$no_cache" ] && {
    logger::info "%s is already there. Nothing to do.\n" "$destination"
  } || {
    printf >&2 "Downloading %s\n" "$url"
    curl "${args[@]}" -o "$destination" "$url" || {
      rm "$destination"
      logger::error >&2 "Download failed!\n"
      return 1
    }
  }
}

mkdir -p _tmp

net::download https://raw.githubusercontent.com/Homebrew/homebrew-core/master/Formula/o/openssh.rb ./_tmp/openssh.rb no_cache
net::download https://raw.githubusercontent.com/Homebrew/homebrew-core/master/Formula/t/terminal-notifier.rb ./_tmp/terminal-notifier.rb no_cache
chmod a+r ./_tmp/*.rb
cp ./_tmp/*.rb .

# Note on bottles - homebrew creative vocabulary and corresponding documentation is really hard to make any sense out of.
#
# "A value of :any or :any_skip_relocation means that the bottle can be safely installed in any Cellar as it did not
# contain any references to the Cellar in which it was originally built"
#
# Seriously? Like - SERIOUSLY? ^^^

patch < openssh.rb.patch
patch < terminal-notifier.rb.patch

# diff --unified _tmp/openssh.rb openssh.rb > openssh.rb.patch
