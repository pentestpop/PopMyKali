# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ENVIRONMENT VARIABLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# This defines where Oh My Zsh is actually installed.
export ZSH="$HOME/.oh-my-zsh"

# Set the theme
ZSH_THEME="xiong-chiamiov"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PLUGINS + TWEAKS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Plugins must be defined BEFORE sourcing oh-my-zsh.sh
plugins=(
  git 
  zsh-autosuggestions 
  zsh-syntax-highlighting
)

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'

# Initialize Oh My Zsh
source $ZSH/oh-my-zsh.sh


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SHELL OPTIONS & BEHAVIOR
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
setopt autocd              # Change directory just by typing the name
setopt interactivecomments # Allow comments (starting with #) in the terminal
setopt magicequalsubst     # Better handling of paths in variables (e.g., PATH=/bin)
setopt nonomatch           # Don't error out if a wildcard (*) finds no files
setopt notify              # Tell me immediately when background jobs finish
setopt numericglobsort     # Sort files numerically (1, 2, 10) instead of (1, 10, 2)
setopt promptsubst         # Required for themes to show dynamic info like Git branches

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# HISTORY SETTINGS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
HISTFILE=~/.zsh_history
HISTSIZE=10000             # Increase this if you want to remember more
SAVEHIST=10000
setopt hist_expire_dups_first # Delete old duplicates when history is full
setopt hist_ignore_dups       # Don't save the same command twice in a row
setopt hist_ignore_space      # Commands starting with a space won't be saved
setopt hist_verify            # Let me check a history shortcut (!!) before it runs

# Define what a "word" is (Stops Ctrl+W from deleting too much)
WORDCHARS='_-'

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# KEYBINDINGS (Fixes Home/End/Arrows)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bindkey -e                           # Use Emacs-style shortcuts (Standard)
bindkey '^[[1;5C' forward-word       # Ctrl + Right Arrow
bindkey '^[[1;5D' backward-word      # Ctrl + Left Arrow
bindkey '^[[H' beginning-of-line     # Home Key
bindkey '^[[F' end-of-line           # End Key
bindkey '^[[3~' delete-char          # Delete Key

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# TAB COMPLETION SETTINGS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
autoload -Uz compinit
compinit -d ~/.cache/zcompdump

# Make completion case-insensitive (type 'doc' and Tab finds 'Documents')
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Use your 'Popped' theme colors in the completion menu
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# COLOR SUPPORT
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"
    # Fix for writable folders in LS_COLORS
    export LS_COLORS="$LS_COLORS:ow=30;44:" 
fi

# Man page colors (Cyan and Green highlights)
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_md=$'\E[1;36m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;33m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_us=$'\E[1;32m'
export LESS_TERMCAP_ue=$'\E[0m'

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Required by something else
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Created by `pipx` on 2025-11-12 18:47:30
export PATH="$PATH:/home/cgrigsby/.local/bin"

# added manually for HTTPX install https://github.com/projectdiscovery/httpx
export PATH="/home/pop/go/bin:$PATH"

#minty
#export GOPATH=/root/go
#export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/go/bin:/bin

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Pop Stuff
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Additional aliases, functions, anything custom

# Pop Aliases
alias venv='python3 -m venv myenv && source myenv/bin/activate'
alias ls='ls -A -F --group-directories-first --sort=extension --color=always'
alias gitupdate='find /opt -maxdepth 1 -type d -exec bash -c "cd \"{}\"; git pull;" \;'
alias grep='grep --color=auto'
alias cat='batcat'
alias icat='kitty +kitten icat'
alias ipaddr='curl -s -4 ifconfig.co/json | jq'
alias ipaddr6='curl -s -6 ifconfig.co/json | jq'
alias ip='ip --color=auto'
# alias lsd='lsd --group-dirs=first'

# Pop Functions 
function mkcd() { mkdir -p "$1" && cd "$1"; }
mousepad() {
    # 'command' ensures we run the actual binary and not this function recursively
    # "$@" expands to all arguments (preserving spaces and quotes)
    command mousepad "$@" &
}

# Pop Prompt - Redundant with theme
#PROMPT='%F{#7AE7C7}%B%~%b
#%F{#7AE7C7}%n%# '
# With time added back
# PROMPT='%F{#7AE7C7}%B%~%b
# %F{#7AE7C7}%D{%H:%M} %# '

# Custom colors to fix terminator
ZSH_HIGHLIGHT_STYLES[command]='fg=1'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=1'
ZSH_HIGHLIGHT_STYLES[alias]='fg=1'
ZSH_HIGHLIGHT_STYLES[function]='fg=1'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=4'

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# FZF (Fuzzy Finder) Setup
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Check common install locations for the shell completion/bindings
# Ctrl+R = replaces standard history search with "fuzzy" search
# Ctrl+T = Quickly find a file path and paste it to your cursor
# Ctrl+C = Fuzzy search for a directory and cd into it immediately

if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh
elif [ -f /usr/share/fzf/key-bindings.zsh ]; then
  source /usr/share/fzf/key-bindings.zsh
  source /usr/share/fzf/completion.zsh
fi

