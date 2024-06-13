
local view_win, view_buf
local M = {
	pos_x = 20,
	pos_y = 5,
	width = 120,
	height = 7,
}
function M.open_view()
	if view_buf == nil then
		view_buf = vim.api.nvim_create_buf(false, true)
	end
	if view_win == nil then
		view_win = vim.api.nvim_open_win(view_buf, false, {
			row=M.pos_y, col=M.pos_x, width=M.width, height=M.height,
			relative='win', border='single', noautocmd=true
		})
		vim.api.nvim_create_autocmd('WinClosed', {callback = function() view_win = nil return true end})
	end
end

function M.view_lines(text)
	M.open_view()
	vim.api.nvim_buf_set_lines(view_buf, 0, -1, false, vim.split(text, '\n'))
end
function M.append_lines(text)
	M.open_view()
	vim.api.nvim_buf_set_lines(view_buf, -1, -1, false, vim.split(text, '\n'))
end

function M.sched_lines(text)
	vim.schedule(function() M.view_lines(text) end)
end
function M.test_completion()
	vim.bo.cfu = function(st, b)
		if st == 1 then
			return vim.fn.col('.')
		end
		return {
			'a', 'b', 'c', 'test'
		}
	end
	vim.api.nvim_create_autocmd('CompleteChanged', {
		callback = function(ev)
			local tx = vim.inspect(ev) ..'\n'.. vim.inspect(vim.v.event) ..'\n'.. vim.inspect(vim.fn.pum_getpos())
			M.sched_lines(tx)
		end})
end
return M

