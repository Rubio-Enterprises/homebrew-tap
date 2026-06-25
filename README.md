# homebrew-tap

A personal Homebrew tap for tools and utilities.

## Installation

```bash
brew tap rubio-enterprises/tap
```

## Formulas

| Formula | Description | Install |
|---------|-------------|---------|
| `marvin-relay` | Go relay server bridging Amazing Marvin webhooks to Apple Live Activities | `brew install rubio-enterprises/tap/marvin-relay` |
| `clipssh` | Send clipboard screenshots to remote SSH hosts | `brew install rubio-enterprises/tap/clipssh` |
| `omlx` | LLM inference server optimized for Apple Silicon | `brew install rubio-enterprises/tap/omlx` |

### marvin-relay

Runs as a launchd service via `brew services`:

```bash
brew install rubio-enterprises/tap/marvin-relay
brew services start marvin-relay
brew services log marvin-relay
```

### clipssh

```bash
brew install rubio-enterprises/tap/clipssh
clipssh user@myserver
```

### omlx

Runs as a launchd service via `brew services`:

```bash
brew install rubio-enterprises/tap/omlx --with-grammar
brew services start omlx
brew services log omlx
```

## Casks

Unsigned QuickLook extensions removed from the official Homebrew cask repository
due to failing macOS Gatekeeper checks.

| Cask | App | Version | Upstream |
|------|-----|---------|----------|
| `syntax-highlight` | Syntax Highlight | 2.1.27 | [sbarex/SourceCodeSyntaxHighlight](https://github.com/sbarex/SourceCodeSyntaxHighlight) |
| `qlmarkdown` | QLMarkdown | 1.0.24 | [sbarex/QLMarkdown](https://github.com/sbarex/QLMarkdown) |

```bash
brew install --cask rubio-enterprises/tap/syntax-highlight
brew install --cask rubio-enterprises/tap/qlmarkdown
```

After installation, open **System Settings > Privacy & Security > Extensions >
Quick Look** to enable the extensions.

## Updating

```bash
brew update
brew upgrade            # upgrades all installed formulas and casks
brew livecheck --cask --tap rubio-enterprises/tap   # check for new upstream cask versions
```

Formula versions are bumped automatically when source repos push new tags.

## Security Notice (QuickLook Casks)

**The QuickLook applications are not signed or notarized by Apple.** This tap
automatically removes the macOS quarantine attribute to allow installation.
By using these casks, you acknowledge that:

- You trust the upstream developer ([sbarex](https://github.com/sbarex))
- You understand that unsigned apps bypass macOS Gatekeeper protections
- You accept the security implications of running unverified software

The sha256 checksums in each cask definition verify download integrity
against the expected release artifacts.

## License

MIT
