
local view_win, view_buf
local M = {}
local function open_view()
	if view_buf == nil then
		view_buf = vim.api.nvim_create_buf(false, true)
	end
	if view_win == nil then
		view_win = vim.api.nvim_open_win(view_buf, false, {
			row=3, col=3, width=50, height=20,
			relative='win', border='single', noautocmd=true
		})
		vim.api.nvim_create_autocmd('WinClosed', {callback = function() view_win = nil return true end})
	end
end
function M.view_lines(text)
	open_view()
	vim.api.nvim_buf_set_lines(view_buf, 0, -1, false, vim.split(text, '\n'))
end
function M.append_lines(text)
	open_view()
	vim.api.nvim_buf_set_lines(view_buf, -1, -1, false, vim.split(text, '\n'))
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
			vim.schedule(function() M.append_lines(tx) end)
		end})
end
return M

