# dotfiles

Personal multi-machine [nix-darwin](https://github.com/LnL7/nix-darwin) /
[home-manager](https://github.com/nix-community/home-manager) configuration.
Covers two macOS machines (`personal-mac`, `work-mac`, via nix-darwin) and one
Linux desktop (`linux-desktop`, via standalone home-manager — nix manages the
user environment; apt/pacman/etc. still own the system) — see `nix/hosts/`.
See `CLAUDE.md` for the full architecture.

No usernames, emails, or hostnames are committed to this repo — see
**Identity** below.

## First-time setup on a new machine

1. Install [Nix](https://nixos.org/download) and, on macOS,
   [nix-darwin](https://github.com/LnL7/nix-darwin). Linux needs nothing
   beyond Nix itself — apt/pacman/etc. still own the system; nix only
   manages the user environment there.
2. Clone this repo to `~/.config/dotfiles`.
3. Supply your identity (see below).
4. **Decide which host this machine is** — currently `personal-mac`,
   `work-mac`, or `linux-desktop` (see `nix/hosts/`), or add a new one first
   (see "Adding a host") if it's neither. This choice is permanent for this
   machine: it picks which profile/apps you get, and the *first* switch
   below is what `nix-switch` then keeps targeting on every rebuild after
   (the host name gets baked into the `~/.zshrc` that switch generates — see
   `CLAUDE.md`). Picking the wrong one gives you the wrong profile with no
   error and no visible sign a choice was even made.
5. Build and switch, replacing `<host>` with the name from step 4:
   - macOS:
     ```sh
     sudo darwin-rebuild switch \
       --flake ~/.config/dotfiles/nix#<host> \
       --override-input identity "path:$HOME/.config/dotfiles-identity"
     ```
   - Linux (untested on real hardware so far — the `home-manager` CLI isn't
     installed yet on a fresh machine, so the very first activation runs
     this flake's own build of it directly):
     ```sh
     nix run ~/.config/dotfiles/nix#homeConfigurations.<host>.activationPackage \
       --override-input identity "path:$HOME/.config/dotfiles-identity"
     ```

   After that first switch, the `nix-switch` shell function covers this for
   you on subsequent rebuilds (dispatching to `darwin-rebuild` or
   `home-manager switch` depending on the OS), targeting the host you just
   chose.

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
wired into the `nix-switch` function) points the build at that file instead of
the placeholder. Nothing about this step touches git or gets committed.

## Adding a host

Hosts are named by role (`personal-mac`, `work-mac`, `linux-desktop`), not
hostname or owner. To add one:

1. Add `nix/hosts/<role>.nix` (system triple, profile, state versions — see
   an existing `nix/hosts/*.nix` for your platform). macOS hosts need both
   `stateVersion` and `homeStateVersion`; Linux (standalone home-manager)
   only needs `homeStateVersion` — there's no nix-darwin `stateVersion` to
   set. Give it *current* values as of when you're actually about to first
   switch it, not copied from an existing host — see CLAUDE.md.
2. Add it to `darwinConfigurations` (macOS) or `homeConfigurations` (Linux)
   in `nix/flake.nix`, using `mkHost` or `mkHomeHost` respectively.
3. Point it at a profile in `nix/home/profiles/`. Reuse an existing one if
   this host should behave like an existing category of machine (e.g. a
   second personal laptop can set `profile = "personal";` to share
   `personal-mac`'s apps/settings while still getting its own state
   versions), or add a new `<profile>.nix` if it needs its own.

See `CLAUDE.md` for the package-placement rules (what goes in
`home/common/`, `modules/darwin/`, or Homebrew) and the git workflow this
repo follows.
