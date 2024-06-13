return {
	'lewis6991/gitsigns.nvim',
	opts = {
		on_attach = function(bufnr)
			local gitsigns = require('gitsigns')
			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end
			local function nav(nkey, cmd)
				if vim.wo.diff then vim.cmd.normal({nkey, bang = true})
				else gitsigns.nav_hunk(cmd)
				end
			end
			map('n', '\\]', function() nav(']c', 'next') end)
			map('n', '\\[', function() nav('[c', 'prev') end)
			map('n', '\\a', gitsigns.stage_hunk)
			map('n', '\\s', function() gitsigns.stage_hunk() nav(']c', 'next') end)
			map('n', '<leader>hr', gitsigns.reset_hunk)
			map('v', '\\a', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
			map('v', '<leader>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
			map('n', '<leader>hS', gitsigns.stage_buffer)
			map('n', '\\c', gitsigns.undo_stage_hunk)
			map('n', '<leader>hR', gitsigns.reset_buffer)
			map('n', '<leader>hp', gitsigns.preview_hunk)
			map('n', '<leader>hb', function() gitsigns.blame_line{full=true} end)
			map('n', '<leader>htb', gitsigns.toggle_current_line_blame)
			map('n', '<leader>hd', gitsigns.diffthis)
			map('n', '<leader>hD', function() gitsigns.diffthis('~') end)
			map('n', '<leader>htd', gitsigns.toggle_deleted)
		end,
	},
}

