# Identity Configuration (SSH, Git, Rclone)

This document explains how SSH keys, git config, and rclone are managed for the repo owner.

> **First-time setup?** See [OWNER.md](OWNER.md) first.

## Overview

- **SSH keys**: Stored in Proton Pass, loaded into SSH agent on shell start
- **SSH config**: Encrypted with age, managed by chezmoi
- **Git config**: Encrypted with age, uses conditional includes for multiple identities
- **Rclone config**: Encrypted by rclone, password stored in Proton Pass

## SSH Keys

SSH keys are stored in Proton Pass and loaded into the SSH agent automatically on shell start.

### How it works

- Shell startup checks if keys are already in agent (fast ~2ms check)
- If agent is empty and you're logged into Proton Pass, keys are loaded automatically
- No private key files are stored on disk - they live only in Proton Pass

### Add a new SSH key

1. Generate: `ssh-keygen -t ed25519 -C "your_email@example.com"`
2. Add public key to the service (GitHub, etc.)
3. Add private key to Proton Pass (paste into a hidden field)
4. Delete local key files: `rm ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub`
5. Reload: `pass-cli ssh-agent load`

### Edit SSH config

```bash
chezmoi edit ~/.ssh/config
chezmoi apply
```

Or edit directly and re-add:

```bash
vim ~/.ssh/config
chezmoi re-add ~/.ssh/config
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

```bash
chezmoi edit ~/.gitconfig                      # Main config
chezmoi edit ~/.gitconfigs/personal.gitconfig  # Personal identity
chezmoi edit ~/.gitconfigs/iww.gitconfig       # Work identity
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
   [includeIf "gitdir:**/repos-newprofile/**"]
     path = ~/.gitconfigs/newprofile.gitconfig
   ```

4. Apply: `chezmoi apply`

## Rclone

Rclone config is encrypted with a password stored in Proton Pass.

### How it works

- Password is lazy-loaded on first `rclone` command
- Shell wrapper fetches password from Proton Pass and sets `RCLONE_CONFIG_PASS`
- Subsequent commands in the same session reuse the cached password

### Edit rclone config

Use the helper function (syncs to chezmoi automatically):

```bash
rclone-config
```

Or manually:

```bash
rclone config
chezmoi re-add ~/.config/rclone/rclone.conf
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

```bash
pass-cli info   # Check if logged in
pass-cli login  # Login if needed
```

### Git using wrong identity?

```bash
git config user.name
git config user.email
```

Verify the repo path matches a conditional include pattern in `~/.gitconfig`.
