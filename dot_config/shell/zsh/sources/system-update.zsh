# sysup: Update all system packages and tools
# Cross-platform system update script

sysup() {
    # Refresh sudo credentials (non-Windows only)
    if [[ "$OSTYPE" != "msys" ]] && [[ "$OSTYPE" != "cygwin" ]]; then
        sudo -v
    fi

    # APT (Debian/Ubuntu)
    if command -v apt &>/dev/null; then
        echo ""
        echo "🔄 Updating APT packages --------------------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        echo "Updating APT package lists..."
        sudo apt update
        echo ""
        echo "Upgrading all APT packages..."
        sudo apt upgrade -y
        echo ""
        echo "Performing cleanup..."
        sudo apt autoremove -y
    fi

    # Pacman/Yay (Arch)
    if command -v pacman &>/dev/null; then
        if command -v yay &>/dev/null; then
            echo ""
            echo "🔄 Updating Arch + AUR packages -------------------------------"
            echo "---------------------------------------------------------------"
            echo ""
            yay -Syu --noconfirm
        else
            echo ""
            echo "🔄 Updating Arch packages -------------------------------------"
            echo "---------------------------------------------------------------"
            echo ""
            sudo pacman -Syu --noconfirm
        fi
    fi

    # Rust/Cargo
    if command -v cargo &>/dev/null; then
        echo ""
        echo "🔄 Updating Rust & Cargo packages -----------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        echo "Updating Rust..."
        rustup update
        echo ""
        echo "Updating all global Cargo packages..."
        cargo install --list | grep -E '^[a-z0-9_-]+ v[0-9.]+:$' | cut -d' ' -f1 | xargs -I {} cargo install {}
    fi

    # UV (Python)
    if command -v uv &>/dev/null; then
        echo ""
        echo "🔄 Updating UV (Python) tools ---------------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        echo "Updating all UV tools..."
        uv tool upgrade --all
    fi

    # Node package managers
    local pkg_manager=""
    if command -v pnpm &>/dev/null; then
        pkg_manager="pnpm"
    elif command -v npm &>/dev/null; then
        pkg_manager="npm"
    elif command -v yarn &>/dev/null; then
        pkg_manager="yarn"
    fi

    if [[ -n "$pkg_manager" ]]; then
        echo ""
        echo "🔄 Updating Node packages ---------------------------------------"
        echo "------------------------------------------------------------------"
        echo ""
        echo "Updating $pkg_manager packages..."
        case "$pkg_manager" in
            pnpm) pnpm up -g ;;
            npm)
                if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
                    npm upgrade --global --force
                else
                    sudo npm upgrade --global --force
                fi
                ;;
            yarn) yarn global upgrade ;;
        esac
    else
        echo "⚠️  No package manager (pnpm, npm, or yarn) found in PATH."
    fi

    # Snap
    if command -v snap &>/dev/null; then
        echo ""
        echo "🔄 Updating Snap packages -------------------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        echo "Updating snapd..."
        sudo snap install core
        echo ""
        echo "Updating all Snap packages..."
        sudo snap refresh
    fi

    # Flatpak
    if command -v flatpak &>/dev/null; then
        echo ""
        echo "🔄 Updating Flatpak packages ----------------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        echo "Updating Flatpak..."
        sudo flatpak update --appstream -y
        echo ""
        echo "Updating all Flatpak remotes..."
        sudo flatpak update -y
    fi

    # Windows-specific (when running in Git Bash/MSYS2)
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        # Scoop
        if command -v scoop &>/dev/null; then
            echo ""
            echo "🔄 Updating Scoop packages ------------------------------------"
            echo "---------------------------------------------------------------"
            echo ""
            scoop update
        fi

        # Chocolatey
        if command -v choco &>/dev/null; then
            echo ""
            echo "🔄 Updating Chocolatey packages -------------------------------"
            echo "---------------------------------------------------------------"
            echo ""
            powershell -Command "Start-Process -FilePath choco -ArgumentList 'upgrade all -y' -Verb RunAs -Wait"
        fi

        # Winget
        if command -v winget &>/dev/null; then
            echo ""
            echo "🔄 Updating Winget packages -----------------------------------"
            echo "---------------------------------------------------------------"
            echo ""
            powershell -Command "Start-Process winget -ArgumentList 'upgrade','--all','--include-unknown' -Verb RunAs -Wait"
        fi
    fi

    # Mac App Store
    if command -v mas &>/dev/null; then
        echo ""
        echo "🔄 Updating Mac App Store packages ----------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        echo "Updating Mac App Store apps..."
        if ! mas upgrade; then
            echo ""
            echo "⚠️ MAS failed — restarting App Store services..."
            echo ""
            sudo killall installd storeaccountd storeassetd storedownloadd 2>/dev/null
            sleep 1
            echo "Retrying MAS update..."
            if ! mas upgrade; then
                echo ""
                echo "❌ MAS upgrade failed after retry. Likely App Store login issue."
                echo "   Please open the App Store app and re-sign-in."
            fi
        fi
    fi

    # Homebrew
    if command -v brew &>/dev/null; then
        echo ""
        echo "🔄 Updating Homebrew packages ---------------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        echo "Updating Homebrew..."
        brew update
        echo ""
        echo "Updating all Homebrew packages..."
        brew upgrade --greedy
        echo ""
        echo "Performing cleanup..."
        brew cleanup
    fi

    # Chezmoi
    if command -v chezmoi &>/dev/null; then
        echo ""
        echo "🔄 Updating Chezmoi configuration -----------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        chezmoi update
    fi

    # Proton Pass SSH keys
    if command -v pass-cli &>/dev/null; then
        echo ""
        echo "🔄 Syncing SSH keys from Proton Pass --------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        pass-ssh-unpack
    fi

    # Bob (Neovim version manager)
    if command -v bob &>/dev/null; then
        echo ""
        echo "🔄 Updating Neovim --------------------------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        bob update nightly
        echo ""
    fi

    # Neovim plugins
    if command -v nvim &>/dev/null; then
        echo ""
        echo "🔄 Updating Neovim plugins ------------------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        nvim --headless "+Lazy! update" "+MasonUpdate" +qa
        echo ""
    fi

    # Komorebi (Windows tiling WM)
    if command -v komorebic &>/dev/null; then
        echo ""
        echo "🔄 Updating Komorebic Application Rules -----------------------"
        echo "---------------------------------------------------------------"
        echo ""
        komorebic fetch-asc
    fi

    echo ""
    echo "--------------------------------------------------------------"
    echo "✅ All system updates completed."
}
