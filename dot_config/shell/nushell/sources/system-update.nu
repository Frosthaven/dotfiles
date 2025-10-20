def sysup [] {

    if ($nu.os-info.family == "windows") {
        # no sudo on Windows
    } else {
        sudo -v
    }

    if (which apt | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating APT packages --------------------------------------"
        print "---------------------------------------------------------------"
        print ""
        print "Updating APT package lists..."
        sudo apt update;
        print ""
        print "Upgrading all APT packages..."
        sudo apt upgrade -y;
        print ""
        print "Performing cleanup..."
        sudo apt autoremove -y;
    }

    if (which pacman | is-empty) {
        # nothing
    } else {
        # check if we have yay installed
        if (which yay | is-empty) {
            print ""
            print "🔄 Updating Arch packages -------------------------------------"
            print "---------------------------------------------------------------"
            print ""
            sudo pacman -Syu --noconfirm;
        } else {
            print ""
            print "🔄 Updating Arch + AUR packages -------------------------------"
            print "---------------------------------------------------------------"
            print ""
            yay -Syu --noconfirm;
        }
    }

    if (which cargo | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Rust & Cargo packages -----------------------------"
        print "---------------------------------------------------------------"
        print ""
        print "Updating Rust..."
        rustup update
        print ""
        print "Updating all global Cargo packages..."
        cargo install --list | lines | where {|l| $l =~ '^[a-z0-9_-]+ v[0-9.]+:$' } | each {|l| $l | split row ' ' | get 0 } | par-each {|c| cargo install $c }
    }

    if (which uv | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating UV (Python) tools ---------------------------------"
        print "---------------------------------------------------------------"
        print ""
        print "Updating all UV tools..."
        uv tool upgrade --all
    }

    # Determine which package manager to use: prefer pnpm > npm > yarn
    let pkg_manager = if (which pnpm | default null) != null {
        "pnpm"
    } else if (which npm | default null) != null {
        "npm"
    } else if (which yarn | default null) != null {
        "yarn"
    } else {
        ""
    }
    # If none found, do nothing
    if ($pkg_manager == "") {
        print "⚠️  No package manager (pnpm, npm, or yarn) found in PATH."
    } else {
        print ""
        print $"🔄 Updating Node packages ---------------------------------------"
        print "------------------------------------------------------------------"
        print ""
        print $"Updating ($pkg_manager) packages..."

        match $pkg_manager {
            "pnpm" => { pnpm up -g },
            "npm" => {
                if ($nu.os-info.family == "windows") {
                    npm upgrade --global --force
                } else {
                    sudo npm upgrade --global --force
                }
            },
            "yarn" => { yarn global upgrade }
        }
    }

    if (which snap | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Snap packages -------------------------------------"
        print "---------------------------------------------------------------"
        print ""
        print "Updating snapd..."
        sudo snap install core
        print ""
        print "Updating all Snap packages..."
        sudo snap refresh
    }

    if (which flatpak | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Flatpak packages ----------------------------------"
        print "---------------------------------------------------------------"
        print ""
        print "Updating Flatpak..."
        sudo flatpak update --appstream -y
        print ""
        print "Updating all Flatpak remotes..."
        sudo flatpak update -y
    }

    if ($nu.os-info.family == "windows") {
        if (which scoop | is-empty) {
            # nothing
        } else {
            print ""
            print "🔄 Updating Scoop packages ------------------------------------"
            print "---------------------------------------------------------------"
            print ""
            print "Updating all Scoop packages..."
            scoop update
        }

        if (which choco | is-empty) {
            # nothing
        } else {
            print ""
            print "🔄 Updating Chocolatey packages -------------------------------"
            print "---------------------------------------------------------------"
            print ""
            print "Updating all Chocolatey packages..."
            powershell -Command "$p = Start-Process -FilePath choco -ArgumentList 'upgrade all -y' -Verb RunAs -PassThru; $p.WaitForExit()"
        }

        if (which winget | is-empty) {
            # nothing
        } else {
            print ""
            print "🔄 Updating Winget packages -----------------------------------"
            print "---------------------------------------------------------------"
            print ""
            print "Updating all Winget packages..."
            powershell -Command "$p = Start-Process winget -ArgumentList 'upgrade','--all','--include-unknown' -Verb RunAs -PassThru; $p.WaitForExit()"
        }
    }

    if (which mas | is-empty) {
        # nothing
    } else {
        print ""
        print ""
        print "🔄 Updating Mac App Store packages ----------------------------"
        print "---------------------------------------------------------------"
        print ""
        print "Updating Mac App Store apps..."
        mas upgrade
    }

    if (which brew | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Homebrew packages ---------------------------------"
        print "---------------------------------------------------------------"
        print ""
        print "Updating Homebrew..."
        brew update
        print ""
        print "Updating all Homebrew packages..."
        brew upgrade --greedy
        print ""
        print "Performing cleanup..."
        brew cleanup
    }

    if (which chezmoi | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Chezmoi configuration -----------------------------"
        print "---------------------------------------------------------------"
        print ""
        print "Updating Chezmoi..."
        chezmoi update
    }

    if (which bob | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Neovim --------------------------------------------"
        print "---------------------------------------------------------------"
        print ""
        print "Updating nvim via bob..."
        bob update
        print ""
    }

    if (which nvim | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Neovim plugins ------------------------------------"
        print "---------------------------------------------------------------"
        print ""
        print "Updating all plugins..."
        nvim --headless "+Lazy! update" "+MasonUpdate" +qa
        print ""
    }

    if (which komorebic | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Komorebic Application Rules -----------------------"
        print "---------------------------------------------------------------"
        print ""
        komorebic fetch-asc
    }

    print ""
    print "--------------------------------------------------------------"
    print "✅ All system updates completed."
}
