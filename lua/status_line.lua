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

local mode = ''
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
	local sl = file

	sl = sl .. ' ' .. flags.help .. flags.preview .. flags.modified .. flags.readonly
	sl = sl .. ' ' .. filetype .. ' buf: ' .. bufnr .. ' l: ' .. linenr .. ' c: ' .. col

	return sl
end

vim.o.statusline = make_status_line()

return {}
