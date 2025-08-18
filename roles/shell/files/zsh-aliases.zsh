# Personal Development Environment - Shell Aliases
# Modern CLI tool aliases with enhanced functionality

# ═══════════════════════════════════════════════════════════════════════════════
# 📁 File Operations & Navigation
# ═══════════════════════════════════════════════════════════════════════════════

# Modern replacements for core utilities
alias cat="bat --style=auto --paging=never"
alias catp="bat --style=auto --paging=always"  # with paging
alias cd="zz"      # zoxide smart cd
alias cdi="zzi"    # zoxide interactive cd

# Enhanced ls with eza (better than exa)
alias l="eza --group-directories-first --icons=auto"
alias ls="eza --group-directories-first --icons=auto"
alias ll="eza --group-directories-first --icons=auto --long --header --git"
alias la="eza --group-directories-first --icons=auto --long --all --header --git"
alias lt="eza --group-directories-first --icons=auto --tree --level=2 --long --all --ignore-glob='.git*|node_modules|.DS_Store'"
alias lta="eza --group-directories-first --icons=auto --tree --long --all --ignore-glob='.git*'"

# Directory operations
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"  # Go back to previous directory

# ═══════════════════════════════════════════════════════════════════════════════
# 🔍 Search & Find
# ═══════════════════════════════════════════════════════════════════════════════

# Modern search tools
alias grep="rg"                    # ripgrep is faster
alias find="fd"                    # fd is more user-friendly
alias ps="procs"                   # modern ps replacement

# ═══════════════════════════════════════════════════════════════════════════════
# 🗂️ File Management
# ═══════════════════════════════════════════════════════════════════════════════

# Safe file operations
if [[ $- == *i* ]]; then
    alias rm='echo "🚫 This is not the command you are looking for, try trash! 🗑️"; false'
fi
alias trash="trash"                # Use trash instead of rm
alias cp="cp -i"                   # Interactive copy
alias mv="mv -i"                   # Interactive move
alias mkdir="mkdir -p"             # Create parent directories

# ═══════════════════════════════════════════════════════════════════════════════
# 💻 Development & Git
# ═══════════════════════════════════════════════════════════════════════════════

# Git shortcuts
alias g="git"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit"
alias gcm="git commit -m"
alias gco="git checkout"
alias gd="git diff"
alias gl="git log --oneline --graph --decorate"
alias gp="git push"
alias gpl="git pull"
alias gs="git status --short --branch"
alias gst="git status"

# Development tools
alias py="python3"
alias pip="uv pip"                 # Use uv for pip operations
alias venv="uv venv"               # Use uv for virtual environments
alias serve="python3 -m http.server 8000"  # Quick HTTP server

# ═══════════════════════════════════════════════════════════════════════════════
# 🌐 Network & System
# ═══════════════════════════════════════════════════════════════════════════════

# Network utilities
alias ping="ping -c 5"             # Limit ping to 5 packets
alias myip="curl -s https://ipinfo.io/ip && echo"
alias localip="ipconfig getifaddr en0"  # macOS local IP
alias ports="lsof -i -P -n | grep LISTEN"

# System information
alias top="btop"                   # Better top
alias df="duf"                     # Better df
alias du="dust"                    # Better du
alias free="vm_stat"               # macOS memory info

# ═══════════════════════════════════════════════════════════════════════════════
# 🛠️ Utilities & Shortcuts
# ═══════════════════════════════════════════════════════════════════════════════

# Quick edits
alias zshrc="$EDITOR ~/.zshrc"
alias zshreload="source ~/.zshrc && echo '✅ Zsh configuration reloaded!'"

# Clipboard operations (macOS)
alias pbcopy="pbcopy"
alias pbpaste="pbpaste"

# Quick directory access
alias dev="cd ~/dev"
alias downloads="cd ~/Downloads"
alias desktop="cd ~/Desktop"
alias documents="cd ~/Documents"

# ═══════════════════════════════════════════════════════════════════════════════
# 🎨 Fun & Useful
# ═══════════════════════════════════════════════════════════════════════════════

# Weather
alias weather="curl -s 'https://wttr.in/?format=3'"
alias forecast="curl -s 'https://wttr.in/'"

# Date and time
alias now="date '+%Y-%m-%d %H:%M:%S'"
alias timestamp="date +%s"
alias iso8601="date -u +%Y-%m-%dT%H:%M:%SZ"
