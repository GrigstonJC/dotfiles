# Host is identified by role, not hostname or owner — see personal-mac.nix.
{
  # System triple this host builds for (nixpkgs.hostPlatform).
  system = "aarch64-darwin";

  # Selects home/profiles/<profile>.nix.
  profile = "work";

  # Pin migration behavior. Don't bump casually — check nix-darwin's and
  # home-manager's release notes first. Set to the current values as of this
  # host's creation, not personal-mac's — each host pins its own.
  stateVersion = 5;
  homeStateVersion = "26.05";
}
