# homebrew-tap

A personal Homebrew tap for tools and utilities.

Homebrew identifies this repository as `rubio-enterprises/tap`, the tap name
used in the commands below.

## Table of Contents

- [Security](#security)
- [Install](#install)
- [Usage](#usage)
- [Formulas](#formulas)
- [Casks](#casks)
- [Updating](#updating)
- [Contributing](#contributing)
- [License](#license)

## Security

**The QuickLook applications are not signed or notarized by Apple.** This tap
automatically removes the macOS quarantine attribute to allow installation.
By using these casks, you acknowledge that:

- You trust the upstream developer ([sbarex](https://github.com/sbarex)).
- You understand that unsigned apps bypass macOS Gatekeeper protections.
- You accept the security implications of running unverified software.

The sha256 checksums in each cask definition verify download integrity
against the expected release artifacts.

## Install

With [Homebrew](https://brew.sh) installed:

```bash
brew tap rubio-enterprises/tap
```

The source-build formulas fetch organization repositories over HTTPS; private
repositories still require authorized GitHub access. The QuickLook casks and
`clippy` require macOS; `omlx` requires Apple Silicon.

## Usage

### CLI

Install a formula and invoke its command, for example:

```bash
brew install rubio-enterprises/tap/clipssh
clipssh user@myserver
```

### clippy fork

The Rubio fork adds `md2teams` for rich Markdown paste into Microsoft Teams and
installs both `clippy` and `pasty`. It replaces homebrew-core's `clippy`; uninstall
the core formula first if installed:

```bash
brew uninstall homebrew/core/clippy  # only if the core formula is installed
brew install rubio-enterprises/tap/clippy
clippy md2teams --help
```

### omlx service

Runs as a launchd service via `brew services`:

```bash
brew install rubio-enterprises/tap/omlx --with-grammar
brew services start omlx
tail -f "$(brew --prefix)/var/log/omlx.log"
```

### QuickLook extensions

```bash
brew install --cask rubio-enterprises/tap/syntax-highlight
brew install --cask rubio-enterprises/tap/qlmarkdown
```

After installation, enable the Quick Look extensions in **System Settings**.
The location varies by macOS version (for example, **Privacy & Security >
Extensions > Quick Look**).

## Formulas

| Formula | Description | Install |
| --- | --- | --- |
| `clippy` | Clipboard tools with Teams-ready Markdown paste (Rubio fork) | `brew install rubio-enterprises/tap/clippy` |
| `clipssh` | Send clipboard images, including screenshots, to remote SSH hosts | `brew install rubio-enterprises/tap/clipssh` |
| `gmaps-sync` | One-way sync from Google Maps saved places to local JSON | `brew install rubio-enterprises/tap/gmaps-sync` |
| `mo` | Markdown viewer that opens .md files in a browser | `brew install rubio-enterprises/tap/mo` |
| `omlx` | LLM inference server optimized for Apple Silicon | `brew install rubio-enterprises/tap/omlx` |
| `taskjuggler` | Project scheduler with interactive htmljs Gantt reports (Rubio fork) | `brew install rubio-enterprises/tap/taskjuggler` |

## Casks

Unsigned QuickLook extensions removed from the official Homebrew cask repository
due to failing macOS Gatekeeper checks.

| Cask | App | Version | Upstream |
| --- | --- | --- | --- |
| `syntax-highlight` | Syntax Highlight | 2.1.27 | [sbarex/SourceCodeSyntaxHighlight](https://github.com/sbarex/SourceCodeSyntaxHighlight) |
| `qlmarkdown` | QLMarkdown | 1.0.24 | [sbarex/QLMarkdown](https://github.com/sbarex/QLMarkdown) |

## Updating

```bash
brew update
brew upgrade            # upgrades all installed formulas and casks
brew livecheck --cask --tap rubio-enterprises/tap   # check for new upstream cask versions
```

Formula versions are bumped automatically when source repos push new tags.
`clippy`, `mo`, and `taskjuggler` use `v<upstream>-strubio.<N>` tags and explicit
fork versions.

A new `:git` formula lands before its first release tag, pinned to the full
commit SHA that tag will reference. The reusable bump workflow only updates an
existing formula; a tag pushed before the formula lands fails with
`Formula/<name>.rb not found`, and rerunning that tag workflow after landing
recovers it.

## Contributing

Organization members can raise questions in this repository's issues and submit
changes through pull requests. Follow the
[PR template](.github/PULL_REQUEST_TEMPLATE.md): use a Conventional Commits title
and fill in the linked work item, What?, Why?, How?, Testing?, Feedback?, and
Other Information or Known Dependencies sections (screenshots when relevant).
Keep the body within 400 words.

Run `mise run test` (or `ruby scripts/check-source-transports.rb`) for the offline
SSH source transport regression check across all formulas and casks. There is no
`mise run lint` task. Run the Markdown and other staged-file checks with
`mise exec -- lefthook run pre-commit`. For formula/cask changes, run the Homebrew
audits and style checks from
[AGENTS.md](AGENTS.md); CI also runs cask livecheck. CI selects current stable
Homebrew before linting instead of relying on the runner image's bundled version.
This updates Homebrew itself, not installed formulae or casks. When changing lint
sidecars, regenerate their configs with `mise run lint-config`.

## License

[MIT](LICENSE) — Copyright (c) 2026 Rubio-Enterprises.
