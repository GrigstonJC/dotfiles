{ config, ... }:
{
	programs.ssh = {
		enable = true;
		enableDefaultConfig = false;
		matchBlocks."github.com" = {
			identityFile = config.my.githubSshKey;
			identitiesOnly = true;
			addKeysToAgent = "yes";
			# UseKeychain is Apple-only; IgnoreUnknown keeps Linux OpenSSH
			# from rejecting the config.
			extraOptions = {
				IgnoreUnknown = "UseKeychain";
				UseKeychain = "yes";
			};
		};
	};
}
