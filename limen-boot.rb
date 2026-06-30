# limen-boot.rb — Homebrew formula.
# Ships ONLY the bootstrap script (the global aqua config is embedded in it).
# `brew upgrade` re-runs the bootstrap, propagating the new scaffolder version.
#
# Install:  brew install farcloser/tap/limen
# Update:   brew upgrade limen

class LimenBoot < Formula
  desc "Bootstrap limen scaffolder"
  homepage "https://github.com/farcloser/limen-boot"
  url "https://github.com/farcloser/limen-boot/archive/refs/tags/v0.0.1.tar.gz"
  sha256 "REPLACE_WITH_TARBALL_SHA256"
  license "MIT"

  def install
    bin.install "limen-boot" => "limen-boot"
  end

  def post_install
    # idempotent: writes the embedded config + installs/updates the scaffolder.
    # non-fatal so a flaky network can't brick the upgrade.
    system bin/"limen-boot" rescue nil
  end

  def caveats
    <<~EOS
      The scaffolder installs/updates automatically on `brew upgrade`.
      Manual: limen-boot

      Per-project setup (inside a repo) is separate:
        aqua policy allow && aqua i -l
    EOS
  end

  test do
    assert_predicate bin/"limen-boot", :executable?
  end
end
