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
        sudo apt update;
        sudo apt upgrade -y;
        sudo apt autoremove -y;
    }

    if (which cargo | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Cargo Rust packages -------------------------------"
        print "---------------------------------------------------------------"
        print ""
        cargo install --list | lines | where {|l| $l =~ '^[a-z0-9_-]+ v[0-9.]+:$' } | each {|l| $l | split row ' ' | get 0 } | par-each {|c| cargo install $c }
        # check if windows or mac
        # if ($nu.os-info.family == "windows") {
        #     print ""
        #     print "Cargo Rust updates are not supported on Windows at this time."
        # } else if ($nu.os-info.name == "macos") {
        #     print ""
        #     print "🔄 Updating Cargo Rust packages -------------------------------"
        #     print "---------------------------------------------------------------"
        #     print ""
        #     cargo install --list | lines | where {|l| $l =~ '^[a-z0-9_-]+ v[0-9.]+:$' } | each {|l| $l | split row ' ' | get 0 } | par-each {|c| cargo install $c }
        # } else {
        #     print ""
        #     print "🔄 Updating Cargo Rust packages -------------------------------"
        #     print "---------------------------------------------------------------"
        #     print ""
        #     bash -c "cargo install $(cargo install --list | egrep '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ')";
        # }
    }

    if (which uv | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating UV tools ------------------------------------------"
        print "---------------------------------------------------------------"
        print ""
        uv tool upgrade --all
    }

    if (which npm | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating NPM packages --------------------------------------"
        print "---------------------------------------------------------------"
        print ""
        npm install -g npm
        npm update -g
    }

    if (which snap | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Snap packages -------------------------------------"
        print "---------------------------------------------------------------"
        print ""
        sudo snap refresh
    }

    if (which flatpak | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Flatpak packages ----------------------------------"
        print "---------------------------------------------------------------"
        print ""
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
            scoop update
        }

        if (which choco | is-empty) {
            # nothing
        } else {
            print ""
            print "🔄 Updating Chocolatey packages -------------------------------"
            print "---------------------------------------------------------------"
            print ""
            powershell -Command "$p = Start-Process -FilePath choco -ArgumentList 'upgrade all -y' -Verb RunAs -PassThru; $p.WaitForExit()"
        }

        if (which winget | is-empty) {
            # nothing
        } else {
            print ""
            print "🔄 Updating Winget packages -----------------------------------"
            print "---------------------------------------------------------------"
            print ""
            powershell -Command "$p = Start-Process winget -ArgumentList 'upgrade','--all','--include-unknown' -Verb RunAs -PassThru; $p.WaitForExit()"
        }
    }

    if (which mas | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Mac App Store packages ----------------------------"
        print "---------------------------------------------------------------"
        print ""
        mas upgrade
    }

    if (which brew | is-empty) {
        # nothing
    } else {
        print ""
        print "🔄 Updating Homebrew packages ---------------------------------"
        print "---------------------------------------------------------------"
        print ""
        brew upgrade
        brew cleanup
    }

    print ""
    print "--------------------------------------------------------------"
    print "✅ All system updates completed."
}
