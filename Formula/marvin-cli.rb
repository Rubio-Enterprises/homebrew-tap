class MarvinCli < Formula
  desc "CLI for Amazing Marvin (desktop local API + public cloud API)"
  homepage "https://github.com/Rubio-Enterprises/marvin-cli"
  version "0.6.0-strubio.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Rubio-Enterprises/marvin-cli/releases/download/v0.6.0-strubio.0/marvin-cli_v0.6.0-strubio.0_darwin_arm64.tar.gz"
      sha256 "655a9e727932c2ddbe499190be99d6cf216c1c6576c469b62d794eefb02e53cb"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/marvin-cli/releases/download/v0.6.0-strubio.0/marvin-cli_v0.6.0-strubio.0_darwin_amd64.tar.gz"
      sha256 "fd30acfb121709cbdaffc6016a29acce90f4a1045e18291a42e23da2b0731d3c"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/marvin-cli/releases/download/v0.6.0-strubio.0/marvin-cli_v0.6.0-strubio.0_linux_amd64.tar.gz"
      sha256 "25c327f76730fd6048e34bfe2ef4eee79be1b787451792463bc94e4aebf2cf0a"
    end
  end

  def install
    bin.install "marvin-cli"
  end

  test do
    assert_match "marvin-cli v#{version}", shell_output("#{bin}/marvin-cli --version")
  end
end
