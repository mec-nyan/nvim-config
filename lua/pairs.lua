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
				stack[#stack] = opening
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
