# config.nu
#
# Installed by:
# version = "0.102.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html

# disable the welcome message
$env.config.show_banner = false

source ./sources/themes/catppuccin-mocha.nu
source ./sources/wezterm.nu
source ./sources/homebrew.nu
source ./sources/starship.nu
source ./sources/zoxide.nu
source ./sources/sf.nu
try { source ./sources/fnm.nu } catch {ignore} # macos/nvim complains

def system-upgrade [] {
    echo "🔄 Updating APT packages..."
    sudo apt update;
    sudo apt upgrade -y;
    sudo apt autoremove -y;

    echo "🔄 Updating Snap packages..."
    if (which snap | is-empty) {
        echo "Snap not installed, skipping."
    } else {
        sudo snap refresh
    }

    echo "🔄 Updating Flatpak packages..."
    if (which flatpak | is-empty) {
        echo "Flatpak not installed, skipping."
    } else {
        flatpak update -y
    }

    echo "🔄 Updating winget packages..."
    if (which winget | is-empty) {
        echo "winget not installed, skipping."
    } else {
        winget upgrade --accept-source-agreements --accept-package-agreements --include-unknown
    }

    echo "🔄 Updating Chocolatey packages..."
    if (which choco | is-empty) {
        echo "Chocolatey not installed, skipping."
    } else {
        choco upgrade all -y
    }

    echo "🔄 Updating Scoop packages..."
    if (which scoop | is-empty) {
        echo "Scoop not installed, skipping."
    } else {
        scoop update *
    }

    echo "🔄 Updating Homebrew packages..."
    if (which brew | is-empty) {
        echo "Homebrew not installed, skipping."
    } else {
        brew update
        brew upgrade
        brew cleanup
    }

    echo "✅ All system updates completed."
}
