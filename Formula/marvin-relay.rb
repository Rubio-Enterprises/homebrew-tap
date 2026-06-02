class MarvinRelay < Formula
  desc "Go relay server bridging Amazing Marvin webhooks to Apple Live Activities"
  homepage "https://github.com/Rubio-Enterprises/marvin-time-tracker"
  url "https://github.com/Rubio-Enterprises/marvin-time-tracker/archive/refs/tags/v2.3.0.tar.gz"
  sha256 "a07b9210bb59f23e9e506cb10fc823a4dc97361b521c13bf99fe6fe41ce26152"
  license "MIT"

  depends_on "go" => :build

  def install
    ldflags = %W[-s -w -X main.version=#{version}]
    system "go", "build", *std_go_args(ldflags:), "-o", bin/"marvin-relay", "./server"
    (etc/"marvin-relay").install "server/config.example" => "config"
  end

  service do
    run [opt_bin/"marvin-relay", "--config", etc/"marvin-relay/config"]
    keep_alive true
    working_dir var/"marvin-relay"
    log_path var/"log/marvin-relay.log"
    error_log_path var/"log/marvin-relay.log"
    environment_variables PATH: std_service_path_env
  end

  post_install_steps do
    mkdir_p "marvin-relay"
  end

  test do
    assert_match "marvin-relay #{version}", shell_output("#{bin}/marvin-relay --version")
  end
end
