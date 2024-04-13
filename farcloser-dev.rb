class FarcloserDev < Formula
  desc "Farcloser: Top-level brew for developers laptops"
  homepage "https://github.com/farcloser/homebrew-brews"
  url "https://github.com/farcloser/homebrew-brews.git",
    revision: "f3f4eb656c97f9b4f30ee6d118b58520225c3369"
  version "dev"
  head "https://github.com/farcloser/homebrew-brews.git", branch: "main"

  depends_on "farcloser/brews/mumbrew"
  depends_on "farcloser/brews/openssh"
  depends_on "farcloser/brews/ssh-agent"
  # Untested on linux, and homebrew is not the right way on linux anyhow
  depends_on :macos

  def install
    system "echo", "installed"
  end
end
