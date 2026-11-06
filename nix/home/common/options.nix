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

	options.my.githubSshKey = lib.mkOption {
		type = lib.types.str;
		default = "~/.ssh/id_ed25519";
		description = ''
			Private key ssh uses for github.com. The key itself lives outside
			the repo; override the path per host (in its home/profiles/*.nix)
			when that machine's key has a different name.
		'';
	};
}
