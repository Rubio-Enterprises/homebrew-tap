class Mo < Formula
  desc "Markdown viewer that opens .md files in a browser"
  homepage "https://github.com/Rubio-Enterprises/mo"
  version "1.6.7-strubio.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/v1.6.7-strubio.1/mo_v1.6.7-strubio.1_darwin_arm64.zip"
      sha256 "1efb96c6f821ae41984202872a6d0423ed897a19d1165dd1ebaa6a2614a0eead"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/v1.6.7-strubio.1/mo_v1.6.7-strubio.1_darwin_amd64.zip"
      sha256 "d5ac16afb152520e1d44c275e57f5826339d87c6203b7e25bda76c6bfeb87126"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/v1.6.7-strubio.1/mo_v1.6.7-strubio.1_linux_arm64.tar.gz"
      sha256 "3a69b6c10f2bebe276bd10de895d802236991d739f51abd413b26afc7543dd98"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Rubio-Enterprises/mo/releases/download/v1.6.7-strubio.1/mo_v1.6.7-strubio.1_linux_amd64.tar.gz"
      sha256 "05ba5cf9fe36dea30932fd19e71b63afb5fe1be0c78038f7f9705ec18c0037f5"
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
