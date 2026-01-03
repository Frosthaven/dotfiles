# Repo Owner Setup

This guide is for Frosthaven only. Identity files (SSH config, git config, rclone) are encrypted with age.

## New Machine Setup

1. **Install age and Proton Pass CLI**:

   | Platform | Commands |
   |----------|----------|
   | Arch | `sudo pacman -S age` and `yay -S proton-pass-cli-bin` |
   | macOS | `brew install age protonpass/tap/pass-cli` |
   | Windows | `winget install FiloSottile.age Proton.ProtonPass` |

2. **Login to Proton Pass**:
   ```bash
   pass-cli login
   ```

3. **Fetch the age decryption key**:
   ```bash
   mkdir -p ~/.config/chezmoi
   pass-cli item view --vault-name "Personal" --item-title "chezmoi/age-key" --field private_key > ~/.config/chezmoi/key.txt
   chmod 600 ~/.config/chezmoi/key.txt
   ```

4. **Run chezmoi**:
   ```bash
   chezmoi init https://github.com/Frosthaven/dotfiles
   # Answer 'y' when prompted
   chezmoi apply
   ```

5. **Restart your shell** - SSH keys will load automatically from Proton Pass.

## Managing Identity Files

For details on editing SSH config, git identities, and rclone, see [IDENTITY.md](IDENTITY.md).

## Quick Reference

| Task | Command |
|------|---------|
| List SSH keys | `ssh-add -l` |
| Reload SSH keys | `pass-cli ssh-agent load` |
| Edit SSH config | `chezmoi edit ~/.ssh/config` |
| Edit git config | `chezmoi edit ~/.gitconfig` |
| Edit rclone config | `rclone-config` |
| Check Proton Pass status | `pass-cli info` |
