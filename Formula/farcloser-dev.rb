class FarcloserDev < Formula
  desc "Farcloser: Top-level brew for developers laptops"
  homepage "https://github.com/farcloser/homebrew-brews"
  url "https://github.com/farcloser/homebrew-brews.git",
    branch: "main"
  version "dev"
  # Bumped when the dependency list changes: the version never does, so this
  # is what makes an installed farcloser-dev show as outdated.
  revision 1

  depends_on "farcloser/brews/mumbrew"
  depends_on "farcloser/brews/ssh-agent"
  depends_on :macos

  def install
    doc.install "README.md"
  end
end
