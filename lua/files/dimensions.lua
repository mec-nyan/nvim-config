-----------------------------
-- Get and set dimensions. --
-----------------------------

local M = {}

--- Set the size and position of the panes.  Since the UI can change later on,
--- consider this provisional.
--- @return table containing the panes' dimensions and position (top-left corner).
function M.get_dimensions()
	local available_width = vim.o.columns
	local available_height = vim.o.lines

	-- We'll have three main windows/panes:
	-- A list of files.
	-- A preview of the currently selected file (if any).
	-- A prompt window to enter our query/regex.

	-- Let's use these sizes for now.
	--
	-- 4 spaces margin plus border.
	display_width = available_width - 8
	-- 2/3 accounting for border.
	display_height = math.floor(available_height / 3) * 2

	local top = math.floor((available_height - display_height) / 2)
	local left = 4

	local top_pane_height = display_height - 3
	local top_pane_left_width = math.floor(display_width / 2)
	local top_pane_right_width = display_width - top_pane_left_width

	-- account for borders.
	top_pane_left_width = top_pane_left_width - 2
	top_pane_right_width = top_pane_right_width - 2

	return {
		top = top,
		left = left,
		top_pane_height = top_pane_height,
		top_pane_left_width = top_pane_left_width,
		top_pane_right_width = top_pane_right_width,
		prompt_width = display_width,
	}
end

return M
