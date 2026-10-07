
local dimensions = require 'files.dimensions'
local dims = dimensions.get_dimensions()

local M = {}


function M.top_left_pane()
	local top_left_buf = vim.api.nvim_create_buf(false, true)
	local top_left_win = vim.api.nvim_open_win(top_left_buf, false, {
		relative = 'editor',
		row = dims.top,
		col = dims.left,
		width = dims.top_pane_left_width,
		height = dims.top_pane_height,
		style = 'minimal',
		title = ' Files ',
		title_pos = 'center',
		focusable = false,
	})

	vim.api.nvim_set_option_value('winhighlight', 'Normal:Normal,FloatBorder:Keyword', {
		scope = 'local', win = top_left_win,
	})

	-- Show cursor line so we can select with <Tab> (or <C-n> etc.).
	vim.api.nvim_set_option_value('cursorline', true, {
		scope = 'local', win = top_left_win,
	})

	return top_left_buf, top_left_win
end

function M.top_right_pane()
	local top_right_buf = vim.api.nvim_create_buf(false, true)
	local top_right_win = vim.api.nvim_open_win(top_right_buf, false, {
		relative = 'editor',
		row = dims.top,
		col = dims.left + dims.top_pane_left_width + 2,
		width = dims.top_pane_right_width,
		height = dims.top_pane_height,
		style = 'minimal',
		title = ' Preview ',
		title_pos = 'center',
		focusable = false,
	})

	vim.api.nvim_set_option_value('winhighlight', 'Normal:Normal,FloatBorder:Keyword', {
		scope = 'local', win = top_right_win,
	})

	-- Show line numbers on preview window.
	vim.api.nvim_set_option_value('number', true, {
		scope = 'local', win = top_right_win,
	})

	-- Don't wrap text on preview window.
	vim.api.nvim_set_option_value('wrap', false, {
		scope = 'local', win = top_right_win,
	})

	return top_right_buf, top_right_win
end

function M.prompt_pane()
	dims.top = dims.top + dims.top_pane_height + 2

	local prompt_buf = vim.api.nvim_create_buf(false, true)
	local prompt = ' 🔎 '
	vim.api.nvim_buf_set_lines(prompt_buf, 0, -1, false, { prompt })

	local prompt_win = vim.api.nvim_open_win(prompt_buf, false, {
		relative = 'editor',
		row = dims.top,
		col = dims.left,
		width = dims.prompt_width - 2,
		height = 1,
		style = 'minimal',
		focusable = false,
	})

	vim.api.nvim_set_option_value('winhighlight', 'Normal:Normal,FloatBorder:String', {
		scope = 'local', win = prompt_win,
	})

	local insert_buf = vim.api.nvim_create_buf(false, true)

	local insert_win = vim.api.nvim_open_win(insert_buf, true, {
		relative = 'win',
		win = prompt_win,
		row = 0,
		col = 5,
		width = dims.prompt_width - 7,
		height = 1,
		style = 'minimal',
		border = 'none',
		focusable = true,
	})

	vim.api.nvim_set_option_value('winhighlight', 'Normal:Normal', {
		scope = 'local', win = insert_win,
	})

	vim.api.nvim_set_option_value('autocomplete', false, {
		scope = 'local', buf = insert_buf,
	})

	return prompt_buf, prompt_win, insert_buf, insert_win
end

return M
