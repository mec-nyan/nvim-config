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

-- See module's `get_mode`.

----------
-- File --
----------

local file = '%<📃 %3*%f%*'

-----------
-- Flags --
-----------

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
	c = '%7*⟨ C ⟩%*',
	cpp = '%7*⟨C++⟩%*',
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

-- NOTE: Am I even using these?
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

-- TODO: Implement the workaround for cmdline mode.
local ruler =  " %{% &ruler ? ( &rulerformat == '' ? '%3*%-14.(%l,%c%V%)%1* %P ' : &rulerformat ) : '' %}"

----------------
-- Git branch --
----------------

local branch = " 🌳 %{ trim(system('[[ -d .git ]] && git branch --show-current'))} %*"

------------
-- Buffer --
------------

-- We use the same workaround that the mode indicator.
local buffer = '%{% mode() == "c" ? "%9*" : "%2*" %}❲ bnr %n❳ %*'

-- Example:


local function make_status_line()
	return string.format("%%{%% v:lua.require'status_line'.get_mode() %%}%s %s %s %%= %s %s %s",
		branch, file, flags, filetype, buffer, ruler)
end

vim.o.statusline = make_status_line()

-- TODO: Validation/error value.
local function tohex(s)
	return string.format("#%x", s)
end

local function get_hl(name)
	return vim.api.nvim_get_hl(0, { name = name })
end

vim.api.nvim_create_autocmd({'VimEnter', 'ColorScheme'}, {
	callback = function()
		vim.schedule(function()
			-- NOTE: Not portable across colorschemes.
			-- TODO: Check for `link`s to other groups.
			local func_hl = get_hl('Function')
			local comment_hl = get_hl('Comment')

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

			-- Cmdline workaround.
			local type_hl = get_hl('Type')
			fg = type_hl.fg and tohex(type_hl.fg) or 'yellow'
			vim.cmd { cmd = 'highlight', args = { 'User8', 'guibg=' .. fg, 'guifg=black', 'gui=italic' } }
			vim.cmd { cmd = 'highlight', args = { 'User9', 'guibg=NONE', 'guifg=' .. fg, 'gui=NONE' } }
		end)
	end,
})

vim.api.nvim_create_autocmd({'ModeChanged'}, {
	pattern = { '*:n*', '*:v*', '*:V*', '*:CTRL-V*', '*:s*', '*:S*', '*:i*', '*:R*', '*:r*', '*:t*' },
	callback = function()
		local mode = vim.fn.mode()
		if #mode < 1 then return end

		mode = mode:lower():sub(1, 1)

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

		vim.cmd { cmd = 'highlight', args = { 'User1', 'guibg=' .. fg, 'guifg=black', 'gui=italic' }, bang = true }
		vim.cmd { cmd = 'highlight', args = { 'User2', 'guibg=NONE', 'guifg=' .. fg, 'gui=NONE' }, bang = true }

		vim.cmd { cmd = 'redrawstatus', bang = true }
	end
})

return {
	get_mode = function()
		local mode = vim.fn.mode()
		if #mode < 1 then return '(?)' end

		mode = mode:lower():sub(1, 1)

		local modes = {
			n = 'nor',
			i = 'ins',
			v = 'vis',
			t = 'tty',
			c = 'com',
			r = 'rep',
		}

		-- Workaround: statusline doesn't update on `cmdline` mode.
		local user1 = mode == 'c' and 8 or 1
		local user2 = mode == 'c' and 9 or 2

		return string.format("%%%d* %s %%*%%%d*", user1, modes[mode], user2)
	end,
}
