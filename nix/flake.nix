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

			nix.settings.experimental-features = "nix-command flakes";
			nixpkgs.config.allowUnfree = true;
			nixpkgs.hostPlatform = "aarch64-darwin";

			system.configurationRevision = self.rev or self.dirtyRev or null;
			system.stateVersion = 5;

			### SYSTEM SETTINGS ###
            system.primaryUser = "jeff";
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
				# nixApplications script below required to get trackpad settings to appy without a restart
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


            services = {
                aerospace = {
                    enable = true;
                    settings = pkgs.lib.importTOML ./aerospace-config.toml;
                };
                jankyborders = {
                    enable = true;
                };
            };


            ### NIX-MANAGED PACKAGES ###
            environment.systemPackages = with pkgs; [
                alacritty
                awscli2
                git
                gnupg
                google-cloud-sdk
                htop
                miller
                mkalias
                neovim
                nodejs
                opencode
                python313    # This needs to be listed first to set the default Python version
                python313Packages.pip
                python313Packages.virtualenv
                python311
                python312
                ripgrep
                silver-searcher
                stow
                tmate
                tmux
                uv
                xclip
            ];


            ### FONTS ###
            fonts.packages = [
                pkgs.nerd-fonts.jetbrains-mono
            ];


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


            ### USERS ###
            users.users.jeff = {
                name = "jeff";
                home = "/Users/jeff";
            };


			### POST-ACTIVATION SCRIPT ###
			system.activationScripts.nixApplications = {
                text = ''
                    # Index nix-installed packages in spotlight
                    apps_source="${config.system.build.applications}/Applications"
                    moniker="Nix Trampolines"
                    app_target_base="/Users/${config.system.primaryUser}/Applications"
                    app_target="$app_target_base/$moniker"
                    sudo -u ${config.system.primaryUser} mkdir -p "$app_target"
                    ${pkgs.rsync}/bin/rsync --archive --checksum --chmod=-w --copy-unsafe-links --delete "$apps_source/" "$app_target"
                    # Avoids a logout/login cycle when applying some settings
                    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
                '';
            };
	};
				
	homeconfig = { pkgs, ... }: {
		home.stateVersion = "23.05";
		programs.home-manager.enable = true;

		### DOTFILES ###
		home.file.".p10k.zsh".source = ./p10k_configuration;
        ### LAZYVIM CONFIG ###
		home.file.".config/lazyvim/init.lua".source = ./lazyvim/init.lua;
		home.file.".config/lazyvim/lua/config/keymaps.lua".source = ./lazyvim/lua/config/keymaps.lua;
		home.file.".config/lazyvim/lua/config/options.lua".source = ./lazyvim/lua/config/options.lua;
		home.file.".config/lazyvim/lua/plugins/custom.lua".source = ./lazyvim/lua/plugins/custom.lua;

		home.packages = with pkgs; [
			# Python tooling
			pyright

			# Shell script tooling
			shellcheck
			shfmt
			bash-language-server

            # Mason dependencies
            git      # Required for downloading packages
            unzip    # Required for extracting packages
            gnumake  # Required for building some packages

			# ZSH language server
			zk
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
            tmux = {
                enable = true;
                prefix = "C-b";
                escapeTime = 0;
                extraConfig = ''
                    set-option -g prefix2 M-o
                    bind-key M-o send-prefix -2
                '';
            };
			zsh = {
				enable = true;
				initContent = pkgs.lib.mkBefore ''
					# Use gnu versions of shell commands
					BREW_BIN="/usr/local/bin/brew"
					if [ -f "/opt/homebrew/bin/brew" ]; then BREW_BIN="/opt/homebrew/bin/brew" fi

					if type "''${BREW_BIN}" &> /dev/null; then export BREW_PREFIX="$("''${BREW_BIN}" --prefix)"
						for bindir in "''${BREW_PREFIX}/opt/"*"/libexec/gnubin"; do export PATH=$bindir:$PATH; done
						for bindir in "''${BREW_PREFIX}/opt/"*"/bin"; do export PATH=$bindir:$PATH; done
						for mandir in "''${BREW_PREFIX}/opt/"*"/libexec/gnuman"; do export MANPATH=$mandir:$MANPATH; done
						for mandir in "''${BREW_PREFIX}/opt/"*"/share/man/man1"; do export MANPATH=$mandir:$MANPATH; done
					fi

                    # Use the right tmux config
                    export TMUX_CONFIG_DIR="$HOME/.config/tmux"

                    # Poetry setup
                    export PATH="$HOME/.local/bin:$PATH"

                    # Install Poetry if not present
                    if ! command -v poetry &> /dev/null; then
                        echo "Installing Poetry..."
                        curl -sSL https://install.python-poetry.org | python3 -
                    fi

                    # Configure Poetry
                    if command -v poetry &> /dev/null; then
                        poetry config virtualenvs.create true
                        poetry config virtualenvs.in-project true
                    fi

                    # npm global prefix (for Claude Code, etc.)
                    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
                    export PATH="$HOME/.npm-global/bin:$PATH"

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
					# Make `ls` pretty
					ls = "gls --color=tty";
					ll = "gls -la --group-directories-first --color=tty";

					lvim = "NVIM_APPNAME=lazyvim nvim";

					desktop = "cd ~/Desktop/";
					dot = "cd ~/.config/dotfiles/nix/";
					proj = "cd ~/Projects/";

					# Python versions
					pip = "pip3";
					python = "python3";
					python311 = "${pkgs.python311}/bin/python3";
					python312 = "${pkgs.python312}/bin/python3";
                    python313 = "${pkgs.python313}/bin/python3";

					# Nix rebuild
					nix-switch = "sudo darwin-rebuild switch --flake ~/.config/dotfiles/nix#m4";

                    # Nix update
                    nix-update = "nix flake update";

                    # Update Claude Code
                    claude-update = "npm install -g @anthropic-ai/claude-code";
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
