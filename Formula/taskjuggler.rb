class Taskjuggler < Formula
  desc "Project scheduler with interactive htmljs Gantt reports (Rubio fork)"
  homepage "https://github.com/Rubio-Enterprises/TaskJuggler"
  url "git@github.com:Rubio-Enterprises/TaskJuggler.git",
      using: :git, tag: "v3.8.4-strubio.1", revision: "237e8008c128fbc35fe3589ceb270b7f7905953a"
  # Fork tag convention (same as mo): v<upstream>-strubio.<N>. Homebrew scans
  # only "3.8.4" out of that tag, so the explicit line is what lets `brew
  # outdated` see a -strubio.2 bump; bump-brew.yml maintains it.
  version "3.8.4-strubio.1"
  license "GPL-2.0-only"

  depends_on "ruby"

  def install
    ENV["GEM_HOME"] = libexec
    system "gem", "build", "taskjuggler.gemspec"
    system "gem", "install", "--no-document", Dir["taskjuggler-*.gem"].first
    bin.install Dir[libexec/"bin/tj3*"]
    bin.env_script_all_files(libexec/"bin", GEM_HOME: ENV["GEM_HOME"])
  end

  test do
    assert_match "tj3 (TaskJuggler) #{version.to_s.split("-").first}",
                 shell_output("#{bin}/tj3 --version")
    # Exercises the fork's htmljs report format, not just upstream scheduling.
    (testpath/"test.tjp").write <<~TJP
      project "Test" 2026-01-01 +2m
      resource dev "Developer"
      task build "Build" {
        effort 5d
        allocate dev
      }
      taskreport "timeline" {
        formats htmljs
        columns name, start, end, chart
      }
    TJP
    system bin/"tj3", "test.tjp"
    assert_path_exists testpath/"timeline.html"
  end
end
