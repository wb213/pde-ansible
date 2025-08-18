# Personal Development Environment - Shell Functions
# Enhanced functions with beautiful output and error handling

# ═══════════════════════════════════════════════════════════════════════════════
# 📁 File Manager Integration
# ═══════════════════════════════════════════════════════════════════════════════

# Enhanced Yazi file manager with directory change support
function ya() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        echo "📂 Navigating to: $cwd"
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🔄 System Update Functions
# ═══════════════════════════════════════════════════════════════════════════════

# Cross-platform system refresh and update
function refresh() {
    echo "🚀 Starting system refresh..."
    echo "═══════════════════════════════════════════════════════════════"
    
    # Update Zinit and plugins (cross-platform)
    echo "\n🔌 Updating Zinit plugins..."
    if command -v zinit >/dev/null 2>&1; then
        zinit update --all
        echo "✅ Zinit plugins updated"
    else
        echo "⚠️  Zinit not found, skipping..."
    fi
    
    # Platform-specific package manager updates
    if command -v brew >/dev/null 2>&1; then
        # macOS with Homebrew
        echo "\n🍺 Updating Homebrew (macOS)..."
        echo "  📥 Updating package definitions..."
        brew update
        
        echo "  ⬆️  Upgrading installed packages..."
        brew upgrade
        
        echo "  🎯 Upgrading specific casks..."
        brew upgrade anki drawio loop quickrecorder \
            font-jetbrains-mono-nerd-font font-caskaydia-cove-nerd-font \
            font-caskaydia-mono-nerd-font font-symbols-only-nerd-font \
            wezterm wireshark-app cherry-studio claude-code zed ghostty --cask
        
        echo "  🧹 Cleaning up old versions..."
        brew cleanup
        
        echo "  🔍 Running diagnostics..."
        brew doctor --quiet || echo "⚠️  Some brew doctor warnings found"
        
        echo "✅ Homebrew update completed"
        
    elif command -v dnf >/dev/null 2>&1; then
        # RHEL/Fedora with DNF
        echo "\n🐧 Updating system packages (RHEL/Fedora)..."
        echo "  📥 Updating package cache..."
        sudo dnf check-update || true
        
        echo "  ⬆️  Upgrading installed packages..."
        sudo dnf upgrade -y
        
        echo "  🧹 Cleaning up package cache..."
        sudo dnf clean all
        
        echo "✅ DNF update completed"
        
    elif command -v apt >/dev/null 2>&1; then
        # Debian/Ubuntu with APT
        echo "\n🐧 Updating system packages (Debian/Ubuntu)..."
        echo "  📥 Updating package lists..."
        sudo apt update
        
        echo "  ⬆️  Upgrading installed packages..."
        sudo apt upgrade -y
        
        echo "  🧹 Cleaning up package cache..."
        sudo apt autoremove -y
        sudo apt autoclean
        
        echo "✅ APT update completed"
        
    else
        echo "⚠️  No supported package manager found (brew/dnf/apt)"
    fi
    
    # Update other tools if present (cross-platform)
    # Skip uv and rustup on macOS if they're managed by Homebrew
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # On macOS, check if tools are managed by Homebrew
        if command -v uv >/dev/null 2>&1 && ! brew list uv >/dev/null 2>&1; then
            echo "\n🐍 Updating UV (Python package manager)..."
            uv self update
            echo "✅ UV updated"
        elif brew list uv >/dev/null 2>&1; then
            echo "\n🐍 UV managed by Homebrew - updated via brew upgrade"
        fi
        
        if command -v rustup >/dev/null 2>&1 && ! brew list rustup >/dev/null 2>&1; then
            echo "\n🦀 Updating Rust toolchain..."
            rustup update
            echo "✅ Rust toolchain updated"
        elif brew list rustup >/dev/null 2>&1; then
            echo "\n🦀 Rust managed by Homebrew - updated via brew upgrade"
        fi
    else
        # On Linux, update normally
        if command -v uv >/dev/null 2>&1; then
            echo "\n🐍 Updating UV (Python package manager)..."
            uv self update
            echo "✅ UV updated"
        fi
        
        if command -v rustup >/dev/null 2>&1; then
            echo "\n🦀 Updating Rust toolchain..."
            rustup update
            echo "✅ Rust toolchain updated"
        fi
    fi
    
    echo "\n🎉 System refresh completed successfully!"
    echo "═══════════════════════════════════════════════════════════════"
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🗂️ Directory & Project Management
# ═══════════════════════════════════════════════════════════════════════════════

# Create and enter directory
function mkcd() {
    if [ $# -ne 1 ]; then
        echo "❌ Usage: mkcd <directory_name>"
        return 1
    fi
    
    mkdir -p "$1" && cd "$1"
    echo "📁 Created and entered directory: $1"
}

# Find and cd to directory
function fcd() {
    local dir
    dir=$(find . -type d -name "*$1*" 2>/dev/null | head -1)
    if [ -n "$dir" ]; then
        cd "$dir"
        echo "📂 Navigated to: $dir"
    else
        echo "❌ Directory matching '$1' not found"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🔍 Search & Information Functions
# ═══════════════════════════════════════════════════════════════════════════════

# Enhanced process search
function psg() {
    if [ $# -eq 0 ]; then
        echo "❌ Usage: psg <process_name>"
        return 1
    fi
    
    echo "🔍 Searching for processes matching: $1"
    ps aux | grep -i "$1" | grep -v grep
}

# Find large files
function findlarge() {
    local size=${1:-100M}
    echo "🔍 Finding files larger than $size..."
    find . -type f -size +$size -exec ls -lh {} \; 2>/dev/null | awk '{print $9 ": " $5}'
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🌐 Network & Development Functions
# ═══════════════════════════════════════════════════════════════════════════════

# Quick HTTP server with better output
function serve() {
    local port=${1:-8000}
    echo "🌐 Starting HTTP server on port $port..."
    echo "📂 Serving directory: $(pwd)"
    echo "🔗 Access at: http://localhost:$port"
    echo "⏹️  Press Ctrl+C to stop"
    python3 -m http.server $port
}

# Test network connectivity
function nettest() {
    echo "🌐 Testing network connectivity..."
    
    # Test DNS resolution
    if nslookup google.com >/dev/null 2>&1; then
        echo "✅ DNS resolution: OK"
    else
        echo "❌ DNS resolution: FAILED"
    fi
    
    # Test internet connectivity
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo "✅ Internet connectivity: OK"
    else
        echo "❌ Internet connectivity: FAILED"
    fi
    
    # Test HTTPS connectivity
    if curl -s --max-time 5 https://www.google.com >/dev/null 2>&1; then
        echo "✅ HTTPS connectivity: OK"
    else
        echo "❌ HTTPS connectivity: FAILED"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🛠️ Development Utilities
# ═══════════════════════════════════════════════════════════════════════════════

# Git repository status for multiple repos
function gitstatus() {
    echo "📊 Git repository status overview..."
    echo "═══════════════════════════════════════════════════════════════"
    
    for dir in */; do
        if [ -d "$dir/.git" ]; then
            echo "\n📁 $dir"
            cd "$dir"
            
            # Check for uncommitted changes
            if ! git diff-index --quiet HEAD --; then
                echo "  🔄 Uncommitted changes detected"
            fi
            
            # Check for untracked files
            if [ -n "$(git ls-files --others --exclude-standard)" ]; then
                echo "  📄 Untracked files present"
            fi
            
            # Check branch status
            local branch=$(git branch --show-current)
            echo "  🌿 Current branch: $branch"
            
            cd ..
        fi
    done
}

# Extract various archive formats
function extract() {
    if [ $# -ne 1 ]; then
        echo "❌ Usage: extract <archive_file>"
        return 1
    fi
    
    if [ ! -f "$1" ]; then
        echo "❌ File '$1' not found"
        return 1
    fi
    
    echo "📦 Extracting: $1"
    
    case "$1" in
        *.tar.bz2)   tar xjf "$1"     ;;
        *.tar.gz)    tar xzf "$1"     ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.rar)       unrar x "$1"     ;;
        *.gz)        gunzip "$1"      ;;
        *.tar)       tar xf "$1"      ;;
        *.tbz2)      tar xjf "$1"     ;;
        *.tgz)       tar xzf "$1"     ;;
        *.zip)       unzip "$1"       ;;
        *.Z)         uncompress "$1"  ;;
        *.7z)        7z x "$1"        ;;
        *)           echo "❌ Unsupported archive format: $1" ;;
    esac
    
    echo "✅ Extraction completed"
}
