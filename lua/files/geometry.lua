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
--- This will return the full size of each pane, including borders.  Is the responsibility of the
--- creator of the window to account for that if necessary.
--- @return Geometry
function M.get_geometry()
	local available_width = vim.o.columns
	local available_height = vim.o.lines

	-- We'll have three main windows/panes:
	-- +- files ------++- preview ----+
	-- | ./foo.cpp    ||#include "bar.|
	-- | ./bar.hpp    ||              |
	-- | ./Makefile   ||auto main() ->|
	-- |              ||{             |
	-- |              ||  std::println|
	-- |              ||  return 0;   |
	-- |              ||}             |
	-- +--------------++-------- c++ -+
	-- +------------------------------+
	-- | > fo_                        +
	-- +------------------------------+
	--
	--
	-- For now I'll use a fixed size.  We can accept options later on and even better adjust
	-- dynamically according to the size of the editor window.  We'll also need to handle a possible
	-- resizing event.
	--
	-- Small margin just in case we're working with a narrow window: four (4) columns.
	-- Use two thirds of the available vertical space and center vertically.
	-- The prompt window needs only one line.  Plus borders this equals three (3) lines.

	local display_width = available_width - 8
	local display_height = math.floor(available_height / 3) * 2
	local prompt_height = 3

	local top = math.floor((available_height - display_height) / 2)
	local left = 4

	local top_pane_height = display_height - prompt_height
	local top_pane_left_width = math.floor(display_width / 2)
	local top_pane_right_width = display_width - top_pane_left_width

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
