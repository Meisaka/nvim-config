local function Telescope(...)
	local ar = ...
	return function() require('telescope.builtin')[ar]() end
end
return {
	{
		'nvim-telescope/telescope.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{
				'nvim-telescope/telescope-fzf-native.nvim',
				build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
			},
		},
		cmd = 'Telescope',
		version = false,
		init = function()
			require('telescope').load_extension('fzf')
		end,
		keys = function()
			local builtin = require('telescope.builtin')
			return {
				{ '<leader>/', builtin.live_grep, desc = 'Grep' },
				{ '<leader>:', builtin.command_history },
				{ '<leader>F', builtin.current_buffer_fuzzy_find, desc = 'Fuzzy Find' },
				{ '<leader>fs', builtin.lsp_document_symbols, desc = 'Telescope/Lsp: Document Symbols'},
				{ '<leader>gt', builtin.lsp_type_definitions, desc = 'Telescope/Lsp: Type Definitions'},
				{ '<leader>es', builtin.lsp_workspace_symbols, desc = 'Telescope/Lsp: Workspace Symbols'},
				{ '<leader>fi', builtin.lsp_implementations, desc = 'Telescope/Lsp: Implementations'},
				{ '<leader>fd', builtin.lsp_definitions, desc = 'Telescope/Lsp: Definitions'},
				{ '<leader>fr', builtin.lsp_references, desc = 'Telescope/Lsp: References' },
				{ '<leader>ff', builtin.find_files, desc = 'Telescope: Find Files' },
				{ '<leader>fb', builtin.buffers, desc = 'Telescope: Buffers' },
				{ '<leader>fq', builtin.quickfix, desc = 'Telescope: quickfix list' },
				{ '<leader>f=', builtin.vim_options, desc = 'Telescope: vim opts' },
				{ '<leader>fT', builtin.builtin, desc = 'Telescope: Telescope' },
				{ '<leader>fe', builtin.diagnostics, desc = 'List Diagnostics' },
				{ '<leader>fk', builtin.keymaps, desc = 'Telescope Keymaps' },
				{ '<leader>fm', builtin.marks, desc = 'Telescope Marks' },
				{ '<leader>fM', function() return builtin.man_pages({sections = {"ALL"}}) end, desc = 'Telescope Man pages' },
				{ '<leader>f"', builtin.registers, desc = 'Telescope Registers' },
				{ '<leader>fo', builtin.oldfiles, desc = 'Recent' },
				{ '<leader>fP', builtin.planets, desc = 'Planets' },
				{ '<leader>gs', builtin.git_status, desc = 'Git Status' },
				{ '<leader>fgf', builtin.git_bcommits, },
				{ '<leader>fgb', builtin.git_branches, desc = 'Git Branches' },
				{ '<leader>fgc', builtin.git_commits, desc = 'Git Commits' },
				{ '<leader>sg', builtin.live_grep, desc = 'Grep' },
			}
		end,
	},
}

