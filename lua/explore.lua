--[[
--
--  Netrw setting (file explorer).
--
--]]

local setkey = vim.keymap.set

-- Hide banner at startup
vim.g.netrw_banner = 0

-- Other options for netrw
vim.g.netrw_liststyle = 3

-- Explore in current window
setkey('n', '<leader>e', '<cmd>Explore<cr>', { desc = 'files' })

-- Explore in horizontal split
setkey('n', '<leader>he', '<cmd>Sexplore<cr>', { desc = 'files' })

-- Explore in vertical split
setkey('n', '<leader>ve', '<cmd>Vexplore<cr>', { desc = 'files' })
