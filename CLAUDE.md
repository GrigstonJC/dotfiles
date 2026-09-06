# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal [nix-darwin](https://github.com/LnL7/nix-darwin) flake that declares one
macOS machine end to end: system defaults, packages, Homebrew casks, and per-user
dotfiles. Nearly everything lives in `nix/flake.nix`; the other files are data it
imports or dotfiles it symlinks.

There is exactly one host — `darwinConfigurations."m4"` (`aarch64-darwin`, user `jeff`).

## Commands

All commands run from `nix/` (the `dot` shell alias jumps there).

```sh
# Apply the configuration (the `nix-switch` alias)
sudo darwin-rebuild switch --flake ~/.config/dotfiles/nix#m4

# Evaluate + build WITHOUT activating — use this to check a change
darwin-rebuild build --flake .#m4

# Bump all flake inputs (the `nix-update` alias), then switch
nix flake update
```

There is no test suite, linter, or CI. `darwin-rebuild build` is the only
verification step: it catches evaluation and build errors without touching the
live system.

## Git workflow

**Never commit directly to `main`, and never push.** Every change — including
one-line edits — goes on its own branch, and pushing is the user's call, not Claude's.

```sh
# 1. Branch off main (which should be clean and up to date)
git checkout -b docs/claude-md      # <type>/<description>

# 2. Commit the change there
git add CLAUDE.md
git commit -m "add CLAUDE.md"

# 3. Stop. Do not push. Report the branch name and let the user review.
```

Branch prefixes: `docs/`, `feat/`, `fix/`, `chore/`.

Note that `git log` on this repo shows a long run of commits made straight to `main`.
That is history, not the convention — follow the procedure above instead.

### Landing a branch on main

The user does this, or asks for it explicitly. History here is linear (there are no
merge commits) and should stay that way:

```sh
git checkout main
git merge --ff-only docs/claude-md   # rebase the branch onto main first if this fails
git push
```

## Architecture

`nix/flake.nix` binds two module functions in a `let` block and composes them at the
bottom under `darwinConfigurations."m4"`:

- **`configuration`** — system scope. macOS defaults (`system.defaults`, keyboard
  remaps), `services.aerospace` / `services.jankyborders`, `environment.systemPackages`,
  the whole `homebrew` block, `fonts.packages`, and a post-activation script
  (`system.activationScripts.nixApplications`) that rsyncs nix app trampolines into
  `~/Applications/Nix Trampolines` so Spotlight indexes them, then runs
  `activateSettings -u` to avoid a logout cycle.
- **`homeconfig`** — home-manager scope for user `jeff`. `home.file` symlinks,
  `home.packages` (dev tooling: pyright, shellcheck, shfmt, bash-language-server),
  and `programs.{zsh,tmux,dircolors}` including all shell aliases.

The modules list also wires in `nix-homebrew` (with Rosetta enabled) and
`home-manager` (`useGlobalPkgs`, `useUserPackages`).

### Where a new package goes

Three separate channels, all declared in `flake.nix`:

| Need | Where |
|---|---|
| CLI tool available system-wide | `environment.systemPackages` |
| Per-user dev tooling / LSPs | `homeconfig`'s `home.packages` |
| GUI app or GNU-flavored CLI | `homebrew.casks` / `homebrew.brews` |
| Mac App Store app | `homebrew.masApps` (needs the numeric app id) |

`homebrew.onActivation.cleanup = "zap"` — anything installed manually and not listed
here is **removed** on the next rebuild. `upgrade = true` also means brew packages
move on every switch.

Python is special: `python313` is listed first in `systemPackages` deliberately, to
win the PATH race and become the default `python3`. `python311`/`python312` are also
installed and reachable via the `python311`/`python312` aliases.

### Neovim

`lvim` (the `lvim` alias, `NVIM_APPNAME=lazyvim nvim`) is the only Neovim
configuration — it points Neovim at `~/.config/lazyvim`, which home-manager symlinks
from `nix/lazyvim/**`. LazyVim bootstraps `lazy.nvim` by cloning it at first launch
and resolves its own plugins, so it is **not** pinned by nix. Plain `neovim` in
`environment.systemPackages` just supplies the unconfigured `nvim` binary LazyVim
runs on top of — there is no separate nix-managed plugin/config setup anymore.

Adding a file under `nix/lazyvim/` is not enough — each path needs its own
`home.file.".config/lazyvim/…".source` entry in `homeconfig`, or it never reaches
`$HOME`.

### Other imported data

- `nix/aerospace-config.toml` — the AeroSpace tiling-WM config (alt-based focus/move/
  workspace bindings), pulled in with `pkgs.lib.importTOML`. Edits require a rebuild.
- `nix/p10k_configuration` — the powerlevel10k theme, symlinked to `~/.p10k.zsh` and
  sourced at the end of the zsh `initContent`.

## Gotchas

- **`nix/.p10k.zsh` is dead weight.** It is byte-identical to `p10k_configuration` and
  tracked in git, but nothing references it. Edit `p10k_configuration`; changing only
  `.p10k.zsh` has no effect.
- **Never edit the generated dotfiles in `$HOME`.** `~/.p10k.zsh`, `~/.config/lazyvim/*`,
  and the zsh config are read-only `/nix/store` symlinks. Edit the source here, rebuild.
- **String escaping in `flake.nix`.** Inside `''…''` blocks, `${…}` is Nix interpolation
  (e.g. `${pkgs.python311}/bin/python3`) and `''${…}` is a literal shell `${…}`. Getting
  this wrong usually shows up as a confusing evaluation error, not a runtime one.
- **Indentation is mixed** — tabs in the older sections, spaces in the newer ones. Match
  whatever the surrounding block uses rather than reformatting.
- **Don't bump `system.stateVersion` (5) or `home.stateVersion` ("23.05")** as part of an
  unrelated change; they pin migration behavior, not a version to keep current.
- The zsh `initContent` installs Poetry over the network on first shell start if it is
  missing — Poetry is intentionally outside nix here.
