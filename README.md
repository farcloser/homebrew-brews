# homebrew-brews

## TL;DR

```bash
brew install farcloser/brews/XXXX
```

## List of brews

### Provisioning

* [farcloser_dev](https://github.com/farcloser/homebrew-brews): top-level brew for all developers laptops

### Individual brews

Homegrown:
* [mumbrew](https://github.com/farcloser/mumbrew)
* [ssh-agent](https://github.com/farcloser/ssh-agent)

Modified and pinned dependencies:
* [openssh](https://github.com/farcloser/homebrew-brews)
* [terminal-notifier](https://github.com/farcloser/homebrew-brews)

## Releasing

A tap is consumed at `HEAD`: merging to `main` is the release of the tap.
Homegrown formulae build from their upstream's releases: `Formula/limen.rb`,
`Formula/mumbrew.rb` and `Formula/ssh-agent.rb` pin a `tag` and the
`revision` it names, and Renovate moves both to the next tag.
`Formula/farcloser-dev.rb` builds from this tap's own `main`.

## References

* https://docs.brew.sh/Formula-Cookbook

## Develop

~~You need curl supporting TLSv1.3~~

* use patches and `refresh.sh` to modify forked formulas
