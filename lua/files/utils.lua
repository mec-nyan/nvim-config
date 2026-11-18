--[[
--
-- Helper functions for package 'files'.
--
--]]

local M = {}

local error_template = 'Command `%s` is not available.  Is it installed?'

M.errors = {
	git = error_template:format('git'),
	find = error_template:format('find'),
	bash = error_template:format('bash'),
	file = error_template:format('file'),
	fzf = error_template:format('fzf'),
	failed = 'command failed',
}

--- Check if the current working directory is a git repository.
--- @return true for git repositories, false otherwise.
--- @return error "command failed" or nil.
local function is_git()
	local cmd = 'git'

	if vim.fn.executable(cmd) ~= 1 then
		return false, M.errors.git
	end

	local out = vim.system(
		{ cmd, 'rev-parse', '--is-inside-work-tree' },
		{ text = true, cwd = vim.fn.getcwd(0, 0) }
	):wait()

	if out.stderr ~= '' then
		return false, string.format('%s: %s', cmd, M.errors.failed)
	end

	return true, nil
end

--- Check whether "filename" is an executable file.
--- @param filename string The name of the file.
--- @return boolean True if the file is executable, false otherwise.
--- @return string Error message "command failed" or nil.
function M.is_executable(filename)
	local cmd = 'file'

	if vim.fn.executable(cmd) ~= 1 then
		return false, M.errors.file
	end

	local out = vim.system(
		{ cmd, filename },
		{ text = true, cwd = vim.fn.getcwd(0, 0)}
	):wait()

	if out.stderr ~= '' then
		return false, string.format('%s: %s', cmd, M.errors.failed)
	end

	-- TODO: I'm matching based on the output of "file" containing the word
	-- "executable".  Is this good enough?
	if out.stdout:match('executable') ~= nil then
		return true, nil
	end

	return false, nil
end

--- Get a list of files.  Filter according to "prompt".
--- @param prompt string[] Contents of the prompt buffer.  Should contain only one line.
--- @return string[] Zero or more file names to display.
function M.process(prompt)
	if #prompt ~= 1 then
		return { '🤪 ...' }
	end

	-- List files:
	-- - Use "find" in non-git directories (show everything).
	-- - Use "git" for git repositories (ignore some files).
	--
	-- TODO: Add options to:
	-- - Show ignored files.
	-- - Don't show hidden files.

	local cmd
	local ls_cmd

	local is_git_repo, error = is_git()

	-- TODO: Better error messages (maybe switching on error types).
	if error ~= nil  and error == M.errors.git then
		return { '💩 ' .. error }
	end

	if is_git_repo then
		ls_cmd = 'git ls-files --cached --others --exclude-standard'
	else
		cmd = 'find'
		if vim.fn.executable(cmd) ~= 1 then
			return { '💩 ' .. M.errors.find }
		end
		ls_cmd = cmd .. ' . -type f -printf "%P\n"'
	end

	-- Filter with fzf (fuzzy) if there's a prompt.
	cmd = 'fzf'
	if vim.fn.executable(cmd) ~= 1 then
		return { '💩 ' .. M.errors.fzf }
	end

	if prompt[1] ~= '' then
		ls_cmd = ls_cmd .. ' | fzf --filter=' .. prompt[1]
	end
	
	cmd = 'bash'
	if vim.fn.executable(cmd) ~= 1 then
		return { '💩 ' .. M.errors.bash }
	end

	local out = vim.system(
		{ 'bash', '-c', ls_cmd },
		{ text = true, cwd = vim.fn.getcwd(0, 0) }
	):wait()

	-- TODO: Error handling?
	if out.stderr ~= '' then
		return { '💩 Unknown error: ' .. out.stderr }
	end

	return vim.split(out.stdout, '\n')
end

return M
