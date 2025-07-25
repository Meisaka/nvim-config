local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " "
vim.g.timeout = false

require("lazy").setup({
	spec = {
		{ "nyoom-engineering/oxocarbon.nvim" },
		{ "savq/melange-nvim" },
		{ import = "plugins" }
	},
	change_detection = { notify = false },
})

