-----------------------
-- Highlight on yank --
-----------------------

vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight yanked chunk',
	group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})


--------------
-- Shabangs --
--------------

-- Expand "shabangs" for Python, Lua, Bash, etc ...

-- NOTE: We only need this for 'python3' (for now).
-- We can add more interpreters as needed (i.e. ruby).
local aliases = {
	lua = 'lua',
	python = 'python3',
	sh = 'sh',
	bash = 'bash',
}

local shabang_au_group = vim.api.nvim_create_augroup('ShaBangAu', { clear = true })

-- TODO: Add filter to remove trailing space if abbr is activated with <space>.
-- Consider that when using <C-]> there will be no trailing space.
-- HINT: The filter can remove the trailing space and add a newline ;)
vim.api.nvim_create_autocmd('FileType', {
	group = shabang_au_group,
	pattern = vim.tbl_keys(aliases),
	callback = function(ev)
		local shabang = '#!/usr/bin/env ' .. aliases[vim.bo[ev.buf].filetype]

		vim.keymap.set('ia', '#!', function()

			-- Only trigger the 'shabang' at the beginning of the file.

			local pos = vim.api.nvim_win_get_cursor(0)

			if pos[1] == 1 and pos[2] == 2 then
				return shabang
			else
				return '#!'
			end
		end,
		{
			buffer = ev.buf,
			expr = true,
			desc = '[abbr] shabang!',
		})
	end,
})
