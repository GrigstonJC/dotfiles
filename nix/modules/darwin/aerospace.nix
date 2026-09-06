{ pkgs, ... }:
{
	services = {
		aerospace = {
			enable = true;
			settings = pkgs.lib.importTOML ../../files/aerospace.toml;
		};
		jankyborders = {
			enable = true;
		};
	};
}
