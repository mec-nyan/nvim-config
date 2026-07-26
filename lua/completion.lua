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


vim.o.completeopt = 'menuone,preview,noselect'

local setkey = vim.keymap.set

setkey('i', '<Tab>', function()
	return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end, { expr = true })

setkey('i', '<S-Tab>', function()
	return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true })



return {}
