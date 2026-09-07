# Ghostty uses native macOS tabs, which the Accessibility API reports as
# separate windows — so every new tab makes AeroSpace re-tile and shrink the
# window. Splits live inside one macOS window, so AeroSpace sees only one.
# See CLAUDE.md (Gotchas) and https://ghostty.org/docs/help/macos-tiling-wms.
{ ... }:
{
	programs.ghostty = {
		# ghostty-bin is installed in modules/darwin/system-defaults.nix.
		# null keeps this module to writing ~/.config/ghostty/config —
		# pkgs.ghostty is Linux-only and would fail to build here.
		package = null;
		enable = true;
		settings.keybind = [
			"cmd+t=new_split:auto"
			"cmd+shift+t=new_tab"
		];
	};
}
