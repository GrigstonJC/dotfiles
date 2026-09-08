{ ... }:
{
	# macOS can't unbind a menu shortcut, only reassign it — NSUserKeyEquivalents
	# matches a menu item by its exact (localized!) title and gives it a new key
	# equivalent, so "disabled" here means "reassigned to a combo nobody presses".
	# Glyphs: @ = cmd, ~ = opt, ^ = ctrl, $ = shift.
	#
	# Ghostty's cmd+t=new_split:auto (home/darwin/ghostty.nix) made splits the
	# everyday unit of work there, and Ghostty's own built-in cmd+w=close_surface
	# (not set by this repo — see `ghostty +list-keybinds`) turned cmd+W into a
	# reflex heavy enough to misfire in other apps: closing a Chrome tab or an
	# iTerm2 session by accident. Chrome keeps cmd+shift+T (reopen closed tab)
	# and cmd+shift+W (close window); iTerm2 keeps cmd+shift+W and cmd+opt+W.
	#
	# Titles are exact matches against each app's own shipped resources
	# (Chrome's en.lproj/locale.pak, iTerm2's MainMenu.nib) — a future rename by
	# either app silently breaks this with no error, so re-check there rather
	# than assuming if it stops working.
	system.defaults.CustomUserPreferences = {
		"com.google.Chrome".NSUserKeyEquivalents = {
			"Close Tab" = "@~^$w";
		};
		"com.googlecode.iterm2".NSUserKeyEquivalents = {
			"Close" = "@~^$w";
		};
	};
}
