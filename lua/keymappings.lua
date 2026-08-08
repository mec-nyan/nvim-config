--[[
--
--  General use key mappings.
--
--]]

local setkey = vim.keymap.set

-- Write
setkey('n', '<M-w>', '<cmd>write<cr>', { desc = '[n] write' })
setkey('i', '<M-w>', '<esc><cmd>write<cr>', { desc = '[i] write' })

-- Quit
setkey('n', '<M-q>', '<cmd>quit<cr>', { desc = '[n] quit' })
setkey('i', '<M-q>', '<esc><cmd>quit<cr>', { desc = '[i] quit' })

-- Windows, tabs
setkey('n', '<M-o>', '<cmd>only<cr>', { desc = '[n] only' })

-- Movement
setkey('n', 'ge', 'G', { desc = '[move] end of file' })

-- Search
setkey('n', '<leader>l', '<cmd>nohlsearch<cr>', { desc = '[n] clear searh highlight' })


return {}
