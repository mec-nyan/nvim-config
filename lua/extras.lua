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

local function set_up_fuzzy_picker()

	-- Set our `findfunc`
	vim.o.findfunc = "v:lua.require'extras'.find"

	-- Clear the cache
	vim.api.nvim_create_autocmd('CmdlineEnter', {
		pattern = ':',
		callback = function()
			files_cache = {}
		end
	})

	-- Add mappings
	vim.keymap.set('n', '<leader>f', ':find ', { silent = true, desc = '[files] fuzzy file picker' })
end


---------------
-- Live grep --
---------------

--[[ WIP ]]--

local selected = 0

local function visit_file()
end

local function grep(arglead, cmdline, cursorpos)

	local pattern = arglead or ""
	if pattern == "" then
		return {}
	end

	local cmd = { "rg", "--vimgrep", "--no-heading", "--color", "never", pattern }

	return vim.fn.systemlist(cmd)
end

local function set_up_live_grep()
	vim.api.nvim_create_autocmd('CmdlineLeavePre', {
		callback = function()
			local complete_info = vim.fn.cmdcomplete_info()
			if complete_info['matches'] ~= nil then
				print("Found it!")
			else
				print("Nothing to see here...")
			end
		end,
	})

	vim.api.nvim_create_user_command('Grep', visit_file,
		{
			nargs = '+',
			bang = true,
			complete = grep
		}
	)
end


set_up_live_grep()

set_cmdline_autocompletion()

set_up_fuzzy_picker()

-- set_up_live_grep()

return {
	-- We need to return our find function so we can assign it later.
	find = _find
}
