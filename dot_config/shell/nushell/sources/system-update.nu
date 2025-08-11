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
        sudo apt update;
        sudo apt upgrade -y;
        sudo apt autoremove -y;
    }

    if (which cargo | is-empty) {
        # nothing
    } else {
        # check if windows or mac
        if ($nu.os-info.family == "windows") {
            print ""
            print "Cargo Rust updates are not supported on Windows at this time."
        } else if ($nu.os-info.name == "macos") {
            print ""
            print "Cargo Rust updates are not supported on MacOS at this time."
        } else {
            print ""
            print "🔄 Updating Cargo Rust packages -------------------------------"
            bash -c "cargo install $(cargo install --list | egrep '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ')";
        }
    }

    if (which uv | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating UV tools ------------------------------------------"
        uv tool upgrade --all
    }

    if (which npm | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating NPM packages --------------------------------------"
        npm install -g npm
        npm update -g
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

    if ($nu.os-info.family == "windows") {
        if (which scoop | is-empty) {
            # nothing
        } else {
            print ""
            print "🔄 Updating Scoop packages ------------------------------------"
            scoop update
        }

        if (which choco | is-empty) {
            # nothing
        } else {
            print ""
            print "🔄 Updating Chocolatey packages -------------------------------"
            powershell -Command "$p = Start-Process -FilePath choco -ArgumentList 'upgrade all -y' -Verb RunAs -PassThru; $p.WaitForExit()"
        }

        if (which winget | is-empty) {
            # nothing
        } else {
            print ""
            print "🔄 Updating Winget packages -----------------------------------"
            powershell -Command "$p = Start-Process winget -ArgumentList 'upgrade','--all','--include-unknown' -Verb RunAs -PassThru; $p.WaitForExit()"
        }
    }

    if (which mas | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Mac App Store packages ----------------------------"
        mas upgrade
    }

    if (which brew | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Homebrew packages ---------------------------------"
        brew upgrade
        brew cleanup
    }


    print "--------------------------------------------------------------"
    print "✅ All system updates completed."
}
