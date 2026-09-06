# Builds one darwinConfiguration from a host descriptor (see hosts/*.nix).
#
# Identity (username, etc.) is resolved here from the `identity` flake input
# rather than baked into any host file — see nix/identity/identity.nix and
# README.md for how the real values get supplied at switch time.
{ inputs }:
host:
let
  inherit (inputs) self nix-darwin nix-homebrew home-manager identity;
  identityValues = import "${identity}/identity.nix";
  username = identityValues.username;
in
nix-darwin.lib.darwinSystem {
  specialArgs = { inherit host; identity = identityValues; };
  modules = [
    ../modules/darwin

    {
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = host.stateVersion;
      system.primaryUser = username;
      users.users.${username} = {
        name = username;
        home = "/Users/${username}";
      };
    }

    nix-homebrew.darwinModules.nix-homebrew
    {
      nix-homebrew = {
        enable = true;
        enableRosetta = true;
        user = username;
      };
    }

    home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
      home-manager.extraSpecialArgs = { inherit host; identity = identityValues; };
      home-manager.users.${username} = import ../home;
    }
  ];
}
