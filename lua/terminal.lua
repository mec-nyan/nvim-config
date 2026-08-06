--[[
--
--  Setup Neovim's built-in terminal emulator.
--
--  TODO: A lot!
--
--]]

--- Open a new window with an existing instance of the terminal emulator.
--- Launch a new instance if none is found.
--- @param direction Where to open the new window (default: below).
local function open_terminal(direction)
	direction = direction or 'below'

	if direction == 'below' then
		vim.cmd.new()
		vim.api.nvim_win_set_height(0, 15)
	else
		vim.cmd.vnew()
	end



	local term_buf = nil

	for _, buf in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == 'terminal' then
			term_buf = buf
			break
		end
	end

	if term_buf then
		vim.api.nvim_win_set_buf(0, term_buf)
	else
		vim.cmd.terminal()
	end

	vim.wo.winhighlight = 'Normal:Pmenu'
	vim.opt_local.spell = false
	vim.cmd.startinsert()

end


-- Immediately enter insert mode in terminals.
vim.api.nvim_create_autocmd('WinEnter', {
	callback = function()
		if vim.bo.buftype == 'terminal' then
			vim.cmd.startinsert()
		end
	end
})

local function open_terminal_vert_right()
	open_terminal('right')
end


-------------------
-- Key mappings. --
-------------------

local setkey = vim.keymap.set

setkey('n', '<leader>tt', open_terminal, { desc = '[term] Open below', noremap = true })
setkey('n', '<leader>tr', open_terminal_vert_right, { desc = '[term] Open right', noremap = true })

setkey('t', '<esc>', '<C-\\><C-n>', { desc = '[term][alias] leave terminal-mode' })
setkey('t', '<M-q>', '<C-\\><C-n><cmd>close<cr>', { desc = '[term] Close' })


-----------------
-- Navigation. --
-----------------

for k, v in pairs({h = 'left', j = 'down', k = 'up', l = 'right'}) do
	setkey('t', '<M-' .. k .. '>', '<C-\\><C-n><C-w>' .. k, { desc = '[term] Window ' .. v })
end

return {}
