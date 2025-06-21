local function trouble_do(name, opt)
	local tr = require('trouble')
	tr[name](opt)
end
local function trouble_go(t_action, v_action)
	local tr = require('trouble')
	if tr.is_open() then
		tr[t_action]({ skip_groups = true, jump = true })
	else
		local ok, err = pcall(vim.diagnostic.jump, {count = v_action, wrap=true, float=true})
		if not ok then vim.notify(err, vim.log.levels.ERROR) end
	end
end
return {
	'folke/trouble.nvim',
	cmd = { 'TroubleToggle', 'Trouble' },
	config = {
		win = {
			type = "floating"
		},
		icons = {
			indent = {
				fold_open = '│_',
				fold_closed = '│*',
			},
			folder_closed = '[*',
			folder_open = '[_',
			kinds = {
				File = 'F]',
			}
		},
	},
	keys = {
		{ '<leader>sE', function() trouble_do('toggle', {mode = 'diagnostics'}) end },
		{ '<leader>se', function() trouble_do('toggle', {mode = 'diagnostics'}) end },
		{ '[d', function() trouble_go('prev', -1) end },
		{ ']d', function() trouble_go('next', 1) end },
	},
}

