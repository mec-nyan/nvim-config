--[[
--
--  Place your colour configuration here.
--
--]]

-- I like this colorscheme with a translucent background.
vim.cmd[[colorscheme catppuccin]]

vim.cmd.highlight{'Normal', 'guibg=None'}

-- Use a darker background for other windows i.e. quickfix, preview, etc.

-- Preview is a special window:
vim.api.nvim_create_autocmd('WinEnter', {
	callback = function()
		if vim.wo.previewwindow then
			vim.wo.winhighlight = 'Normal:Pmenu'
		end
	end
})

-- Both loclist and qflist have the same filetype `qf`.
vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'qf' },
	callback = function()
		vim.wo.winhighlight = 'Normal:Pmenu'
	end
})
