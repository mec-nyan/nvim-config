--[[
--
--  Automatically close text pairs
--
--  () [] {} "" '' ``
--
--]]

local setkey = vim.keymap.set

-- TODO: Use a buffer-local stack.
vim.g.pairs_stack = nil

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
			local stack = vim.g.pairs_stack or {}
			stack[#stack + 1] = opening
			vim.g.pairs_stack = stack
			return pair .. '<left>'
		end, { desc = '[pairs] insert ' .. pair .. '.', expr = true })

		-- Closing mapping:
		setkey('i', closing, function()
			local stack = vim.g.pairs_stack or {}
			local col = vim.fn.col('.')
			local next = vim.fn.getline('.'):sub(col, col)
			
			if next == closing and stack[#stack] == opening then
				stack[#stack] = nil
				vim.g.pairs_stack = stack
				return '<right>'
			else
				return closing
			end
		end, { desc = '[pairs] closing ' .. pair .. '.', expr = true })

	else
		-- Same character pairs like "" and '' etc.
		setkey('i', opening, function()
			local stack = vim.g.pairs_stack or {}
			if stack[#stack] ~= opening then
				stack[#stack + 1] = opening
				vim.g.pairs_stack = stack
				return pair .. '<left>'
			else
				local col = vim.fn.col('.')
				local next = vim.fn.getline('.'):sub(col, col)
				
				if next == closing and stack[#stack] == opening then
					stack[#stack] = nil
					vim.g.pairs_stack = stack
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
	local stack = vim.g.pairs_stack or {}
	if #stack == 0 then
		return '<backspace>'
	end

	local col = vim.fn.col('.')
	local line = vim.fn.getline('.')
	local current = line:sub(col - 1, col - 1)
	local next = line:sub(col, col)

	if stack[#stack] == current and _pairs[current] == next then
		stack[#stack] = nil
		vim.g.pairs_stack = stack
		return '<right><backspace><backspace>'
	else
		return '<backspace>'
	end
end, { desc = '[pairs] backspace', expr = true})


-- Clear the stack
vim.api.nvim_create_user_command('PairsReset', function()
	stack = {}
	vim.g.pairs_stack = stack
end, { desc = 'Clear pairs\' stack'}
)
