use std "path add"

# $HOME/.local/bin is used by several binaries - zig, go, php, etc.
path add ($env.HOME | path join ".local" "bin")
