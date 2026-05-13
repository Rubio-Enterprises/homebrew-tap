class Clipssh < Formula
  desc "Send clipboard images to remote SSH hosts"
  homepage "https://github.com/Rubio-Enterprises/clipssh"
  url "https://github.com/Rubio-Enterprises/clipssh/archive/refs/tags/v1.3.1.tar.gz"
  sha256 "e3fc4c6078f34bd555b60d364a7e4dd25df211fefa49ac18852667770af5d1f7"
  license "MIT"

  depends_on xcode: ["13.0", :build]
  depends_on :macos

  def install
    inreplace "swift/Sources/clipssh-paste/main.swift",
              'let version = "1.0.0"',
              "let version = \"#{version}\""

    cd "swift" do
      system "swift", "build", "--disable-sandbox", "-c", "release"
      bin.install ".build/release/clipssh-paste"
    end

    inreplace "clipssh", "%%VERSION%%", version.to_s
    bin.install "clipssh"
  end

  test do
    assert_match "clipssh #{version}", shell_output("#{bin}/clipssh --version")
    assert_match "clipssh-paste #{version}", shell_output("#{bin}/clipssh-paste --version")
  end
end
