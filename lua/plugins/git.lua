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
			map('n', '\\]', function() nav(']c', 'next') end, {desc="Git nav next hunk"})
			map('n', '\\[', function() nav('[c', 'prev') end, {desc="Git nav previous hunk"})
			map('n', ']\\', function() nav(']c', 'next') end, {desc="Git nav next hunk"})
			map('n', '[\\', function() nav('[c', 'prev') end, {desc="Git nav previous hunk"})
			map('n', '\\a', gitsigns.stage_hunk, {desc="Git stage hunk"})
			map('n', '\\s', function() gitsigns.stage_hunk() nav(']c', 'next') end, {desc="Git stage hunk, nav next"})
			map('n', '<leader>hr', gitsigns.reset_hunk, {desc="Git reset hunk"})
			map('v', '\\a', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc="Git stage hunk (selected)"})
			map('v', '<leader>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc="Git reset hunk (selected)"})
			map('n', '<leader>hS', gitsigns.stage_buffer, {desc="Git stage buffer"})
			map('n', '\\c', gitsigns.undo_stage_hunk, {desc="Git undo stage hunk"})
			map('n', '<leader>hR', gitsigns.reset_buffer, {desc="Git reset buffer"})
			map('n', '<leader>hp', gitsigns.preview_hunk, {desc="Git preview hunk"})
			map('n', '<leader>hb', function() gitsigns.blame_line{full=true} end, {desc="Git show full blame for line"})
			map('n', '<leader>htb', gitsigns.toggle_current_line_blame, {desc="Git toggle line blame"})
			map('n', '<leader>hd', gitsigns.diffthis, {desc="Git diff this"})
			map('n', '<leader>hD', function() gitsigns.diffthis('~') end, {desc="Git diff this"})
			map('n', '<leader>htd', gitsigns.toggle_deleted, {desc="Git toggle view deleted"})
		end,
	},
}

