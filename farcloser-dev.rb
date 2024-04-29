class FarcloserDev < Formula
  desc "Farcloser: Top-level brew for developers laptops"
  homepage "https://github.com/farcloser/homebrew-brews"
  url "https://github.com/farcloser/homebrew-brews.git",
    branch: "main"
  version "dev"

  depends_on "farcloser/brews/mumbrew"
  # depends_on "farcloser/brews/openssh"
  depends_on "farcloser/brews/ssh-agent"
  # Untested on linux, and homebrew is not the right way on linux anyhow
  depends_on :macos

  def install
    doc.install "README.md"
  end
end
