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
	command = 'wincmd L | vert res 80',

})
