return {
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		event = { 'VeryLazy', },
		opts = {
			highlight = { enable = true },
			indent = { enable = false },
			ensure_installed = {
				'bash', 'cpp', 'diff', 'glsl', 'json', 'jsonc', 'lua', 'luadoc', 'luap',
				'python', 'rust', 'toml', 'typescript', 'vim', 'yaml',
			},
			textobjects = {
				move = {
					enable = true,
					goto_next_start = { [']F'] = '@function.outer', [']c'] = '@class.outer' },
					goto_next_end = { [']f'] = '@function.inner', [']C'] = '@class.outer' },
					goto_previous_start = {
						['[f'] = '@function.inner', ['[F'] = '@function.outer', ['[c'] = '@class.outer'
					},
					goto_previous_end = { ['[C'] = '@class.outer' },
				}
			}
		},
		config = function(_, opts)
			require'nvim-treesitter'.define_modules {
				meisaka_indent = { module_path = 'meisaka.indent' }
			}
			require('nvim-treesitter.configs').setup(opts)
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter-context',
		opts = {
			max_lines = 3,
			trim_scope = 'outer',
			min_window_height = 8,
		},
		dependancies = { 'nvim-treesitter/nvim-treesitter' },
	},
	{
		'nvim-treesitter/nvim-treesitter-textobjects',
		dependancies = { 'nvim-treesitter/nvim-treesitter' },
	},
}

