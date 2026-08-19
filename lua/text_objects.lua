--[[
--
--  Text objects.
--
--]]


local setkey = vim.keymap.set


------------------
-- Go (example) --
------------------

vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'go' },
	callback = function()

		-- Select current function.
		setkey('v', 'af', '<esc>?func<cr>vf{%',
			{ desc = '[visual] select function (g0)', silent = true })

		-- Select current type block or function.
		setkey('v', 'af', '<esc>?func\\|type<cr>vf{%',
			{ desc = '[visual] select type or function block', silent = true })

		-- Select the body of the function/type (alias for `vi{`)
		setkey('v', 'if', 'i{',
			{ desc = '[visual] select within type or function block', silent = true })
		setkey('v', 'ib', 'i{', 
			{ desc = '[visual] select within type or function block', silent = true })
	end,
	desc = '[text obj] golang'
})
