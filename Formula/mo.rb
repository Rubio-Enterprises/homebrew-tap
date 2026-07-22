class Mo < Formula
  desc "Markdown viewer that opens .md files in a browser"
  homepage "https://github.com/Rubio-Enterprises/mo"
  version "0.27.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/strubio-v0.27.0/mo_strubio-v0.27.0_darwin_arm64.zip"
      sha256 "0de87c005b80210694e9bd8467b83e09aef41bd2a2be6e3f0e9f4fa4886f2534"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/strubio-v0.27.0/mo_strubio-v0.27.0_darwin_amd64.zip"
      sha256 "b8f7dd40d4734084bbd9a7be3b7ffc60ac46e6825503b55a6a03d3e223698640"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/strubio-v0.27.0/mo_strubio-v0.27.0_linux_arm64.tar.gz"
      sha256 "d6eec2a1a01c6264296a1eee1ec3c4efaf10ed0064bc4e35df8244df07ba7441"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/strubio-v0.27.0/mo_strubio-v0.27.0_linux_amd64.tar.gz"
      sha256 "c4e335e210c5434e247af252bd138af406cfa8220a0e787ffff2f1a51ed6d661"
    end
  end

  def install
    bin.install "mo"
    generate_completions_from_executable(bin/"mo", "completion")
  end

  test do
    assert_match "mo version", shell_output("#{bin}/mo --version")
  end
end
