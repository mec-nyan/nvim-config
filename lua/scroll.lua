--[[
--
--
--  Simple smooth scrolling.
--
--]]


local setkey = vim.keymap.set

local delay = 14

local ctrl_e_j = vim.api.nvim_replace_termcodes('<C-e>j', false, false, true)
local ctrl_y_k = vim.api.nvim_replace_termcodes('<C-y>k', false, false, true)
local ctrl_e = vim.api.nvim_replace_termcodes('<C-e>', false, false, true)
local ctrl_y = vim.api.nvim_replace_termcodes('<C-y>', false, false, true)


---------------
-- next page --
---------------

local function make_callback_next(timer, amount)
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

	timer:start(0, delay, vim.schedule_wrap(make_callback_next(timer, amount)))

	return timer
end


-------------------
-- previous page --
-------------------

local function make_callback_prev(timer, amount)
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

	timer:start(0, delay, vim.schedule_wrap(make_callback_prev(timer, amount)))

	return timer
end


-------------------------------
-- Move focused line around. --
-------------------------------

-- Helpers.
local function make_callback_down(timer, amount)
	local start = 0

	return function()
		if start == amount then
			timer:stop()
			timer:close()
		end
		
		vim.api.nvim_feedkeys(ctrl_e, 'n', false)
		start = start + 1
	end
end


local function make_callback_up(timer, amount)
	local start = 0

	return function()
		if start == amount then
			timer:stop()
			timer:close()
		end
		
		vim.api.nvim_feedkeys(ctrl_y, 'n', false)
		start = start + 1
	end
end


-- Centre:

local function cursor_line_to_centre()
	local heigth = vim.api.nvim_win_get_height(0)
	local centre = math.floor(heigth / 2)
	local pos = vim.fn.winline()

	if pos == centre then
		return
	end

	local timer = vim.uv.new_timer()

	if pos > centre then
		timer:start(0, delay, vim.schedule_wrap(make_callback_down(timer, pos - centre)))
	else
		timer:start(0, delay, vim.schedule_wrap(make_callback_up(timer, centre - pos)))
	end

	return timer
end

-- Top

local function cursor_line_to_top()
	local offset = vim.wo.scrolloff
	local pos = vim.fn.winline()
	if pos <= offset + 1 then
		return
	end

	local amount = pos - offset
	local timer = vim.uv.new_timer()
	timer:start(0, delay, vim.schedule_wrap(make_callback_down(timer, amount)))

	return timer
end

-- Bottom

local function cursor_line_to_bottom()
	-- TODO: Check if there are enough lines above to scroll all the way down.
	local offset = vim.wo.scrolloff
	local heigth = vim.api.nvim_win_get_height(0)
	local pos = vim.fn.winline()
	local amount = heigth - (pos + offset)
	local timer = vim.uv.new_timer()
	timer:start(0, delay, vim.schedule_wrap(make_callback_up(timer, amount)))
	
	return timer
end


setkey('n', '<C-d>', scroll_next, { desc = '[scroll] page down' })
setkey('n', '<C-u>', scroll_prev, { desc = '[scroll] page up' })

setkey('n', 'zt', cursor_line_to_top, { desc = '[scroll] cursor line to top' })
setkey('n', 'zz', cursor_line_to_centre, { desc = '[scroll] cursor line to centre' })
setkey('n', 'zb', cursor_line_to_bottom, { desc = '[scroll] cursor line to bottom' })
