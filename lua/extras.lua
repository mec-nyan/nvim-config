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

	-- We can apply different options for a specific command line:
	--
	-- i.e. set a different height for 'search':
	vim.api.nvim_create_autocmd('CmdlineEnter', {
		pattern = { '/', '?' },
		command = 'set pumheight=8'
	})

	vim.api.nvim_create_autocmd('CmdlineEnter', {
		pattern = { ':' },
		command = 'set pumheight=0'
	})

	vim.api.nvim_create_autocmd('CmdlineLeave', {
		pattern = { '/', '?' },
		command = 'set pumheight&'
	})

end


-----------------------
-- Fuzzy file picker --
-----------------------

-- Helper function: map
local function map(tbl, fun)
	if tbl == nil or #tbl == 0 then return end

	local new_tbl = {}

	for k, v in pairs(tbl) do
		new_tbl[k] = fun(v)
	end

	return new_tbl
end

-- Helper function: filter
local function filter(tbl, fun)
	if tbl == nil or #tbl == 0 then return end

	local new_tbl = {}

	for k, v in pairs(tbl) do
		if fun(v) then
			new_tbl[k] = v
		end
	end

	return new_tbl
end

set_cmdline_autocompletion()

return {}
