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
			nixpkgs.hostPlatform = "aarch64-darwin";

			system.configurationRevision = self.rev or self.dirtyRev or null;
			system.stateVersion = 5;

			security.pam.enableSudoTouchIdAuth = true;


			### SYSTEM SETTINGS ###
			system.defaults = {
				dock.autohide = true;
				dock.show-recents = false;
				dock.persistent-apps = [
					"/Applications/Bear.app"
					"/Applications/Google Chrome.app"
					"/Applications/Nix Apps/Alacritty.app"
					"/Applications/GIMP.app"
					"/System/Applications/TV.app"
					"/System/Applications/Podcasts.app"
				];
				dock.persistent-others = [
					"/Applications"
				];
				dock.wvous-bl-corner = 4;
				dock.wvous-tl-corner = 2;
				dock.wvous-br-corner = 1;
				dock.wvous-tr-corner = 4;
				# postuseractivation script below required to get trackpad settings to appy without a restart
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
					"autoconf"
					"awscli"
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
					"htop"
					"less"
					"m4"
					"make"
					"mas"
					"nano"
					"pyenv"
					"ripgrep"
					"screen"
					"the_silver_searcher"
					"watch"
					"wdiff"
					"wget"
					"zip"
				];
				casks = [
					#"alacritty"
					"devtoys"
					"discord"
					"docker"
					"dropbox"
					"expressvpn"
					"gimp"
					"google-chrome"
					"google-cloud-sdk"
					"firefox"
					"iterm2"
					"libreoffice"
					"neo4j"
					"numi"
					"slack"
					"spotify"
					"steam"
				];
				masApps = {
					"Bear" = 1091189122;
					#"Tot"
				};
			};


			### USERS ###
			users.users.jeff = {
				name = "jeff";
				home = "/Users/jeff";
			};


			### POST-ACTIVATION SCRIPT ###
			system.activationScripts.postUserActivation.text = ''
				# Index nix-installed packages in spotlight
				apps_source="${config.system.build.applications}/Applications"
				moniker="Nix Trampolines"
				app_target_base="$HOME/Applications"
				app_target="$app_target_base/$moniker"
				mkdir -p "$app_target"
				${pkgs.rsync}/bin/rsync --archive --checksum --chmod=-w --copy-unsafe-links --delete "$apps_source/" "$app_target"
				# Avoids a logout/login cycle when applying some settings
				/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
			'';
	};
				
	homeconfig = { pkgs, ... }: {
		home.stateVersion = "23.05";
		programs.home-manager.enable = true;

		### DOTFILES ###
		home.file.".vimrc".source = ./vim_configuration;
		home.file.".config/nvim/init.vim".source = ./vim_configuration;
		home.file.".p10k.zsh".source = ./p10k_configuration;

		home.packages = with pkgs; [
			oh-my-zsh
		];

		programs = {
			dircolors = {
				enable = true;
				enableZshIntegration = true;
				settings = {
					DIR = "1;34";
					LINK = "31";
					FIFO = "5";
					SOCK = "5";
					BLK = "5";
					CHR = "5";
					ORPHAN = "31";
					EXEC = "32";
				};
			};
			zsh = {
				enable = true;
				initExtra = ''
					# Use gnu versions of shell commands
					BREW_BIN="/usr/local/bin/brew"
					if [ -f "/opt/homebrew/bin/brew" ]; then BREW_BIN="/opt/homebrew/bin/brew" fi

					if type "''${BREW_BIN}" &> /dev/null; then export BREW_PREFIX="$("''${BREW_BIN}" --prefix)"
						for bindir in "''${BREW_PREFIX}/opt/"*"/libexec/gnubin"; do export PATH=$bindir:$PATH; done
						for bindir in "''${BREW_PREFIX}/opt/"*"/bin"; do export PATH=$bindir:$PATH; done
						for mandir in "''${BREW_PREFIX}/opt/"*"/libexec/gnuman"; do export MANPATH=$mandir:$MANPATH; done
						for mandir in "''${BREW_PREFIX}/opt/"*"/share/man/man1"; do export MANPATH=$mandir:$MANPATH; done
					fi

					# Use powerlevel10k theme
					source ~/.p10k.zsh
				'';
				plugins = [
					{
						name = "powerlevel10k";
						src = pkgs.zsh-powerlevel10k;
						file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
					}
				];
				oh-my-zsh = {
					enable = true;
					plugins = [
						"git"
						"ssh-agent"
					];
				};
				shellAliases = {
					ll = "ls -la";
					vim = "nvim";
					desktop = "cd ~/Desktop/";
					dot = "cd ~/.config/dotfiles/nix/";
					proj = "cd ~/Projects/";
					switch = "darwin-rebuild switch --flake ~/.config/dotfiles/nix#m4";
				};
			};
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
