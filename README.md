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

Modified and pinned dependencies:
* [openssh](https://github.com/farcloser/homebrew-brews)
* [terminal-notifier](https://github.com/farcloser/homebrew-brews)

## Releasing

A tap is consumed at `HEAD`: merging to `main` is the release of the tap.
A homegrown formula builds from its upstream's release: `Formula/mumbrew.rb` pins a
`tag` and the `revision` it names, and Renovate moves both to the next tag.

## References

* https://docs.brew.sh/Formula-Cookbook

## Develop

~~You need curl supporting TLSv1.3~~

* use patches and `refresh.sh` to modify forked formulas
