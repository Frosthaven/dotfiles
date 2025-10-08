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

source ./sources/_env_path.nu
source ./sources/themes/catppuccin-mocha.nu
source ./sources/cargo.nu
source ./sources/nvim-bob.nu
source ./sources/pnpm.nu
source ./sources/uv.nu
source ./sources/wezterm.nu
source ./sources/homebrew.nu
source ./sources/starship.nu
source ./sources/zoxide.nu
source ./sources/sf.nu
source ./sources/system-update.nu
source ./sources/functions-extra.nu
