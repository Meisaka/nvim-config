
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd("colorscheme melange")


local mel = require('melange/palettes/dark')
for name, attrs in pairs {
	Normal = { fg = mel.a.fg, bg = "#1e1b1a" },
	Whitespace = { fg = "#4e433e", italic = false, nocombine = true },
	--LspInlayHint = { fg = "#4e433e", italic = false, nocombine = true },
	LspInlayHint = { fg = "#70787e", italic = true, nocombine = false },
	['@lsp.type.namespace'] = { fg = "#78b98A" },
	['@lsp.type.class'] = { fg = '#73b9be' },
} do
	vim.api.nvim_set_hl(0, name, attrs)
end
 --
	--view	ee	h i    
        --
--vim.cmd("set list")
vim.opt.cin = false
vim.opt.list = true
vim.cmd("set noea")
vim.cmd("set cot=menu,longest,menuone")
vim.cmd("set listchars=tab:»\\ →,leadmultispace:†\\ ·\\ ‡\\ ·\\ ,trail:▫,precedes:←,extends:◊")
vim.api.nvim_create_autocmd({"ChanInfo"}, {
	callback = function(ev)
		local info = vim.api.nvim_get_chan_info(1)
		vim.env.ui_info = vim.inspect(info)
		if info.client ~= nil and info.client.type == "ui" then
			--vim.cmd("set guifont=Envy\\ Code\\ R:h13")
			vim.cmd("set listchars=tab:┆\\ →,leadmultispace:†\\ ·\\ ‡\\ ·\\ ,trail:◣,precedes:←,extends:※")
		end
		return true
	end
})
--vim.api.nvim_create_autocmd('BufWinEnter', { callback = function(ev)
--	vim.print(vim.inspect(vim.bo.filetype))
--end })
vim.keymap.set('n', '<leader>ef', vim.cmd.Ex)
vim.keymap.set('n', '<F5>', ':checktime<CR>')

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.wrap = false

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.keymap.set("n", "J", "mzJ`z")

--vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
--vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

--vim.keymap.set("n", "<C-d>", "<C-d>zz")
--vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>j", "mzo<Esc>`z")
vim.keymap.set("n", "<leader>k", "mzO<Esc>`z")
vim.keymap.set("n", "<leader>h", "<cmd>nohl<cr>")

vim.keymap.set("x", "<leader>p", "\"_dP")
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")
vim.keymap.set("n", "<leader><C-s>", "<Cmd>so<CR><C-l>")

