# Host is identified by role, not hostname or owner — this machine's actual
# hostname contains a first name, which is exactly what this file avoids.
{
  # System triple this host builds for (nixpkgs.hostPlatform).
  system = "aarch64-darwin";

  # Selects home/profiles/<profile>.nix.
  profile = "personal";

  # Pin migration behavior. Don't bump casually — check nix-darwin's and
  # home-manager's release notes first.
  stateVersion = 5;
  homeStateVersion = "23.05";
}
