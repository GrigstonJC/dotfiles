# dotfiles

Personal multi-machine [nix-darwin](https://github.com/LnL7/nix-darwin) /
[home-manager](https://github.com/nix-community/home-manager) configuration.
Currently covers two macOS machines, `personal-mac` and `work-mac` (see
`nix/hosts/`); a standalone home-manager path for Ubuntu/PopOS/Arch is
planned. See `CLAUDE.md` for the full architecture.

No usernames, emails, or hostnames are committed to this repo — see
**Identity** below.

## First-time setup on a new machine

1. Install [Nix](https://nixos.org/download) and, on macOS,
   [nix-darwin](https://github.com/LnL7/nix-darwin).
2. Clone this repo to `~/.config/dotfiles`.
3. Supply your identity (see below).
4. **Decide which host this machine is** — currently `personal-mac` or
   `work-mac` (see `nix/hosts/`), or add a new one first (see "Adding a
   host") if it's neither. This choice is permanent for this machine: it
   picks which profile/apps you get, and the *first* switch below is what
   `nix-switch` then keeps targeting on every rebuild after (via
   `$DOTFILES_HOST` — see `CLAUDE.md`). Picking the wrong one gives you the
   wrong profile with no error and no visible sign a choice was even made.
5. Build and switch, replacing `<host>` with the name from step 4:
   ```sh
   sudo darwin-rebuild switch \
     --flake ~/.config/dotfiles/nix#<host> \
     --override-input identity "path:$HOME/.config/dotfiles-identity"
   ```
   After that first switch, the `nix-switch` shell alias covers this for you
   on subsequent rebuilds, targeting the host you just chose.

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

Git identity (`programs.git.settings.user.{name,email}`, see
`home/common/git.nix`) is also sourced from here rather than from a profile —
each machine has its own identity file, so a work machine's git email never
needs to live in a committed profile.

`--override-input identity "path:$HOME/.config/dotfiles-identity"` (already
wired into the `nix-switch` alias) points the build at that file instead of
the placeholder. Nothing about this step touches git or gets committed.

## Adding a host

Hosts are named by role (`personal-mac`, `work-mac`), not hostname or owner. To
add one:

1. Add `nix/hosts/<role>.nix` (system triple, profile, state versions — see
   `nix/hosts/personal-mac.nix` or `work-mac.nix`). Give it *current*
   `stateVersion`/`homeStateVersion` values as of when you're actually about
   to first switch it, not copied from an existing host — see CLAUDE.md.
2. Add it to `darwinConfigurations` in `nix/flake.nix`.
3. Point it at a profile in `nix/home/profiles/`. Reuse an existing one if
   this host should behave like an existing category of machine (e.g. a
   second personal laptop can set `profile = "personal";` to share
   `personal-mac`'s apps/settings while still getting its own state
   versions), or add a new `<profile>.nix` if it needs its own.

See `CLAUDE.md` for the package-placement rules (what goes in
`home/common/`, `modules/darwin/`, or Homebrew) and the git workflow this
repo follows.
