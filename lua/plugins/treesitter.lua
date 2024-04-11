return {
	'nvim-treesitter/nvim-treesitter',
	build = ':TSUpdate',
	event = { 'VeryLazy', },
	opts = {
		highlight = { enable = true },
		indent = { enable = true },
		ensure_installed = {
			'bash', 'cpp', 'diff', 'glsl', 'json', 'jsonc', 'lua', 'luadoc', 'luap',
			'python', 'rust', 'toml', 'typescript', 'vim', 'yaml',
		},
		textobjects = {
			move = {
				enable = true,
				goto_next_start = { [']f'] = '@function.outer', [']c'] = '@class.outer' },
				goto_next_end = { [']F'] = '@function.outer', [']C'] = '@class.outer' },
				goto_previous_start = { ['[f'] = '@function.outer', ['[c'] = '@class.outer' },
				goto_previous_end = { ['[F'] = '@function.outer', ['[C'] = '@class.outer' },
			}
		}
	},
	config = function(_, opts)
		require('nvim-treesitter.configs').setup(opts)
	end,
}

