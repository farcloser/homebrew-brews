# limen.rb — Homebrew formula.
# Ships ONLY the bootstrap script (the global aqua config is embedded in it).
# The bootstrap itself is a shell step, after the install and after every
# upgrade: Homebrew runs post_install inside its sandbox, which allows writes
# to the Cellar and the formula's log only, and limen-install writes the
# global aqua config under ~/.config and the shell rc.
#
# Install:  brew install farcloser/brews/limen && limen-install
# Update:   brew upgrade limen && limen-install

class Limen < Formula
  desc "Install limen scaffolder"
  homepage "https://github.com/farcloser/limen-install"
  url "https://github.com/farcloser/limen-install.git",
    tag:      "v0.7.3",
    revision: "13be95b5211c1374dfbab360c849cccc5ea53ce1"
  license "MIT"

  def install
    bin.install "limen-install" => "limen-install"
  end

  def caveats
    <<~EOS
      Run the bootstrap once now, and again after every `brew upgrade limen`:
        limen-install
      It installs aqua, pins the matching limen in the global aqua config and
      installs it. Homebrew cannot run it for you: post_install is sandboxed
      away from your home directory, which is where the bootstrap writes.
    EOS
  end

  test do
    assert_predicate bin/"limen-install", :executable?
  end
end
