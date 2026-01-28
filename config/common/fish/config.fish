# Fish shell configuration

# Starship prompt
starship init fish | source

# Aliases
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias cat='bat'
alias vim='nvim'

# Environment variables
set -x EDITOR nvim
set -x VISUAL nvim

# Zoxide
zoxide init fish | source