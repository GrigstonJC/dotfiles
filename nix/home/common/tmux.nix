{ ... }:
{
	programs.tmux = {
		enable = true;
		prefix = "C-b";
		escapeTime = 0;
		extraConfig = ''
			set-option -g prefix2 M-o
			bind-key M-o send-prefix -2
		'';
	};
}
