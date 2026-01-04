# pass-ssh-unpack

Extract SSH keys from Proton Pass to local files and generate SSH config.

## Overview

`pass-ssh-unpack` is a cross-platform Rust CLI tool that pulls SSH keys stored in your Proton Pass vaults, saves them to disk with proper permissions, generates matching SSH config entries, and optionally syncs rclone SFTP remotes.

**Key features:**
- Cross-platform (Linux, macOS, Windows)
- Incremental updates (only updates entries for unpacked keys)
- Auto-prune (removes config entries whose key files no longer exist)
- Wildcard matching for vault names and item titles
- Machine-specific key filtering (e.g., `github/hostname`)
- Portable paths using SSH's `%d` token
- Password-only entries (items without private keys still get config entries)
- Encrypted rclone config support
- Progress indicators with spinners and progress bars

## Requirements

- [Proton Pass CLI](https://proton.me/support/pass-cli) (`pass-cli`)
- OpenSSH (`ssh-keygen`)
- [rclone](https://rclone.org/) (optional, for SFTP remote sync)
- Logged into Proton Pass (`pass-cli login`)

## Installation

Install via cargo:

```bash
cargo install pass-ssh-unpack
```

The shell wrappers in chezmoi automatically find and call the binary, adding chezmoi sync functionality on top.

## Usage

```bash
pass-ssh-unpack [OPTIONS]
```

### Options

CLI options override corresponding config file settings.

| Option | Short | Description |
|--------|-------|-------------|
| `--vault <PATTERN>` | `-v` | Vault(s) to process (repeatable, supports wildcards) |
| `--item <PATTERN>` | `-i` | Item title pattern(s) (repeatable, supports wildcards) |
| `--full` | `-f` | Full regeneration (clear config first) |
| `--dry-run` | | Show what would be done without making changes |
| `--quiet` | `-q` | Suppress output |
| `--ssh` | | Only process SSH keys (skip rclone sync) |
| `--rclone` | | Only process rclone remotes (skip SSH extraction) |
| `--purge` | | Remove all managed SSH keys and rclone remotes |
| `--config <PATH>` | `-c` | Custom config file path |
| `--output-dir <PATH>` | `-o` | Override SSH output directory |
| `--sync-public-key <MODE>` | | Override public key sync mode (never/if-empty/always) |
| `--rclone-password-path <PATH>` | | Override rclone password path in Proton Pass |
| `--always-encrypt` | | Force rclone config encryption after operations |
| `--help` | `-h` | Show help |
| `--version` | `-V` | Show version |

### Examples

```bash
# Extract all SSH keys from all vaults
pass-ssh-unpack

# Extract all keys from a specific vault
pass-ssh-unpack -v Personal

# Extract from multiple vaults
pass-ssh-unpack -v Personal -v "Dragon Servers"

# Extract from vaults matching a pattern
pass-ssh-unpack -v "Dragon*"

# Extract keys matching a pattern
pass-ssh-unpack -i 'github/*'

# Extract keys matching multiple patterns
pass-ssh-unpack -i 'inmotion*' -i 'thedragon.dev'

# Combine vault and item title patterns
pass-ssh-unpack -v "Dragon*" -i '*.dev'

# Full regeneration (clears config first)
pass-ssh-unpack --full

# Only process SSH keys (skip rclone)
pass-ssh-unpack --ssh

# Only process rclone remotes (skip SSH)
pass-ssh-unpack --rclone

# Purge all managed data without regenerating
pass-ssh-unpack --purge

# Quiet mode (for scripting)
pass-ssh-unpack -q
```

## Configuration

On first run, a default config file is created at `~/.config/pass-ssh-unpack/config.toml`:

```toml
# Directory where SSH keys and config are written
ssh_output_dir = "~/.ssh/proton-pass"

# Default vault filter(s) - applied when no --vault flag is given
default_vaults = []

# Default item filter(s) - applied when no --item flag is given
default_items = []

# When to sync generated public keys back to Proton Pass
# Options: "never", "if_empty" (default), "always"
sync_public_key = "if_empty"

[rclone]
# Enable rclone SFTP remote sync
enabled = true

# Path in Proton Pass to rclone config password (if encrypted)
password_path = ""

# Always ensure rclone config is encrypted after operations
always_encrypt = false
```

## Proton Pass SSH Key Structure

Each SSH key item in Proton Pass should have:

### Required Fields

| Field | Description |
|-------|-------------|
| `content.title` | Item name (e.g., `github/cachycosmic`) |
| `content.content.SshKey.private_key` | The private key content (can be empty for password auth) |

### Extra Fields (Custom)

Add these as custom text fields in Proton Pass:

| Field Name | Description | Example |
|------------|-------------|---------|
| `Host` | SSH hostname for config **(required)** | `github.com` |
| `Username` | SSH user for config | `git` |
| `Aliases` | Comma-separated alias hostnames | `gh, github` |

If `Aliases` is empty, the item title is used as an alias.

## Generated Files

### Directory Structure

```
~/.ssh/proton-pass/
├── config              # SSH config file (Include this in ~/.ssh/config)
├── VaultName/
│   ├── key-title       # Private key (chmod 600)
│   └── key-title.pub   # Public key
└── AnotherVault/
    └── ...
```

### SSH Config Format

```ssh-config
# =============================================================================
# DO NOT EDIT THIS FILE - IT IS AUTO-GENERATED BY pass-ssh-unpack
# =============================================================================

Host github.com
    IdentityFile "%d/.ssh/proton-pass/Personal/github-cachycosmic"
    IdentitiesOnly yes
    User git

# Alias of github.com
Host gh
    IdentityFile "%d/.ssh/proton-pass/Personal/github-cachycosmic"
    IdentitiesOnly yes
    User git
```

### Using the Config

Add this line to your `~/.ssh/config`:

```ssh-config
Include ~/.ssh/proton-pass/config
```

## Behavior

### Incremental Updates (default)

Running without `--full` preserves existing config entries and key files. Only entries for keys that are actually unpacked are updated.

### Full Regeneration (`--full`)

Running with `--full` deletes the entire `~/.ssh/proton-pass` folder first, then regenerates everything from scratch.

### Purge Only (`--purge`)

Running with `--purge` removes all managed data without regenerating:
1. Deletes the entire `~/.ssh/proton-pass/` folder
2. Deletes all rclone remotes with `description = "managed by pass-ssh-unpack"`
3. Exits without extracting any keys

### Auto-Prune

On every run, entries whose referenced key files don't exist on disk are automatically removed from the config.

### Machine-Specific Keys

If an item title contains a `/` (e.g., `github/cachycosmic`), the part after the last `/` is compared to the current hostname. The key is only extracted if they match (case-insensitive).

### Public Key Generation

If the `public_key` field in Proton Pass is empty, `pass-ssh-unpack` generates the public key from the private key and attempts to save it back to Proton Pass.

## Rclone Integration

When `rclone` is available and configured, `pass-ssh-unpack` automatically creates SFTP remotes for each SSH entry.

### Requirements

- `rclone` command available in PATH
- rclone config password stored in Proton Pass (optional, for encrypted configs)

### Generated Remotes

For each SSH entry with a private key:

```ini
[thedragon.dev]
type = sftp
host = thedragon.dev
user = root
key_file = ~/.ssh/proton-pass/Dragon Servers/thedragon.dev
description = managed by pass-ssh-unpack
```

For password-only entries (no private key):

```ini
[home.thedragon.dev]
type = sftp
host = home.thedragon.dev
user = frosthaven
ask_password = true
description = managed by pass-ssh-unpack
```

### Conflict Handling

Existing rclone remotes without the `description = "managed by pass-ssh-unpack"` marker are skipped to prevent overwriting user-created remotes.

### Auto-Prune Behavior

On every run:
- Managed SFTP remotes whose `key_file` no longer exists are deleted
- Managed alias remotes whose target remote was deleted are also deleted

## Chezmoi Integration

The shell wrappers automatically sync rclone config changes to chezmoi after running the binary:

1. If `~/.config/rclone/rclone.conf` is managed by chezmoi, it's re-added after changes
2. Changes are auto-committed with message "chore: update rclone config via pass-ssh-unpack"
3. If only 1 commit ahead of remote, changes are auto-pushed

This happens automatically when using the shell wrapper function. To skip chezmoi sync, use `--dry-run`.

## Troubleshooting

### "pass-cli not found"

Install the Proton Pass CLI from https://proton.me/support/pass-cli

### "Not logged into Proton Pass"

Run `pass-cli login` to authenticate.

### "ssh-keygen not found"

Install OpenSSH. On most systems this is pre-installed.

### Keys not appearing in config

1. Ensure the item has a `Host` field in extra_fields
2. Check if the item title has a machine suffix that doesn't match your hostname
3. Run with `--full` to do a clean regeneration

### Permission denied errors

SSH requires private keys to have strict permissions. The command sets `chmod 600` automatically, but if issues persist, verify permissions manually:

```bash
chmod 600 ~/.ssh/proton-pass/VaultName/key-name
```
