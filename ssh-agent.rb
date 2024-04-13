class SshAgent < Formula
  desc "Farcloser: Launchctl agent for ssh-agent"
  homepage "https://github.com/farcloser/ssh-agent"
  url "https://github.com/farcloser/ssh-agent.git",
      branch: "main"
  version "dev"

  depends_on "farcloser/brews/openssh"

  def install
    bin.install "farcloser-ssh-agent"
  end

  service do
    run macos: [opt_bin/"farcloser-ssh-agent", opt_bin/"ssh-agent"]
    run_type :immediate
    keep_alive true
  end
end
