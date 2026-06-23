class Darfio < Formula
  desc "Opinionated CLI wrapper around fio that gets disk benchmarking right on macOS"
  homepage "https://github.com/Rubio-Enterprises/darfio"
  # darfio is a private repo, so anonymous release-asset downloads 404. Clone over
  # SSH with the :git strategy (uses the operator's key — no token) and build from
  # source, exactly like the other private formulae in this tap.
  url "git@github.com:Rubio-Enterprises/darfio.git",
      using: :git, tag: "v1.0.0", revision: "39bc82f2684ce22267b09afa681c72bcdda9b52c"
  license "MIT"

  depends_on "fio"
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "darfio #{version}", shell_output("#{bin}/darfio --version")
  end
end
