--[[
--
-- Extras:
--
--     Fuzzy file picker.
--     Command line autocompletion.
--     Live grep.
--
--
--  I'll put these here and then move them to their own files if needed.
--
--]]


-- See `:h cmdline-autocompletion` for details.
local function set_cmdline_autocompletion()
	vim.api.nvim_create_autocmd('CmdlineChanged', {
		pattern = { ':', '/', '?' },
		callback = function()
			vim.fn.wildtrigger()
		end,
	})

	vim.o.wildmode = 'noselect:lastused,full'
	vim.o.wildoptions = 'pum'
end


set_cmdline_autocompletion()

return {}
