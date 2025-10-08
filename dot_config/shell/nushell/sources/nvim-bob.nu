# Add nvim-bob (stable and nightly) to PATH in Nu shell
$env.PATH = ($env.PATH | append ($env.HOME + "/.local/share/bob/nvim-bin"))
$env.PATH = ($env.PATH | append ($env.HOME + "/.local/share/bob/nightly/bin"))
