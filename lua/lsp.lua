--[[
--
--  LSP configuration.
--
--]]

---------------------------------
-- Configure language servers. --
---------------------------------

local function config_gopls()
	vim.lsp.config['gopls'] = {
		cmd = { 'gopls' },
		filetypes = { 'go', 'gomod', 'gowork' },
		root_markers = { { 'go.mod', 'go.work' }, '.git' },
		single_file_support = true,
	}

	vim.lsp.enable 'gopls'
end

local function config_clangd()
	vim.lsp.config['clangd'] = {
		cmd = { 'clangd' },
		filetypes = { 'c', 'cpp' },
		root_markers = { { '.clangd', '.clang-format' }, '.git' },
		single_file_support = true,
	}

	vim.lsp.enable 'clangd'
end

local function config_pylsp()
	vim.lsp.config['pylsp'] = {
		cmd = { 'pylsp' },
		filetypes = { 'python' },
		root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
		single_file_support = true,
	}

	vim.lsp.enable 'pylsp'
end

local function config_rust_analyzer()
	vim.lsp.config['rust-analyzer'] = {
		cmd = { 'rust-analyzer' },
		filetypes = { 'rust' },
		root_markers = { 'Cargo.toml', '.git' },
		single_file_support = true,
	}

	vim.lsp.enable 'rust-analyzer'
end


return M
