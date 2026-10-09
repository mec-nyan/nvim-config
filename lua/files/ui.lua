local panes = require 'files.panes'
local preview = require 'files.preview'
local file_utils = require 'files.utils'

local M = {
	top_left_buf = nil,
	top_left_buf = nil,

	top_right_buf = nil,
	top_right_win = nil,

	prompt_buf = nil,
	prompt_win = nil,

	insert_buf = nil,
	insert_win = nil,
}

function M.open(self, geometry)
	self.top_left_buf, self.top_left_win = panes.top_left_pane(geometry)
	self.top_right_buf, self.top_right_win = panes.top_right_pane(geometry)
	self.prompt_buf, self.prompt_win = panes.prompt_pane(geometry)
	self.insert_buf, self.insert_win = panes.insert_pane(geometry, self.prompt_win)

	-- TODO: Can we better indicate to 'startinsert' in a particular buffer/window?
	vim.cmd 'startinsert'

	-- TODO: These shouldn't be here...
	local setkey = vim.keymap.set
	-- Quit.
	setkey({'i', 'n'}, '<esc>', function()
		vim.cmd 'stopinsert'
		self:close()
	end, {
		buf = self.insert_buf,
	})

	-- Open file.
	setkey({'i', 'n'}, '<cr>', function()
		vim.cmd 'stopinsert'

		local pos = vim.api.nvim_win_get_cursor(self.top_left_win)
		local line = vim.api.nvim_buf_get_lines(self.top_left_buf, pos[1] - 1, pos[1], false)

		vim.api.nvim_win_close(self.top_left_win, true)
		vim.api.nvim_win_close(self.top_right_win, true)
		vim.api.nvim_win_close(self.prompt_win, true)
		vim.api.nvim_win_close(self.insert_win, true)

		if #line ~= 1 then return end

		local filename = line[1]

		-- Edit in current window.
		-- TODO: Add key bindings to open in new tab or split.
		vim.cmd('edit ' .. filename)
	end, {
		buf = self.insert_buf,
	})

	-----------------------
	-----------------------
	-- more key bindings --
	-----------------------
	-----------------------
	-- Navigate files list.
	local function prev()
		local pos = vim.api.nvim_win_get_cursor(self.top_left_win)
		if pos[1] > 1 then
			pos[1] = pos[1] - 1
		end
		vim.api.nvim_win_set_cursor(self.top_left_win, pos)
		preview.update_preview(self.top_left_buf, self.top_left_win, self.top_right_buf, self.top_right_win)
	end

	local function next()
		local pos = vim.api.nvim_win_get_cursor(self.top_left_win)
		local count = vim.api.nvim_buf_line_count(self.top_left_buf)
		-- Account for the last '\n'.
		if pos[1] < count - 1 then
			pos[1] = pos[1] + 1
		end
		vim.api.nvim_win_set_cursor(self.top_left_win, pos)
		preview.update_preview(self.top_left_buf, self.top_left_win, self.top_right_buf, self.top_right_win)
	end

	local list_bindings = {
		{
			action = next,
			keys = { '<Tab>', '<C-n>' },
		},
		{
			action = prev,
			keys = { '<S-Tab>', '<C-p>' },
		},
	}

	for _, binding in pairs(list_bindings) do
		for _, key in pairs(binding.keys) do
			setkey({'i', 'n'}, key, binding.action, { buf = self.insert_buf })
		end
	end

	vim.api.nvim_create_autocmd('CursorMovedI', {
		buf = self.insert_buf,
		callback = function()
			-- Get prompt, if any.
			local text = vim.api.nvim_buf_get_lines(self.insert_buf, 0, -1, false)
			-- Get the list of files, filtering by "prompt".
			text = file_utils.process(text)
			-- Put the resulting list on the top left pane.
			vim.api.nvim_buf_set_lines(self.top_left_buf, 0, -1, false, text)
			-- Move the cursor back to the first line/item.
			vim.api.nvim_win_set_cursor(self.top_left_win, {1, 1})
			-- Update the preview window.
			preview.update_preview(self.top_left_buf, self.top_left_win, self.top_right_buf, self.top_right_win)
		end,
	})
end

function M.close(self)
	vim.api.nvim_win_close(self.insert_win, true)
	vim.api.nvim_win_close(self.prompt_win, true)
	vim.api.nvim_win_close(self.top_right_win, true)
	vim.api.nvim_win_close(self.top_left_win, true)
end


return M
