--[[
--
--  Window navigation/manipulation.
--
--]]


local setkey = vim.keymap.set

local directions = {
	left = 'h',
	down = 'j',
	up = 'k',
	right = 'l',
}

local actions = {
	{
		name = 'increase height',
		cmd = '+',
		key = ']',
	},
	{
		name = 'decrease height',
		cmd = '-',
		key = '[',
	},
	{
		name = 'increase width',
		cmd = '>',
		key = '.',
	},
	{
		name = 'decrease width',
		cmd = '<',
		key = ',',
	},
	{
		name = 'equalize',
		cmd = '=',
		key = '=',
	},
}

local modes = {
	i = 'insert',
	t = 'term',
	n = 'normal',
}

for _, opt in ipairs({
	{ mode = 'n' },
	{ mode = 'i', prefix = '<esc>' },
	{ mode = 't', prefix = '<C-\\><C-n>' },
}) do
	local mode = opt.mode
	local prefix = opt.prefix or ''

	-- Resize
	for _, action in ipairs(actions) do
		local key = '<M-' .. action.key .. '>'
		local cmd = prefix .. '<C-w>' .. action.cmd
		local description = string.format(
			'[%s][window] %s', modes[mode], action.name)

		if mode == 'i' or mode == 't' then
			cmd = cmd .. 'a'  -- back to insert mode
		end

		setkey(mode, key, cmd, { desc = description })
	end

	-- Move
	for dir, k in pairs(directions) do
		local key = '<M-' .. k .. '>'
		local cmd = prefix .. '<C-w>' .. k
		local description = string.format(
			'[%s][window] go %s', modes[mode], dir)

		setkey(mode, key, cmd, { desc = description })
	end
end


return {}
