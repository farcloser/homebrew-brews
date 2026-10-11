# homebrew-brews

The farcloser Homebrew tap: a distribution hub for end-user tools. Nothing a project or a
developer workstation needs is here; that comes through
[limen-install](https://github.com/farcloser/limen-install) and aqua.

## TL;DR

```bash
brew tap farcloser/brews
brew trust farcloser/brews
brew install farcloser/brews/mumbrew
```

Homebrew refuses a formula from a tap it has not been told to trust, hence the second
line.

## Formulas

* [mumbrew](https://github.com/farcloser/mumbrew): a simplistic auto-updater for Homebrew,
  as a service.
* terminal-notifier: our build of
  [julienXX/terminal-notifier](https://github.com/julienXX/terminal-notifier), from its
  release, which mumbrew depends on.

## Releasing

A tap is consumed at `HEAD`: merging to `main` is the release of the tap. A homegrown
formula builds from its upstream's release: `Formula/mumbrew.rb` pins a `tag` and the
`revision` it names, and Renovate moves both to the next tag.

## Development

The repository is governed by [limen](https://github.com/farcloser/limen); install it
through [limen-install](https://github.com/farcloser/limen-install), then:

```bash
just lint   # brew audit and style, with the shared lanes
just fix
just test   # installs the formulas from this checkout; CI's macOS legs only
```

* https://docs.brew.sh/Formula-Cookbook
