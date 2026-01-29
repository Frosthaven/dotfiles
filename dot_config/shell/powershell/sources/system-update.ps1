# sysup: Update all system packages and tools
# Cross-platform system update script

function sysup {
    # Refresh sudo credentials (non-Windows only)
    if (-not $IsWindows) {
        sudo -v
    }

    # APT (Debian/Ubuntu)
    if (Get-Command apt -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "🔄 Updating APT packages --------------------------------------"
        Write-Host "---------------------------------------------------------------"
        Write-Host ""
        Write-Host "Updating APT package lists..."
        sudo apt update
        Write-Host ""
        Write-Host "Upgrading all APT packages..."
        sudo apt upgrade -y
        Write-Host ""
        Write-Host "Performing cleanup..."
        sudo apt autoremove -y
    }

    # Pacman/Yay (Arch)
    if (Get-Command pacman -ErrorAction SilentlyContinue) {
        if (Get-Command yay -ErrorAction SilentlyContinue) {
            Write-Host ""
            Write-Host "🔄 Updating Arch + AUR packages -------------------------------"
            Write-Host "---------------------------------------------------------------"
            Write-Host ""
            yay -Syu --noconfirm
        } else {
            Write-Host ""
            Write-Host "🔄 Updating Arch packages -------------------------------------"
            Write-Host "---------------------------------------------------------------"
            Write-Host ""
            sudo pacman -Syu --noconfirm
        }
    }

    # Rust/Cargo
    if (Get-Command cargo -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "🔄 Updating Rust & Cargo packages -----------------------------"
        Write-Host "---------------------------------------------------------------"
        Write-Host ""
        Write-Host "Updating Rust..."
        rustup update
        Write-Host ""
        Write-Host "Updating all global Cargo packages..."
        $packages = cargo install --list | Select-String -Pattern '^[a-z0-9_-]+ v[0-9.]+:$' | ForEach-Object { ($_ -split ' ')[0] }
        foreach ($pkg in $packages) {
            cargo install $pkg
        }
    }

    # UV (Python)
    if (Get-Command uv -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "🔄 Updating UV (Python) tools ---------------------------------"
        Write-Host "---------------------------------------------------------------"
        Write-Host ""
        Write-Host "Updating all UV tools..."
        uv tool upgrade --all
    }

    # Bun
    if (Get-Command bun -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "🔄 Updating Bun -----------------------------------------------"
        Write-Host "---------------------------------------------------------------"
        Write-Host ""
        Write-Host "Updating Bun..."
        bun upgrade
    }

    # Node package managers
    $pkgManager = $null
    if (Get-Command pnpm -ErrorAction SilentlyContinue) {
        $pkgManager = "pnpm"
    } elseif (Get-Command npm -ErrorAction SilentlyContinue) {
        $pkgManager = "npm"
    } elseif (Get-Command yarn -ErrorAction SilentlyContinue) {
        $pkgManager = "yarn"
    }

    if ($pkgManager) {
        Write-Host ""
        Write-Host "🔄 Updating Node packages ---------------------------------------"
        Write-Host "------------------------------------------------------------------"
        Write-Host ""
        Write-Host "Updating $pkgManager packages..."
        switch ($pkgManager) {
            "pnpm" { pnpm up -g }
            "npm" {
                if ($IsWindows) {
                    npm upgrade --global --force
                } else {
                    sudo npm upgrade --global --force
                }
            }
            "yarn" { yarn global upgrade }
        }
    } else {
        Write-Host "⚠️  No package manager (pnpm, npm, or yarn) found in PATH."
    }

    # Snap
    if (Get-Command snap -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "🔄 Updating Snap packages -------------------------------------"
        Write-Host "---------------------------------------------------------------"
        Write-Host ""
        Write-Host "Updating snapd..."
        sudo snap install core
        Write-Host ""
        Write-Host "Updating all Snap packages..."
        sudo snap refresh
    }

    # Flatpak
    if (Get-Command flatpak -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "🔄 Updating Flatpak packages ----------------------------------"
        Write-Host "---------------------------------------------------------------"
        Write-Host ""
        Write-Host "Updating Flatpak..."
        sudo flatpak update --appstream -y
        Write-Host ""
        Write-Host "Updating all Flatpak remotes..."
        sudo flatpak update -y
    }

    # Windows-specific package managers
    if ($IsWindows) {
        # Scoop
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            Write-Host ""
            Write-Host "🔄 Updating Scoop packages ------------------------------------"
            Write-Host "---------------------------------------------------------------"
            Write-Host ""
            scoop update
        }

        # Chocolatey
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Host ""
            Write-Host "🔄 Updating Chocolatey packages -------------------------------"
            Write-Host "---------------------------------------------------------------"
            Write-Host ""
            $process = Start-Process -FilePath choco -ArgumentList 'upgrade all -y' -Verb RunAs -PassThru
            $process.WaitForExit()
        }

        # Winget
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host ""
            Write-Host "🔄 Updating Winget packages -----------------------------------"
            Write-Host "---------------------------------------------------------------"
            Write-Host ""
            $process = Start-Process winget -ArgumentList 'upgrade','--all','--include-unknown' -Verb RunAs -PassThru
            $process.WaitForExit()
        }
    }

    # Mac App Store
    if (Get-Command mas -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "🔄 Updating Mac App Store packages ----------------------------"
        Write-Host "---------------------------------------------------------------"
        Write-Host ""
        Write-Host "Updating Mac App Store apps..."
        $result = mas upgrade
        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "⚠️ MAS failed — restarting App Store services..."
            Write-Host ""
            sudo killall installd storeaccountd storeassetd storedownloadd 2>$null
            Start-Sleep -Seconds 1
            Write-Host "Retrying MAS update..."
            mas upgrade
            if ($LASTEXITCODE -ne 0) {
                Write-Host ""
                Write-Host "❌ MAS upgrade failed after retry. Likely App Store login issue."
                Write-Host "   Please open the App Store app and re-sign-in."
            }
        }
    }

    # Homebrew
    if (Get-Command brew -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "🔄 Updating Homebrew packages ---------------------------------"
        Write-Host "---------------------------------------------------------------"
        Write-Host ""
        Write-Host "Updating Homebrew..."
        brew update
        Write-Host ""
        Write-Host "Updating all Homebrew packages..."
        brew upgrade --greedy
        Write-Host ""
        Write-Host "Performing cleanup..."
        brew cleanup
    }

    # Chezmoi
    if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "🔄 Updating Chezmoi configuration -----------------------------"
        Write-Host "---------------------------------------------------------------"
        Write-Host ""
        chezmoi update
    }

    # Proton Pass SSH keys
    if (Get-Command pass-cli -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "🔄 Syncing SSH keys from Proton Pass --------------------------"
        Write-Host "---------------------------------------------------------------"
        Write-Host ""
        pass-ssh-unpack --vault "* Servers"
    }

    # Bob (Neovim version manager)
    if (Get-Command bob -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "🔄 Updating Neovim --------------------------------------------"
        Write-Host "---------------------------------------------------------------"
        Write-Host ""
        bob update nightly
        Write-Host ""
    }

    # Neovim plugins
    if (Get-Command nvim -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "🔄 Updating Neovim plugins ------------------------------------"
        Write-Host "---------------------------------------------------------------"
        Write-Host ""
        nvim --headless "+Lazy! update" "+MasonUpdate" +qa
        Write-Host ""
    }

    # Komorebi (Windows tiling WM)
    if (Get-Command komorebic -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "🔄 Updating Komorebic Application Rules -----------------------"
        Write-Host "---------------------------------------------------------------"
        Write-Host ""
        komorebic fetch-asc
    }

    Write-Host ""
    Write-Host "--------------------------------------------------------------"
    Write-Host "✅ All system updates completed."
}
