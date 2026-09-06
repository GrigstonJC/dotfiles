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
		gnumake  # Required for building some packages

		# ZSH language server
		zk
	];
}
