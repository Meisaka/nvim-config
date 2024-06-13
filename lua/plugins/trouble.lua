local function trouble_go(t_action, v_action)
	local tr = require('trouble')
	if tr.is_open() then
		tr[t_action]({ skip_groups = true, jump = true })
	else
		local ok, err = pcall(vim.diagnostic[v_action])
		if not ok then vim.notify(err, vim.log.levels.ERROR) end
	end
end
return {
	'folke/trouble.nvim',
	cmd = { 'TroubleToggle', 'Trouble' },
	config = { icons = false, },
	keys = {
		{ '[d', function() trouble_go('previous', 'goto_prev') end },
		{ ']d', function() trouble_go('next', 'goto_next') end },
	},
}

