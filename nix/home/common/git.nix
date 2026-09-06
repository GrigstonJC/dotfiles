# user.name/user.email come from the identity input (see nix/identity/)
# rather than being set here, so no name or email is ever committed.
{ config, identity, ... }:
{
	programs.git = {
		enable = true;
		# signing.format is deliberately left unset: its default depends on
		# each host's home.stateVersion (see hosts/*.nix), and hardcoding it
		# here would override that per-host migration pinning for every host.
		settings = {
			user.name = identity.gitName;
			user.email = identity.gitEmail;
			credential.helper = "store";
			core.excludesFile = "${config.home.homeDirectory}/.gitignore";
			init.defaultBranch = "main";
		};
	};
}
