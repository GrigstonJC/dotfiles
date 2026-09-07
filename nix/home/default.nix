# Entry point for the home-manager configuration. Shared across every host
# and platform this repo supports — Darwin today, standalone home-manager
# on Linux planned (see CLAUDE.md).
{ lib, host, identity, ... }:
{
	home.stateVersion = host.homeStateVersion;
	home.username = identity.username;
	home.homeDirectory =
		if lib.hasSuffix "-darwin" host.system
		then "/Users/${identity.username}"
		else "/home/${identity.username}";
	programs.home-manager.enable = true;

	# Which flake output built this machine (e.g. "personal-mac") — how
	# nix-switch (home/common/shell.nix) knows what to switch without a
	# hardcoded host name in a file every host shares.
	home.sessionVariables.DOTFILES_HOST = host.name;

	# Platform comes from host.system (a plain string, known up front) rather
	# than pkgs.stdenv.isDarwin — referencing pkgs inside `imports` on a
	# useGlobalPkgs home-manager submodule is a real infinite-recursion trap,
	# since pkgs there is itself threaded through config.
	imports = [
		./common
		(if lib.hasSuffix "-darwin" host.system then ./darwin else ./linux)
		(./profiles + "/${host.profile}.nix")
	];
}
