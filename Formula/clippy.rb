class Clippy < Formula
  desc "Clipboard tools with Teams-ready Markdown paste (Rubio fork)"
  homepage "https://github.com/Rubio-Enterprises/clippy"
  url "https://github.com/Rubio-Enterprises/clippy.git",
      using: :git, tag: "v1.9.1-strubio.1", revision: "05ddd259aee635e048b74b6596f700304c85ad20"
  # Fork tag convention (same as mo): v<upstream>-strubio.<N>. Homebrew scans
  # only "1.9.1" out of that tag, so the explicit line is what lets `brew
  # outdated` see a -strubio.2 bump; bump-brew.yml maintains it.
  version "1.9.1-strubio.1"
  license "MIT"

  depends_on "go" => :build
  depends_on :macos

  conflicts_with "homebrew/core/clippy", because: "both install clippy and pasty binaries"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/neilberkman/clippy/cmd/internal/common.Version=#{version}
      -X github.com/neilberkman/clippy/cmd/internal/common.Commit=#{tap.user}
      -X github.com/neilberkman/clippy/cmd/internal/common.Date=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/clippy"
    system "go", "build", *std_go_args(ldflags:, output: bin/"pasty"), "./cmd/pasty"
    %w[clippy pasty].each do |cmd|
      generate_completions_from_executable(bin/cmd, shell_parameter_format: :cobra)
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clippy --version")
    assert_match version.to_s, shell_output("#{bin}/pasty --version")
    assert_match "Teams", shell_output("#{bin}/clippy md2teams --help")
    (testpath/"test.txt").write("test content\n")
    json = <<~JSON
      {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26"}}
      {"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"buffer_copy","arguments":{"file":"#{testpath}/test.txt"}}}
    JSON
    assert_match "Copied 2 lines from test.txt", pipe_output("#{bin}/clippy mcp-server 2>&1", json, 0)
  end
end
