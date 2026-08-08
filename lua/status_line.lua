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

local mode = "%{% luaeval('_A[vim.api.nvim_get_mode().mode]', {'n': '%1* nor ', 'i': '%2* ins ', 'v': '%3* vis ', 't': '%4* ter ', 'c': '%5* com ', 'R': '%6* rep '}) %}"
local file = '%<%f'
local flags = {
	help = '%h',
	preview = '%w',
	modified = '%m',
	readonly = '%r',
}
local filetype = '%y'          -- i.e. [vim].
local quickfix = '%q'          -- Quickfix List and Location List.
local bufnr = '%n'             -- Buffer number.
local linenr = '%l'            -- Line number.
local nlines = '%L'            -- Number of lines in buffer.
local col = '%v'               -- Screen column.
local perc = '%p'              -- Percentage.
local showcmd = '%S'

-- Example:

local function make_status_line()
	-- TODO: Get the colours from the theme.
	vim.cmd.highlight { "User1", "guibg=slateblue", "guifg=white", "gui=italic" }
	vim.cmd.highlight { "User2", "guibg=hotpink", "guifg=white", "gui=italic" }
	vim.cmd.highlight { "User3", "guibg=purple", "guifg=white", "gui=italic" }
	vim.cmd.highlight { "User4", "guibg=yellowgreen", "guifg=black", "gui=italic" }
	vim.cmd.highlight { "User5", "guibg=green", "guifg=white", "gui=italic" }
	vim.cmd.highlight { "User6", "guibg=indianred", "guifg=white", "gui=italic" }

	local sl = mode .. '%*'

	sl = sl .. ' ' .. file .. '%='
	sl = sl .. ' ' .. flags.help .. flags.preview .. flags.modified .. flags.readonly
	sl = sl .. ' ' .. filetype .. ' buf: ' .. bufnr
	sl = sl .. ' ' .. " %{% &ruler ? ( &rulerformat == '' ? '%-14.(%l,%c%V%) %P' : &rulerformat ) : '' %}"

	return sl
end

vim.o.statusline = make_status_line()

return {}
