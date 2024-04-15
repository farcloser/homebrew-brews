class Mumbrew < Formula
  desc "Farcloser: Simplistic auto-updater for homebrew"
  homepage "https://github.com/farcloser/mumbrew"
  url "https://github.com/farcloser/mumbrew.git",
      branch: "main"
  version "dev"

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
    working_dir HOMEBREW_PREFIX

    log_path var/"log/farcloser.mumbrew.err.log"
    error_log_path var/"log/farcloser.mumbrew.out.log"
  end

  test do
    system "./test.sh"
  end
end
