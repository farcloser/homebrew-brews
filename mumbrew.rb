class Mumbrew < Formula
  desc "Simplistic auto-updater for homebrew"
  homepage "https://github.com/farcloser/mumbrew"
  url "https://github.com/farcloser/mumbrew.git",
    revision: "b988720260e8e640d17e125d500d72d3af0ca3d1"
  version "dev"
  head "https://github.com/farcloser/mumbrew.git", branch: "master"

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

    log_path var/"log/mumbrew.err.log"
    error_log_path var/"log/mumbrew.out.log"
  end

  test do
    system "./test.sh"
  end
end
