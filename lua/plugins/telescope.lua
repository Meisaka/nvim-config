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
				{ '<leader>:', '<cmd>Telescope command_history<cr>' },
				{ '<leader>ff', builtin.find_files, },
				{ '<leader>fb', builtin.buffers, },
				{ '<leader>fr', '<cmd>Telescope oldfiles<cr>', desc = 'Recent' },
				{ '<leader>gs', '<cmd>Telescope git_status<cr>', },
				{ '<leader>sg', builtin.live_grep, desc = 'Grep' },
			}
		end,
	},
}

