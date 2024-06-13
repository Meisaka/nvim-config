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
				{ '<leader>/', builtin.live_grep },
				{ '<leader>:', builtin.command_history },
				{ '<leader>fs', builtin.lsp_document_symbols, },
				{ '<leader>gt', builtin.lsp_type_definitions, },
				{ '<leader>es', builtin.lsp_workspace_symbols, },
				{ '<leader>fr', builtin.lsp_references, },
				{ '<leader>ff', builtin.find_files, },
				{ '<leader>fb', builtin.buffers, },
				{ '<leader>fk', builtin.keymaps, },
				{ '<leader>fm', builtin.marks, },
				{ '<leader>fo', builtin.oldfiles, desc = 'Recent' },
				{ '<leader>gs', builtin.git_status, },
				{ '<leader>fgf', builtin.git_bcommits, },
				{ '<leader>fgb', builtin.git_branches, },
				{ '<leader>fgc', builtin.git_commits, },
				{ '<leader>sg', builtin.live_grep, desc = 'Grep' },
			}
		end,
	},
}

