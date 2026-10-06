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

local function is_git()
	local out = vim.system({ 'git', 'rev-parse', '--is-inside-work-tree' },
		{ text = true, cwd = vim.fn.getcwd(0, 0) }):wait()

	if out.stderr ~= '' then return false end

	return true
end

local function process(text)
	if #text ~= 1 then
		return { '🤪 ...' }
	end

	-- Regular search (not `git`).
	local ls_cmd = 'find . -type f -printf "%P\n"'

	if is_git() then
		ls_cmd = 'git ls-files --cached --others --exclude-standard'
	end

	if text[1] ~= '' then
		ls_cmd = ls_cmd .. ' | fzf --filter=' .. text[1]
	end

	local out = vim.system({ 'bash', '-c', ls_cmd },
		{ text = true, cwd = vim.fn.getcwd(0, 0) }):wait()

	if out.stderr ~= '' then
		return { '💩 ...' }
	end

	return vim.split(out.stdout, '\n')
end


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

	-- Let's try one big window first.
	local top_left_buf = vim.api.nvim_create_buf(false, true)
	local top_left_win = vim.api.nvim_open_win(top_left_buf, false, {
		relative = 'editor',
		row = top,
		col = left,
		width = top_pane_left_width,
		height = top_pane_height,
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

	local top_right_buf = vim.api.nvim_create_buf(false, true)
	local top_right_win = vim.api.nvim_open_win(top_right_buf, false, {
		relative = 'editor',
		row = top,
		col = left + top_pane_left_width + 2,
		width = top_pane_right_width,
		height = top_pane_height,
		style = 'minimal',
		title = ' Preview ',
		title_pos = 'center',
		focusable = false,
	})

	vim.api.nvim_set_option_value('winhighlight', 'Normal:Normal,FloatBorder:Keyword', {
		scope = 'local', win = top_right_win,
	})

	top = top + top_pane_height + 2

	local prompt_buf = vim.api.nvim_create_buf(false, true)
	local prompt = ' 🔎 '
	vim.api.nvim_buf_set_lines(prompt_buf, 0, -1, false, { prompt })

	local prompt_win = vim.api.nvim_open_win(prompt_buf, false, {
		relative = 'editor',
		row = top,
		col = left,
		width = display_width - 2,
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
		width = display_width - 7,
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

	vim.cmd 'startinsert'

	setkey({'i', 'n'}, '<esc>', function()
		vim.api.nvim_win_close(top_left_win, true)
		vim.api.nvim_win_close(top_right_win, true)
		vim.api.nvim_win_close(prompt_win, true)
		vim.api.nvim_win_close(insert_win, true)
		vim.cmd 'stopinsert'
	end, {
		buf = insert_buf,
	})

	vim.api.nvim_create_autocmd('CursorMovedI', {
		buf = insert_buf,
		callback = function(ev)
			local buf = ev.buf
			local text = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			text = process(text)
			vim.api.nvim_buf_set_lines(top_left_buf, 0, -1, false, text)
		end,
	})
end

-- TODO: Change key binding when it's working properly.
setkey('n', '<leader>]', file_picker, {
	desc = '[files] open',
})
