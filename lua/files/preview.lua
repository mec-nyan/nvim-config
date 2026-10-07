local file_utils = require 'files.utils'

local M = {}

-- Preview function.
function M.update_preview(top_left_buf, top_left_win, top_right_buf, top_right_win)
	local pos = vim.api.nvim_win_get_cursor(top_left_win)
	local line = vim.api.nvim_buf_get_lines(top_left_buf, pos[1] - 1, pos[1], false)

	if #line ~= 1 then return end
	local filename = line[1]

	local preview = nil
	local out = { 'Oops!' }

	local is_exe, error = file_utils.is_executable(filename)

	if not is_exe then
		preview = vim.system({ 'cat', filename }, { text = true }):wait()
	else
		out = { string.format('"%s" is an executable file.', filename) }
	end

	if preview ~= nil and preview.stderr == '' then
		out = vim.split(preview.stdout, '\n')
	end
	
	vim.api.nvim_buf_set_lines(top_right_buf, 0, -1, false, out)

	-- Syntax highlighting for the preview.
	-- TODO: Set special cases where filetype cannot be deduced from file extension
	-- (i.e. "Makefile", etc).
	local extension = filename:match('%.(.*)') or 'text'

	vim.api.nvim_win_call(top_right_win, function()
		vim.cmd('set filetype=' .. extension)
	end)

	vim.api.nvim_win_set_config(top_right_win, {
		footer = ' ' .. extension .. ' ',
		footer_pos = 'right',
	})
end

return M
