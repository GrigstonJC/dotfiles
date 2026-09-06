# dotfiles

Personal multi-machine [nix-darwin](https://github.com/LnL7/nix-darwin) /
[home-manager](https://github.com/nix-community/home-manager) configuration.
Currently covers one macOS machine (`personal-mac`); a standalone
home-manager path for Ubuntu/PopOS/Arch is planned. See `CLAUDE.md` for the
full architecture.

No usernames, emails, or hostnames are committed to this repo — see
**Identity** below.

## First-time setup on a new machine

1. Install [Nix](https://nixos.org/download) and, on macOS,
   [nix-darwin](https://github.com/LnL7/nix-darwin).
2. Clone this repo to `~/.config/dotfiles`.
3. Supply your identity (see below).
4. Build and switch:
   ```sh
   sudo darwin-rebuild switch \
     --flake ~/.config/dotfiles/nix#personal-mac \
     --override-input identity "path:$HOME/.config/dotfiles-identity"
   ```
   After that first switch, the `nix-switch` shell alias covers this for you
   on subsequent rebuilds.

## Identity

This repo commits no personally identifying information. `nix/identity/identity.nix`
is a tracked placeholder so the flake still evaluates on a fresh clone
(`nix flake check` passes with it as-is). Your real values live outside the
repo and are supplied at switch time:

```sh
mkdir -p ~/.config/dotfiles-identity
cp ~/.config/dotfiles/nix/identity/identity.nix ~/.config/dotfiles-identity/
$EDITOR ~/.config/dotfiles-identity/identity.nix   # fill in username, gitName, gitEmail
```

Git identity (`programs.git.userName`/`userEmail`, see `home/common/git.nix`) is
also sourced from here rather than from a profile — each machine has its own
identity file, so a work machine's git email never needs to live in a
committed profile.

`--override-input identity "path:$HOME/.config/dotfiles-identity"` (already
wired into the `nix-switch` alias) points the build at that file instead of
the placeholder. Nothing about this step touches git or gets committed.

## Adding a host

Hosts are named by role (`personal-mac`), not hostname or owner. To add one:

1. Add `nix/hosts/<role>.nix` (system triple, profile, state versions —
   see `nix/hosts/personal-mac.nix`).
2. Add it to `darwinConfigurations` in `nix/flake.nix`.
3. If it needs its own home-manager profile, add `nix/home/profiles/<profile>.nix`.

See `CLAUDE.md` for the package-placement rules (what goes in
`home/common/`, `modules/darwin/`, or Homebrew) and the git workflow this
repo follows.
