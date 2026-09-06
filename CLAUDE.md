# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A multi-machine [nix-darwin](https://github.com/LnL7/nix-darwin) /
[home-manager](https://github.com/nix-community/home-manager) configuration, designed
to eventually also cover Linux (Ubuntu/PopOS/Arch, via standalone home-manager — no
NixOS host exists yet). See `README.md` for first-time and new-machine setup.

Hosts are named by **role**, not hostname or owner (`personal-mac`, not `m4` or
`jeff`) — this repo commits no usernames, emails, or hostnames. See **Identity** below.

Two hosts exist today: `darwinConfigurations.personal-mac` and `.work-mac` (both
`aarch64-darwin`).

## Commands

All commands run from `nix/` (the `dot` shell alias jumps there).

```sh
# Apply the configuration (the `nix-switch` alias) — needs a real identity, see below
sudo darwin-rebuild switch --flake ~/.config/dotfiles/nix#personal-mac \
  --override-input identity "path:$HOME/.config/dotfiles-identity"

# Evaluate + build WITHOUT activating — use this to check a change
darwin-rebuild build --flake .#personal-mac --override-input identity "path:$HOME/.config/dotfiles-identity"

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

## Identity

Nothing identifying is committed. `nix/identity/identity.nix` is a tracked
**placeholder** (`username`, `gitName`, `gitEmail`) that exists only so a fresh
clone evaluates and `nix flake check` passes. Real values live outside the repo,
at `~/.config/dotfiles-identity/identity.nix`, and are supplied at switch time via
`--override-input identity "path:$HOME/.config/dotfiles-identity"` (already wired
into the `nix-switch` alias). See README.md for the one-time setup.

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
  flake.nix              inputs + darwinConfigurations wiring only
  identity/identity.nix  committed placeholder (see Identity)
  mk/mkHost.nix          builds one darwinConfiguration from a host descriptor
  hosts/<role>.nix        { system, profile, stateVersion, homeStateVersion }
  modules/darwin/        nix-darwin system modules (macOS-only)
  home/
    default.nix           picks common + platform + profile for one host
    common/                the portable core — works on Darwin and (future) Linux
    darwin/, linux/        platform-only home-manager config (both empty stubs today)
    profiles/<name>.nix    profile-only home-manager config (both empty today)
  files/                  data files modules import/symlink (p10k, lazyvim, aerospace)
```

`nix/flake.nix` calls `mk/mkHost.nix` once per host in `hosts/`. `mkHost.nix` resolves
identity, then builds a `nix-darwin.lib.darwinSystem` wiring in `modules/darwin`
(system scope), `nix-homebrew`, and `home-manager.darwinModules.home-manager` — the
latter pointing `home-manager.users.<username>` at `home/default.nix`.

`home/default.nix` always imports `home/common/`, then picks `home/darwin` or
`home/linux` by inspecting `host.system` (a plain string — **not**
`pkgs.stdenv.isDarwin`; see Gotchas), then imports `home/profiles/<host.profile>.nix`.

**Which host is "this machine"?** There's no detection — it's whichever flake
attribute you build with, chosen once by the human running the command. `mkHost`
takes that name as an explicit argument (`mkHost "personal-mac" (import
./hosts/personal-mac.nix)` in `flake.nix`) and threads it onto `host.name`, which
`home/default.nix` exports as `$DOTFILES_HOST` via `home.sessionVariables`. That's
how `nix-switch` (`home/common/shell.nix`) knows which host to target without a
hardcoded name in a file every host shares — it reads `$DOTFILES_HOST`, set by the
*previous* successful switch. A machine that has never switched yet has no value
to read, which is exactly why first setup on a new host uses the full explicit
`darwin-rebuild switch --flake …#<name> …` command by hand (README) rather than
`nix-switch`.

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
nix. Plain `neovim` in `modules/darwin/system-defaults.nix` just supplies the
unconfigured `nvim` binary LazyVim runs on top of.

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
