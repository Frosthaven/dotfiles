#!/bin/bash

# Install snap and flatpak if they aren't already installed
command -v curl >/dev/null 2>&1 || { sudo apt update && sudo apt install -y curl && echo "curl installed."; } || echo "curl already installed."
command -v wget >/dev/null 2>&1 || { sudo apt update && sudo apt install -y wget && echo "wget installed."; } || echo "wget already installed."
command -v flatpak >/dev/null 2>&1 || { sudo apt update && sudo apt install -y flatpak && echo "Flatpak installed."; } || echo "Flatpak already installed."
command -v snap >/dev/null 2>&1 || { sudo apt update && sudo apt install -y snapd && echo "Snap installed."; } || echo "Snap already installed."
flatpak remote-list | grep -q flathub || flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
