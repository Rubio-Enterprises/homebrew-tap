class MarvinCli < Formula
  desc "CLI for Amazing Marvin (desktop local API + public cloud API)"
  homepage "https://github.com/Rubio-Enterprises/marvin-cli"
  version "0.8.0-strubio.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Rubio-Enterprises/marvin-cli/releases/download/v0.8.0-strubio.2/marvin-cli_v0.8.0-strubio.2_darwin_arm64.tar.gz"
      sha256 "42cd2c43f2be5ce8dfaaf1a569a82f03eaa6df3c686b0ce8b5830b2d02f6bb22"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/marvin-cli/releases/download/v0.8.0-strubio.2/marvin-cli_v0.8.0-strubio.2_darwin_amd64.tar.gz"
      sha256 "5176d0e0f51f4c2c5892dcbea38964416f8025943e6060bf9204011499b4c9e5"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/marvin-cli/releases/download/v0.8.0-strubio.2/marvin-cli_v0.8.0-strubio.2_linux_amd64.tar.gz"
      sha256 "b2f471025fef810f9d2ef48f035484c6696cfa17ac705c645f33fd19fa1eea0f"
    end
  end

  def install
    bin.install "marvin-cli"
  end

  test do
    assert_match "marvin-cli v#{version}", shell_output("#{bin}/marvin-cli --version")
  end
end
