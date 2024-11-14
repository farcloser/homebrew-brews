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

net::download(){
  local url="$1"
  local destination="${2:-/dev/stdout}"
  local no_cache="${3:-}"
  local args=(--tlsv1.2 -sSfL --proto "=https" --http2-prior-knowledge)
  # shellcheck disable=SC2015
  [ "$destination" != /dev/stdout ] && [ -e "$destination" ] && [ ! "$no_cache" ] && {
    log::info "%s is already there. Nothing to do.\n" "$destination"
  } || {
    printf >&2 "Downloading %s\n" "$url"
    curl "${args[@]}" -o "$destination" "$url" || {
      rm "$destination"
      log::error >&2 "Download failed!\n"
      return 1
    }
  }
}

mkdir -p _tmp

net::download https://raw.githubusercontent.com/Homebrew/homebrew-core/master/Formula/o/openssh.rb "$root"/_tmp/openssh.rb no_cache
net::download https://raw.githubusercontent.com/Homebrew/homebrew-core/master/Formula/t/terminal-notifier.rb "$root"/_tmp/terminal-notifier.rb no_cache
cp "$root"/_tmp/* "$root"
chmod a+r "$root"/*.rb

# Note on bottles - homebrew creative vocabulary and corresponding documentation is really hard to make any sense out of.
#
# "A value of :any or :any_skip_relocation means that the bottle can be safely installed in any Cellar as it did not
# contain any references to the Cellar in which it was originally built"
#
# Seriously? Like - SERIOUSLY? ^^^

patch --directory "$root" < openssh.rb.patch
patch --directory "$root" < terminal-notifier.rb.patch

# diff --unified _tmp/openssh.rb openssh.rb > openssh.rb.patch
