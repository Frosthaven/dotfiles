if (!(Get-Process whkd -ErrorAction SilentlyContinue))
{
    Start-Process whkd -WindowStyle hidden
}

. $PSScriptRoot\komorebi.generated.ps1

# Send the ALT key whenever changing focus to force focus changes
komorebic alt-focus-hack enable
# Default to minimizing windows when switching workspaces
komorebic window-hiding-behaviour cloak
# Set cross-monitor move behaviour to insert instead of swap
komorebic cross-monitor-move-behaviour insert
# Enable hot reloading of changes to this file
komorebic watch-configuration enable

# create named workspaces 1-4 on monitor 1
komorebic ensure-workspaces 1 1 2 3 4

# assign layouts to workspaces, possible values: bsp, columns, rows, vertical-stack, horizontal-stack, ultrawide-vertical-stack
komorebic named-workspace-layout 1 ultrawide-vertical-stack
komorebic named-workspace-layout 2 ultrawide-vertical-stack
komorebic named-workspace-layout 3 ultrawide-vertical-stack
komorebic named-workspace-layout 4 ultrawide-vertical-stack

# set the gaps around the edge of the screen for a workspace
#komorebic named-workspace-padding 1 5
#komorebic named-workspace-padding 2 5
#komorebic named-workspace-padding 3 5
#komorebic named-workspace-padding 4 5

# set the gaps between the containers for a workspace
#komorebic named-workspace-container-padding 1 5
#komorebic named-workspace-container-padding 2 5
#komorebic named-workspace-container-padding 3 5
#komorebic named-workspace-container-padding 4 5

# you can assign specific apps to named workspaces
# komorebic named-workspace-rule exe "Firefox.exe" III

# Configure the invisible border dimensions
komorebic invisible-borders 7 0 14 7

# Uncomment the next lines if you want a visual border around the active window0
# komorebic active-window-border-colour 66 165 245 --window-kind single
# komorebic active-window-border-colour 256 165 66 --window-kind stack
# komorebic active-window-border-colour 255 51 153 --window-kind monocle
# komorebic active-window-border enable

komorebic complete-configuration
