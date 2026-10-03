--[[
--
-- Files
--
-- A simple, visual file picker.
--
-- ----------------------------- --
-- Select file(s) by:
--
--     - (Fuzzy) Match/filter files by name.
--     - (Fuzzy) Match/filter files by content (live 'grep').
--     - Choosing an item on the files list (move up/down with <Tab>, <C-n>, <C-p>)
--
-- And:
--
--     - Preview content (cat).
--
-- Layout:
--
--     - Two panes: files list, content preview.
--     - Bottom prompt window to type name/filter.
--
--]]

local setkey = vim.keymap.set

-- NOTE: This is for testing only.  Delete this function and its bindings
-- once we're done.  (Or save it on `utils` or something like that.)

local function source_me()
	vim.cmd 'source %'
	print(string.format('File "%s" reloaded ✨', vim.fn.expand('%:t')))
end

setkey('n', '<leader>s', source_me, {
	desc = '[TEST] Source current file.',
})


-----------
-- Files --
-----------

local function file_picker()
	local available_width = vim.o.columns
	local available_height = vim.o.lines

	-- We'll have three main windows/panes:
	-- A list of files.
	-- A preview of the currently selected file (if any).
	-- A prompt window to enter our query/regex.
	
	-- Let's use these sizes for now.
	--
	-- 4 spaces margin plus border.
	display_width = available_width - (8 + 2)
	-- 2/3 accounting for border.
	display_height = math.floor(available_height / 3) * 2 - 2

	local top = math.floor((available_height - display_height) / 2)
	local left = 4

	-- Let's try one big window first.
	local buf = vim.api.nvim_create_buf(false, true)
	local big_win = vim.api.nvim_open_win(buf, true, {
		relative = 'editor',
		row = top,
		col = left,
		width = display_width,
		height = display_height,
		style = 'minimal',
		title = ' Files ',
		title_pos = 'center',
	})

	vim.wo.winhighlight = 'Normal:Normal,FloatBorder:Keyword'

end

-- TODO: Change key binding when it's working properly.
setkey('n', '<leader>]', file_picker, {
	desc = '[files] open',
})
