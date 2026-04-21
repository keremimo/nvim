-- Core settings
require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.commands'
require('config.profiles').setup()

-- Plugins
require('plugins').setup()

-- vim: ts=2 sts=2 sw=2 et
