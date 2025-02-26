# fzf - [s]earch [f]iles command (sf)
# this will use the output of the fzf command to open the file in nvim. You can
# change the editor launch command to whatever you want.
# see: https://github.com/junegunn/fzf
# see: https://github.com/sharkdp/bat
def sf [] {
    let fzfoutput = fzf --preview "bat --color=always {}" --preview-window=right:50%:wrap --height 50% --border --prompt="Search Files: " | str trim
    if (not ($fzfoutput | is-empty)) {
        nvim $fzfoutput
    }
}
