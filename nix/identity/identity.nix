# Placeholder identity, tracked in git so a fresh clone still evaluates and
# `nix flake check` passes.
#
# Real values must never be committed. Copy this file to
# ~/.config/dotfiles-identity/identity.nix, fill it in, and it's picked up
# automatically at switch time via the `nix-switch` alias's --override-input.
# See README.md.
{
  username = "changeme";
}
