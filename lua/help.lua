--[[
--
--
--  Help options.
--
--
--]]


-- Open help windows in a vertical split.
vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'help' },
	callback = function()
		-- Don't change it if this is the only window.
		local windows = vim.api.nvim_list_wins()
		if #windows == 1 then
			return
		end

		local width = vim.o.columns
		local height = vim.o.lines

		-- If the window is wide, move it to the right and set its width to 80 columns.
		if width >= 160 then
			vim.cmd 'wincmd L | vert res 80'
		-- Otherwise, if we have enough vertical space, set its height to a third of it.
		elseif height >= 45 then
			help_win_h = math.floor(height / 3)
			vim.cmd('res ' .. help_win_h)
		end
	end,
})
