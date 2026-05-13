class Clipssh < Formula
  desc "Send clipboard images to remote SSH hosts"
  homepage "https://github.com/Rubio-Enterprises/clipssh"
  url "https://github.com/Rubio-Enterprises/clipssh/archive/refs/tags/v1.3.0.tar.gz"
  sha256 "aeb941aa52f09db07d93a873934ad4075a50c0788a42f49bc39d7c96880f8675"
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
