# Custom options for values that should be standardized across machines but
# may need a per-host override (see hosts/*.nix).
{ lib, pkgs, ... }:
{
	options.my.defaultPython = lib.mkOption {
		type = lib.types.package;
		default = pkgs.python313;
		description = ''
			Interpreter that wins PATH precedence for the unpinned `python3` /
			`pip3` shell commands. Must stay first in home/common/python.nix's
			package list — home-manager's profile builder resolves same-priority
			filename collisions (bin/python3, bin/pip3, ...) by list order, not
			by this option alone. Override per host (in hosts/*.nix, via
			home-manager config) to change that machine's default version.
		'';
	};
}
