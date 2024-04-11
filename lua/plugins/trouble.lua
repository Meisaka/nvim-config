local function trouble_go(t_action, v_action)
	local tr = require('trouble')
	if tr.is_open() then
		tr[t_action]({ skip_groups = true, jump = true })
	else
		local ok, err = pcall(vim.cmd[cprev])
		if not ok then vim.notify(err, vim.log.levels.ERROR) end
	end
end
return {
	'folke/trouble.nvim',
	cmd = { 'TroubleToggle', 'Trouble' },
	config = { icons = false, },
	keys = {
		{ '<leader>cp', function() trouble_go('previous', 'cprev') end },
		{ '<leader>cn', function() trouble_go('next', 'cnext') end },
	},
}

