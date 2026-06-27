class Mo < Formula
  desc "Markdown viewer that opens .md files in a browser"
  homepage "https://github.com/Rubio-Enterprises/mo"
  version "0.26.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/strubio-v0.26.0/mo_strubio-v0.26.0_darwin_arm64.zip"
      sha256 "affe5f62b2784c39b155bca731abff7973bf4e98fe7ff75981121cb30c807feb"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/strubio-v0.26.0/mo_strubio-v0.26.0_darwin_amd64.zip"
      sha256 "dc87486f608cf5b3916eeeee994ac4eeb335159393a8633be2f14dd3c2db60b1"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/strubio-v0.26.0/mo_strubio-v0.26.0_linux_arm64.tar.gz"
      sha256 "d7c350a502c7fa193c5f444a7d2d4cbaea71dbfaf04a51933490580adc7afbc6"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/strubio-v0.26.0/mo_strubio-v0.26.0_linux_amd64.tar.gz"
      sha256 "9049db0af6bb114b7df63986b6230b4072fcb45226436a8d21fb92945384a649"
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
