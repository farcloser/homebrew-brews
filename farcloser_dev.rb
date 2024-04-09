class FarcloserDev < Formula
  desc "Top-level brew to provision developers laptops"
  homepage "https://github.com/farcloser/homebrew-brews"
  url "https://github.com/farcloser/homebrew-brews.git",
    revision: "7a096049534dc1783bf6cdb393083314e6599055"
  version "dev"
  head "https://github.com/farcloser/homebrew-brews.git", branch: "main"

  depends_on "farcloser/brews/mumbrew"

  def install
    system "echo", "installed"
  end
end
