# ===================================================================
# 📁 Direnv Configuration - Environment Variable Management
# ===================================================================
# Direnv automatically loads and unloads environment variables
# based on the current directory, using .envrc files

# Check if direnv is installed and defer its initialization
if command -v direnv >/dev/null 2>&1; then
    # Use zsh-defer if available, otherwise load normally
    if (( ${+functions[zsh-defer]} )); then
        zsh-defer eval "$(direnv hook zsh)"
    else
        eval "$(direnv hook zsh)"
    fi
    
    # Optional: Set direnv configuration
    export DIRENV_LOG_FORMAT=""  # Disable direnv log messages (set to "" for quiet)
    
    # Direnv aliases for convenience
    alias da='direnv allow'      # Allow .envrc in current directory
    alias dd='direnv deny'       # Deny .envrc in current directory  
    alias dr='direnv reload'     # Reload .envrc in current directory
    alias ds='direnv status'     # Show direnv status
    alias de='direnv edit'       # Edit .envrc file
fi
