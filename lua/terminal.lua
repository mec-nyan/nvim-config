--[[
--
--  Setup Neovim's built-in terminal emulator.
--
--  TODO: A lot!
--
--]]


local function open_terminal()
	vim.cmd.new()
	vim.api.nvim_win_set_height(0, 15)

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

	vim.o.winhighlight = 'Normal:Pmenu'
	vim.cmd.startinsert()

end


local setkey = vim.keymap.set

setkey('n', '<leader>t', open_terminal, { desc = 'Open terminal' })
setkey('t', '<esc>', '<C-\\><C-n>', { desc = 'Alias: leave terminal-mode' })
setkey('t', '<M-q>', '<C-\\><C-n><cmd>close<cr>', { desc = 'Terminal: close' })


for k, v in pairs({h = 'left', j = 'down', k = 'up', l = 'right'}) do
	setkey('t', '<M-' .. k .. '>', '<C-\\><C-n><C-w>' .. k, { desc = '[t] Window ' .. v })
end

return {}
