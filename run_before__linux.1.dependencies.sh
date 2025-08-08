#!/bin/bash

# Ensure elevated privileges
sudo -v

# Install wl-clipboard if on wayland
# Check if the session is Wayland
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  echo "ensuring wl-clipboard is available..."
  if ! command -v wl-copy >/dev/null 2>&1; then
    echo "ensuring wl-clipboard is available"
    sudo apt-get update -qq >/dev/null
    sudo apt-get install -y -qq wl-clipboard >/dev/null
  fi
fi

# Install snap and flatpak if they aren't already installed
echo "ensuring curl, wget, flatpak, and snap are available..."
command -v curl >/dev/null 2>&1 || { sudo apt update && sudo apt install -y curl && echo "curl installed."; } || echo "curl already installed."
command -v wget >/dev/null 2>&1 || { sudo apt update && sudo apt install -y wget && echo "wget installed."; } || echo "wget already installed."
command -v flatpak >/dev/null 2>&1 || { sudo apt update && sudo apt install -y flatpak && echo "Flatpak installed."; } || echo "Flatpak already installed."
command -v snap >/dev/null 2>&1 || { sudo apt update && sudo apt install -y snapd && echo "Snap installed."; } || echo "Snap already installed."
flatpak remote-list | grep -q flathub || flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
