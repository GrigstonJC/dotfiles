{
	description = "Multi-machine, multi-platform dotfiles (nix-darwin + home-manager)";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
		nix-darwin = {
			url = "github:LnL7/nix-darwin";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# Machine-specific values that must never be committed (username, etc.).
		# identity/identity.nix here is a tracked PLACEHOLDER so a fresh clone
		# still evaluates. Real values live outside the repo and are supplied
		# at switch time via --override-input; see README.md.
		identity = {
			url = "path:./identity";
			flake = false;
		};
	};

	outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager, identity }:
	let
		mkHost = import ./mk/mkHost.nix { inherit inputs; };
	in
	{
		darwinConfigurations = {
			# Build with: $ darwin-rebuild build --flake .#<name>
			personal-mac = mkHost (import ./hosts/personal-mac.nix);
			work-mac = mkHost (import ./hosts/work-mac.nix);
		};

		# Expose the package set, including overlays, for convenience.
		darwinPackages = self.darwinConfigurations.personal-mac.pkgs;
	};
}
