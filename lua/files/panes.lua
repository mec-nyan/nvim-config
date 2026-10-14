
local M = {}


--- @class Geometry
--- @field top number The Y coordinate of the main rectangle.
--- @field left number The X coordinate of the main rectangle.
--- @field top_pane_height number The height of the top (main) pane.
--- @field top_pane_left_width number The width of the top left window.
--- @field top_pane_right_width number The width of the top right window.
--- @field prompt_width number The width of the prompt pane.


--- Make the top left pane of the file picker.
--- @param geometry Geometry
--- @return number top_left_buf The buffer ID.
--- @return number top_left_win The window ID.
function M.top_left_pane(geometry)
	local top_left_buf = vim.api.nvim_create_buf(false, true)
	local top_left_win = vim.api.nvim_open_win(top_left_buf, false, {
		relative = 'editor',
		row = geometry.top,
		col = geometry.left,
		width = geometry.top_pane_left_width - 2,  -- Account for borders.
		height = geometry.top_pane_height - 2,     -- Account for borders.
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


--- Make the top right pane of the file picker.
--- @param geometry Geometry
--- @return number top_right_buf The buffer ID.
--- @return number top_right_win The window ID.
function M.top_right_pane(geometry)
	local top_right_buf = vim.api.nvim_create_buf(false, true)
	local top_right_win = vim.api.nvim_open_win(top_right_buf, false, {
		relative = 'editor',
		row = geometry.top,
		col = geometry.left + geometry.top_pane_left_width,
		width = geometry.top_pane_right_width - 2,           -- Account for borders.
		height = geometry.top_pane_height - 2,               -- Account for borders.
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


--- Make the prompt pane of the file picker.
--- @param geometry Geometry
--- @return number prompt_buf The buffer ID.
--- @return number prompt_win The window ID.
function M.prompt_pane(geometry)
	local prompt_buf = vim.api.nvim_create_buf(false, true)
	local prompt = ' 🔎 '
	vim.api.nvim_buf_set_lines(prompt_buf, 0, -1, false, { prompt })

	local prompt_win = vim.api.nvim_open_win(prompt_buf, false, {
		relative = 'editor',
		row = geometry.top + geometry.top_pane_height,
		col = geometry.left,
		width = geometry.prompt_width - 2,              -- Account for borders.
		height = 1,                                     -- Account for borders (total height is 3).
		style = 'minimal',
		focusable = false,
	})

	vim.api.nvim_set_option_value('winhighlight', 'Normal:Normal,FloatBorder:String', {
		scope = 'local', win = prompt_win,
	})

	return prompt_buf, prompt_win
end


--- Make the insert pane of the file picker.
--- @param geometry Geometry
--- @return number insert_buf The buffer ID.
--- @return number insert_win The window ID.
function M.insert_pane(geometry, parent)
	local insert_buf = vim.api.nvim_create_buf(false, true)

	local insert_win = vim.api.nvim_open_win(insert_buf, true, {
		relative = 'win',
		win = parent,
		row = 0,
		col = 5,
		width = geometry.prompt_width - 7,  -- Subtract parent borders and prompt text.
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

	return insert_buf, insert_win
end

return M
