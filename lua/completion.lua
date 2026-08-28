--[[
--
--  Completion related configuration:
--      - Complete options
--      - LSP
--      - Mappings
--
--
--  TODO: For some configurations (like this one) maybe return a function
--  accepting arguments to let other possible users customise these settings.
--
--]]

require 'lsp'.setup()

vim.o.completeopt = 'fuzzy,menuone,preview,noselect'
-- Does this belong here (or maybe in `colours`).
vim.o.pumborder = 'rounded'
vim.o.winborder = 'rounded'
-- TODO: I'm kinda hardcoding these according the theme I'm using (catppuccin),
-- I probably should do this `dynamically` if possible (d'you know I mean?).
-- TODO: Customise the `FloatBorder` for diagnostics too.
-- TODO: Use a darker colour for the preview window (autocmd).
vim.cmd[[
	highlight Pmenu guifg=#9399b2 guibg=#181825
	highlight PmenuBorder guifg=#89b4fa guibg=#181825
	highlight FloatBorder guifg=#89b4fa guibg=#181825
]]

local setkey = vim.keymap.set

setkey('i', '<Tab>', function()
	if vim.fn.pumvisible() == 1 then
		return '<C-n>'
	end

	if #vim.g.pairs_stack > 0 then
		local _pairs = {
			['('] = ')',
			['['] = ']',
			['{'] = '}',
			['"'] = '"',
			["'"] = "'",
			['`'] = '`',
		}

		local stack = vim.g.pairs_stack
		local next_pair = _pairs[stack[#stack]]

		stack[#stack] = nil
		vim.g.pairs_stack = stack

		local col = vim.fn.col('.')
		local next = vim.fn.getline('.'):sub(col, col)

		if next ~= nil and next == next_pair then
			return '<right>'
		end

		return '<C-o>/' .. next_pair .. '<cr><right>'

	end

	return '<Tab>'
end, { expr = true })

setkey('i', '<S-Tab>', function()
	return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true })


vim.api.nvim_create_autocmd('InsertCharPre', {
	-- Start completion after two characters have been inserted.
	-- Use only valid identifier's characters (don't trigger on {}()[] etc).
	callback = function()
		local col = vim.fn.col('.')
		if col < 2 then return end

		local line = vim.fn.getline('.')
		if #line < 1 then return end

		local current = vim.v.char
		local previous = line:sub(col -1, col -1)

		if current:match('^[_a-zA-Z0-9.]$') and
			previous:match('^[_a-zA-Z0-9.]$') then
			vim.lsp.completion.get()
		end
	end,
})

-- Confirm with <enter>
-- This needs to be improved for other uses of <enter> and <tab>.
setkey('i', '<Enter>', function()
	if vim.fn.pumvisible() == 1 then
		return '<C-y>'
	end

	local col = vim.fn.col('.')
	local line = vim.fn.getline('.')
	local next = line:sub(col, col)

	if next:match('[})%]]') then
		-- TODO: Check if we can keep the right indent level all the time.
		return '<Enter><C-o>k<C-o>$<C-o>o'
	end

	return '<Enter>'
end, { expr = true, silent = true })


-- Trigger omnifunc with ctrl+space.
setkey('i', '<C-Space>', '<C-x><C-o>', { desc = '[i][alias] trigger completion' })


vim.api.nvim_create_autocmd('InsertLeave', {
	callback = function()
		vim.cmd.pclose()
	end,
})
