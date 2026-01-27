use std "path add"

# If $env.HOME is not defined, lets set it to the same as $env.USERPROFILE if it is defined
if ($nu.os-info.family == "windows") {
    $env.HOME = $env.USERPROFILE
}

# $HOME/.local/bin is used by several binaries - zig, go, php, etc.
path add ($env.HOME | path join ".local" "bin")

# $HOME/.local/share/pnpm is where pnpm installs global packages
path add ($env.HOME | path join ".local" "share" "pnpm")

# $HOME/.npm-global/bin is where npm installs global packages
path add ($env.HOME | path join ".npm-global" "bin")

# CUDA toolkit
if ("/opt/cuda/bin" | path exists) {
    path add "/opt/cuda/bin"
    $env.CUDA_HOME = "/opt/cuda"
}

# /usr/local/bin is used by system-wide installed binaries (rclone, etc.)
if ($nu.os-info.family == "unix") {
    path add "/usr/local/bin"
}

