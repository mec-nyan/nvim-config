--[[
--
--  Diagnostics
--
--]]

local setkey = vim.keymap.set
local jump = vim.diagnostic.jump


------------------
-- Key mappings --
------------------

setkey('n', ']d', function() jump({ count = 1, float = true }) end, { desc = '[diagnostics] next' })
setkey('n', '[d', function() jump({ count = -1, float = true }) end, { desc = '[diagnostics] previous' })


-------------
-- Colours --
-------------

local highlight = vim.cmd.highlight

highlight({ 'DiagnosticError', 'guifg=hotpink' })


------------
-- Config --
------------

local severity = vim.diagnostic.severity

local error, warning, info, hint = severity.ERROR, severity.WARN, severity.INFO, severity.HINT

vim.diagnostic.config {
	text = {
		[error] = '🐛',
		[warning] = ' ',
		[info] = '📜',
		[hint] = '💡',
	},
}


return {}
