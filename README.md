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

A tap is consumed at `HEAD`: merging to `main` is the release, and every
formula but one tracks its upstream at `branch: "main"`. The one versioning
act is the `revision` pin in `Formula/limen.rb`, which names a commit of
[limen-install](https://github.com/farcloser/limen-install); it is bumped by
hand.

## References

* https://docs.brew.sh/Formula-Cookbook

## Develop

~~You need curl supporting TLSv1.3~~

* use patches and `refresh.sh` to modify forked formulas
