# AUDIT — homebrew-brews

Date: 2026-07-06. Method: every tracked file reviewed; `just lint` suite and
`brew audit --strict --tap farcloser/brews` executed on macOS; the full
`just lint` aggregate executed on Windows (UTM guest, guest-local copy);
commit validation executed directly (`git-validation -run
DCO,short-subject,dangling-whitespace`, range `origin/main..HEAD`: PASS); the
formula generation pipeline (`refresh.sh` → `tmp/` → `patch/` → `Formula/`)
re-executed for reproducibility; upstream pins checked against
`git ls-remote` and homebrew-core.

## 1. `patch/openssh.rb.patch` is malformed — `refresh.sh` cannot run

The hunk `@@ -21,3 +21,2 @@` (patch line 8) declares three source lines but
carries two, so GNU patch aborts at the next hunk header:
`malformed patch at line 11`. Reproduced: bottle-strip `tmp/openssh.rb`, then
`patch --dry-run < patch/openssh.rb.patch` → exit 2. `refresh.sh` runs under
`errexit` and dies at that step.

The patch was hand-edited (its headers also reference `_tmp/openssh.rb`, a
path that does not exist in this layout). Consequence: `Formula/openssh.rb`
is not reproducible from its declared pipeline. For contrast,
`Formula/terminal-notifier.rb` was verified reproducible — regeneration is
byte-identical to the committed file.

Fix: regenerate the patch from a bottle-stripped copy of `tmp/openssh.rb`
against the committed formula, and correct the stale instruction comment at
the end of `refresh.sh` (`diff --unified tmp/openssh.rb openssh.rb >
openssh.rb.patch` — both paths wrong).

## 2. `brew style` fails: four formulas are mode 600

`Formula/farcloser-dev.rb`, `Formula/limen.rb`, `Formula/openssh.rb`,
`Formula/terminal-notifier.rb` are `600`; `brew style` fails all four with
`FormulaAudit/Files: Incorrect file permissions (600)` — `just lint` and
`just fix` are red on macOS right now. CI is unaffected (fresh checkouts get
644), so this is local working-tree state. Cause: umask-077 generation
(`tmp/*.rb` are also 600); the `chmod a+r` at `refresh.sh:36` postdates the
last generation, and the two hand-written formulas never got it.
Fix: `chmod 644 Formula/*.rb`.

## 3. `brew upgrade` can never upgrade the dev-versioned formulas

`farcloser-dev.rb:6`, `limen.rb:13`, `mumbrew.rb:6`, `ssh-agent.rb:6`: all
pin `version "dev"` forever. Homebrew marks a keg outdated by version (plus
the integer formula `revision` counter); a changed git ref under a constant
version never marks anything outdated. Every `brew upgrade` — including the
nightly cron mumbrew exists to run — is a permanent no-op for these four.
`limen.rb`'s stated contract ("`brew upgrade` re-runs the bootstrap,
propagating the new scaffolder version") is unsatisfiable as written, since
`post_install` only re-runs on an actual upgrade or reinstall.

Fix: make versions meaningful (e.g. `limen.rb` versions track the limen
release the pinned bootstrap installs), or bump the formula `revision`
integer on every source-pin change.

## 4. `Formula/limen.rb` pin is stale

`limen.rb:12` pins limen-install at `e1bd5a1d…`; upstream `main` is
`b4a570f1…` (`git ls-remote`, today). New installs bootstrap an outdated
limen-install (predates the windows-support work in that script). Existing
installs additionally never notice (finding 3).

## 5. Moving-branch sources are unpinned

`farcloser-dev.rb:5`, `mumbrew.rb:5`, `ssh-agent.rb:5`: `branch: "main"`.
Installs are non-reproducible and carry no verifiable checksum, contradicting
both the README's "modified and pinned dependencies" stance and the tap's own
`limen.rb` precedent (`revision:` pin). `farcloser-dev.rb` references this
tap itself, where a commit pin would chase its own tail — if it stays on a
moving branch, that exception should be recorded in the formula;
`mumbrew.rb` and `ssh-agent.rb` have no such structural excuse.

## 6. Service log paths are crossed

`mumbrew.rb:23-24` and `ssh-agent.rb:22-23`: `log_path` (launchd
StandardOutPath — stdout) points at `*.err.log`, while `error_log_path`
(stderr) points at `*.out.log`. Diagnostics land in the oppositely-named
file.

## 7. `mumbrew.rb` test block cannot pass

`mumbrew.rb:28` runs `system "./test.sh"`, but `brew test` executes in an
empty ephemeral testpath — no `test.sh` exists there (the tap-root `test.sh`
is a different file entirely and is not staged either). `brew test mumbrew`
fails unconditionally.

## 8. `terminal-notifier.rb` carries homebrew-core's bottle block

`terminal-notifier.rb:9-22`: the digests are homebrew-core's bottles; this
tap publishes no bottles and declares no `root_url`, so the block is dead
config that misdescribes the artifacts users build. It is also inconsistent:
`refresh.sh` deliberately strips exactly this block from openssh ("we build
from source, so it is useless"). Extend the strip to terminal-notifier — in
`refresh.sh`, not the patch, for the same hash-churn reason documented there.

## 9. `test.sh` is dead and its assumptions are stale

Wired to nothing (the root `Justfile`'s `test:` recipe is empty), and
superseded by `just do lint homebrew audit`, which audits the working tree
via a tap symlink instead of a copy. Its openssh exemption ("solely 'line too
long'") no longer reflects reality — `brew audit --strict --tap
farcloser/brews` passes clean today (verified) — and as written it swallows
*every* openssh audit failure, not just long lines. Remove it, or fold
anything it still adds into the just recipes.

## 10. `refresh.sh` — interface and robustness

- Not reachable through `just`, despite being this repository's central
  workflow (the justfile is the declared interface for all workflows).
- `cp "$root"/tmp/* "$root/Formula"` copies any stray file in `tmp/` into
  `Formula/`; only the two expected files should move.
- `refresh.sh:17` sets a `--tlsv1.2` floor; the house requirement that
  motivated `build-curl` is dependable TLS 1.3 (the README's struck-through
  note documents the retreat).

## 11. `lint commits` mutates repository git config (canonical recipe, surfaced here)

Because this repository ships `.allowed_signers`, the canonical `commits`
recipe runs `git config --add gpg.ssh.allowedSignersFile` on every lint — a
write, by its own comment "convenience wiring, not enforcement". Sandboxed
agent environments deny `.git/config` writes as a git-hardening measure, so
`just do lint commits` cannot run in them, in any repo carrying
`.allowed_signers` — while the actual validation (`git-validation`) needs no
config write at all (verified: runs and passes directly). A lint that
mutates state also contradicts the lint/fix split. Belongs upstream in limen:
move the signer wiring out of the lint (into fix, or a dedicated setup
recipe).

## 12. Minor

- `README.md` names the meta-formula `farcloser_dev`; the formula is
  `farcloser-dev`.
- `.gitignore` carries two identical "added by limen fix: baseline patterns"
  section headers (repeated-append artifact).
- Working tree at audit time: `aqua.yaml` modified but uncommitted; one
  unpushed commit (`c1769b5`).

## Verified clean

limen 12/12 (pinned enforcer, macOS and Windows); `brew audit --strict`
across the tap; lint `just`/`aqua`/`yaml`/`shell`/`dockerfile`/`links` on
macOS; the full `just lint` aggregate green on Windows (guest-local copy —
share-mounted runs wedge in yamlfmt's tree walk, a known WebDAV limitation,
not a repository defect), with the homebrew recipes skipping loudly off-mac
as designed; commit range DCO/subject/whitespace validation PASS;
terminal-notifier generation pipeline in sync; openssh at current
homebrew-core version (10.4p1); limen v0.0.1 windows release assets install
and run in the guest; `.allowed_signers` present and tracked.
