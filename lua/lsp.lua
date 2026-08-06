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

------------------------------
-- Config lsp kind symbols. --
------------------------------

local function config_lspkind()
	local my_kind = {
		Text = 'abc',
		Method = 'x.f()',
		Function = 'f(x)',
		Constructor = 'C()',
		Field = 'x.a',
		Variable = 'var',
		Class = 'Cls',
		Interface = 'I{}',
		Module = 'mod',
		Property = 'prop',
		Unit = 'unit',
		Value = 'val',
		Enum = 'enum',
		Keyword = 'kwrd',
		Snippet = 'snip',
		Color = 'rgb',
		File = 'file',
		Reference = 'x&',
		Folder = 'dir',
		EnumMember = 'enum',
		Constant = 'cons',
		Struct = '{}',
		Event = 'ev',
		Operator = 'op',
		TypeParameter = '<T>',
	}

	local cik = vim.lsp.protocol.CompletionItemKind

	for k, v in pairs(my_kind) do
		cik[cik[k]] = v
	end
end


local function config_lang_servers()
	config_rust_analyzer()
	config_clangd()
	config_gopls()
	config_pylsp()
end

local function set_autocmds()
	vim.api.nvim_create_autocmd('LspAttach', {
		callback = function(ev)
			local bufnr = vim.api.nvim_get_current_buf()

			vim.lsp.completion.enable(true, ev.data.client_id, bufnr, {
				autotrigger = true,
				convert = function(item)
					return { abbr = item.label:gsub('%b()', '') }
				end,
			})

			vim.api.nvim_create_autocmd('BufWritePre', {
				callback = function()
					vim.lsp.buf.format()
				end
			})

			vim.lsp.inlay_hint.enable(true)
		end,
	})
end


return {
	setup = function()
		config_lspkind()
		config_lang_servers()
		set_autocmds()
	end,
}
