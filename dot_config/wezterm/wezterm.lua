local config = {}

config = require("lua/config/options").setup(config)
config = require("lua/config/appearance").setup(config)
config = require("lua/config/keymap").setup(config)
config = require("lua/config/events").setup(config)

return config
