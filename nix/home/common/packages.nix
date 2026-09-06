{ pkgs, ... }:
{
	home.packages = with pkgs; [
		# Portable CLI tools — also needed on non-Darwin, standalone-home-manager hosts
		gnupg
		gnupg.info  # home.packages only installs meta.outputsToInstall
		            # ([out man]) by default — list additional outputs like
		            # this explicitly
		htop
		miller
		nodejs
		ripgrep
		silver-searcher
		tmux  # also provided by programs.tmux
		uv
		xclip

		# GNU-flavored commands — nix provides the same tool identically on
		# Linux, unlike Homebrew
		autoconf
		bash
		binutils
		coreutils
		diffutils
		ed
		findutils
		flex
		gawk
		gnugrep   # grep
		gnum4     # m4
		gnupatch  # gpatch
		gnused    # gnu-sed
		gnutar    # gnu-tar
		gzip
		indent    # gnu-indent
		less
		nano
		procps    # provides `watch`; `ps`/`top` come from macOS's native adv_cmds
		screen
		wdiff
		wget
		which     # gnu-which
		zip

		# Shell script tooling
		bash-language-server
		shellcheck
		shfmt

		# Python tooling
		pyright

		# Mason dependencies (LazyVim's LSP installer)
		git      # Also a general CLI tool
		gnumake  # Required for building some packages; also covers GNU make generally
		unzip    # Required for extracting packages

		# ZSH language server
		zk
	];
}
