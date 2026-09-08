# limen.rb — Homebrew formula.
# Ships ONLY the bootstrap script (the global aqua config is embedded in it).
# `brew upgrade` re-runs the bootstrap, propagating the new scaffolder version.
#
# Install:  brew install farcloser/brews/limen
# Update:   brew upgrade limen

class Limen < Formula
  desc "Install limen scaffolder"
  homepage "https://github.com/farcloser/limen-install"
  url "https://github.com/farcloser/limen-install.git",
    revision: "12b99e74446cdbb1d84a0835e2bba1b30294bd2e"
  version "dev"
  license "MIT"

  def install
    bin.install "limen-install" => "limen-install"
  end

  def post_install
    # idempotent: writes the embedded config + installs/updates the scaffolder.
    # Non-fatal so a flaky network can't brick the upgrade — but rescue ONLY
    # the command failure (Homebrew's system raises BuildError), and say so:
    # a modifier `rescue nil` would swallow real defects too, silently.
    system bin/"limen-install"
  rescue BuildError
    opoo "limen-install failed (flaky network?)"
  end

  def caveats
    <<~EOS
      The scaffolder installs/updates automatically on `brew upgrade`.
      Manual: limen-install
    EOS
  end

  test do
    assert_predicate bin/"limen-install", :executable?
  end
end
