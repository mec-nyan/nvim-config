--[[
--
--  Decorate comments.
--
--  Draw a box around a comment using the language comment markers.
--
--]]


local function get_comment_style(ft)
	local comment_marker
	local comment_match

	local c_style = { c = 1, cpp = 1, go = 1, rust = 1, typescript = 1, javascript = 1 }
	local sh_style = { sh = 1, bash = 1, python = 1, swayconfig = 1 }
	local lua_style = { lua = 1 }

	if lua_style[ft] then
		comment_marker = '--'
		comment_match = '^%s*%-%-'
	elseif c_style[ft] then
		comment_marker = '//'
		comment_match = '^%s*//'
	elseif sh_style[ft] then
		comment_marker = '#'
		comment_match = '^%s*#'
	end

	return comment_marker, comment_match
end


local function decorate(ft)

	local line = vim.api.nvim_get_current_line()
	local comment_marker, comment_match = get_comment_style(ft)
	if not comment_marker then
		vim.notify("Filetype " .. ft .. " is not supported.", vim.log.levels.INFO, {})
		return
	end

	if not line:match(comment_match) then
		vim.notify("Line is not a comment.", vim.log.levels.INFO, {})
		return
	end

	local left = line:match(comment_match)  -- Include leading spaces.
	local content = line:gsub(comment_match, "") .. " "  -- pad the end.
	local width = vim.fn.strdisplaywidth(content)

	local message = left .. content .. comment_marker

	local surround = left .. string.rep(comment_marker:sub(1, 1), width) .. comment_marker

	local line = vim.api.nvim_win_get_cursor(0)[1]

	vim.api.nvim_buf_set_lines(0, line - 1, line, false, {surround, message, surround})
end

-- TODO: Visual mode (block comments).


-- TODO: Export the function and let the user do the mappings.
vim.keymap.set('n', '<leader>dc', function() 
	decorate(vim.bo.filetype) 
end, { desc = '[comment] decorate' })
