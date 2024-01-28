class Mumbrew < Formula
  desc "Auto-updater for homebrew with notifications"
  homepage "https://github.com/farcloser/mumbrew"
  version "dev"
  url "https://github.com/farcloser/mumbrew.git",
    :revision => "0503330469deee70d5080007d77508af5fae7c8b"
  head "https://github.com/farcloser/mumbrew.git"

  depends_on "terminal-notifier"

  def install
    bin.install "mumbrew"
  end

  service do
    run ["/bin/bash", opt_bin/"mumbrew"]
    run_type :cron
    cron "0 2 * * *"

    #run_type :interval
    #interval 86400
    working_dir HOMEBREW_PREFIX

    log_path var/"log/mumbrew.err.log"
    error_log_path var/"log/mumbrew.out.log"
  end


  test do
    system "./test.sh"
  end
end