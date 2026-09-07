# Builds one standalone homeConfiguration from a host descriptor (see
# hosts/*.nix) — the Linux path, where nix manages the user environment but
# not the system (apt/pacman/etc. own that). No nix-darwin, no Homebrew.
#
# Identity resolution and the `name` parameter mirror mk/mkHost.nix — see
# that file's header.
{ inputs }:
name: host:
let
  inherit (inputs) nixpkgs home-manager identity;
  identityValues = import "${identity}/identity.nix";
  namedHost = host // { inherit name; };
  pkgs = import nixpkgs {
    system = host.system;
    config.allowUnfree = true;
  };
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = { host = namedHost; identity = identityValues; };
  modules = [ ../home ];
}
