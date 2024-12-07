{
	description = "nix-darwin system flake";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
		nix-darwin = {
			url = "github:LnL7/nix-darwin";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};


	outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager }:
	let
		configuration = { pkgs, config, ... }: {

		services.nix-daemon.enable = true;
		nix.settings.experimental-features = "nix-command flakes";
		nixpkgs.config.allowUnfree = true;

		system.configurationRevision = self.rev or self.dirtyRev or null;
		system.stateVersion = 5;

		security.pam.enableSudoTouchIdAuth = true;
		programs.zsh.enable = true;


		### SYSTEM SETTINGS ###
		system.defaults = {
			dock.autohide = true;
			dock.show-recents = false;
			dock.persistent-apps = [
				"/Applications/Bear.app"
				"/Applications/Google Chrome.app"
				"/Applications/Nix Apps/Alacritty.app"
				"/System/Applications/TV.app"
			];
			dock.persistent-others = [
				"/Applications"
			];
		};
		system.keyboard = {
			enableKeyMapping = true;
			remapCapsLockToEscape = true;
		};


		### NIX-MANAGED PACKAGES ###
		environment.systemPackages = [
			pkgs.alacritty
			pkgs.git
			pkgs.mkalias
			pkgs.neovim
			pkgs.tmux
		];


		### FONTS ###
		fonts.packages = [
			pkgs.nerd-fonts.jetbrains-mono
		];


		### HOMEBREW-MANAGED PACKAGES ###
		homebrew = {
			enable = true;
			onActivation.cleanup = "zap";
			brews = [
				"mas"
			];
			casks = [
				"google-chrome"
				"firefox"
			];
			masApps = {
				"Bear" = 1091189122;
			};
		};


		### USERS ###
		users.users.jeff = {
			name = "jeff";
			home = "/Users/jeff";
		};


		### SCRIPTS ###

		# Index nix-installed packages in spotlight
		system.activationScripts.postUserActivation.text = ''
			apps_source="${config.system.build.applications}/Applications"
			moniker="Nix Trampolines"
			app_target_base="$HOME/Applications"
			app_target="$app_target_base/$moniker"
			mkdir -p "$app_target"
			${pkgs.rsync}/bin/rsync --archive --checksum --chmod=-w --copy-unsafe-links --delete "$apps_source/" "$app_target"
		'';


		nixpkgs.hostPlatform = "aarch64-darwin";

	};


	### HOME-MANAGER-MANAGED SETTINGS ###
	homeconfig = { pkgs, ... }: {
		home.stateVersion = "23.05";
		programs.home-manager.enable = true;

		### DOTFILES ###
		home.file.".zshrc".source = ./zsh_configuration;
		home.file.".vimrc".source = ./vim_configuration;
		home.file.".config/nvim/init.vim".source = ./vim_configuration;

		home.packages = with pkgs; [];

		home.sessionVariables = {
			EDITOR = "nvim";
		};
	};
	in

	{
		# Build darwin flake using: $ darwin-rebuild build --flake .#m4
		darwinConfigurations."m4" = nix-darwin.lib.darwinSystem {
			modules = [
				configuration
				nix-homebrew.darwinModules.nix-homebrew {
					nix-homebrew = {
						enable = true;
						enableRosetta = true;
						user = "jeff";
					};
				}
				home-manager.darwinModules.home-manager {
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
					home-manager.verbose = true;
					home-manager.users.jeff = homeconfig;
				}
			];
		};

		# Expose the package set, including overlays, for convenience.
		darwinPackages = self.darwinConfigurations."m4".pkgs;
	};
}
