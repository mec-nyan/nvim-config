--[[
--
--  General use key mappings.
--
--]]

local setkey = vim.keymap.set

-- Write
setkey('n', '<M-w>', '<cmd>write<cr>', { desc = 'write (normal)' })
setkey('i', '<M-w>', '<esc><cmd>write<cr>', { desc = 'write (insert)' })

-- Quit
setkey('n', '<M-q>', '<cmd>quit<cr>', { desc = 'quit (normal)' })
setkey('i', '<M-q>', '<esc><cmd>quit<cr>', { desc = 'quit (normal)' })

-- Windows, tabs
setkey('n', '<M-o>', '<cmd>only<cr>', { desc = 'only' })

-- Movement
setkey('n', 'ge', 'G', { desc = 'end of file' })

-- Search
setkey('n', '<leader>l', { desc = 'clear searh highlight' })


return {}
