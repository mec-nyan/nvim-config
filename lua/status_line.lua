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
	-- TODO: Get the colours from the theme.
	-- User1: mode
	vim.cmd.highlight { "User1", "guibg=slateblue", "guifg=white", "gui=italic" }
	-- User2: branch
	vim.cmd.highlight { "User2", "guibg=NONE", "guifg=slateblue", "gui=NONE" }
	-- User3: file
	vim.cmd.highlight { "User3", "guibg=NONE", "guifg=grey40", "gui=NONE" }
	vim.cmd.highlight { "User4", "guibg=yellowgreen", "guifg=black", "gui=NONE" }
	vim.cmd.highlight { "User5", "guibg=green", "guifg=white", "gui=NONE" }
	vim.cmd.highlight { "User6", "guibg=indianred", "guifg=white", "gui=NONE" }
	vim.cmd.highlight { "User7", "guibg=none", "guifg=darkorange", "gui=NONE" }
	vim.cmd.highlight { "User8", "guibg=none", "guifg=dodgerblue", "gui=bold" }
	vim.cmd.highlight { "User9", "guibg=none", "guifg=grey40" }

	return string.format("%%{%% v:lua.require'status_line'.get_mode() %%}%s %s %s %%= %s buf: %s - %s",
		branch, file, flags, filetype, bufnr, ruler)
end

vim.o.statusline = make_status_line()

return {
	get_mode = function()
		local mode = vim.api.nvim_get_mode().mode

		if mode == 'n' then
			vim.cmd.highlight { 'User1', 'guibg=slateblue', 'guifg=white', 'gui=italic' }
			vim.cmd.highlight { "User2", "guibg=NONE", "guifg=slateblue", "gui=NONE" }
		elseif mode == 'i' then
			vim.cmd.highlight { 'User1', 'guibg=hotpink', 'guifg=white', 'gui=italic' }
			vim.cmd.highlight { "User2", "guibg=NONE", "guifg=hotpink", "gui=NONE" }
		elseif mode == 'v' or mode == 'V' then
			vim.cmd.highlight { 'User1', 'guibg=purple', 'guifg=white', 'gui=italic' }
			vim.cmd.highlight { "User2", "guibg=NONE", "guifg=purple", "gui=NONE" }
		elseif mode == 't' then
			vim.cmd.highlight { 'User1', 'guibg=yellowgreen', 'guifg=black', 'gui=italic' }
			vim.cmd.highlight { "User2", "guibg=NONE", "guifg=yellowgreen", "gui=NONE" }
		elseif mode == 'c' then
			vim.cmd.highlight { 'User1', 'guibg=orange', 'guifg=black', 'gui=italic' }
			vim.cmd.highlight { "User2", "guibg=NONE", "guifg=orange", "gui=NONE" }
		elseif mode == 'r' or mode == 'R' then
			vim.cmd.highlight { 'User1', 'guibg=indianred', 'guifg=white', 'gui=italic' }
			vim.cmd.highlight { "User2", "guibg=NONE", "guifg=indianred", "gui=NONE" }
		elseif mode == 'rm' then
			vim.cmd.highlight { 'User1', 'guibg=dodgerblue', 'guifg=white', 'gui=italic' }
			vim.cmd.highlight { "User2", "guibg=NONE", "guifg=dodgerblue", "gui=NONE" }
		end

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
