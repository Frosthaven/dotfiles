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
