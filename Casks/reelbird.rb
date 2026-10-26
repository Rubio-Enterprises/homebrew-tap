cask "reelbird" do
  version "0.3.1"
  sha256 "b3ceeaf166d50a5d4acf34879f53144321bf2b1655de539b15ca689005bd393f"

  url "https://github.com/btahir/reelbird/releases/download/v#{version}/Reelbird-#{version}.zip"
  name "Reelbird"
  desc "Screen recorder with instant share links, auto-zoom and captions"
  homepage "https://reelbird.app/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "Reelbird.app"
  binary "#{appdir}/Reelbird.app/Contents/Helpers/reelbird"

  # Recordings in ~/Movies/Reelbird and the sharing secrets in the login
  # Keychain are user data and are left in place.
  zap trash: [
    "~/Library/Application Support/Reelbird",
    "~/Library/Caches/app.reelbird.Reelbird",
    "~/Library/HTTPStorages/app.reelbird.Reelbird",
    "~/Library/Preferences/app.reelbird.Reelbird.plist",
  ]
end
