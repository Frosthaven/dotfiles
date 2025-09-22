# Stop all Docker containers and power off DDEV
def docker-off [] {
    let os = (bash -c "uname" | str trim | str downcase)

    # Power off DDEV
    if $os == "linux" or $os == "darwin" {
        bash -c "ddev poweroff"
    } else {
        powershell -c "ddev poweroff"
    }

    # Get running containers
    let containers = if $os == "linux" or $os == "darwin" {
        (bash -c "docker ps --format '{{.Names}}'" | lines)
    } else if $os == "windows_nt" or $os == "windows" {
        (powershell -c "docker ps --format '{{.Names}}'" | lines)
    } else {
        echo "Unsupported OS: $os"
        []
    }

    # Only run docker stop if the list isn’t empty
    if not ($containers | is-empty) {
        let cmd = ($containers | str join ' ')
        if $os == "linux" or $os == "darwin" {
            bash -c $"docker stop ($cmd)" | ignore
        } else {
            powershell -c $"docker stop ($cmd)" | ignore
        }
    }
}
