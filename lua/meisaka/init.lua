
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
vim.opt.ea = false
vim.opt.cot="menu,longest,menuone"
vim.opt.listchars="tab:» →,leadmultispace:† · ‡ · ,trail:▫,precedes:←,extends:◊"
vim.api.nvim_create_autocmd({"ChanInfo"}, {
	callback = function(ev)
		local info = vim.api.nvim_get_chan_info(1)
		vim.env.ui_info = vim.inspect(info)
		if info.client ~= nil and info.client.type == "ui" then
			--vim.cmd("set guifont=Envy\\ Code\\ R:h13")
			vim.opt.listchars="tab:┆ →,leadmultispace:† · ‡ · ,trail:◣,precedes:←,extends:※"
		end
		return true
	end
})
vim.opt.indentexpr='meisaka#indent()'
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
vim.opt.scrolloff = 7
vim.opt.sidescrolloff = 7
vim.opt.expandtab = false
vim.opt.wrap = false

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.keymap.set("n", "J", "mzJ`z")

vim.keymap.set("v", "<leader>j", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<leader>k", ":m '<-2<CR>gv=gv")

--vim.keymap.set("n", "<C-d>", "<C-d>zz")
--vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

local function cnav(act)
	local ok, err = pcall(vim.cmd[act])
	if not ok then vim.notify(err, vim.log.levels.ERROR) end
end
vim.keymap.set("n", "<leader>j", function() cnav("cnext") end)
vim.keymap.set("n", "<leader>k", function() cnav("cprev") end)
--vim.keymap.set("n", "<leader>j", "mzo<Esc>`z")
--vim.keymap.set("n", "<leader>k", "mzO<Esc>`z")
vim.keymap.set("n", "<leader>h", "<cmd>nohl<cr>")

vim.keymap.set("x", "<leader>p", "\"_dP")
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

-- delete without register
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")
-- source a lua script:
vim.keymap.set("n", "<leader><C-s>", "<Cmd>so<CR><C-l>")

