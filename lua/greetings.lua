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
	"                 == N e o v i m ==             ",
	"                                               ",
	"                                               ",
	"If you're new to Nvim, type :help nvim<Enter>  ",
	"To optimise Nvim, type      :checkhealth<Enter>",
	"To quit, type               :q<Enter>          ",
	"For help, type              :help<Enter>       ",
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
		bufhidden = 'wipe',
		buflisted = false,
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

	for i = 1, top do
		table.insert(intro_message, 1, '')
	end


	vim.api.nvim_buf_set_lines(buf, 0, -1, false, intro_message)

	vim.opt_local.readonly = true
	vim.opt_local.modified = false
end


show()

return {}
