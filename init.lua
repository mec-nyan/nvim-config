--[[
--
-- Neovim-config.
--
-- A fully featured, configuration only Neovim setup relying solely on Neovim's
-- powerful built-in features.
--
-- This config aims to be easy to modify and expand.  If desired, plugins can
-- easily be added using Neovim's built-in package manager.
--
-- The organisation of this config is a little bit different than other,
-- grouping related options together.  Instead of placing all 'options'
-- (`vim.o`) and then all key mappings, etc, I've decided to organise it in
-- groups of related functionality.  I.e. completion related functionality is in
-- one group, LSP is in another group, colours are in another group, etc.  Each
-- group will have all the required settings (mappings, options, autocommands,
-- etc) in one place.  Hope that makes sense.
--
-- Without any further ado, let's get started.
--
--]]

-- Small set of options/configuration that must run before any other options
-- should go here:
require 'initial_setup'

-- General key mappings.
require 'keymappings'

-- Your colorscheme and modifications to colours and highlighting groups:
require 'colours'

-- Neovim's built-in terminal.
require 'terminal'

-- Completion
require 'completion'

-- Explorer
require 'explore'
