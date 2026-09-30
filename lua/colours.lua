--[[
--
--  Place your colour configuration here.
--
--]]

-- Some helpers.

local function tohex(s)
	return string.format("#%x", s)
end

local function get_hl(name)
	return vim.api.nvim_get_hl(0, { name = name })
end

-- I like this colorscheme with a translucent background.
vim.cmd[[colorscheme catppuccin]]

-- Get these values new.  We'll change them on the following command.
local normal_hl = get_hl('Normal')

vim.cmd.highlight{'Normal', 'guibg=None'}

-- Completion (popup) colours.
--
-- TODO: Floating preview?
--
vim.o.pumborder = 'rounded'
vim.o.winborder = 'rounded'  -- Not working with floating preview ...

local function_hl = get_hl('Function')
local ok_msg_hl = get_hl('OkMsg')
local keyword_hl = get_hl('Keyword')
local cursor_line_hl = get_hl('CursorLine')
local comment_hl = get_hl('Comment')

local popup_groups = {
	Pmenu = {
		fg = tohex(normal_hl.fg),
		bg = tohex(normal_hl.bg),
	},
	PmenuKind = {
		fg = tohex(keyword_hl.fg),
		bg = tohex(normal_hl.bg),
		italic = true,
	},
	PmenuExtra = {
		fg = tohex(comment_hl.fg),
		bg = tohex(normal_hl.bg),
	},
	PmenuSel = {
		fg = tohex(normal_hl.fg),
		bg = tohex(cursor_line_hl.bg),
	},
	PmenuKindSel = {
		fg = tohex(ok_msg_hl.fg),
		bg = tohex(cursor_line_hl.bg),
		italic = true,
	},
	PmenuExtraSel = {
		fg = tohex(comment_hl.fg),
		bg = tohex(cursor_line_hl.bg),
	},
	PmenuBorder = {
		fg = tohex(function_hl.fg),
		bg = tohex(normal_hl.bg),
	},
	FloatBorder = {
		fg = tohex(keyword_hl.fg),
		bg = tohex(normal_hl.bg),
	},
}

for name, opts in pairs(popup_groups) do
	vim.api.nvim_set_hl(0, name, opts)
end

-- Use a darker background for other windows i.e. quickfix, preview, etc.

vim.api.nvim_set_hl(0, '_alt_normal', {
	-- TODO: Review the fallback colour selection.
	fg = normal_hl.fg or 'white',
	bg = normal_hl.bg or 'black',
})

-- Preview is a special window:
vim.api.nvim_create_autocmd('WinEnter', {
	callback = function()
		if vim.wo.previewwindow then
			vim.wo.winhighlight = 'Normal:_alt_normal'
		end
	end
})

-- Both loclist and qflist have the same filetype `qf`.
vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'qf', 'help' },
	callback = function()
		vim.wo.colorcolumn = ''
		vim.wo.winhighlight = 'Normal:_alt_normal'
	end
})
