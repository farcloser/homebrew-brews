# This file is the project's own — add recipes below. Keep the import: it
# mounts every shared limen task under `just do ...`.
import '.limen/just/main.just'

# brew audit addresses formulas by tap name, not by path — declare which tap
# this repository is so `just do lint homebrew audit` can register the working
# tree under that name.
export LINT_HOMEBREW_TAP := 'farcloser/brews'

# The FIRST recipe defined here becomes `just`'s default.
lint: do::lint::homebrew::default do::lint::default
fix: do::fix::homebrew::default do::fix::default

# Install the tap's formulas from this checkout and exercise them
# (test-install.sh). CI's macOS legs only: on a laptop the install would
# replace the user's own openssh and ssh-agent.
test:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "$(uname -s)" != 'Darwin' ] || [ -z "${CI:-}" ]; then
        echo "the install test runs on CI's macOS legs only (skipped, not failed)."
        exit 0
    fi
    # shellcheck disable=SC2154 # BREW_BIN is exported by the canonical .justfile (main.just).
    [ -n "${BREW_BIN:-}" ] || { echo "brew was not found on your PATH when just started" >&2; exit 1; }
    # Appended, not prepended: aqua's tools keep precedence.
    PATH="$PATH:$(dirname "$BREW_BIN")" ./test-install.sh

# --- added by limen fix: the recipe the security workflow runs ---
security: do::security::default
