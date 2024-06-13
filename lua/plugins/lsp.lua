return {
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		main = 'mason',
		build = ':MasonUpdate',
		config = function(_, opts)
			require("mason").setup(opts)
		end,
	},
	{ "williamboman/mason-lspconfig.nvim",
		ensure_installed = { "clangd" },
	},
	{ 'hrsh7th/cmp-nvim-lsp' },
	{ 'hrsh7th/cmp-buffer' },
	{ 'hrsh7th/nvim-cmp',
		opts = {
			sources = {
				{ name = 'nvim_lsp' },
			},
		},
		config = function(_, opts)
			local cmp = require('cmp')
			cmp.setup({
				mapping = cmp.mapping.preset.insert({
					['<C-l>'] = cmp.mapping.confirm(),
					['<C-e>'] = cmp.mapping.abort(),
					['<C-u>'] = cmp.mapping.scroll_docs(-7),
					['<C-d>'] = cmp.mapping.scroll_docs(7),
					['<Tab>'] = cmp.mapping.confirm({ select = true }),
				}),
				sources = opts.sources,
			})
		end,
	},
	{ "neovim/nvim-lspconfig",
		dependencies = {
			"mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		opts = function()
			local cmp = require('cmp_nvim_lsp').default_capabilities()
			diag = { enable = false }
			return {
				inlay_hints = { enabled = true },
				servers = {
					clangd = {
						settings = {},
					},
					['rust_analyzer'] = {
						--settings = { inlayHints = { typeHints = { enable = true } } },
						cmd = {
							'C:\\Users\\Meisaka\\.rustup\\toolchains\\stable-x86_64-pc-windows-msvc\\bin\\rust-analyzer.exe'
						},
					},
					['tsserver'] = {},
				},
				setup = {
					clangd = { capabilities = cmp },
					['rust_analyzer'] = { capabilities = cmp },
					['tsserver'] = { capabilities = cmp },
				},
			}
		end,
		config = function(_, opt)
			require("mason").setup()
			require("mason-lspconfig").setup()
			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('UserLspConfig', {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					local opts = { buffer = ev.buf }
					vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
					vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
					vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
					vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
					vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
					vim.keymap.set('i', '<C-n>', '<C-x><C-o>', opts)
					vim.keymap.set('i', '<C-f>', vim.lsp.buf.signature_help, opts)
					vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
					vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
					vim.keymap.set('n', '<leader>wl', function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
						end, opts)
					vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
					vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
					vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
					vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
					--vim.keymap.set('n', '<leader>f', function()
						--vim.lsp.buf.format { async = true }
						--end, opts)
					vim.keymap.set('n', '<leader>uh', function()
						vim.lsp.inlay_hint.enable(opts.buffer, not vim.lsp.inlay_hint.is_enabled(opts.buffer))
						end, opts)
					vim.lsp.inlay_hint.enable(opts.buffer, true)
				end,
			})
			for k,v in pairs(opt.servers) do
				require("lspconfig")[k].setup(v)
			end
		end,
		setup = function() end,
	},
}

