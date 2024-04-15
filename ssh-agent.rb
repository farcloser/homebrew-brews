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

  # See /System/Library/LaunchAgents/com.openssh.ssh-agent.plist
  service do
    run macos: [opt_bin/"farcloser-ssh-agent", HOMEBREW_PREFIX/"bin/ssh-agent"]
    run_type :immediate
    keep_alive true

    working_dir HOMEBREW_PREFIX

    log_path var/"log/farcloser.ssh-agent.err.log"
    error_log_path var/"log/farcloser.ssh-agent.out.log"
  end
end
