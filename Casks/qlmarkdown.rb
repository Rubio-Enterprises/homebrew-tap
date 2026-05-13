cask "qlmarkdown" do
  version "1.0.24"
  sha256 "e7340e4ca56b943547d3a901e4114237f229222efaf05461dc532758ad0e078a"

  url "https://github.com/sbarex/QLMarkdown/releases/download/#{version}/QLMarkdown.zip"
  name "sbarex QLMarkdown"
  desc "Quick Look generator for Markdown files"
  homepage "https://github.com/sbarex/QLMarkdown"

  # The Sparkle feed contains pubDate values in Italian (e.g.
  # mar, 31 dic 2024 18:36:00 +0100), so the Sparkle strategy cannot
  # accurately sort items by date. We work with all feed items in the
  # strategy block to avoid the sorting issues.
  livecheck do
    url "https://sbarex.github.io/QLMarkdown/appcast.xml"
    strategy :sparkle do |items|
      items.map(&:short_version)
    end
  end

  auto_updates true
  depends_on macos: :big_sur

  app "QLMarkdown.app"
  binary "#{appdir}/QLMarkdown.app/Contents/Resources/qlmarkdown_cli"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/QLMarkdown.app"]
  end

  zap trash: [
    "~/Library/Application Scripts/org.sbarex.QLMarkdown",
    "~/Library/Application Scripts/org.sbarex.QLMarkdown.QLExtension",
    "~/Library/Containers/org.sbarex.QLMarkdown",
    "~/Library/Containers/org.sbarex.QLMarkdown.QLExtension",
    "~/Library/Group Containers/org.sbarex.qlmarkdown",
    "~/Library/Group Containers/org.sbarex.QLMarkdown",
    "~/Library/Preferences/org.sbarex.QLMarkdown.plist",
    "~/Library/QuickLook/QLMarkdown.qlgenerator",
  ]
end
