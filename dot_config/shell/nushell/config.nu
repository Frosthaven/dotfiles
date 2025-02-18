# config.nu
#
# Installed by:
# version = "0.102.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html

# disable the welcome message
$env.config.show_banner = false

source ./sources/themes/catppuccin-mocha.nu
source ./sources/wezterm.nu
source ./sources/homebrew.nu
source ./sources/starship.nu
source ./sources/zoxide.nu
try { source ./sources/fnm.nu } catch {ignore} # macos/nvim complains
