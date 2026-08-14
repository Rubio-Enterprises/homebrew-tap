# Agent context

This repo follows Rubio-Enterprises standards. Run `/audit-standards` from a Claude Code session to check conformance, or `/onboard-repo` for greenfield setup.

Repo-specific context (in-progress migrations, gotchas, agent guidance):

## Overview

Personal Homebrew tap (`rubio-enterprises/tap`) distributing:

- **Formulas** (`Formula/`): compiled software (`marvin-relay`, a Go relay server) and shell utilities (`clipssh`, clipboard-to-SSH tool)
- **Casks** (`Casks/`): macOS apps (currently `qlmarkdown` and `syntax-highlight` — unsigned QuickLook extensions)

## Common Commands

```bash
# Lint & validate
brew audit --formula --tap rubio-enterprises/tap
brew audit --cask --tap rubio-enterprises/tap
brew style rubio-enterprises/tap

# Check for upstream version updates
brew livecheck --tap rubio-enterprises/tap
brew livecheck --cask --tap rubio-enterprises/tap

# Bump a cask version (writes locally, no PR)
brew bump-cask-pr --write-only --no-audit --no-style "rubio-enterprises/tap/<cask-name>"
```

## CI/CD

- **`lint.yml`**: Runs on every push to main and all PRs. Audits formulas/casks, checks style, and runs cask livecheck.
- **`bump-casks.yml`**: Monthly cron (1st of month, 9 AM UTC) + manual dispatch. Detects outdated casks via `brew livecheck --json`, bumps versions, and opens a PR for review.

## Key Patterns

### Formulas

- No explicit livecheck block — Homebrew auto-detects the `:git` strategy from the stable URL (`git ls-remote --tags`). Do not use `strategy :github_latest` (requires GitHub Releases, which these repos don't create).
- Formula version bumps are automated from each source repo's CI on tag push, but the **mechanism varies per repo** — do not assume one. Some use `mislav/bump-homebrew-formula-action`; `mo` instead rewrites `Formula/mo.rb` wholesale from a heredoc and PUTs it via `gh api` in its own release workflow (`.github/workflows/tagpr.yml`), authenticated by a per-run `rubio-tap-push` App token scoped to `contents:write` on this repo only. Either way the formula is **machine-generated**: hand-editing a bumped field here is pointless, because the next release overwrites it. Fix the generator in the source repo.
- `mo` also demonstrates the fork tag convention: source tags are `v<upstream>-strubio.<N>` (e.g. `v1.6.7-strubio.1`) and the formula `version` is that tag minus its leading `v` (`1.6.7-strubio.1`), same shape as `marvin-cli`.
- Build-time version embedding with Go ldflags (`-X main.version=#{version}`) for compiled formulas, `inreplace` for shell scripts
- Service block for launchd integration (`brew services start/stop`)
- Config files installed to `etc/<formula-name>/`
- Test block verifies `--version` output

### Casks

- Both casks are **unsigned** — the `postflight` block removes `com.apple.quarantine` via `xattr -dr` (this is the whole reason this tap exists instead of using homebrew-cask)
- Livecheck uses custom Sparkle strategy to work around Italian locale date parsing
- `auto_updates true` since both apps self-update via Sparkle
- `zap trash` lists all Library paths for clean uninstall

### Updating a formula version

Formula versions are updated automatically: push a `v*` tag in the source repo and `mislav/bump-homebrew-formula-action` commits the new version + sha256 directly to this tap.

To update manually:

1. Update `url` with the new tag in the formula file
2. Download the new release tarball and compute `sha256`
3. Update the `sha256` in the formula
4. Run `brew audit --formula --tap rubio-enterprises/tap && brew style rubio-enterprises/tap`
