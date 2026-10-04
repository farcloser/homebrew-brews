#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★
# (c) 2024 Farcloser <apostasie@farcloser.world>
# Distributed under the terms of the MIT license
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★

root="$(cd "$(dirname "${BASH_SOURCE[0]:-$PWD}")" 2>/dev/null 1>&2 && pwd)"
readonly root

. "$root"/lib/log.sh

net::download(){
  local url="$1"
  local destination="${2:-/dev/stdout}"
  local no_cache="${3:-}"
  # The transport floor every curl of ours carries, plus retries: a plain
  # GET, safe to repeat, and the network is the usual reason it fails.
  local args=(--proto '=https' --tlsv1.2 -fsSL --http2-prior-knowledge --retry 5 --retry-delay 3 --retry-all-errors)
  # shellcheck disable=SC2015
  [ "$destination" != /dev/stdout ] && [ -e "$destination" ] && [ ! -n "$no_cache" ] && {
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

# The pristine upstream formulas, kept between runs: the patches are regenerated against them (see the end).
upstream="$root"/build/upstream
mkdir -p "$upstream"

net::download https://raw.githubusercontent.com/Homebrew/homebrew-core/master/Formula/o/openssh.rb "$upstream"/openssh.rb no_cache
net::download https://raw.githubusercontent.com/Homebrew/homebrew-core/master/Formula/t/terminal-notifier.rb "$upstream"/terminal-notifier.rb no_cache
cp "$upstream"/* "$root/Formula"
chmod a+r "$root"/Formula/*.rb

# Strip the bottle blocks (we build from source, so they are useless), instead of carrying their removal in the
# patches: upstream refreshes the hashes with every release, which would break the patches every time.
perl -0777 -pi -e 's/  bottle do\n(?:    .*\n)+?  end\n\n//' "$root"/Formula/openssh.rb "$root"/Formula/terminal-notifier.rb

patch --directory "$root/Formula" < "$root"/patch/openssh.rb.patch
patch --directory "$root/Formula" < "$root"/patch/terminal-notifier.rb.patch

# Regenerate a patch: diff --unified build/upstream/<f>.rb Formula/<f>.rb > patch/<f>.rb.patch
