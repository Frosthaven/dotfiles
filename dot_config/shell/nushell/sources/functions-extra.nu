def cosmic-res [] {
    if (which cosmic-randr | is-empty) {
        echo "cosmic-randr not found, skipping resolution change"
    } else {
        cosmic-randr mode DP-1 5120 1440 --refresh 119.999
    }
}

def cosmic-res-safe [] {
    if (which cosmic-randr | is-empty) {
        echo "cosmic-randr not found, skipping resolution change"
    } else {
        cosmic-randr mode DP-1 3840 1080 --refresh 119.974
    }
}

# -----------------------------------------------------------------------------

def cosmic-reboot [] {
    if (which cosmic-randr | is-empty) {
        echo "cosmic-randr not found, skipping resolution change"
    } else {
        cosmic-res-safe
        reboot
    }
}

def cosmic-logout [] {
    if (which cosmic-randr | is-empty) {
        echo "cosmic-randr not found, skipping resolution change"
    } else {
        cosmic-res-safe
        pkill cosmic-session
    }
}

def cosmic-shutdown [] {
    if (which cosmic-randr | is-empty) {
        echo "cosmic-randr not found, skipping resolution change"
    } else {
        cosmic-res-safe
        shutdown now
    }
}

# -----------------------------------------------------------------------------


def rr [] {
    let options = [
        "Reboot",
        "Logout",
        "Shutdown",
        "Resolution (5120x1440 @ 120Hz)",
        "Resolution Safe (3840x1080 @ 120Hz)",
        "Cancel"
    ]

    let last_index = ($options | length) - 1
    for i in 0..$last_index {
        let label = $options | get $i
        print $"($i + 1). ($label)"
    }

    # Read choice
    print ""
    print "Select an option (1-6): "
    let choice = (input | str trim)

    match $choice {
        "1" => {
            cosmic-res-safe
            cosmic-reboot
        },
        "2" => {
            cosmic-res-safe
            cosmic-logout
        },
        "3" => {
            cosmic-res-safe
            cosmic-shutdown
        },
        "4" => {
            cosmic-res
        },
        "5" => {
            cosmic-res-safe
        },
        _ => {
            print "Cancelled."
        }
    }
}
