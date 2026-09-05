class Omlx < Formula
  desc "LLM inference server optimized for Apple Silicon"
  homepage "https://github.com/Rubio-Enterprises/omlx"
  url "git@github.com:Rubio-Enterprises/omlx.git",
      using: :git, tag: "v0.4.4.post2", revision: "ce5ef51a7edfd79d9d9d377635c1597e26b32668"
  version "0.4.4.post2"
  license "Apache-2.0"
  # Build fix only (transformers cap below) — bump so installs built
  # before the cap are seen as outdated and rebuilt.
  revision 1

  head "git@github.com:Rubio-Enterprises/omlx.git", branch: "main"

  option "with-grammar", "Install xgrammar for structured output (requires torch, ~2GB)"

  depends_on "rust" => :build
  depends_on arch: :arm64
  depends_on :macos
  depends_on "python@3.11"

  # mlx-audio pins mlx-lm==0.31.1 which conflicts with omlx's git-pinned
  # mlx-lm. Fetch source separately so we can patch the pin before install.
  resource "mlx-audio" do
    url "https://github.com/Blaizzy/mlx-audio/archive/51753266e0a4f766fd5e6fbc46652224efc23981.tar.gz"
    sha256 "7f9297a18f4cfa8a30efde3ba0056b87dfbb5d64747591eef5ff44333f9a19ef"
  end

  service do
    run [opt_bin/"omlx", "serve"]
    keep_alive true
    working_dir var
    log_path var/"log/omlx.log"
    error_log_path var/"log/omlx.log"
    environment_variables PATH: std_service_path_env
  end

  def install
    # Create venv with pip so dependency resolution works properly
    system "python3.11", "-m", "venv", libexec

    # Build native extensions from source with headerpad so Homebrew can
    # rewrite Mach-O install names to absolute Cellar/opt paths. Rust/maturin
    # extension builds (cohere_melody) need the linker flag via RUSTFLAGS;
    # C/C++ extension builds use LDFLAGS.
    ENV.append "LDFLAGS", "-Wl,-headerpad_max_install_names"
    ENV.append "RUSTFLAGS", "-C link-arg=-Wl,-headerpad_max_install_names"

    # Install omlx (with optional grammar extra for structured output)
    # transformers is capped below 5.13: 5.13.0 added a `key.__module__`
    # check to AutoTokenizer.register() that rejects the string-form key
    # mlx-lm 0.31.x passes ("NewlineTokenizer"), crashing `omlx serve` at
    # import (AttributeError: 'str' object has no attribute '__module__').
    # Verified 5.12.1 lacks the check. Drop the cap once omlx bumps to an
    # mlx-lm release that registers with a class key.
    install_spec = build.with?("grammar") ? "#{buildpath}[grammar]" : buildpath.to_s
    system libexec/"bin/pip", "install",
           "--no-binary", "cohere_melody,pydantic-core,rpds-py,tiktoken",
           install_spec, "transformers<5.13"

    # Install mlx-audio with patched mlx-lm pin to avoid version conflict
    resource("mlx-audio").stage do
      inreplace "pyproject.toml", '"mlx-lm==0.31.1"', '"mlx-lm>=0.31.1"'
      system libexec/"bin/pip", "install", ".[all]"
    end

    # python-multipart is declared in omlx's [audio] extra, not in mlx-audio
    system libexec/"bin/pip", "install", "python-multipart>=0.0.5"

    bin.install_symlink Dir[libexec/"bin/omlx"]

    return if build.without?("grammar")

    (libexec/"patch-xgrammar.py").write <<~PYTHON
      import glob
      import json
      import os
      import subprocess
      import sys

      import site
      import tvm_ffi

      site_dir = site.getsitepackages()[0]
      tvmlib = os.path.join(os.path.dirname(tvm_ffi.__file__), "lib")
      dylib = os.path.join(site_dir, "xgrammar", "libxgrammar_bindings.dylib")
      dist_dirs = sorted(glob.glob(os.path.join(site_dir, "xgrammar-*.dist-info")))

      print("Patching xgrammar macOS arm64 wheel")
      print(f"  site={site_dir}")
      print(f"  tvmlib={tvmlib}")
      print(f"  dylib={dylib} (exists? {str(os.path.exists(dylib)).lower()})")
      print(f"  dist-info={json.dumps(dist_dirs)}")

      if not os.path.exists(dylib):
          raise SystemExit(f"xgrammar dylib not found at {dylib}")
      if not dist_dirs:
          raise SystemExit(f"xgrammar dist-info not found under {site_dir}")

      rpaths = subprocess.check_output(["/usr/bin/otool", "-l", dylib], text=True)
      if tvmlib in rpaths:
          print("  rpath already points at tvm_ffi/lib")
      else:
          print(f"  adding rpath -> {tvmlib}")
          subprocess.run(["/usr/bin/install_name_tool", "-add_rpath", tvmlib, dylib], check=True)
          subprocess.run(["/usr/bin/codesign", "--force", "--sign", "-", dylib], check=True)

      record = os.path.join(dist_dirs[0], "RECORD")
      if os.path.exists(record) and "libxgrammar_bindings.dylib" in open(record, encoding="utf-8").read():
          print("  RECORD already lists the dylib")
      else:
          print(f"  writing dylib entry to {record}")
          with open(record, "a", encoding="utf-8") as record_file:
              record_file.write("xgrammar/libxgrammar_bindings.dylib,,\\n")

      print("  verifying import xgrammar...")
      subprocess.run([sys.executable, "-c", "import xgrammar; print('xgrammar import OK')"], check=True)
    PYTHON
  end

  # Patch the macOS arm64 xgrammar wheel so its native binding loads.
  # The 0.1.32+ wheel ships libxgrammar_bindings.dylib with
  # @rpath/libtvm_ffi.dylib but no LC_RPATH pointing at where tvm_ffi
  # installs its native lib, and the dist-info is missing a RECORD
  # entry for the dylib so tvm_ffi's manifest-based lookup fails.
  # Both manifest as RuntimeError("Cannot find library: ...") at
  # `import xgrammar`, which crashes /admin/api/grammar/parsers and
  # hides the Reasoning Parser dropdown. Tracking upstream:
  # jundot/omlx#1005.
  #
  # Runs in post_install_steps rather than install because Homebrew's
  # post-install "Cleaning" step deletes every dist-info/RECORD file
  # in the keg as part of its relocation pass (RECORD hashes become
  # invalid once brew rewrites Mach-O install names). Anything we
  # write to RECORD inside `def install` is wiped before the user
  # sees it.
  post_install_steps do
    if_path_exists "patch-xgrammar.py", base: :libexec do
      run "bin/python",
          args:           ["{{libexec}}/patch-xgrammar.py"],
          base:           :libexec,
          print_stdout:   true,
          writable_paths: ["{{libexec}}"]
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/omlx --version")
  end
end
