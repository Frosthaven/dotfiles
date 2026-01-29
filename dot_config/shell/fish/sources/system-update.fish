# sysup: Update all system packages and tools
# Cross-platform system update script

function sysup
    # Refresh sudo credentials (non-Windows only)
    if test (uname) != "MINGW64_NT" -a (uname) != "CYGWIN_NT"
        sudo -v
    end

    # APT (Debian/Ubuntu)
    if command -q apt
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
    end

    # Pacman/Yay (Arch)
    if command -q pacman
        if command -q yay
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
        end
    end

    # Rust/Cargo
    if command -q cargo
        echo ""
        echo "🔄 Updating Rust & Cargo packages -----------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        echo "Updating Rust..."
        rustup update
        echo ""
        echo "Updating all global Cargo packages..."
        for pkg in (cargo install --list | grep -E '^[a-z0-9_-]+ v[0-9.]+:\$' | cut -d' ' -f1)
            cargo install $pkg
        end
    end

    # UV (Python)
    if command -q uv
        echo ""
        echo "🔄 Updating UV (Python) tools ---------------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        echo "Updating all UV tools..."
        uv tool upgrade --all
    end

    # Bun
    if command -q bun
        echo ""
        echo "🔄 Updating Bun -----------------------------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        echo "Updating Bun..."
        bun upgrade
    end

    # Node package managers
    set -l pkg_manager ""
    if command -q pnpm
        set pkg_manager "pnpm"
    else if command -q npm
        set pkg_manager "npm"
    else if command -q yarn
        set pkg_manager "yarn"
    end

    if test -n "$pkg_manager"
        echo ""
        echo "🔄 Updating Node packages ---------------------------------------"
        echo "------------------------------------------------------------------"
        echo ""
        echo "Updating $pkg_manager packages..."
        switch $pkg_manager
            case pnpm
                pnpm up -g
            case npm
                if test (uname) = "MINGW64_NT" -o (uname) = "CYGWIN_NT"
                    npm upgrade --global --force
                else
                    sudo npm upgrade --global --force
                end
            case yarn
                yarn global upgrade
        end
    else
        echo "⚠️  No package manager (pnpm, npm, or yarn) found in PATH."
    end

    # Snap
    if command -q snap
        echo ""
        echo "🔄 Updating Snap packages -------------------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        echo "Updating snapd..."
        sudo snap install core
        echo ""
        echo "Updating all Snap packages..."
        sudo snap refresh
    end

    # Flatpak
    if command -q flatpak
        echo ""
        echo "🔄 Updating Flatpak packages ----------------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        echo "Updating Flatpak..."
        sudo flatpak update --appstream -y
        echo ""
        echo "Updating all Flatpak remotes..."
        sudo flatpak update -y
    end

    # Mac App Store
    if command -q mas
        echo ""
        echo "🔄 Updating Mac App Store packages ----------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        echo "Updating Mac App Store apps..."
        if not mas upgrade
            echo ""
            echo "⚠️ MAS failed — restarting App Store services..."
            echo ""
            sudo killall installd storeaccountd storeassetd storedownloadd 2>/dev/null
            sleep 1
            echo "Retrying MAS update..."
            if not mas upgrade
                echo ""
                echo "❌ MAS upgrade failed after retry. Likely App Store login issue."
                echo "   Please open the App Store app and re-sign-in."
            end
        end
    end

    # Homebrew
    if command -q brew
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
    end

    # Chezmoi
    if command -q chezmoi
        echo ""
        echo "🔄 Updating Chezmoi configuration -----------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        chezmoi update
    end

    # Proton Pass SSH keys
    if command -q pass-cli
        echo ""
        echo "🔄 Syncing SSH keys from Proton Pass --------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        pass-ssh-unpack --vault "* Servers"
    end

    # Bob (Neovim version manager)
    if command -q bob
        echo ""
        echo "🔄 Updating Neovim --------------------------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        bob update nightly
        echo ""
    end

    # Neovim plugins
    if command -q nvim
        echo ""
        echo "🔄 Updating Neovim plugins ------------------------------------"
        echo "---------------------------------------------------------------"
        echo ""
        nvim --headless "+Lazy! update" "+MasonUpdate" +qa
        echo ""
    end

    # Komorebi (Windows tiling WM)
    if command -q komorebic
        echo ""
        echo "🔄 Updating Komorebic Application Rules -----------------------"
        echo "---------------------------------------------------------------"
        echo ""
        komorebic fetch-asc
    end

    echo ""
    echo "--------------------------------------------------------------"
    echo "✅ All system updates completed."
end
