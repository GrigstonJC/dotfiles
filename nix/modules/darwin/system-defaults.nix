{ pkgs, host, ... }:
{
	nix.settings.experimental-features = "nix-command flakes";
	nixpkgs.config.allowUnfree = true;
	nixpkgs.hostPlatform = host.system;

	### SYSTEM SETTINGS ###
	system.defaults = {
		dock.autohide = true;
		controlcenter.BatteryShowPercentage = true;
		dock.tilesize = 48;
		dock.show-recents = false;
		dock.persistent-apps = [
			"/Applications/Bear.app"
			"/Applications/Google Chrome.app"
			"/Applications/Slack.app"
			"/Applications/iTerm.app"
			"/Applications/GIMP.app"
			"/Applications/Discord.app"
			"/System/Applications/Podcasts.app"
			"/Applications/Spotify.app"
			"/System/Applications/TV.app"
		];
		dock.persistent-others = [
			"/Applications"
		];
		dock.wvous-bl-corner = 4;
		dock.wvous-tl-corner = 2;
		dock.wvous-br-corner = 1;
		dock.wvous-tr-corner = 4;
		# trampolines.nix's nixApplications script is required to get trackpad
		# settings to apply without a restart.
		# Settings may not be reflected in system settings for some reason (cache-related?)
		trackpad.Clicking = true;
		trackpad.Dragging = true;
		trackpad.TrackpadRightClick = true;
		NSGlobalDomain."com.apple.swipescrolldirection" = false;
	};
	system.keyboard = {
		enableKeyMapping = true;
		remapCapsLockToEscape = true;
	};

	### NIX-MANAGED PACKAGES ###
	# Portable CLI tools live in home/common/packages.nix instead, so they also
	# work on non-Darwin hosts. Only genuinely system-scoped / Darwin-specific
	# packages belong here.
	environment.systemPackages = with pkgs; [
		alacritty
		awscli2
		google-cloud-sdk
		mkalias
		neovim
		opencode
		stow
		tmate
	];

	### FONTS ###
	fonts.packages = [
		pkgs.nerd-fonts.jetbrains-mono
	];
}
