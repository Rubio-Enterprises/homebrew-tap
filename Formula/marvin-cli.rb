class MarvinCli < Formula
  desc "CLI for Amazing Marvin (desktop local API + public cloud API)"
  homepage "https://github.com/Rubio-Enterprises/marvin-cli"
  version "0.6.0-strubio.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Rubio-Enterprises/marvin-cli/releases/download/v0.6.0-strubio.1/marvin-cli_v0.6.0-strubio.1_darwin_arm64.tar.gz"
      sha256 "2ddac82ac9f4200ce26f05380519e6d088a6164f355cfd27d2184b20015dd9ef"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/marvin-cli/releases/download/v0.6.0-strubio.1/marvin-cli_v0.6.0-strubio.1_darwin_amd64.tar.gz"
      sha256 "b851f0c17d4c618d2d13f6d23322a864b2ac2d479f1fe468ac13c2e074e4381a"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/marvin-cli/releases/download/v0.6.0-strubio.1/marvin-cli_v0.6.0-strubio.1_linux_amd64.tar.gz"
      sha256 "bf3c6119b0296ba7d7c46ed2a3dc424aaf4ff3d8f4b9d5ed91f55227a30b585f"
    end
  end

  def install
    bin.install "marvin-cli"
  end

  test do
    assert_match "marvin-cli v#{version}", shell_output("#{bin}/marvin-cli --version")
  end
end
