--[[
--
-- Helper functions for package 'files'.
--
--]]

local M = {}

--- Check if the current working directory is a git repository.
--- @return true for git repositories, false otherwise.
--- @return error "command failed" or nil.
local function is_git()
	local out = vim.system(
		{ 'git', 'rev-parse', '--is-inside-work-tree' },
		{ text = true, cwd = vim.fn.getcwd(0, 0) }
	):wait()

	if out.stderr ~= '' then
		return false, "command failed"
	end

	return true, nil
end

--- Check whether "filename" is an executable file.
--- @param filename (string) the name of the file.
--- @return true if the file is executable, false otherwise.
--- @return error message "command failed" or nil.
function M.is_executable(filename)
	local out = vim.system(
		{ 'file', filename },
		{ text = true, cwd = vim.fn.getcwd(0, 0)}
	):wait()

	if out.stderr ~= '' then
		return false, "command failed"
	end

	-- TODO: I'm matching based on the output of "file" containing the word
	-- "executable".  Is this good enough?
	if out.stdout:match('executable') ~= nil then
		return true, nil
	end

	return false, nil
end

--- Get a list of files.  Filter according to "prompt".
--- @param prompt (table) contents of the prompt buffer.
--- @return table with 0 or more file names to display.
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

	local ls_cmd = 'find . -type f -printf "%P\n"'

	if is_git() then
		ls_cmd = 'git ls-files --cached --others --exclude-standard'
	end

	-- Filter with fzf (fuzzy) if there's a prompt.
	if prompt[1] ~= '' then
		ls_cmd = ls_cmd .. ' | fzf --filter=' .. prompt[1]
	end

	local out = vim.system(
		{ 'bash', '-c', ls_cmd },
		{ text = true, cwd = vim.fn.getcwd(0, 0) }
	):wait()

	-- TODO: Error handling?
	if out.stderr ~= '' then
		return { '💩 ...' }
	end

	return vim.split(out.stdout, '\n')
end

return M
