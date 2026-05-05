class Darfio < Formula
  desc "Opinionated CLI wrapper around fio that gets disk benchmarking right on macOS"
  homepage "https://github.com/Rubio-Enterprises/darfio"
  version "1.0.0"
  license "MIT"

  depends_on "fio"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Rubio-Enterprises/darfio/releases/download/v1.0.0/darfio_strubio-v1.0.0_darwin_arm64.tar.gz"
      sha256 "d5fabb9a199300970915182e1944eae17929a7690e5d56dc1a00473b751792e5"
    end
  end

  def install
    bin.install "darfio"
  end

  test do
    assert_match "darfio #{version}", shell_output("#{bin}/darfio --version")
  end
end
