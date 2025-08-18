#!/bin/bash

# ──────────────────────────────────────────────────────────────
# Script to:
# - Detect if using apt or pacman
# - Install: git, yay (if pacman), snapd, flatpak
# - Install clipboard utilities based on session type (Wayland/X11)
# - Prompt for sudo once and keep it alive
# ──────────────────────────────────────────────────────────────

# Ask for sudo password up front
if sudo -v; then
    # Keep sudo alive while the script runs
    while true; do
        sudo -n true
        sleep 60
    done &
    SUDO_KEEPALIVE_PID=$!
else
    echo "❌ Failed to obtain sudo privileges."
    exit 1
fi

# Cleanup sudo keep-alive loop on exit
trap 'kill $SUDO_KEEPALIVE_PID' EXIT

# ──────────────────────────────────────────────────────────────
# Helper: Check if a command exists
is_installed() {
    command -v "$1" &> /dev/null
}

# Helper: Detect X11 or Wayland
detect_display_protocol() {
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        echo "wayland"
    elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
        echo "x11"
    else
        if [ -n "$WAYLAND_DISPLAY" ]; then
            echo "wayland"
        elif [ -n "$DISPLAY" ]; then
            echo "x11"
        else
            echo "unknown"
        fi
    fi
}

# ──────────────────────────────────────────────────────────────
# Install tools on apt-based systems
install_with_apt() {
    echo "📦 Using apt package manager"
    sudo apt update

    # Install base tools
    for pkg in git snapd flatpak; do
        if ! is_installed "$pkg"; then
            echo "Installing $pkg..."
            sudo apt install -y "$pkg"
        else
            echo "✔️ $pkg already installed."
        fi
    done

    # Install snapd and enable its service
    if is_installed snap; then
        sudo systemctl enable --now snapd.socket
        sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null
    else
        sudo apt install -y snapd
        sudo systemctl enable --now snapd.socket
        sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null
    fi

    # Install Flatpak
    if ! is_installed flatpak; then
        echo "Installing flatpak..."
        sudo apt install -y flatpak
    else
        echo "✔️ flatpak already installed."
    fi

    # Install flatseal via flatpak
    if ! flatpak list | grep -q flatseal; then
        echo "Installing Flatseal via flatpak..."
        flatpak install -y flathub com.github.tchx84.Flatseal
    else
        echo "✔️ Flatseal already installed."
    fi

    # Clipboard tools
    if [ "$1" = "wayland" ]; then
        if ! is_installed wl-copy; then
            echo "Installing wl-clipboard..."
            sudo apt install -y wl-clipboard
        else
            echo "✔️ wl-clipboard already installed."
        fi
    elif [ "$1" = "x11" ]; then
        for tool in xclip xsel; do
            if ! is_installed "$tool"; then
                echo "Installing $tool..."
                sudo apt install -y "$tool"
            else
                echo "✔️ $tool already installed."
            fi
        done
    fi
}

# ──────────────────────────────────────────────────────────────
# Install tools on pacman-based systems
install_with_pacman() {
    echo "📦 Using pacman package manager"
    sudo pacman -Sy --noconfirm

    # Install git
    if ! is_installed git; then
        echo "Installing git..."
        sudo pacman -S --noconfirm git
    else
        echo "✔️ git already installed."
    fi

    # Install base-devel if missing (needed for yay)
    if ! pacman -Qi base-devel &>/dev/null; then
        echo "Installing base-devel..."
        sudo pacman -S --noconfirm base-devel
    else
        echo "✔️ base-devel already installed."
    fi

    # Install yay (AUR helper)
    if ! is_installed yay; then
        echo "Installing yay from AUR..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay || exit
        makepkg -si --noconfirm
        cd - || exit
        rm -rf /tmp/yay
    else
        echo "✔️ yay already installed."
    fi

    # Install snapd from AUR
    if ! is_installed snap; then
        echo "Installing snapd via yay..."
        yay -S --noconfirm snapd
        sudo systemctl enable --now snapd.socket
        sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null
    else
        echo "✔️ snapd already installed."
    fi

    # Install flatpak
    if ! is_installed flatpak; then
        echo "Installing flatpak..."
        sudo pacman -S --noconfirm flatpak
    else
        echo "✔️ flatpak already installed."
    fi

    # Install flatseal via flatpak
    if ! flatpak list | grep -q flatseal; then
        echo "Installing Flatseal via flatpak..."
        flatpak install -y flathub com.github.tchx84.Flatseal
    else
        echo "✔️ Flatseal already installed."
    fi

    # Clipboard tools
    if [ "$1" = "wayland" ]; then
        if ! is_installed wl-copy; then
            echo "Installing wl-clipboard..."
            sudo pacman -S --noconfirm wl-clipboard
        else
            echo "✔️ wl-clipboard already installed."
        fi
    elif [ "$1" = "x11" ]; then
        for tool in xclip xsel; do
            if ! is_installed "$tool"; then
                echo "Installing $tool..."
                sudo pacman -S --noconfirm "$tool"
            else
                echo "✔️ $tool already installed."
            fi
        done
    fi
}

# ──────────────────────────────────────────────────────────────
# Main logic

SESSION_TYPE=$(detect_display_protocol)
echo "🖥️ Detected session type: $SESSION_TYPE"

if is_installed pacman; then
    install_with_pacman "$SESSION_TYPE"
elif is_installed apt; then
    install_with_apt "$SESSION_TYPE"
else
    echo "❌ Unsupported package manager. Only 'apt' and 'pacman' are supported."
    exit 1
fi

echo "✅ All required tools are installed or already present."

