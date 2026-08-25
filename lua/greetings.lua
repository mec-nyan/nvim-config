--[[
--
--  Greetings
--
--  A simple initial screen.
--
--
--  What?
--
--      - A nice(r) logo.
--          - I have a nice design I'm planning on using here.
--          - Also, can we use an image?
--      - Hints.
--      - Maybe actions.
--
--
--]]


-- First try. Just put a string (with highlighting/colours) there.
vim.o.shortmess = vim.o.shortmess .. 'I'



local function show()
	local intro_message = {
		"                    N e o v i m                ",
		"______________________________________________ ",
		"                                               ",
		"If you're new to Nvim, type :help nvim<Enter>  ",
		"To optimise Nvim, type      :checkhealth<Enter>",
		"To quit, type               :q<Enter>          ",
		"For help, type              :help<Enter>       ",
		"                                               ",
	}

	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_get_current_buf()

	-- TODO; Improve this guard:
	if vim.fn.argc() > 0 or vim.api.nvim_buf_get_name(buf) ~= '' then
		vim.notify("greetings: skipped.", vim.log.levels.INFO, {})
		return
	end

	local height = vim.api.nvim_win_get_height(win)
	local width = vim.api.nvim_win_get_width(win)

	if vim.opt_local.filetype ~= 'greetings' then
		-- Set buffer options.
		-- TODO: Some user options will need to be restored!
		local options = {
			bufhidden = 'wipe',
			buflisted = false,
			list = false,
			swapfile = false,
			readonly = false,
			filetype = 'greetings',
			number = false,
			relativenumber = false,
			colorcolumn = '',
			cursorcolumn = false,
			spell = false,
		}

		for opt, val in pairs(options) do
			vim.opt_local[opt] = val
		end
	end

	local banner = {
		height = #intro_message,
		width = #intro_message[1],
	}

	local top = math.floor((height - banner.height) / 3)
	local left = math.floor((width - banner.width) / 2)

	local padding = string.rep(' ', left)
	for i, line in pairs(intro_message) do
		intro_message[i] = padding .. intro_message[i]
	end

	local blank = ''

	for i = 1, top do
		table.insert(intro_message, 1, blank)
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, intro_message)

	-- Colours
	local ns = vim.api.nvim_create_namespace('greetings_hl')

	vim.api.nvim_set_hl(ns, 'Neo', { fg = 'dodgerblue', bold = true })
	vim.api.nvim_set_hl(ns, 'Vim', { fg = 'limegreen', bold = true })
	vim.api.nvim_set_hl(ns, 'Cyoa', { fg = 'grey50', italic = true })

	vim.api.nvim_win_set_hl_ns(win, ns)

	-- NOTE: row and col are ZERO BASED.  Adjust accordingly ...
	-- (That's why `top` and `left` give us the right row and col).
	
	local set_extmark = vim.api.nvim_buf_set_extmark
	
	local row = top
	local col, end_col = intro_message[top+1]:find('N e o')

	set_extmark(buf, ns, row, col - 1,
		{ end_row = row, end_col = end_col, hl_group = 'Neo' })

	col, end_col = intro_message[top+1]:find('v i m')

	set_extmark(buf, ns, row, col - 1,
		{ end_row = row, end_col = end_col, hl_group = 'Vim' })

	row = row + 1

	set_extmark(buf, ns, row, left,
		{ end_row = row, end_col = #intro_message[row+1], hl_group = 'Cyoa' })

	row = row + 1

	for i = 1, 4 do
		row = row + 1
		set_extmark(buf, ns, row, left,
			{ end_row = row, end_col = #intro_message[row+1], hl_group = 'Cyoa' })

		col, end_col = intro_message[row+1]:find(':[%a%s]+')

		set_extmark(buf, ns, row, col - 1,
			{ end_row = row, end_col = end_col, hl_group = 'Vim' })

		col, end_col = intro_message[row+1]:find('<%a+>')

		set_extmark(buf, ns, row, col - 1,
			{ end_row = row, end_col = end_col, hl_group = 'Neo' })
	end

	vim.opt_local.readonly = true
	vim.opt_local.modified = false
	vim.opt_local.fillchars = 'eob: '
end


vim.api.nvim_create_autocmd({'VimEnter'}, {
	callback = function()
		show()
	end,
})

vim.api.nvim_create_autocmd('VimResized', {
	callback = function()
		if vim.bo.filetype == 'greetings' then
			show()
		end
	end,
})
