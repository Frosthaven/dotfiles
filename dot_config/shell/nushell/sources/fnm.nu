# Add FNM to PATH ENV ---------------------------------------------------------
# -----------------------------------------------------------------------------

use std "path add"

# Add fnm install location to PATH
if $nu.os-info.name == 'macos' {
    path add "/opt/homebrew/bin"
} else {
    path add ($env.HOME | path join ".local" "share" "fnm")
}

# Add Multishell to PATH ENV --------------------------------------------------
# -----------------------------------------------------------------------------

# Load fnm environment variables (JSON format)
fnm env --json | from json | load-env

# Add multishell path to PATH
path add $env.FNM_MULTISHELL_PATH

# Prepend bin inside multishell path (non-Windows)
$env.PATH = $env.PATH | prepend (
    $env.FNM_MULTISHELL_PATH | path join (if $nu.os-info.name == 'windows' {""} else {"bin"})
)

# Sync Node Version on Directory Changes --------------------------------------
# -----------------------------------------------------------------------------

# 5. Hook: auto-use Node version if file present and not in home directory
# $env.config.hooks.env_change.PWD = (
#     $env.config.hooks.env_change.PWD? | append {
#         condition: {|| true }
#         code: {||
#             if (['.nvmrc' '.node-version' 'package.json'] | any {|el| $el | path exists}) {
#                 ^fnm use --install-if-missing
#             }
#         }
#     }
# )
