{ ... }:
{
	### HOMEBREW-MANAGED PACKAGES ###
	homebrew = {
		enable = true;
		onActivation.cleanup = "zap";
		onActivation.upgrade = true;
		# Only things with no sensible nix equivalent belong here — a Mac App
		# Store CLI and a macOS-specific GPU monitor. GNU-flavored commands and
		# anything else nix provides identically live in
		# home/common/packages.nix instead.
		brews = [
			"herdr"  # herdrdev/herdr's own flake fails to build (crates.io 403)
			"mas"
			"nvtop"
		];
		casks = [
			"aldente"
			"betterdisplay"
			"devtoys"
			"discord"
			"docker-desktop"
			"dropbox"
			"element"
			"expressvpn"
			"firefox"
			"gimp"
			"google-chrome"
			"iterm2"
			"libreoffice"
			"neo4j"
			"numi"
			"slack"
			"spotify"
			"steam"
		];
		taps = [];
		masApps = {
			"Bear" = 1091189122;
			# Tot (1498235191) must be installed manually through Mac App Store because it's an iOS app
		};
	};
}
