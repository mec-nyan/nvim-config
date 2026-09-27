--[[
--
--  Status line.
--
--]]

local M = {}

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

function M.flags()
	local parts = {}

	if vim.bo.filetype == 'help' then
		table.insert(parts, '📜 ')
	end

	if vim.bo.modified then
		table.insert(parts, '🗡️ ')
	end

	if not vim.bo.modifiable then
		table.insert(parts, '🔒 ')
	end

	return table.concat(parts)
end

local flags = "%{v:lua.require'status_line'.flags()}" .. '%w'

--------------------------------------
-- Nice icons/emojis for filetypes! --
--------------------------------------

-- TODO: I'll only add the ones I encounter frequently.  I should add an 'or' function to use the
-- default '&filetype' if not listed.
local file_type_icons = {
	[''] = '🩵💚',                 -- empty buffer i.e. start screen.
	greetings = '🛸',
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

local ruler = '%3*%-14.(%l,%c%V%)%{% mode() == "c" ? "%8*" : "%1*" %} %P '

----------------
-- Git branch --
----------------

local branch_name = ''

local function update_branch()
	local output = vim.fn.system {
		'git',
		'-C',
		vim.fn.getcwd(),
		'branch',
		'--show-current',
	}

	if vim.v.shell_error == 0 then
		branch_name = vim.trim(output)
	else
		branch_name = ''
	end

	vim.cmd.redrawstatus()
end

function M.get_branch()
	if branch_name == '' then
		return ''
	end

	return ' 🌳 ' .. branch_name .. ' '
end

vim.api.nvim_create_autocmd({
	'VimEnter',
	'BufEnter',
	'DirChanged',
	'FocusGained',
}, {
	callback = update_branch,
})

local branch = "%{v:lua.require'status_line'.get_branch()}%*"
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

---[[
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
--]]


local last_mode_colour

local function set_mode_colour(mode)
	local colours = {
		i = { 'OkMsg', '9acd32' },        -- Yellow green.
		n = { 'Function', 'ff69b4' },     -- Hot pink.
		v = { 'Keyword', '7b68ee' },      -- Medium slate blue.
		t = { 'String', '7cfc00' },       -- Lime green.
		r = { 'ErrorMsg', 'cd5c5c' },     -- Indian red.
		c = { 'Type', 'ffff00' },         -- Yellow.
	}

	local group = colours[mode] or colours.r
	local hl = get_hl(group[1])
	local fg = hl.fg and tohex(hl.fg) or group[2]

	if fg == last_mode_colour then return end

	last_mode_colour = fg

	vim.api.nvim_set_hl(0, 'User1', {
		fg = 'black',
		bg = fg,
		italic = true,
	})

	vim.api.nvim_set_hl(0, 'User2', {
		fg = fg,
		bg = 'NONE',
	})

	vim.cmd.redrawstatus()
end

vim.api.nvim_create_autocmd({'ModeChanged'}, {
	pattern = { '*:n*', '*:v*', '*:V*', '*:CTRL-V*', '*:s*', '*:S*', '*:i*', '*:R*', '*:r*', '*:t*' },
	callback = function()
		local mode = vim.fn.mode():lower():sub(1, 1)
		set_mode_colour(mode)
	end,
})

function M.get_mode()
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
end

return M

