vim.keymap.set("i", "jk", "<ESC>")
vim.keymap.set("n", "yy", "^y$")
vim.g.mapleader = " "

-- Restore default vim 's' behavior
vim.keymap.set("n", "s", "s")

-- Flash jump on <Space>j
vim.keymap.set("n", "<leader>j", function()
	require("flash").jump()
end, { desc = "Flash Jump" })
