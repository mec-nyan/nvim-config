--[[
--
-----------
-- Files --
-----------
--
-- -----------------------------
-- A simple, visual file picker.
-- -----------------------------
--
-- Select file(s) by:
--
--     🗹 (Fuzzy) Match/filter files by name.
--
--     ☐ (Fuzzy) Match/filter files by content (live 'grep').
--
--     🗹 Choosing an item on the files list (move up/down with <Tab>, <C-n>, <C-p>)
--
-- And:
--
--     🗹 Preview content (cat).
--
--     🗹 Syntax highlighting.
--
------------
-- Layout --
------------
--
--     - Two panes: files list, content preview.
--     - Bottom prompt window to type name/filter.
--
--
-- TODO: Handle window resizing.
--
--]]


local dimensions = require 'files.geometry'
local ui = require 'files.ui'

--- Open a file picker window with preview.
local function file_picker()
	local geometry = dimensions.get_geometry()
	ui:open(geometry)
end

local setkey = vim.keymap.set

setkey('n', '<leader>]', file_picker, {
	desc = '[files] open',
})
