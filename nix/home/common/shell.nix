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

			# Nix rebuild. Targets $DOTFILES_HOST (set per host by
			# home/default.nix — see hosts/*.nix) rather than a hardcoded
			# name, so this same function is correct on every machine.
			# Warns if flake.lock is stale before switching — stale inputs
			# (Homebrew's live Cask API in particular) can break silently for
			# months without this. Doesn't update anything itself; run
			# nix-update, review, and commit that separately.
			nix-switch() {
				if [ -z "$DOTFILES_HOST" ]; then
					echo "DOTFILES_HOST is not set — this shell hasn't picked up a switch yet. Run the full darwin-rebuild switch command by hand once (see README.md), then nix-switch will work." >&2
					return 1
				fi

				local lock="$HOME/.config/dotfiles/nix/flake.lock"
				if [ -f "$lock" ]; then
					local age_days=$(( ($(date +%s) - $(stat --format=%Y "$lock")) / 86400 ))
					if [ "$age_days" -ge 30 ]; then
						echo "flake.lock is $age_days days old — consider running nix-update first" >&2
					fi
				fi
				sudo darwin-rebuild switch --flake "$HOME/.config/dotfiles/nix#$DOTFILES_HOST" \
					--override-input identity "path:$HOME/.config/dotfiles-identity"
			}
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
			# Make `ls` pretty. Unprefixed: nix's coreutils ships plain `ls`
			# (unlike Homebrew's g-prefix convention), and it's ahead of
			# /bin/ls on PATH via the home-manager profile.
			ls = "ls --color=tty";
			ll = "ls -la --group-directories-first --color=tty";

			desktop = "cd ~/Desktop/";
			dot = "cd ~/.config/dotfiles/nix/";
			proj = "cd ~/Projects/";

			# Python versions
			pip = "pip3";
			python = "python3";
			python311 = "${pkgs.python311}/bin/python3";
			python312 = "${pkgs.python312}/bin/python3";
			python313 = "${pkgs.python313}/bin/python3";

			# Nix update
			nix-update = "nix flake update";

			# Update Claude Code
			claude-update = "npm install -g @anthropic-ai/claude-code";
		};
	};
}
