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
        print ""
        print "🔄 Updating Pacman packages -----------------------------------"
        print "---------------------------------------------------------------"
        print ""
        print "Updating Pacman package lists..."
        sudo pacman -Syu --noconfirm;
    }

    if (which yay | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Yay packages --------------------------------------"
        print "---------------------------------------------------------------"
        print ""
        print "Updating all Yay packages..."
        yay -Syu --noconfirm;
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

    if (which npm | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating NPM packages --------------------------------------"
        print "---------------------------------------------------------------"
        print ""
        print "Updating npm packages..."
        if ($nu.os-info.family == "windows") {
            npm install -g npm
            npm update -g
        } else {
            sudo npm install -g npm
            sudo npm update -g
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
        flatpak update --appstream -y
        print ""
        print "Updating all Flatpak remotes..."
        flatpak update -y
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
