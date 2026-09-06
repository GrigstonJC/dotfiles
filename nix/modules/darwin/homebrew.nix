{ ... }:
{
	### HOMEBREW-MANAGED PACKAGES ###
	homebrew = {
		enable = true;
		onActivation.cleanup = "zap";
		onActivation.upgrade = true;
		brews = [
			# Install GNU-flavored commands
			"autoconf"
			"bash"
			"binutils"
			"coreutils"
			"diffutils"
			"ed"
			"findutils"
			"flex"
			"gawk"
			"gnu-indent"
			"gnu-sed"
			"gnu-tar"
			"gnu-which"
			"gpatch"
			"grep"
			"gzip"
			"less"
			"m4"
			"make"
			"nano"
			"screen"
			"watch"
			"wdiff"
			"wget"
			"zip"

			# Others
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
