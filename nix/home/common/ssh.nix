{ config, ... }:
{
	programs.ssh = {
		enable = true;
		enableDefaultConfig = false;
		settings."github.com" = {
			IdentityFile = config.my.githubSshKey;
			IdentitiesOnly = true;
			AddKeysToAgent = "yes";
			# UseKeychain is Apple-only; IgnoreUnknown keeps Linux OpenSSH
			# from rejecting the config.
			IgnoreUnknown = "UseKeychain";
			UseKeychain = true;
		};
	};
}
