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
				controlcenter.BatteryShowPercentage = true;
				dock.tilesize = 48;
				dock.show-recents = false;
				dock.persistent-apps = [
					"/Applications/Bear.app"
					"/Applications/Google Chrome.app"
					"/Applications/Slack.app"
					"/Applications/iTerm.app"
					"/Applications/GIMP.app"
					"/Applications/Neo4j Desktop.app"
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
                mkalias
                neovim
                python312    # This needs to be listed first to set the default Python version
                python312Packages.pip
                python312Packages.virtualenv
                python310
                python311
                ripgrep
                silver-searcher
                stow
                tmate
                tmux
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
				];
				casks = [
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
		#home.file.".vimrc".source = ./vim_configuration;
		#home.file.".config/nvim/init.vim".source = ./vim_configuration;
		home.file.".p10k.zsh".source = ./p10k_configuration;

		home.packages = with pkgs; [
			# Python tooling
			pyright

			# Shell script tooling
			shellcheck
			shfmt
			nodePackages.bash-language-server

            # Mason dependencies
            nodejs   # Required for many language servers
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
			neovim = {
				enable = true;
    			viAlias = true;
    			vimAlias = true;

    			plugins = with pkgs.vimPlugins; [
					# LSP Support
					nvim-lspconfig
					mason-nvim
					mason-lspconfig-nvim

					# Autocompletion
					nvim-cmp
					cmp-nvim-lsp
					cmp-buffer
					cmp-path
					cmp-cmdline
					cmp-vsnip
					vim-vsnip

					# Python-specific plugins
					vim-python-pep8-indent
					python-syntax
	
					# File navigation and search
					telescope-nvim
					plenary-nvim
					nvim-tree-lua

					# Status line
					lualine-nvim

					# Git integration
					vim-fugitive
					gitsigns-nvim

					# Theme
					tokyonight-nvim

					# Treesitter
      				(nvim-treesitter.withPlugins (plugins: with plugins; [
						tree-sitter-python
						tree-sitter-lua
						tree-sitter-vim
						tree-sitter-markdown
						tree-sitter-bash
						#tree-sitter-zsh
					]))

					# Folding
					nvim-ufo
					promise-async

					# Shell script support
					ale
				];
				extraConfig = ''
					set number
					set relativenumber
					set expandtab
					set tabstop=4
					set softtabstop=4
					set shiftwidth=4
                    set encoding=utf-8
                    set ignorecase
                    set smartcase
					set autoindent
                    set clipboard=unnamed

                    inoremap jk <ESC>
                    map yy ^y$

                    " Set leader key to space
                    let mapleader=" "
                    set timeoutlen=500

					" Enable Python syntax highlighting
					let g:python_highlight_all = 1

					" Set colorscheme
					colorscheme tokyonight

					" Folding settings
					set foldmethod=expr
					set foldexpr=nvim_treesitter#foldexpr()
					set nofoldenable
					set foldlevel=99
					set foldcolumn=1

					" Only fold outer classes by default in Python
					let g:python_fold_class = 1
					let g:python_fold_function = 0

					" Customize fold text
					set fillchars=fold:·

					" Shell script specific settings
					autocmd FileType sh,bash,zsh setlocal
						\ tabstop=2
						\ softtabstop=2
						\ shiftwidth=2
						\ expandtab
						\ autoindent

					" ALE configuration for shell scripts
					let g:ale_fixers = {
						\ 'sh': ['shfmt'],
						\ 'bash': ['shfmt'],
						\ 'zsh': ['shfmt'],
						\}
					let g:ale_linters = {
						\ 'sh': ['shellcheck'],
						\ 'bash': ['shellcheck'],
						\ 'zsh': ['shellcheck'],
						\}
					let g:ale_fix_on_save = 1
					let g:ale_sh_shellcheck_options = '--external-sources'
					let g:ale_sh_shfmt_options = '-i 2 -ci'
				'';

				extraLuaConfig = ''
					-- LSP Configuration
					require('mason').setup()
					require('mason-lspconfig').setup({
                        automatic_installation = false
					})

					local lspconfig = require('lspconfig')

					-- Python LSP setup
					lspconfig.pyright.setup{}

					-- Bash/ZSH LSP setup
					lspconfig.bashls.setup{
						filetypes = { "sh", "bash", "zsh" },
						settings = {
							bashIde = {
								globPattern = "*@(.sh|.inc|.bash|.command|.zsh)"
							}
						}
					}

					-- Autocompletion setup
					local cmp = require('cmp')
					cmp.setup({
						snippet = {
							expand = function(args)
							vim.fn["vsnip#anonymous"](args.body)
							end,
						},
						mapping = cmp.mapping.preset.insert({
							['<C-d>'] = cmp.mapping.scroll_docs(-4),
							['<C-f>'] = cmp.mapping.scroll_docs(4),
							['<C-Space>'] = cmp.mapping.complete(),
							['<CR>'] = cmp.mapping.confirm({ select = true }),
						}),
						sources = cmp.config.sources({
							{ name = 'nvim_lsp' },
							{ name = 'vsnip' },
							{ name = 'buffer' },
							{ name = 'path' },
						})
					})

					-- Telescope setup
					local telescope = require('telescope')
                    telescope.setup{
                        defaults = {
                            mappings = {
                                i = {
                                    ["<C-j>"] = "move_selection_next",
                                    ["<C-k>"] = "move_selection_previous",
                                    ["<C-n>"] = "move_selection_next",
                                    ["<C-p>"] = "move_selection_previous",
                                },
                            },
                        },
                    }

					-- File tree setup
					require('nvim-tree').setup{}

					-- TreeSitter configuration
					require('nvim-treesitter.configs').setup {
						highlight = { enable = true },
						indent = { enable = true },
						fold = { enable = true },
					}

                    -- UFO folding setup
                    require('ufo').setup({
                        provider_selector = function()
                            return {'treesitter', 'indent'}
                        end,
                        preview = {
                            win_config = {
                                border = {"", "─", "", "", "", "─", "", ""},
                                winblend = 0,
                                winhighlight = 'Normal:Folded',
                                maxheight = 20  -- Maximum preview window height
                            },
                            mappings = {
                                scrollB = '<C-b>',
                                scrollF = '<C-f>',
                                scrollU = '<C-u>',
                                scrollD = '<C-d>',
                                closePreview = 'K',
                            }
                        }
                    })

                    -- Peek keymap
                    vim.keymap.set('n', 'K', function()
                        local winid = require('ufo').peekFoldedLinesUnderCursor()
                            if not winid then
                                vim.lsp.buf.hover()
                            end
                        end)

					-- Keymaps
					local opts = { noremap = true, silent = true }
					vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
					vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
					vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
					vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

					-- LSP keymaps
					vim.api.nvim_create_autocmd('LspAttach', {
						group = vim.api.nvim_create_augroup('UserLspConfig', {}),
						callback = function(ev)
						local bufopts = { noremap=true, silent=true, buffer=ev.buf }
						vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
						vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
						vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
						vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
						vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
						vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
						vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
						end,
					})

					-- Custom file tree keymaps
					vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', opts)

					-- Telescope keymaps
					local builtin = require('telescope.builtin')
					vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
					vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
					vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
					vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
				'';
			};
            tmux = {
                enable = true;
                prefix = "C-b";
                extraConfig = ''
                    set-option -g prefix2 M-o
                    bind-key M-o send-prefix -2
                '';
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

                    # Use the right tmux config
                    export TMUX_CONFIG_DIR="$HOME/.config/tmux"

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

					#vim = "nvim";

					desktop = "cd ~/Desktop/";
					dot = "cd ~/.config/dotfiles/nix/";
					proj = "cd ~/Projects/";

					# Python versions
					pip = "pip3";
					python = "python3";
					python310 = "${pkgs.python310}/bin/python3";
					python311 = "${pkgs.python311}/bin/python3";
					python312 = "${pkgs.python312}/bin/python3";

					# Nix rebuild
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
