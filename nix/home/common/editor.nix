# LazyVim is the only Neovim configuration this repo manages — see
# CLAUDE.md. The nix package providing the `nvim` binary itself lives in
# modules/darwin/system-defaults.nix (Darwin-only for now).
{ ... }:
{
	home.file.".config/lazyvim/init.lua".source = ../../files/lazyvim/init.lua;
	home.file.".config/lazyvim/lua/config/keymaps.lua".source = ../../files/lazyvim/lua/config/keymaps.lua;
	home.file.".config/lazyvim/lua/config/options.lua".source = ../../files/lazyvim/lua/config/options.lua;
	home.file.".config/lazyvim/lua/plugins/custom.lua".source = ../../files/lazyvim/lua/plugins/custom.lua;

	programs.zsh.shellAliases.lvim = "NVIM_APPNAME=lazyvim nvim";
}
