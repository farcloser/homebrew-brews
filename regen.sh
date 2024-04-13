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
  local args=(--tlsv1.2 -sSfL --proto "=https" --http2-prior-knowledge)
  # shellcheck disable=SC2015
  [ "$destination" != /dev/stdout ] && [ -e "$destination" ] && {
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

net::download https://raw.githubusercontent.com/Homebrew/homebrew-core/master/Formula/o/openssh.rb ./openssh_origin.rb
net::download https://raw.githubusercontent.com/Homebrew/homebrew-core/master/Formula/t/terminal-notifier.rb ./terminal-notifier_origin.rb

# Not on bottles - homebrew creative vocabulary and corresponding documentation is really hard to make sense out of.
# Folks? What about using plain english software? WTF does any_skip_relocation could possibly mean?
grep -v 'depends_on "openssl' ./openssh_origin.rb | \
  grep -v 'uses_from_macos "krb5"' | \
  grep -v 'with-kerberos5' | \
  grep -v ' cellar: :any_skip_relocation,' | \
  sed -E 's|--with-ssl-dir=.+|--without-openssl|' |
  sed -E 's|desc "(.*)|desc "Farcloser: \1|' > ./openssh.rb

# shellcheck disable=SC2002
cat ./terminal-notifier_origin.rb | \
  sed -E 's|desc "(.*)|desc "Farcloser: \1|' > ./terminal-notifier.rb

chmod a+r ./openssh.rb
rm -f ./openssh_origin.rb

chmod a+r ./terminal-notifier.rb
rm -f ./terminal-notifier_origin.rb
