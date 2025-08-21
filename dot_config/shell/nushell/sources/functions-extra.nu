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
