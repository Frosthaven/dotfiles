# Add $HOME/.local/bin to PATH
set -gx PATH $HOME/.local/bin $PATH

# Add nvim-bob to PATH
set -gx PATH $HOME/.local/share/bob/nvim-bin $PATH

# Starship prompt
starship init fish | source

# eza aliases
alias l='eza --icons=always'
alias ls='eza --icons=always --group --header --group-directories-first'
alias ll='eza --icons=always --group --header --group-directories-first --long --git'
alias lg='eza --icons=always --group --header --group-directories-first --long --git --git-ignore'
alias le='eza --icons=always --group --header --group-directories-first --long --extended'
alias lt='eza --icons=always --group --header --group-directories-first --tree --level level'
alias lc='eza --icons=always --group --header --group-directories-first --across'
alias lo='eza --icons=always --group --header --group-directories-first --oneline'
alias la='eza --icons=always --all'
alias lsa='eza --icons=always --group --header --group-directories-first --all'
alias lla='eza --icons=always --group --header --group-directories-first --all --long --git'
alias lga='eza --icons=always --group --header --group-directories-first --all --long --git --git-ignore'

# Neovim aliases
alias vim='nvim'
alias vi='nvim'

# Zoxide
zoxide init fish | source
alias cd='z'  # replace cd with zoxide

# fzf file search helper (sf)
function sf
    set file (fzf --preview "bat --color=always {}" \
                  --preview-window=right:50%:wrap \
                  --height 50% \
                  --border \
                  --prompt="search files: " \
                  --query="$argv")
    if test -n "$file"
        nvim "$file"  # replace with preferred editor if desired
    end
end

# Automatic Nushell (optional)
# if not set -q NU; and test -x "$HOME/.cargo/bin/nu"
#     exec "$HOME/.cargo/bin/nu"
# end

# Add Cargo to PATH
if test -d "$HOME/.cargo/bin"
    set -gx PATH $HOME/.cargo/bin $PATH
end
