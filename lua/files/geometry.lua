------------------------------------------------
-- Layout of the panes for the file explorer. --
------------------------------------------------


local M = {}


--- @class Geometry
--- @field top number The Y coordinate of the main rectangle.
--- @field left number The X coordinate of the main rectangle.
--- @field top_pane_height number The height of the top (main) pane.
--- @field top_pane_left_width number The width of the top left window.
--- @field top_pane_right_width number The width of the top right window.
--- @field prompt_width number The width of the prompt pane.


--- Calculate the dimensions and position of the panes according to the size of the editor.
--- @return Geometry
function M.get_geometry()
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
