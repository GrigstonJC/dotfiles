{ pkgs, ... }:
{
	home.packages = with pkgs; [
		# Portable CLI tools (promoted from environment.systemPackages so they
		# also work on non-Darwin, standalone-home-manager hosts)
		ripgrep
		uv
		htop
		miller
		tmux             # also provided by programs.tmux; kept for parity with
		                 # the pre-refactor systemPackages list
		gnupg
		gnupg.info  # home.packages only installs meta.outputsToInstall ([out
		            # man]) by default, unlike environment.systemPackages —
		            # add the info pages back explicitly for parity
		silver-searcher
		xclip
		nodejs

		# GNU-flavored commands (migrated from Homebrew — nix provides the same
		# tool identically on Linux, so there's no reason to keep these on a
		# macOS-only package manager). gnumake is listed once, below, doing
		# double duty as both this and a Mason dependency.
		autoconf
		bash
		binutils
		coreutils
		diffutils
		ed
		findutils
		flex
		gawk
		indent    # gnu-indent
		gnused    # gnu-sed
		gnutar    # gnu-tar
		which     # gnu-which
		gnupatch  # gpatch
		gnugrep   # grep
		gzip
		less
		gnum4     # m4
		nano
		screen
		procps    # provides `watch`; `ps`/`top` come from macOS's native adv_cmds
		wdiff
		wget
		zip

		# Shell script tooling
		shellcheck
		shfmt
		bash-language-server

		# Python tooling
		pyright

		# Mason dependencies (LazyVim's LSP installer) — git also covers the
		# general-purpose CLI tool promoted from systemPackages
		git
		unzip    # Required for extracting packages
		gnumake  # Required for building some packages; also the GNU-flavored
		         # `make` migrated from Homebrew

		# ZSH language server
		zk
	];
}
