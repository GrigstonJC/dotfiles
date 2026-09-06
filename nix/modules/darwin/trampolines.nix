{ config, pkgs, ... }:
{
	### POST-ACTIVATION SCRIPT ###
	system.activationScripts.nixApplications = {
		text = ''
			# Index nix-installed packages in spotlight
			apps_source="${config.system.build.applications}/Applications"
			moniker="Nix Trampolines"
			app_target_base="/Users/${config.system.primaryUser}/Applications"
			app_target="$app_target_base/$moniker"
			sudo -u ${config.system.primaryUser} mkdir -p "$app_target"
			${pkgs.rsync}/bin/rsync --archive --checksum --chmod=-w --copy-unsafe-links --delete "$apps_source/" "$app_target"
			# Avoids a logout/login cycle when applying some settings
			/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
		'';
	};
}
