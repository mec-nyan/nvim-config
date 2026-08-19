--[[
--
--  Automatically close text pairs
--
--  () [] {} "" '' ``
--
--]]

local setkey = vim.keymap.set

local stack = {}

local _pairs = {
	['('] = ')',
	['['] = ']',
	['{'] = '}',
	['"'] = '"',
	["'"] = "'",
	['`'] = '`',
}


for opening, closing in pairs(_pairs) do

	local pair = opening .. closing

	if opening ~= closing then
		-- Opening mapping:
		setkey('i', opening, function()
			stack[#stack + 1] = opening
			return pair .. '<left>'
		end, { desc = '[pairs] insert ' .. pair .. '.', expr = true })

		-- Closing mapping:
		setkey('i', closing, function()
			local col = vim.fn.col('.')
			local next = vim.fn.getline('.'):sub(col, col)
			
			if next == closing and stack[#stack] == opening then
				stack[#stack] = nil
				return '<right>'
			else
				return closing
			end
		end, { desc = '[pairs] closing ' .. pair .. '.', expr = true })

	else
		-- Same character pairs like "" and '' etc.
		setkey('i', opening, function()
			if stack[#stack] ~= opening then
				stack[#stack + 1] = opening
				return pair .. '<left>'
			else
				local col = vim.fn.col('.')
				local next = vim.fn.getline('.'):sub(col, col)
				
				if next == closing and stack[#stack] == opening then
					stack[#stack] = nil
					return '<right>'
				else
					return closing
				end
			end
		end, { desc = '[pairs] insert/close ' .. pair .. '.', expr = true })

	end
end


-- Delete empty pair from within.
setkey('i', '<backspace>', function()
	if #stack == 0 then
		return '<backspace>'
	end

	local col = vim.fn.col('.')
	local line = vim.fn.getline('.')
	local current = line:sub(col - 1, col - 1)
	local next = line:sub(col, col)

	if stack[#stack] == current and _pairs[current] == next then
		stack[#stack] = nil
		return '<right><backspace><backspace>'
	else
		return '<backspace>'
	end
end, { desc = '[pairs] backspace', expr = true})
