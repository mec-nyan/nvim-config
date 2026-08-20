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
