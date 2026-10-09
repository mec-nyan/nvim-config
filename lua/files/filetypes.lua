local M = {}

local by_extension = {
	c = 'c',
	cpp = 'cpp',
	go = 'go',
	js = 'javascript',
	lua = 'lua',
	md = 'markdown',
	py = 'python',
	rs = 'rust',
	ts = 'typescript',
}

function M.get_filetype(filename)
	-- TODO: Handle other special cases by name.
	if filename == 'Makefile' then
		return 'make'
	end

	local extension = filename:match('%.(.*)') or ''

	return by_extension[extension] or 'text'
end

return M
