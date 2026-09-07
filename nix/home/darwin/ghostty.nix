# Ghostty uses native macOS tabs, which the Accessibility API reports as
# separate windows — so every new tab makes AeroSpace re-tile and shrink the
# window. Splits live inside one macOS window, so AeroSpace sees only one.
# See CLAUDE.md (Gotchas) and https://ghostty.org/docs/help/macos-tiling-wms.
{ ... }:
let
	# Ported from iTerm2's Default profile
	# (~/Library/Preferences/com.googlecode.iterm2.plist). That profile's
	# (Light) and (Dark) ANSI palettes are byte-identical — only
	# background/foreground/bold differ per appearance — so the palette and
	# cursor/selection colors are defined once and shared between themes.
	shared = {
		palette = [
			"0=#002831"  "1=#d11c24"  "2=#738a05"  "3=#a57706"
			"4=#2176c7"  "5=#c61c6f"  "6=#259286"  "7=#eae3cb"
			"8=#475b62"  "9=#bd3613"  "10=#475b62" "11=#536870"
			"12=#708284" "13=#5956ba" "14=#819090" "15=#fcf4dc"
		];
		cursor-color = "708284";
		cursor-text = "002831";
		selection-background = "002831";
		selection-foreground = "819090";
	};
in
{
	programs.ghostty = {
		# ghostty-bin is installed in modules/darwin/system-defaults.nix.
		# null keeps this module to writing ~/.config/ghostty/config —
		# pkgs.ghostty is Linux-only and would fail to build here.
		package = null;
		enable = true;

		# iTerm2's Background/Foreground Color (Light) and (Dark).
		themes = {
			iterm2-light = shared // {
				background = "001e27";
				foreground = "708284";
				bold-color = "819090";
			};
			iterm2-dark = shared // {
				background = "1a1a1a";
				foreground = "e6e6e6";
				bold-color = "5ecacf";
			};
		};

		settings = {
			# Follows macOS's light/dark appearance, same as iTerm2 does.
			theme = "light:iterm2-light,dark:iterm2-dark";
			keybind = [
				"cmd+t=new_split:auto"
				"cmd+shift+t=new_tab"
			];
		};
	};
}
