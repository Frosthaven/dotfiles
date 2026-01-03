# Identity Configuration (SSH, Git, Rclone)

This document explains how SSH keys, git config, and rclone are managed in this dotfiles setup.

## Overview

- **SSH keys**: Stored in Proton Pass, loaded into SSH agent on shell start
- **SSH config**: Managed by Chezmoi (`~/.ssh/config`) - encrypted with age
- **Git config**: Managed by Chezmoi with conditional includes for multiple identities - encrypted with age
- **Rclone config**: Encrypted by rclone, synced by Chezmoi, password stored in Proton Pass

**Note:** SSH config, git config, and rclone config are only applied for the repository owner (determined by the prompt during `chezmoi init`). These files are encrypted with age to protect identity information.

## First-Time Setup

### For Repository Owner

Identity files are encrypted with age. Before running `chezmoi apply`:

1. **Install age** (encryption tool):
   | Platform | Command |
   |----------|---------|
   | Arch | `sudo pacman -S age` |
   | macOS | `brew install age` |
   | Windows | `winget install FiloSottile.age` |

2. **Install Proton Pass CLI** (installed automatically via Chezmoi packages, or manually):
   | Platform | Command |
   |----------|---------|
   | Arch | `yay -S proton-pass-cli-bin` |
   | macOS | `brew install protonpass/tap/pass-cli` |
   | Windows | Download from proton.me |

3. **Login to Proton Pass**:
   ```bash
   pass-cli login
   ```

4. **Fetch the age decryption key**:
   ```bash
   mkdir -p ~/.config/chezmoi
   pass-cli item view --vault-name "Personal" --item-title "chezmoi/age-key" --field private_key > ~/.config/chezmoi/key.txt
   chmod 600 ~/.config/chezmoi/key.txt
   ```

5. **Run chezmoi**:
   ```bash
   chezmoi init <repo-url>   # Answer 'y' when prompted if you're the repo owner
   chezmoi apply
   ```

### For Others

If you're not the repository owner, identity files are skipped. Just run:

```bash
chezmoi init <repo-url>   # Answer 'n' when prompted
chezmoi apply
```

You'll need to set up your own git config, SSH config, and rclone config.

### Verify Setup

```bash
ssh-add -l          # Should list your SSH keys
rclone listremotes  # Should list your remotes (fetches password on first use)
```

## SSH Keys

SSH keys are stored in Proton Pass and loaded into the SSH agent automatically on shell start.

### Add a new SSH key

1. Add key to Proton Pass (GUI or CLI) - any vault works
2. Reload keys: `pass-cli ssh-agent load` (or restart shell)
3. Update `~/.ssh/config` if needed:
   ```bash
   chezmoi edit ~/.ssh/config
   chezmoi apply
   ```

### How it works

- Shell startup checks if keys are already in agent (fast ~2ms check)
- If agent is empty and you're logged into Proton Pass, keys are loaded automatically
- No private key files are stored on disk - they live only in Proton Pass
- SSH config file is encrypted with age in the chezmoi repository

### Edit SSH config

Since SSH config is encrypted, use `chezmoi edit`:

```bash
chezmoi edit ~/.ssh/config
```

Or edit the live file and re-add:

```bash
vim ~/.ssh/config
chezmoi re-add ~/.ssh/config   # Re-encrypts and updates chezmoi source
```

## Git Config

Git uses conditional includes for multiple identities based on repository path.

### Files

| File | Purpose |
|------|---------|
| `~/.gitconfig` | Main config with conditional includes |
| `~/.gitconfigs/personal.gitconfig` | Personal identity |
| `~/.gitconfigs/iww.gitconfig` | Work identity |
| `~/.gitignore_global` | Global gitignore patterns |

### Edit config

Since git config files are encrypted, use `chezmoi edit` which handles decryption/encryption automatically:

```bash
chezmoi edit ~/.gitconfig                      # Main config
chezmoi edit ~/.gitconfigs/personal.gitconfig  # Personal identity
chezmoi edit ~/.gitconfigs/iww.gitconfig       # Work identity
```

Changes take effect after running `chezmoi apply`, or edit the live file directly and re-add:

```bash
vim ~/.gitconfig
chezmoi re-add ~/.gitconfig   # Re-encrypts and updates chezmoi source
```

### Add a new identity

1. Create profile:
   ```bash
   chezmoi edit ~/.gitconfigs/newprofile.gitconfig
   ```

2. Add content:
   ```ini
   [user]
     name = Your Name
     email = your@email.com
   ```

3. Add conditional include to `~/.gitconfig`:
   ```ini
   [IncludeIf "gitdir:**/repos-newprofile/**"]
     path = ~/.gitconfigs/newprofile.gitconfig
   ```

4. Apply: `chezmoi apply`

## Rclone

Rclone config is encrypted with a password stored in Proton Pass at `pass://Personal/rclone/password`.

### How it works

- Rclone password is lazy-loaded on first `rclone` command
- A shell wrapper function fetches the password from Proton Pass and sets `RCLONE_CONFIG_PASS`
- Subsequent `rclone` commands in the same session reuse the cached password

### Edit rclone config

Use the helper function that automatically syncs changes to chezmoi:

```bash
rclone-config
```

This runs `rclone config` and then `chezmoi re-add ~/.config/rclone/rclone.conf`.

### Manual edit

```bash
rclone config
chezmoi re-add ~/.config/rclone/rclone.conf
```

### Add a new remote

```bash
rclone-config   # Opens rclone config wizard, syncs to chezmoi when done
```

## Syncing Changes

After editing configs, sync to other machines:

```bash
chezmoi git add -A
chezmoi git commit -m "Update configs"
chezmoi git push
```

On other machines:

```bash
chezmoi update
```

## Troubleshooting

### SSH keys not loading?

```bash
pass-cli info       # Check if logged in
pass-cli login      # Login if needed
pass-cli ssh-agent load
```

### Rclone asking for password?

The password is fetched automatically from Proton Pass on first use. If prompted:

```bash
pass-cli info   # Check if logged in
pass-cli login  # Login if needed
```

### Git using wrong identity?

Check which config is being used:

```bash
git config user.name
git config user.email
```

Verify the repo path matches a conditional include pattern in `~/.gitconfig`.

## Quick Reference

| Task | Command |
|------|---------|
| List SSH keys | `ssh-add -l` |
| Reload SSH keys | `pass-cli ssh-agent load` |
| List rclone remotes | `rclone listremotes` |
| Edit rclone config | `rclone-config` |
| Edit SSH config | `chezmoi edit ~/.ssh/config` |
| Edit git config | `chezmoi edit ~/.gitconfig` |
| Check Proton Pass status | `pass-cli info` |
