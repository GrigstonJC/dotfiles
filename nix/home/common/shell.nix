{ pkgs, ... }:
{
	### DOTFILES ###
	home.file.".p10k.zsh".source = ../../files/p10k.zsh;

	programs.dircolors = {
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

	programs.zsh = {
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

			desktop = "cd ~/Desktop/";
			dot = "cd ~/.config/dotfiles/nix/";
			proj = "cd ~/Projects/";

			# Python versions
			pip = "pip3";
			python = "python3";
			python311 = "${pkgs.python311}/bin/python3";
			python312 = "${pkgs.python312}/bin/python3";
			python313 = "${pkgs.python313}/bin/python3";

			# Nix rebuild. Hardcoded to personal-mac while it's the only host;
			# becomes a host-parameterized function once work-mac exists.
			nix-switch = "sudo darwin-rebuild switch --flake \"$HOME/.config/dotfiles/nix#personal-mac\" --override-input identity \"path:$HOME/.config/dotfiles-identity\"";

			# Nix update
			nix-update = "nix flake update";

			# Update Claude Code
			claude-update = "npm install -g @anthropic-ai/claude-code";
		};
	};
}
