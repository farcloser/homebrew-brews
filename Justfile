# This file is the project's own — add recipes below. Keep the import: it
# mounts every shared limen task under `just do ...`.
import '.limen/just/main.just'

# brew audit addresses formulas by tap name, not by path — declare which tap
# this repository is so `just do lint homebrew audit` can register the working
# tree under that name.
export LINT_HOMEBREW_TAP := 'farcloser/brews'

# The FIRST recipe defined here becomes `just`'s default (until then, the
# shared default lists everything). The aggregates CI runs, for example:
lint: do::lint::homebrew::default do::lint::default
fix: do::fix::homebrew::default do::fix::default
test:
