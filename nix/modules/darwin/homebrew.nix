{ ... }:
{
	### HOMEBREW-MANAGED PACKAGES ###
	homebrew = {
		enable = true;
		onActivation.cleanup = "zap";
		onActivation.upgrade = true;
		# GNU-flavored commands used to live here — migrated to nix
		# (home/common/packages.nix), which provides the same tool identically
		# on Linux too. mas and nvtop stay on Homebrew: no nix-managed
		# equivalent makes sense for a Mac App Store CLI or a macOS-specific
		# GPU monitor.
		brews = [
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
			"gimp"
			"google-chrome"
			"firefox"
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
