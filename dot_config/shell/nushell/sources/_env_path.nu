use std "path add"

# If $env.HOME is not defined, lets set it to the same as $env.USERPROFILE if it is defined
$env.HOME = $env.USERPROFILE

# $HOME/.local/bin is used by several binaries - zig, go, php, etc.
path add ($env.HOME | path join ".local" "bin")
