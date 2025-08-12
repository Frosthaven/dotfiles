use std "path add"

# 1. Add fnm install location to PATH
if $nu.os-info.name == 'macos' {
    path add "/opt/homebrew/bin"
} else {
    path add ($env.HOME | path join ".local" "share" "fnm")
}

# 2. Load fnm environment variables (JSON format)
fnm env --json | from json | load-env

# 3. Add multishell path to PATH
path add $env.FNM_MULTISHELL_PATH

# 4. Prepend bin inside multishell path (non-Windows)
$env.PATH = $env.PATH | prepend (
    $env.FNM_MULTISHELL_PATH | path join (if $nu.os-info.name == 'windows' {""} else {"bin"})
)

# 5. Hook: auto-use Node version if file present and not in home directory
# $env.config.hooks.env_change.PWD = (
#     $env.config.hooks.env_change.PWD? | append {
#         condition: {|| true }
#         code: {||
#             if ($env.PWD != $env.HOME) and (['.nvmrc' '.node-version' 'package.json'] | any {|el| $el | path exists}) {
#                 ^fnm use --install-if-missing
#             }
#         }
#     }
# )
