# Builds one darwinConfiguration from a host descriptor (see hosts/*.nix).
#
# Identity (username, etc.) is resolved here from the `identity` flake input
# rather than baked into any host file — see nix/identity/identity.nix and
# README.md for how the real values get supplied at switch time.
#
# `name` is the flake attribute this host is registered under in flake.nix
# (e.g. "personal-mac") — threaded onto `host` here rather than duplicated
# inside every hosts/*.nix file, so it stays single-sourced. Consumed by
# home/common/shell.nix, which bakes it straight into the generated
# ~/.zshrc's nix-switch function, and by home/default.nix, which also
# exports it as $DOTFILES_HOST for prompts/scripting (not what nix-switch
# itself reads — see that file's Gotchas note on why).
{ inputs }:
name: host:
let
  inherit (inputs) self nix-darwin nix-homebrew home-manager identity;
  identityValues = import "${identity}/identity.nix";
  username = identityValues.username;
  namedHost = host // { inherit name; };
in
nix-darwin.lib.darwinSystem {
  specialArgs = { host = namedHost; identity = identityValues; };
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
      home-manager.extraSpecialArgs = { host = namedHost; identity = identityValues; };
      home-manager.users.${username} = import ../home;
    }
  ];
}
