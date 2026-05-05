class Mo < Formula
  desc "Markdown viewer that opens .md files in a browser"
  homepage "https://github.com/Rubio-Enterprises/mo"
  version "0.25.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/strubio-v0.25.5/mo_strubio-v0.25.5_darwin_arm64.zip"
      sha256 "ed9de5e043177f6d89e7f28b76faad4ff061fa58e94d039425492e0b45ece644"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/strubio-v0.25.5/mo_strubio-v0.25.5_darwin_amd64.zip"
      sha256 "7f79ca4eae49b9049836172146ee2e2f7a24b548592377dd5291facafca2458b"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/strubio-v0.25.5/mo_strubio-v0.25.5_linux_arm64.tar.gz"
      sha256 "d96ceb925d9627ff53c3f1ac6a299065aa4fa42c16c0f2d19ffff176aa2ff7dd"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/strubio-v0.25.5/mo_strubio-v0.25.5_linux_amd64.tar.gz"
      sha256 "0861b2e49ef5798ea555830cddc03a75beed8ab50b2059cc6ead84e4dd8d1365"
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
