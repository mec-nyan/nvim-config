-- Health check for the file picker.

return {
	check = function()
		vim.health.start('Files report:')

		-- We depend on some commands for the picker to work.

		local commands = {'git', 'file', 'find', 'fzf', 'bash'}

		for _, cmd in pairs(commands) do
			if vim.fn.executable(cmd) == 1 then
				vim.health.ok(cmd .. ' is available.')
			else
				vim.health.error(cmd .. ' is not available.')
			end
		end
	end,
}
