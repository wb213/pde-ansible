# ===================================================================
# 📁 Direnv Configuration - Environment Variable Management
# ===================================================================
# Direnv automatically loads and unloads environment variables
# based on the current directory, using .envrc files

# Check if direnv is installed
if command -v direnv >/dev/null 2>&1; then
    # Initialize direnv hook for zsh
    eval "$(direnv hook zsh)"
    
    # Optional: Set direnv configuration
    export DIRENV_LOG_FORMAT=""  # Disable direnv log messages (set to "" for quiet)
    
    # Direnv aliases for convenience
    alias da='direnv allow'      # Allow .envrc in current directory
    alias dd='direnv deny'       # Deny .envrc in current directory  
    alias dr='direnv reload'     # Reload .envrc in current directory
    alias ds='direnv status'     # Show direnv status
    alias de='direnv edit'       # Edit .envrc file
    
    # Function to create a basic .envrc file
    function direnv_init() {
        local envrc_file=".envrc"
        
        if [[ -f "$envrc_file" ]]; then
            echo "⚠️  .envrc already exists in current directory"
            return 1
        fi
        
        cat > "$envrc_file" << 'EOF'
# Direnv configuration file
# This file is automatically loaded when entering this directory

# Example environment variables
# export PROJECT_NAME="my-project"
# export DEBUG=true
# export API_URL="http://localhost:3000"

# Load .env file if it exists
dotenv_if_exists .env

# Example: Load specific Python version
# use python 3.11

# Example: Add local bin to PATH
# PATH_add ./bin

# Example: Load from another .envrc
# source_up_if_exists
EOF
        
        echo "📁 Created .envrc file in current directory"
        echo "💡 Edit the file and run 'direnv allow' to activate"
        
        # Automatically open in editor if available
        if command -v $EDITOR >/dev/null 2>&1; then
            $EDITOR "$envrc_file"
        elif command -v hx >/dev/null 2>&1; then
            hx "$envrc_file"
        elif command -v vim >/dev/null 2>&1; then
            vim "$envrc_file"
        fi
    }
    
    # Function to show direnv help
    function direnv_help() {
        echo "🔧 Direnv Commands:"
        echo "  da          - Allow .envrc in current directory"
        echo "  dd          - Deny .envrc in current directory"
        echo "  dr          - Reload .envrc in current directory"
        echo "  ds          - Show direnv status"
        echo "  de          - Edit .envrc file"
        echo "  direnv_init - Create a new .envrc template"
        echo ""
        echo "📖 Common .envrc patterns:"
        echo "  export VAR=value           - Set environment variable"
        echo "  dotenv_if_exists .env      - Load .env file"
        echo "  use python 3.11            - Use specific Python version"
        echo "  PATH_add ./bin             - Add directory to PATH"
        echo "  source_up_if_exists        - Load parent .envrc"
    }
    
else
    echo "⚠️  direnv not found. Install it with your package manager."
fi
