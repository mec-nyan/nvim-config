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


-- Use a script variable to hold results.
local files_cache = {}

local function _find(arg, _)
	if #files_cache == 0 then
		-- TODO: Can we rewrite this directly in Lua?
		files_cache = vim.fn.map(
			vim.fn.filter(
				vim.fn.globpath('.', '**', 1, 1),
				'!isdirectory(v:val)'
			), "fnamemodify(v:val, ':.')"
		)

		-- How to use my helpers
		-- files_cache = map(files_cache, function(item) return "- " .. item end)
	end

	if arg == '' then return files_cache end

	return vim.fn.matchfuzzy(files_cache, arg)
end

-- Set our `findfunc`
vim.o.findfunc = "v:lua.require'extras'.find"

-- Clear the cache
vim.api.nvim_create_autocmd('CmdlineEnter', {
	pattern = ':',
	callback = function()
		files_cache = {}
	end
})

set_cmdline_autocompletion()

return {
	find = _find
}
