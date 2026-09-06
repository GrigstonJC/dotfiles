{ pkgs, config, ... }:
{
	# Only config.my.defaultPython is actually installed here. python311 and
	# python312 are deliberately NOT listed — they're reachable only via the
	# fully-qualified store paths baked into shell.nix's python311/python312
	# aliases, which pulls each into the closure without installing a second
	# generic bin/idle, bin/python3, bin/2to3, etc. that collides with the
	# default's. home-manager's home.packages buildEnv fails hard on such
	# collisions, unlike environment.systemPackages, which silently tolerates
	# them.
	#
	# pip/virtualenv are pinned to 3.13 regardless of the default.
	home.packages = [
		config.my.defaultPython
		pkgs.python313Packages.pip
		pkgs.python313Packages.virtualenv
	];
}
