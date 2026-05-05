class GmapsSync < Formula
  desc "One-way sync from Google Maps saved places to local JSON"
  homepage "https://github.com/Rubio-Enterprises/gmaps-sync"
  url "https://github.com/Rubio-Enterprises/gmaps-sync/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "ceee370b32186ce06de8be5e4b445df1cc1241e0b6317d9655329a8cb847a267"
  license "MIT"

  depends_on "node"

  def install
    system "npm", "ci"
    system "npm", "run", "build"
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec/"bin/gmaps-sync"
  end

  def post_install
    old_plist = Pathname.new(Dir.home)/"Library/LaunchAgents/com.gmaps-sync.pull.plist"
    if old_plist.exist?
      opoo "Found old gmaps-sync scheduling plist at #{old_plist}"
      opoo "Remove it with: launchctl unload #{old_plist} && rm #{old_plist}"
      opoo "Then use: brew services start gmaps-sync"
    end
  end

  def caveats
    <<~EOS
      To start the daily sync:
        brew services start gmaps-sync

      If you previously used `gmaps-sync schedule`, remove the old plist first:
        launchctl unload ~/Library/LaunchAgents/com.gmaps-sync.pull.plist
        rm ~/Library/LaunchAgents/com.gmaps-sync.pull.plist
    EOS
  end

  service do
    run [opt_bin/"gmaps-sync", "pull"]
    run_type :cron
    cron "0 6 * * *"
    log_path var/"log/gmaps-sync/pull-stdout.log"
    error_log_path var/"log/gmaps-sync/pull-stderr.log"
  end

  test do
    assert_match "gmaps-sync", shell_output("#{bin}/gmaps-sync --help")
  end
end
