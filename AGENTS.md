# Agent context

This repo follows Rubio-Enterprises standards. Run `/audit-standards` from a Claude Code session to check conformance, or `/onboard-repo` for greenfield setup.

Repo-specific context (in-progress migrations, gotchas, agent guidance):

## Overview

Personal Homebrew tap (`rubio-enterprises/tap`) distributing:

- **Formulas** (`Formula/`): five, in two distribution shapes that matter when bumping them — `:git` source builds (`clipssh`, `gmaps-sync`, `omlx`, `taskjuggler`) and prebuilt release archives with per-arch `sha256` (`mo`). See "Formulas" under Key Patterns.
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
- Formula version bumps are automated from each source repo's CI on tag push, and **the mechanism depends on the formula's shape** — there are exactly two, so check which one applies before touching anything:
  - **`:git` formulas** (`clipssh`, `gmaps-sync`, `omlx`, `taskjuggler`) call the org reusable `Rubio-Enterprises/.github/.github/workflows/bump-brew.yml`, which rewrites `tag:`/`revision:`. It hard-refuses anything without `using: :git` (`grep -q 'using: :git' || exit 1`), so it can never bump `mo`.
  - **`mo`** (prebuilt archives, four `url` + `sha256` pairs) has its own `bump-tap` job in `Rubio-Enterprises/mo`'s `.github/workflows/tagpr.yml`, which recomputes the checksums from the published release assets and PUTs the whole formula via `gh api`. Re-drivable for an already published tag with `gh workflow run tagpr.yml -f tag=<tag>`.
- Both paths authenticate as the per-run `rubio-tap-push` App (`contents:write`, scoped to this repo) and **push straight to `main`**. That works because the App holds an `always` ruleset bypass declared in `.github-private`'s terraform — human PRs against this tap stay fully gated. If a bump ever 409s with "Changes must be made through a pull request", the bypass is the thing to check, not the workflow.
- Either way the formula is **machine-generated**: hand-editing a bumped field here is pointless, because the next release overwrites it. Fix the generator in the source repo.
- `mo` and `taskjuggler` carry the fork tag convention: source tags are `v<upstream>-strubio.<N>` (e.g. `v1.6.7-strubio.1`) and the formula `version` is that tag minus its leading `v` (`1.6.7-strubio.1`). For `taskjuggler` that `version` line is load-bearing: Homebrew scans only `3.8.4` out of `v3.8.4-strubio.1`, so without it `brew outdated` would never see a `-strubio.2` bump. The reusable updates an existing `version` line but never inserts one.
- Version embedding is per-formula: `inreplace` of a `%%VERSION%%` placeholder for the shell/Swift builds (`clipssh`), and nothing at all for `mo` (its binary is prebuilt with the version already compiled in via ldflags upstream in `mo`'s own release workflow).
- Service block for launchd integration (`brew services start/stop`) — used by `gmaps-sync` and `omlx`
- Python formulas (`gmaps-sync`, `omlx`) install into `libexec` with a virtualenv and symlink entry points into `bin`; the Ruby formula (`taskjuggler`) does the gem equivalent — `gem build` + `gem install` into `libexec` as `GEM_HOME`, with `env_script_all_files` wrappers in `bin` (runtime gems resolve from rubygems.org at build time, like `pip` in the Python formulas)
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
