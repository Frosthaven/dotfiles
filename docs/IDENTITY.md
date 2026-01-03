# Identity Configuration (SSH, Git, Rclone)

This document explains how SSH keys, git config, and rclone are managed in this dotfiles setup.

## Overview

- **SSH keys**: Stored in Proton Pass, loaded into SSH agent on shell start
- **SSH config**: Managed by Chezmoi (`~/.ssh/config`)
- **Git config**: Managed by Chezmoi with conditional includes for multiple identities
- **Rclone config**: Encrypted by rclone, synced by Chezmoi, password stored in Proton Pass

## First-Time Setup

### 1. Install Proton Pass CLI

Installed automatically via Chezmoi packages. Manual install if needed:

| Platform | Command |
|----------|---------|
| Arch | `yay -S proton-pass-cli-bin` |
| macOS | `brew install protonpass/tap/pass-cli` |
| Windows | Download from proton.me |

### 2. Login to Proton Pass

```bash
pass-cli login
```

### 3. Verify

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

```bash
# Edit directly (changes take effect immediately)
vim ~/.gitconfig
chezmoi re-add ~/.gitconfig   # Persist to chezmoi

# Or edit via chezmoi
chezmoi edit ~/.gitconfig
chezmoi apply
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
| Edit SSH config | `chezmoi edit ~/.ssh/config && chezmoi apply` |
| Edit git config | `vim ~/.gitconfig && chezmoi re-add ~/.gitconfig` |
| Check Proton Pass status | `pass-cli info` |
