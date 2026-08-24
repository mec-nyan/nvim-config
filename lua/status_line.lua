--[[
--
--  Status line.
--
--]]


-------------------------------------
-- This is the default statusline. --
-------------------------------------

local default_sl = "%<%f %h%w%m%r %{% v:lua.require('vim._core.util').term_exitcode() %}%=%{% luaeval('(package.loaded[''vim.ui''] and vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin or -1) and vim.ui.progress_status()) or '''' ')%}%{% &showcmdloc == 'statusline' ? '%-10.S ' : '' %}%{% exists('b:keymap_name') ? '<'..b:keymap_name..'> ' : '' %}%{% &busy > 0 ? '◐ ' : '' %}%{% luaeval('(package.loaded[''vim.diagnostic''] and next(vim.diagnostic.count()) and vim.diagnostic.status() .. '' '') or '''' ') %}%{% &ruler ? ( &rulerformat == '' ? '%-14.(%l,%c%V%) %P' : &rulerformat ) : '' %}"


-- Let's try to build it in blocks.

--------------------
-- Mode indicator --
--------------------

--[[
local nvim_modes = {
	n = '%1* nor ',
	i = '%2* ins ',
	v = '%3* vis ',
	V = '%3* vis ',
	t = '%4* ter ',
	c = '%5* com ',
	R = '%6* rep ',
	r = '%6* >_  ',
	rm = '%6* more ',
}

local mode = "%{% luaeval('_A[vim.api.nvim_get_mode().mode]', { "

for k, v in pairs(nvim_modes) do
	mode = mode .. string.format("'%s': '%s', ", k, v)
end

mode = mode .." } ) %}"

--]]

----------
-- File --
----------

local file = '%<📃 %3*%f%*'

-- local flags = '%h%w%m%r'

local is_help = "%{% luaeval('vim.bo.filetype == \"help\" and \"📜 \" or \"\"')%}"
local ro = "%{% luaeval('vim.bo.modifiable and \"\" or \"🔒 \"') %}"
local modified = "%{% luaeval('vim.bo.modified and \"🗡️ \" or \"\"') %}"

local flags = is_help .. "%w" .. modified .. ro

--------------------------------------
-- Nice icons/emojis for filetypes! --
--------------------------------------

-- TODO: I'll only add the ones I encounter frequently.  I should add an 'or' function to use the
-- default '&filetype' if not listed.
local file_type_icons = {
	[''] = '🩵💚',                 -- empty buffer i.e. start screen.
	lua = '🌙',
	python = '🐍',
	c = '%8*⟨ C ⟩%*',
	cpp = '%8*⟨C++⟩%*',
	rust = '🦀',
	help = '🪓',
	go = '🐹',
	zig = '🦎',
	sh = '🐚',
	bash = '🐚',
	markdown = 'MD',
	gitcommit = '%7* %*',
	debsources = '📦',
	dockerfile = '🐋',
	vim = '%5* Vim %*'
}

filetype = " %{% get({ "

for k, v in pairs(file_type_icons) do
	filetype = filetype .. string.format("'%s': '%s', ", k, v)
end

filetype = filetype .. "}, &filetype, &filetype) %} "

local quickfix = '%q'          -- Quickfix List and Location List.
local bufnr = '%n'             -- Buffer number.
local linenr = '%l'            -- Line number.
local nlines = '%L'            -- Number of lines in buffer.
local col = '%v'               -- Screen column.
local perc = '%p'              -- Percentage.
local showcmd = '%S'


-----------
-- Ruler --
-----------

local ruler =  " %{% &ruler ? ( &rulerformat == '' ? '%-14.(%l,%c%V%) %P' : &rulerformat ) : '' %}"

----------------
-- Git branch --
----------------

local branch = "%2*  %{ trim(system('[[ -d .git ]] && git branch --show-current'))} %*"

-- Example:


local function make_status_line()
	return string.format("%%{%% v:lua.require'status_line'.get_mode() %%}%s %s %s %%= %s buf: %s - %s",
		branch, file, flags, filetype, bufnr, ruler)
end

vim.o.statusline = make_status_line()

-- TODO: Validation/error value.
local function tohex(s)
	return string.format("#%x", s)
end

vim.api.nvim_create_autocmd({'VimEnter', 'ColorScheme'}, {
	callback = function()
		vim.schedule(function()
			-- NOTE: Not portable across colorschemes.
			-- TODO: Check for `link`s to other groups.
			local func_hl = vim.api.nvim_get_hl(0, { name = 'Function' })
			local comment_hl = vim.api.nvim_get_hl(0, { name = 'Comment' })

			local fg = func_hl.fg and tohex(func_hl.fg) or 'slateblue'

			-- User1: mode
			vim.cmd { cmd = 'highlight', args = { 'User1', 'guibg=' .. fg, 'guifg=black', 'gui=italic' } }

			-- User2: branch
			vim.cmd { cmd = 'highlight', args = { 'User2', 'guibg=NONE', 'guifg=' .. fg, 'gui=NONE' } }

			-- User3: file
			fg = comment_hl.fg and tohex(comment_hl.fg) or 'grey40'
			vim.cmd { cmd = 'highlight', args = { 'User3', 'guibg=NONE', 'guifg=' .. fg, 'gui=NONE' } }

			-- Others (used for `ft`).
			vim.cmd { cmd = 'highlight', args = { 'User4', 'guibg=yellowgreen', 'guifg=black', 'gui=NONE' } }
			vim.cmd { cmd = 'highlight', args = { 'User5', 'guibg=green', 'guifg=white', 'gui=NONE' } }
			vim.cmd { cmd = 'highlight', args = { 'User6', 'guibg=indianred', 'guifg=white', 'gui=NONE' } }
			vim.cmd { cmd = 'highlight', args = { 'User7', 'guibg=NONE', 'guifg=darkorange', 'gui=NONE' } }
			vim.cmd { cmd = 'highlight', args = { 'User8', 'guibg=NONE', 'guifg=dodgerblue', 'gui=NONE' } }
			-- vim.cmd { cmd = 'highlight', args = { 'User9', 'guibg=NONE', 'guifg=', 'gui=NONE' } }
		end)
	end,
})

vim.api.nvim_create_autocmd({'ModeChanged'}, {
	callback = function()
		local mode = vim.fn.mode()
		if #mode < 1 then return end

		mode = mode:lower():sub(1, 1)

		local get_hl = function(name) return vim.api.nvim_get_hl(0, { name = name }) end

		local groups = {}

		for k, v in pairs {
			kwd = { name = 'Keyword', default = '7b68ee' },      -- Medium slate blue.
			fun = { name = 'Function', default = 'ff69b4' },     -- Hot pink.
			str = { name = 'String', default = '7cfc00' },       -- Lime green.
			err = { name = 'ErrorMsg', default = 'cd5c5c' },     -- Indian red.
			type = { name = 'Type', default = 'ffff00' },        -- Yellow.
			ok = { name = 'OkMsg', default = '9acd32' },         -- Yellow green.
		} do
			groups[k] = get_hl(v.name).fg or v.default
		end

		local fg

		if mode == 'i' then
			fg = tohex(groups.ok)
		elseif mode == 'v' then
			fg = tohex(groups.kwd)
		elseif mode == 't' then
			fg = tohex(groups.str)
		elseif mode == 'c' then
			fg = tohex(groups.type)
		elseif mode == 'r' then
			fg = tohex(groups.err)
		elseif mode == 'n' then
			fg = tohex(groups.fun)
		else
			fg = tohex(groups.err)
		end

		vim.cmd { cmd = 'highlight', args = { 'clear', 'User1' } }
		vim.cmd { cmd = 'highlight', args = { 'clear', 'User2' } }

		vim.cmd { cmd = 'highlight', args = { 'User1', 'guibg=' .. fg, 'guifg=black' }, bang = true }
		vim.cmd { cmd = 'highlight', args = { 'User2', 'guibg=NONE', 'guifg=' .. fg }, bang = true }

		vim.cmd { cmd = 'redrawstatus', bang = true }
	end
})

return {
	get_mode = function()
		local mode = vim.api.nvim_get_mode().mode

		local modes = {
			n = 'nor',
			i = 'ins',
			v = 'vis',
			V = 'VIS',
			t = 'tty',
			c = 'com',
			r = 'rep',
			R = 'REP',
			rm = 'more',
		}

		return string.format("%%1* %s %%*", modes[mode])
	end,
}
