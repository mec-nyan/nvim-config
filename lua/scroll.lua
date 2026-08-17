--[[
--
--
--  Simple smooth scrolling.
--
--]]


local delay = 14

local ctrl_e_j = vim.api.nvim_replace_termcodes('<C-e>j', false, false, true)
local ctrl_y_k = vim.api.nvim_replace_termcodes('<C-y>k', false, false, true)
local ctrl_e = vim.api.nvim_replace_termcodes('<C-e>', false, false, true)
local ctrl_y = vim.api.nvim_replace_termcodes('<C-y>', false, false, true)


---------------
-- next page --
---------------

local function make_cb_next(timer, amount)
	local start = 0

	return function()
		-- Scroll for `amount` lines up or until we've reached the last line.
		
		local current = vim.fn.line('.')
		local last = vim.fn.line('$')

		if start == amount or current == last then
			timer:stop()
			timer:close()
			return
		end

		vim.api.nvim_feedkeys(ctrl_e_j, 'n', false)
		start = start + 1
	end
end

local function scroll_next()
	local amount = vim.wo.scroll
	local timer = vim.uv.new_timer()

	timer:start(0, delay, vim.schedule_wrap(make_cb_next(timer, amount)))

	return timer
end


-------------------
-- previous page --
-------------------

local function make_cb_prev(timer, amount)
	local start = 0

	return function()
		-- Scroll for `amount` lines down or until the first line is visible.
		
		local first = vim.fn.line('w0')

		if start == amount or first == 1 then
			timer:stop()
			timer:close()
			return
		end

		vim.api.nvim_feedkeys(ctrl_y_k, 'n', false)
		start = start + 1
	end
end

local function scroll_prev()
	local amount = vim.wo.scroll
	local timer = vim.uv.new_timer()

	timer:start(0, delay, vim.schedule_wrap(make_cb_prev(timer, amount)))

	return timer
end


local setkey = vim.keymap.set

setkey('n', '<C-u>', scroll_prev, { desc = '[scroll] page up' })
setkey('n', '<C-d>', scroll_next, { desc = '[scroll] page down' })
