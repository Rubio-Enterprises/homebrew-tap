# Agent context

This repo follows the `@rubio-enterprises/standards` package: set up with `mise run setup`, run
the Checks with `mise run check`.

Repo-specific context (in-progress migrations, gotchas, agent guidance):

## Overview

Personal Homebrew tap (`rubio-enterprises/tap`) distributing:

- **Formulas** (`Formula/`): four, in two distribution shapes that matter when bumping them — `:git` source builds (`clippy`, `clipssh`, `taskjuggler`) and prebuilt release archives with per-arch `sha256` (`mo`). See "Formulas" under Key Patterns.
- **Casks** (`Casks/`): macOS apps — `qlmarkdown` and `syntax-highlight` (unsigned QuickLook extensions) and `reelbird` (signed, but below homebrew-cask's notability threshold)

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
  - **`:git` formulas** (`clippy`, `clipssh`, `taskjuggler`) call the org reusable [bump-brew.yml](https://github.com/Rubio-Enterprises/.github/blob/main/.github/workflows/bump-brew.yml), which rewrites `tag:`/`revision:`. It hard-refuses anything without `using: :git` (`grep -q 'using: :git' || exit 1`), so it can never bump `mo`.
  - **`mo`** (prebuilt archives, four `url` + `sha256` pairs) has its own `bump-tap` job in `Rubio-Enterprises/mo`'s [tagpr.yml](https://github.com/Rubio-Enterprises/mo/blob/main/.github/workflows/tagpr.yml), which recomputes the checksums from the published release assets and PUTs the whole formula via `gh api`. Re-drivable for an already published tag with `gh workflow run tagpr.yml -f tag=<tag>`.
- Both paths authenticate as the per-run `rubio-tap-push` App (`contents:write`, scoped to this repo) and **push straight to `main`**. That works because the App holds an `always` ruleset bypass declared in `.github-private`'s terraform — human PRs against this tap stay fully gated. If a bump ever 409s with "Changes must be made through a pull request", the bypass is the thing to check, not the workflow.
- Either way the formula is **machine-generated**: hand-editing a bumped field here is pointless, because the next release overwrites it. Fix the generator in the source repo.
- `clippy`, `mo`, and `taskjuggler` carry the fork tag convention: source tags are `v<upstream>-strubio.<N>` (e.g. `v1.6.7-strubio.1`) and the formula `version` is that tag minus its leading `v` (`1.6.7-strubio.1`). For `clippy` and `taskjuggler` that `version` line is load-bearing: Homebrew scans only the upstream version out of the fork tag, so without it `brew outdated` would never see a `-strubio.2` bump. The reusable updates an existing `version` line but never inserts one.
- `clippy` is macOS-only and replaces core's same-named formula. Use `conflicts_with "homebrew/core/clippy"`: the installer ignores a bare same-name conflict. Its `fetch` downloads Go modules before the network-denied build; ldflags embed the fork version in both `clippy` and `pasty`. `md2teams --help` tests the fork without touching the pasteboard; the MCP buffer-copy test does touch it.
- Version embedding is per-formula: `inreplace` of a `%%VERSION%%` placeholder for the shell/Swift builds (`clipssh`), and nothing at all for `mo` (its binary is prebuilt with the version already compiled in via ldflags upstream in `mo`'s own release workflow).
- The Ruby formula (`taskjuggler`) uses `gem build` + `gem install` into `libexec` as `GEM_HOME`, with `env_script_all_files` wrappers in `bin`; runtime gems resolve from rubygems.org at build time.
- Test block verifies `--version` output

### Casks

- The QuickLook casks are **unsigned** — the `postflight` block removes `com.apple.quarantine` via `xattr -dr` (this is why they live here instead of homebrew-cask). Their livecheck uses a custom Sparkle strategy to work around Italian locale date parsing, and they set `auto_updates true` because both apps self-update via Sparkle
- `reelbird` is signed and notarized, so it has no quarantine postflight. It never self-updates (no `auto_updates`), and livecheck follows GitHub's latest release. `brew audit --new` fails only on GitHub notability; the tap's non-`--new` audit passes
- Every cask's `binary` stanza links the CLI bundled in the app onto `PATH`
- `zap trash` lists all Library paths for clean uninstall; user recordings and Keychain items stay

### Updating a formula version

Use the source repo's bump path above: `:git` formulas update `tag:`/`revision:` and any existing explicit `version`; archive formulas update URLs/checksums.

For a new `:git` formula, merge it into the tap before pushing its first release tag. `bump-brew.yml` fails with `Formula/<name>.rb not found` rather than creating a formula. The initial formula must pin the full commit SHA the planned tag will reference. An empty revision disables Homebrew's tag-integrity check.

After changes, run `brew audit --formula --tap rubio-enterprises/tap && brew style rubio-enterprises/tap`.
