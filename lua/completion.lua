--[[
--
--  Completion related configuration:
--      - Complete options
--      - LSP
--      - Mappings
--
--
--  TODO: For some configurations (like this one) maybe return a function
--  accepting arguments to let other possible users customise these settings.
--
--]]

require 'lsp'.setup()

vim.o.completeopt = 'fuzzy,menuone,preview,noselect'
vim.o.pumborder = 'rounded'
vim.o.winborder = 'rounded'
vim.cmd[[highlight link FloatBorder Function]]
vim.cmd[[highlight link PmenuBorder String]]

local setkey = vim.keymap.set

setkey('i', '<Tab>', function()
	return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end, { expr = true })

setkey('i', '<S-Tab>', function()
	return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true })

vim.api.nvim_create_autocmd('InsertCharPre', {
	callback = function()
		vim.lsp.completion.get()
	end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
	callback = function()
		vim.cmd.pclose()
	end,
})

return {}
