class MarvinCli < Formula
  desc "CLI for Amazing Marvin (desktop local API + public cloud API)"
  homepage "https://github.com/Rubio-Enterprises/marvin-cli"
  version "0.8.0-strubio.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Rubio-Enterprises/marvin-cli/releases/download/v0.8.0-strubio.0/marvin-cli_v0.8.0-strubio.0_darwin_arm64.tar.gz"
      sha256 "99895da9ef425ba2140fa264a33a3e930a890f28606cc2e6cc58236a18a1d3eb"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/marvin-cli/releases/download/v0.8.0-strubio.0/marvin-cli_v0.8.0-strubio.0_darwin_amd64.tar.gz"
      sha256 "972fa0af17bd2fa5ebc50bd1be9afa093748d00e676d20da6735d1ed7ca98496"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/marvin-cli/releases/download/v0.8.0-strubio.0/marvin-cli_v0.8.0-strubio.0_linux_amd64.tar.gz"
      sha256 "3670506730a384f2dd003a59ee68f3c988d535774b4bda8faa414185a55f02a8"
    end
  end

  def install
    bin.install "marvin-cli"
  end

  test do
    assert_match "marvin-cli v#{version}", shell_output("#{bin}/marvin-cli --version")
  end
end
