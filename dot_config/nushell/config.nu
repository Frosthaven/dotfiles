# config.nu
#
# Installed by:
# version = "0.102.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html

# disable osc133, which causes issues with wezterm
$env.config.shell_integration.osc133 = false

# disable the welcome message
$env.config.show_banner = false

# add brew to path
$env.PATH = ($env.PATH | append "/opt/homebrew/bin")

use ./starship.nu
use ./fnm.nu
use ./zoxide.nu

