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
	"n e o v i m",
	"",
	"Type:                               ",
	":help nvim<Enter>   if you are new! ",
	":checkhealth<Enter> to optimise Nvim",
	":q<Enter>           to exit         ",
	":help<Enter>        for help        ",
}


local function show()
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_get_current_buf()

	local height = vim.api.nvim_win_get_height(win)
	local width = vim.api.nvim_win_get_width(win)

	local info_message = string.format("%dx%d", width, height)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { info_message })
end


-- show()

return {}
