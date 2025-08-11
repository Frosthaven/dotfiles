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

def sysup [] {

    sudo -v

    if (which apt | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating APT packages --------------------------------------"
        sudo apt update;
        sudo apt upgrade -y;
        sudo apt autoremove -y;
    }

    if (which cargo | is-empty) {
        # nothing
    } else {
        # check if windows
        if ($nu.os-info.family == "Windows") {
            print ""
            print "Cargo updates are not supported on Windows at this time."
        } else {
            print ""
            print "🔄 Updating Cargo Rust packages -------------------------------"
            bash -c "cargo install $(cargo install --list | egrep '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ')";
        }
    }


    if (which snap | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Snap packages -------------------------------------"
        sudo snap refresh
    }

    if (which flatpak | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Flatpak packages ----------------------------------"
        flatpak update -y
    }

    if (which winget | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating winget packages -----------------------------------"
        winget upgrade --accept-source-agreements --accept-package-agreements --include-unknown
    }

    if (which choco | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Chocolatey packages -------------------------------"
        choco upgrade all -y
    }

    if (which scoop | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Scoop packages ------------------------------------"
        scoop update *
    }

    if (which brew | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Homebrew packages ---------------------------------"
        brew update
        brew upgrade
        brew cleanup
    }

    print "--------------------------------------------------------------"
    print "✅ All system updates completed."
}
