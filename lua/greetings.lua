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


local function show()
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_get_current_buf()

	-- TODO; Improve this guard:
	if vim.fn.argc() > 0 or vim.api.nvim_buf_get_name(buf) ~= '' then
		vim.notify("greetings: skipped.", vim.log.levels.INFO, {})
		return
	end

	local height = vim.api.nvim_win_get_height(win)
	local width = vim.api.nvim_win_get_width(win)

	-- Set buffer options.
	-- TODO: Some user options will need to be restored!
	local options = {
		-- bufhidden = 'wipe',
		-- buflisted = false,
		list = false,
		swapfile = false,
		readonly = false,
		filetype = '',
		number = false,
		relativenumber = false,
		colorcolumn = '',
		cursorcolumn = false,
		spell = false,
	}

	for opt, val in pairs(options) do
		vim.opt_local[opt] = val
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

	local blank = string.rep(' ', width-1)

	for i = 1, top do
		table.insert(intro_message, 1, blank)
	end

	for i = #intro_message, height do
		table.insert(intro_message, #intro_message, blank)
	end



	vim.api.nvim_buf_set_lines(buf, 0, -1, false, intro_message)

	-- Colours
	local ns = vim.api.nvim_create_namespace('greetings_hl')
	vim.api.nvim_set_hl(0, 'Neo', { fg = 'dodgerblue', bold = true })
	vim.api.nvim_set_hl(0, 'Vim', { fg = 'limegreen', bold = true })
	vim.api.nvim_set_hl(0, 'Cyoa', { fg = 'grey50', italic = true })
	-- vim.api.nvim_win_set_hl_ns(win, ns)

	vim.api.nvim_buf_set_extmark(buf, ns, top, left,
		{ end_row = top, end_col = left + 25 , hl_group = 'Neo' })
	vim.api.nvim_buf_set_extmark(buf, ns, top, left + 26,
		{ end_row = top, end_col = left + 40 , hl_group = 'Vim' })
	vim.api.nvim_buf_set_extmark(buf, ns, top + 1, left,
		{ end_row = top + 2, end_col = 0 , hl_group = 'Cyoa' })

	local cmds = { ':help nvim', ':checkhealth', ':q', ':help' }
	for i = 1, 4 do
		line = top + i + 2
		vim.api.nvim_buf_set_extmark(buf, ns, line, left,
			{ end_row = line, end_col = #intro_message[top + 1], hl_group = 'Cyoa' })
		vim.api.nvim_buf_set_extmark(buf, ns, line, left + 28,
			{ end_row = line, end_col = left + 28 + #cmds[i], hl_group = 'Vim' })
	end

	vim.opt_local.readonly = true
	vim.opt_local.modified = false
	print("buf: ", buf)
end


show()
