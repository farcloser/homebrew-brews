class Mumbrew < Formula
  desc "Farcloser: Simplistic auto-updater for homebrew"
  homepage "https://github.com/farcloser/mumbrew"
  url "https://github.com/farcloser/mumbrew.git",
      tag:      "v2.1.0",
      revision: "5aa83e4abc60b34637bbe61d22f3bb33224bbc46"

  depends_on "farcloser/brews/terminal-notifier"

  def install
    bin.install "mumbrew"
  end

  service do
    run ["/bin/bash", opt_bin/"mumbrew"]
    run_type :cron
    cron "0 2 * * *"

    # run_type :interval
    # interval 86400

    # launchd starts the agent with /usr/bin:/bin:/usr/sbin:/sbin only;
    # without Homebrew's bin, mumbrew finds neither brew nor terminal-notifier.
    environment_variables PATH: std_service_path_env
    working_dir HOMEBREW_PREFIX

    log_path var/"log/farcloser.mumbrew.out.log"
    error_log_path var/"log/farcloser.mumbrew.err.log"
  end

  test do
    system "/bin/bash", "-n", bin/"mumbrew"
  end
end
