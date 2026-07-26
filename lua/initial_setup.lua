--[[
--
--  These options/configuration must be set before any other config.
--
--]]

vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Let's set some common options first.
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.modeline = true
vim.o.hlsearch = true
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.swapfile = true
vim.o.showmode = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'number' -- or 'yes' as you like.
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300
vim.o.completeopt = 'menuone,preview,noselect'
vim.o.shortmess = vim.o.shortmess .. 'c'
vim.o.termguicolors = true
-- TODO: Replace with Unicode symbols.
vim.o.listchars = 'tab:> ,trail:_,nbsp:+,extends:>,precedes:<'
vim.o.list = true
vim.o.encoding = 'utf-8'
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.colorcolumn = '80,100'
vim.o.textwidth = 100
vim.o.autocomplete = true
vim.o.incsearch = true
vim.o.scrolloff = 4
vim.o.expandtab = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.foldmethod = 'syntax'
vim.o.foldenable = true
vim.o.foldlevel = 3
vim.o.foldcolumn = '1'
-- TODO: Replace with Unicode symbols.
vim.o.fillchars = 'fold: ,foldopen:+,foldclose:-,foldsep:|'
vim.o.laststatus = 3
vim.o.spelllang = 'en_gb'
vim.o.spell = true


-- Universal key mappings.
local setkey = vim.keymap.set

setkey('n', '<M-w>', '<cmd>write<cr>', { desc = 'write (normal)' })
setkey('i', '<M-w>', '<esc><cmd>write<cr>', { desc = 'write (insert)' })
setkey('n', '<M-q>', '<cmd>quit<cr>', { desc = 'quit (normal)' })
setkey('i', '<M-q>', '<esc><cmd>quit<cr>', { desc = 'quit (normal)' })

return {}
