# Host is identified by role, not hostname or owner — see personal-mac.nix.
{
  # System triple this host builds for. x86_64-linux is the common case for
  # a desktop PC — change to aarch64-linux if the actual hardware is ARM.
  system = "x86_64-linux";

  # Selects home/profiles/<profile>.nix.
  profile = "personal";

  # Pin migration behavior. No stateVersion here — that option is
  # nix-darwin-specific; standalone home-manager only needs
  # homeStateVersion. Set to the current value as of this host's creation,
  # not copied from another host.
  homeStateVersion = "26.05";
}
