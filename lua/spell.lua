--[[
--
--
--  Spelling suggestions pop-up.
--
--
--]]


local function popup()
	local suggestions = vim.fn.spellsuggest(vim.fn.expand('<cword>'))

	if #suggestions == 0 then
		vim.notify('No suggestions', vim.log.levels.INFO, {})
		return
	end

	local buf = vim.api.nvim_get_current_buf()

	local new_buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, suggestions)

	local min_width = 10

	for _, word in pairs(suggestions) do
		if #word > min_width then
			min_width = #word
		end
	end

	min_width = min_width + 4  -- Line numbers and small padding.

	local spell_win = vim.api.nvim_open_win(buf, true, {
		border = 'rounded',
		relative = 'cursor',
		height = #suggestions,
		width = min_width,
		row = 1,
		col = 0,
		style = 'minimal'
	})

	vim.api.nvim_set_option_value('filetype', 'spell_suggestions_popup', { buf = new_buf })
	vim.api.nvim_win_set_buf(spell_win, new_buf)
end


local setkey = vim.keymap.set

vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'spell_suggestions_popup' },
	callback = function()

		-- Abort with `q`
		setkey('n', 'q', '<C-w>c', {
			buf = 0,
			desc = '[spell] discard suggestions pop-up',
		})

		-- ... Or `<esc>`
		setkey('n', '<esc>', '<C-w>c', {
			buf = 0,
			desc = '[spell] discard suggestions pop-up',
		})

		-- Navigate with `<Tab>` (NOTE: `j`, `k`, `ctrl_n` and `ctrl_p` will also work).
		setkey('n', '<Tab>', 'j', {
			buf = 0,
			desc = '[spell] next'
		})

		setkey('n', '<S-Tab>', 'k', {
			buf = 0,
			desc = '[spell] previous'
		})

		-- Accept suggestion
		setkey('n', '<Enter>', function()
			local suggestion = vim.fn.getline('.')

			-- Close pop-up
			vim.api.nvim_win_close(0, true)

			-- Substitute suggestion for current word
			vim.cmd(':norm diwi' .. suggestion)
		end, {
			buf = 0,
			desc = '[spell] accept',
		})
	end,
})


setkey('n', 'z=', popup, { desc = '[spell] show suggestions' })
