class FarcloserDev < Formula
  desc "Farcloser: Top-level brew for developers laptops"
  homepage "https://github.com/farcloser/homebrew-brews"
  url "https://github.com/farcloser/homebrew-brews.git",
    branch: "main"
  version "dev"

  depends_on "farcloser/brews/limen-boot"
  depends_on "farcloser/brews/mumbrew"
  depends_on "farcloser/brews/ssh-agent"
  depends_on :macos

  def install
    doc.install "README.md"
  end
end
