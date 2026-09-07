# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A multi-machine [nix-darwin](https://github.com/LnL7/nix-darwin) /
[home-manager](https://github.com/nix-community/home-manager) configuration, covering
macOS (via nix-darwin) and Linux (Ubuntu/PopOS/Arch, via standalone home-manager — nix
manages the user environment, not the system; no NixOS host exists). See `README.md`
for first-time and new-machine setup.

Hosts are named by **role**, not hostname or owner (`personal-mac`, not `m4` or
`jeff`) — this repo commits no usernames, emails, or hostnames. See **Identity** below.

Three hosts exist today: `darwinConfigurations.personal-mac`/`.work-mac`
(`aarch64-darwin`) and `homeConfigurations.linux-desktop` (`x86_64-linux`).

## Commands

All commands run from `nix/` (the `dot` shell alias jumps there).

```sh
# Apply the configuration (the `nix-switch` function) — needs a real identity,
# see below, and <host> is whichever host you're building for (see "Which
# host is 'this machine'?" below). macOS:
sudo darwin-rebuild switch --flake ~/.config/dotfiles/nix#<host> \
  --override-input identity "path:$HOME/.config/dotfiles-identity"

# Linux (standalone home-manager):
home-manager switch --flake ~/.config/dotfiles/nix#<host> \
  --override-input identity "path:$HOME/.config/dotfiles-identity"

# Evaluate + build WITHOUT activating — darwin hosts:
darwin-rebuild build --flake .#<host> --override-input identity "path:$HOME/.config/dotfiles-identity"
# Linux hosts (can't fully realize on a non-Linux builder — see Gotchas):
nix build .#homeConfigurations.<host>.activationPackage --override-input identity "path:$HOME/.config/dotfiles-identity"

# Fresh-clone sanity check — evaluates with the committed placeholder identity,
# no override needed
nix flake check

# Bump all flake inputs (the `nix-update` alias), then switch
nix flake update
```

There is no test suite, linter, or CI. `darwin-rebuild build` is the primary
verification step: it catches evaluation and build errors without touching the live
system. `nix store diff-closures <old-result> <new-result>` is the way to confirm a
structural change didn't alter what actually gets installed — see Gotchas.

## Git workflow

**Never commit directly to `main`, and never push.** Every change — including
one-line edits — goes on its own branch, and pushing is the user's call, not
Claude's.

```sh
# 1. Branch off main (which should be clean and up to date)
git checkout -b feat/add-work-mac   # <type>/<description>

# 2. Commit the change there
git add <files>
git commit -m "..."

# 3. Stop. Do not push. Report the branch name and let the user review.
```

Branch prefixes: `docs/`, `feat/`, `fix/`, `chore/`.

Note that early `git log` history on this repo shows commits made straight to
`main`. That is history, not the convention — follow the procedure above
instead.

### Landing a branch on main

The user does this, or asks for it explicitly — via a GitHub PR, merged there.
That produces a merge commit each time; that's fine, and matches how this
repo has actually been landing branches (don't assume or aim for a
fast-forward-only, linear history — it isn't one).

## Keeping README.md current

Update `README.md` whenever a change affects setup, the host list, or any
"how do I do X" a user would need to know — a new host, a changed command, a
renamed option someone would type. Check it as part of making the change,
not only when someone happens to notice it's gone stale (see git history for
an example: the host-selection step and host list went unmentioned for a
while after `work-mac` was added).

`README.md` and this file have different jobs. README is for **using** this
repo: setup steps, what exists, how to add a host — written for someone
about to run a command. It is not for architecture or rationale; that
belongs here. If you're explaining *why* something works a particular way,
it goes in CLAUDE.md; if you're telling someone what to *do*, it goes in
README.md.

## Identity

Nothing identifying is committed. `nix/identity/identity.nix` is a tracked
**placeholder** (`username`, `gitName`, `gitEmail`) that exists only so a fresh
clone evaluates and `nix flake check` passes. Real values live outside the repo,
at `~/.config/dotfiles-identity/identity.nix`, and are supplied at switch time via
`--override-input identity "path:$HOME/.config/dotfiles-identity"` (already wired
into the `nix-switch` function). See README.md for the one-time setup.

`home/common/git.nix` reads `identity.gitName`/`identity.gitEmail` for
`programs.git.settings.user.{name,email}` — **not** a profile. Each host already
has its own identity file, so git identity is naturally per-host without needing
a `home/profiles/*.nix` split; don't hardcode a name/email into a profile file to
give one host a different git identity; put it in that host's local identity file
instead.

Two things about the identity mechanism worth knowing before touching it:

- **Flakes only evaluate git-tracked files.** A gitignored identity file is invisible
  to Nix and fails evaluation outright — that's why the placeholder must stay
  committed rather than gitignored.
- **`--override-input` does not get written back to `flake.lock`.** Verified directly:
  `nix build --override-input identity path:<real-dir>` leaves `flake.lock` and
  `git status` untouched. This is what keeps the real path (and the username inside
  it) out of git even though `flake.lock` is committed.

## Architecture

```
nix/
  flake.nix              inputs + darwinConfigurations/homeConfigurations wiring
  identity/identity.nix  committed placeholder (see Identity)
  mk/
    mkHost.nix             builds one darwinConfiguration (macOS) from a host descriptor
    mkHomeHost.nix          builds one standalone homeConfiguration (Linux) likewise
  hosts/<role>.nix        { system, profile, homeStateVersion, [stateVersion] } —
                          stateVersion only applies to darwin hosts
  modules/darwin/        nix-darwin system modules (macOS-only)
  home/
    default.nix           picks common + platform + profile for one host
    common/                the portable core — works on Darwin and Linux
    darwin/, linux/        platform-only home-manager config (both empty stubs today)
    profiles/<name>.nix    profile-only home-manager config (all empty today)
  files/                  data files modules import/symlink (p10k, lazyvim, aerospace)
```

`nix/flake.nix` calls `mk/mkHost.nix` for each macOS host and `mk/mkHomeHost.nix` for
each Linux host, one call per entry in `hosts/`. `mkHost.nix` resolves identity, then
builds a `nix-darwin.lib.darwinSystem` wiring in `modules/darwin` (system scope),
`nix-homebrew`, and `home-manager.darwinModules.home-manager` — the latter pointing
`home-manager.users.<username>` at `home/default.nix`. `mkHomeHost.nix` skips all of
that and builds a bare `home-manager.lib.homeManagerConfiguration` pointed at the same
`home/default.nix` — no nix-darwin, no Homebrew, no `modules/darwin` involved at all.

`home/default.nix` sets `home.username`/`home.homeDirectory` from `identity.username`
explicitly (required for standalone home-manager, which has no OS user record to
infer them from; harmless on Darwin, where they already matched what nix-darwin
auto-derived). It always imports `home/common/`, then picks `home/darwin` or
`home/linux` by inspecting `host.system` (a plain string — **not**
`pkgs.stdenv.isDarwin`; see Gotchas), then imports `home/profiles/<host.profile>.nix`.

**Which host is "this machine"?** There's no detection — it's whichever flake
attribute you build with, chosen once by the human running the command. Both
`mkHost` and `mkHomeHost` take that name as an explicit argument (`mkHost
"personal-mac" (import ./hosts/personal-mac.nix)` in `flake.nix`) and thread it onto
`host.name`, which `home/default.nix` exports as `$DOTFILES_HOST` via
`home.sessionVariables`. That's how `nix-switch` (`home/common/shell.nix`) knows
which host to target without a hardcoded name in a file every host shares — it reads
`$DOTFILES_HOST`, set by the *previous* successful switch, and dispatches to
`darwin-rebuild` or `home-manager switch` based on `uname`. A machine that has never
switched yet has no value to read, which is exactly why first setup on a new host
uses the full explicit command by hand (README) rather than `nix-switch`.

### Where a new package goes

| Need | Where |
|---|---|
| Portable — wanted on every machine, works on Linux too | `home/common/packages.nix` |
| macOS system settings/services | `modules/darwin/**` |
| GUI app or Mac App Store app | `homebrew.casks` / `masApps` (`modules/darwin/homebrew.nix`) |
| GNU-flavored CLI with no nix equivalent | Homebrew — but check first; most do have one |

`homebrew.onActivation.cleanup = "zap"` (`modules/darwin/homebrew.nix`) — anything
installed manually and not listed there is **removed** on the next rebuild.
`upgrade = true` also means brew packages move on every switch.

**Standardize-with-override:** custom options under `my.*` (declared in
`home/common/options.nix`) express "same everywhere, but a host can override it."
`my.defaultPython` is the example today — a host would override it via its own
home-manager config, not by editing `home/common/`.

Python is special, twice over:
- `config.my.defaultPython` (default `pkgs.python313`) must stay **first** in
  `home/common/python.nix`'s package list — home-manager's profile builder resolves
  same-priority filename collisions (`bin/python3`, `bin/pip3`, …) by list order.
- `python311`/`python312` are **not** installed via `home.packages` at all — only
  `config.my.defaultPython` is. They're reachable solely through the fully-qualified
  store paths baked into their zsh aliases (`home/common/shell.nix`), which pulls each
  into the closure without installing a second `bin/idle`/`bin/python3`/etc. that would
  collide with the default's. `environment.systemPackages` tolerates that exact
  collision silently (`ignoreCollisions`-style behavior); `home.packages` does not —
  confirmed by building it the naive way first and hitting a hard
  `pkgs.buildEnv error: two given paths contain a conflicting subpath` failure.

### Neovim

`lvim` (the `lvim` alias, `NVIM_APPNAME=lazyvim nvim`) is the only Neovim
configuration — it points Neovim at `~/.config/lazyvim`, symlinked by
`home/common/editor.nix` from `nix/files/lazyvim/**`. LazyVim bootstraps `lazy.nvim`
by cloning it at first launch and resolves its own plugins, so it is **not** pinned by
nix. Plain `neovim` in `home/common/packages.nix` just supplies the unconfigured
`nvim` binary LazyVim runs on top of, on every platform.

Adding a file under `nix/files/lazyvim/` is not enough — each path needs its own
`home.file.".config/lazyvim/…".source` entry in `home/common/editor.nix`, or it never
reaches `$HOME`.

### `nix/files/`

Data consumed by modules, not modules themselves:

- `aerospace.toml` — AeroSpace tiling-WM config, pulled in with `pkgs.lib.importTOML`
  by `modules/darwin/aerospace.nix`. Edits require a rebuild.
- `p10k.zsh` — the powerlevel10k theme, symlinked to `~/.p10k.zsh` by
  `home/common/shell.nix` and sourced at the end of the zsh `initContent`.
- `lazyvim/**` — see Neovim above.

## Gotchas

- **Never hardcode a host name (`personal-mac`, `work-mac`, …) in anything under
  `home/common/` or `modules/`.** Those files are shared by every host; a literal
  host name there is correct for exactly one of them. `nix-switch` shipped with
  `#personal-mac` hardcoded for a while — harmless when it was the only host,
  a real bug once `work-mac` existed. Use `host.name`/`$DOTFILES_HOST` instead
  (see Architecture).
- **Never reference `pkgs` inside a home-manager module's `imports` list.** `pkgs` in a
  `useGlobalPkgs` home-manager submodule is itself threaded through `config`, so using
  it to decide what to import (e.g. `if pkgs.stdenv.isDarwin then …`) is a genuine
  infinite-recursion trap — hit this directly while building `home/default.nix`. Use a
  plain value that doesn't depend on `config` instead (here, `host.system`, a string
  known up front).
- **Nothing named `lib/` at the repo root.** A global `~/.gitignore` on this machine
  (generic Python-project boilerplate) ignores any `lib/` directory anywhere in the
  tree, silently. The host-builder helper lives at `nix/mk/` for exactly this reason —
  don't rename it back to `lib/`.
- **Never edit the generated dotfiles in `$HOME`.** `~/.p10k.zsh`, `~/.config/lazyvim/*`,
  and the zsh config are read-only `/nix/store` symlinks. Edit the source here, rebuild.
- **String escaping in Nix `''…''` blocks.** `${…}` is Nix interpolation
  (e.g. `${pkgs.rsync}/bin/rsync`) and `''${…}` is a literal shell `${…}`. Getting this
  wrong usually shows up as a confusing evaluation error, not a runtime one.
- **Indentation is mixed** — tabs in code carried over from the original single-file
  flake, spaces in code written since. Match whatever the surrounding file uses rather
  than reformatting.
- **Don't bump `stateVersion`/`homeStateVersion` in `hosts/*.nix`** as part of an
  unrelated change; they pin migration behavior, not a version to keep current. A
  new host should get the *current* values at creation time, not copy an existing
  host's — e.g. `work-mac`'s `homeStateVersion` is `"26.05"` where `personal-mac`'s
  is still `"23.05"`. This is also why `home/common/git.nix` deliberately doesn't
  set `programs.git.signing.format`: home-manager's own default for it depends on
  each host's `home.stateVersion` (legacy `"openpgp"` below `"25.05"`, `null`
  after), and hardcoding it in the shared file would override that per-host
  migration behavior for every host.
- **A structural refactor is not proven safe by "it builds."** Two derivations can both
  build successfully while installing different things. Use
  `nix store diff-closures <old> <new>` (on the two `result` symlinks, or saved store
  paths) and explain every line item — don't accept an unexplained diff.
- The zsh `initContent` installs Poetry over the network on first shell start if it is
  missing — Poetry is intentionally outside nix here.
- **`linux-desktop` can't be fully built from a macOS machine.** `nix build
  .#homeConfigurations.linux-desktop.activationPackage` from Darwin fetches
  essentially everything from the binary cache successfully, but fails on a handful
  of tiny glue scripts (session-vars, activation script, etc.) that home-manager
  generates per-configuration rather than pulling from cache — those need an actual
  `x86_64-linux` builder (real hardware, emulation, or a remote builder). A clean
  `nix flake check` plus that mostly-successful fetch is the strongest verification
  available without one; don't mistake the platform-mismatch errors at the end for a
  real bug in the config.
- **Don't add an AeroSpace `on-window-detected` rule for Ghostty.** Ghostty's docs
  recommend `run = ['layout tiling']` for tiling WMs; it was tried on real hardware and
  does not work — `layout` only decides how a detected window is placed, and each native
  macOS tab is still reported as its own window, so the workspace still splits. The fix
  lives on the Ghostty side instead (`home/darwin/ghostty.nix` rebinds `cmd+t` to
  `new_split:auto`). Revisit if Ghostty ships non-native tabs (ghostty-org/ghostty#10711).
