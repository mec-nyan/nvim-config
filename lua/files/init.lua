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

local file_utils = require 'files.utils'
local panes = require 'files.panes'

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

	local top_left_buf, top_left_win = panes.top_left_pane()
	local top_right_buf, top_right_win = panes.top_right_pane()
	local _, prompt_win, insert_buf, insert_win = panes.prompt_pane()

	vim.cmd 'startinsert'

	------------------
	------------------
	-- key bindings --
	------------------
	------------------
	-- Quit.
	setkey({'i', 'n'}, '<esc>', function()
		vim.cmd 'stopinsert'
		vim.api.nvim_win_close(top_left_win, true)
		vim.api.nvim_win_close(top_right_win, true)
		vim.api.nvim_win_close(prompt_win, true)
		vim.api.nvim_win_close(insert_win, true)
	end, {
		buf = insert_buf,
	})

	-- Open.
	setkey({'i', 'n'}, '<cr>', function()
		vim.cmd 'stopinsert'

		local pos = vim.api.nvim_win_get_cursor(top_left_win)
		local line = vim.api.nvim_buf_get_lines(top_left_buf, pos[1] - 1, pos[1], false)

		vim.api.nvim_win_close(top_left_win, true)
		vim.api.nvim_win_close(top_right_win, true)
		vim.api.nvim_win_close(prompt_win, true)
		vim.api.nvim_win_close(insert_win, true)

		if #line ~= 1 then return end

		local filename = line[1]

		-- Edit in current window.
		-- TODO: Add key bindings to open in new tab or split.
		vim.cmd('edit ' .. filename)
	end, {
		buf = insert_buf,
	})

	--------------------
	--------------------
	-- update preview --
	--------------------
	--------------------
	-- Preview function.
	local function update_preview()
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

	-----------------------
	-----------------------
	-- more key bindings --
	-----------------------
	-----------------------
	-- Navigate files list.
	local function prev()
		local pos = vim.api.nvim_win_get_cursor(top_left_win)
		if pos[1] > 1 then
			pos[1] = pos[1] - 1
		end
		vim.api.nvim_win_set_cursor(top_left_win, pos)
		update_preview()
	end

	local function next()
		local pos = vim.api.nvim_win_get_cursor(top_left_win)
		local count = vim.api.nvim_buf_line_count(top_left_buf)
		-- Account for the last '\n'.
		if pos[1] < count - 1 then
			pos[1] = pos[1] + 1
		end
		vim.api.nvim_win_set_cursor(top_left_win, pos)
		update_preview()
	end

	local list_bindings = {
		{
			action = next,
			keys = { '<Tab>', '<C-n>' },
		},
		{
			action = prev,
			keys = { '<S-Tab>', '<C-p>' },
		},
	}

	for _, binding in pairs(list_bindings) do
		for _, key in pairs(binding.keys) do
			setkey({'i', 'n'}, key, binding.action, { buf = insert_buf })
		end
	end

	vim.api.nvim_create_autocmd('CursorMovedI', {
		buf = insert_buf,
		callback = function()
			-- Get prompt, if any.
			local text = vim.api.nvim_buf_get_lines(insert_buf, 0, -1, false)
			-- Get the list of files, filtering by "prompt".
			text = file_utils.process(text)
			-- Put the resulting list on the top left pane.
			vim.api.nvim_buf_set_lines(top_left_buf, 0, -1, false, text)
			-- Move the cursor back to the first line/item.
			vim.api.nvim_win_set_cursor(top_left_win, {1, 1})
			-- Update the preview window.
			update_preview()
		end,
	})
end

-- TODO: Change key binding when it's working properly.
setkey('n', '<leader>]', file_picker, {
	desc = '[files] open',
})
