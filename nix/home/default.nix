# Entry point for the home-manager configuration. Shared across every host
# and platform this repo supports — Darwin today, standalone home-manager
# on Linux planned (see CLAUDE.md).
{ lib, host, ... }:
{
	home.stateVersion = host.homeStateVersion;
	programs.home-manager.enable = true;

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
