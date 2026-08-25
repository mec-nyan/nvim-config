--[[
--
--
--  Diff mode.
--
--
--]]

-- Show separate status lines for diff windows.
vim.api.nvim_create_autocmd('WinEnter', {
	callback = function()
		if vim.wo.diff then
			vim.opt.laststatus = 2
		else
			vim.opt.laststatus = 3
		end
	end,
})
