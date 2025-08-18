#!/bin/bash

# PDE Configuration Drift Detection Script
# Compares current system state with Ansible-generated baseline

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Detect platform
PLATFORM=$(uname -s)
if [[ "$PLATFORM" == "Darwin" ]]; then
    OS_FAMILY="Darwin"
elif [[ -f /etc/redhat-release ]]; then
    OS_FAMILY="RedHat"
elif [[ -f /etc/debian_version ]]; then
    OS_FAMILY="Debian"
else
    OS_FAMILY="Unknown"
fi

# Generate current state snapshot
generate_current_state() {
    {
        echo "# PDE Current State - Generated $(date)"
        echo "# Platform: $OS_FAMILY"
        echo "# User: $(whoami)"
        echo "# Home: $HOME"
        echo ""
        
        echo "=== HOMEBREW_PACKAGES ==="
        if command -v brew >/dev/null 2>&1; then
            brew list --formula | sort
        fi
        
        echo "=== HOMEBREW_CASKS ==="
        if command -v brew >/dev/null 2>&1; then
            brew list --cask | sort
        fi
        
        echo "=== HOMEBREW_TAPS ==="
        if command -v brew >/dev/null 2>&1; then
            brew tap | sort
        fi
        
        echo "=== DNF_PACKAGES ==="
        if command -v dnf >/dev/null 2>&1; then
            dnf list installed 2>/dev/null | awk 'NR>1 {print $1}' | sort
        fi
        
        echo "=== APT_PACKAGES ==="
        if command -v dpkg-query >/dev/null 2>&1; then
            dpkg-query -W -f='${Package}\n' | sort
        fi
        
        echo "=== CURRENT_DOTFILES ==="
        find ~ -maxdepth 1 -name ".*" -type f | sed "s|$HOME/||" | sort
        
        echo "=== CURRENT_CONFIG_DIRS ==="
        find ~/.config -maxdepth 1 -type d 2>/dev/null | sed "s|$HOME/||" | sort
        
        echo "=== GIT_CONFIG ==="
        git config --list 2>/dev/null | grep -E "^(user\.|core\.)" | sort || true
        
        echo "=== SHELL_CONFIG ==="
        echo "default_shell:$SHELL"
        echo "zinit_installed:$([ -d ~/.local/share/zinit ] && echo yes || echo no)"
        echo "starship_installed:$(command -v starship >/dev/null && echo yes || echo no)"
        
        echo "=== TOOL_VERSIONS ==="
        for tool in helix zellij yazi eza bat fd rg fzf jq; do
            if command -v "$tool" >/dev/null 2>&1; then
                version=$("$tool" --version 2>/dev/null | head -1 || echo "unknown")
                echo "$tool:$version"
            fi
        done
        
        echo "=== FILE_CHECKSUMS ==="
        for file in ~/.zshrc ~/.gitconfig ~/.config/starship.toml; do
            if [ -f "$file" ]; then
                if command -v md5 >/dev/null 2>&1; then
                    # macOS
                    echo "$(basename "$file"):$(md5 -q "$file")"
                elif command -v md5sum >/dev/null 2>&1; then
                    # Linux
                    echo "$(basename "$file"):$(md5sum "$file" | cut -d' ' -f1)"
                fi
            fi
        done
        
    } > ~/.pde-current.txt
}

# Normalize snapshot files for comparison
normalize_snapshot() {
    local input_file="$1"
    local output_file="$2"
    
    awk '
    /^#/ { next }                          # Skip comments
    /^$/ { next }                          # Skip empty lines
    /^=== (.+) ===$/ { 
        section = $2; 
        gsub(/===/, "", section);
        gsub(/ /, "", section);
        next 
    }
    { 
        if (section != "") {
            print section ":" $0
        }
    }' "$input_file" | sort > "$output_file"
}

# Show colored diff output
show_colored_diff() {
    local diff_file="$1"
    
    while IFS= read -r line; do
        case "$line" in
            +++*|---*) 
                echo -e "${BLUE}📄 $line${NC}" ;;
            @@*) 
                echo -e "${PURPLE}📍 $line${NC}" ;;
            +*) 
                echo -e "${GREEN}🟢 $line${NC}" ;;  # Added
            -*) 
                echo -e "${RED}🔴 $line${NC}" ;;   # Removed
            *) 
                echo "   $line" ;;
        esac
    done < "$diff_file"
}

# Main drift detection function
detect_drift() {
    echo -e "${CYAN}🔍 Detecting PDE configuration drift...${NC}"
    echo ""
    
    # Check if baseline exists
    if [ ! -f ~/.pde-baseline.txt ]; then
        echo -e "${RED}❌ No baseline found.${NC}"
        echo "   Run 'ansible-playbook playbook.yml' to generate baseline."
        echo "   Or run 'ansible-playbook playbook.yml --tags baseline' to update baseline only."
        exit 1
    fi
    
    # Show baseline info
    baseline_date=$(head -1 ~/.pde-baseline.txt | sed 's/# PDE Baseline Snapshot - Generated //')
    echo -e "${BLUE}📊 Baseline created: $baseline_date${NC}"
    
    # Generate current state
    echo -e "${YELLOW}📊 Capturing current system state...${NC}"
    generate_current_state
    
    # Normalize both files
    echo -e "${YELLOW}🔧 Normalizing snapshots for comparison...${NC}"
    normalize_snapshot ~/.pde-baseline.txt /tmp/pde-baseline-normalized.txt
    normalize_snapshot ~/.pde-current.txt /tmp/pde-current-normalized.txt
    
    # Compare and show results
    echo -e "${YELLOW}📋 Comparing baseline vs current state...${NC}"
    echo ""
    
    if diff -u /tmp/pde-baseline-normalized.txt /tmp/pde-current-normalized.txt > /tmp/pde-drift.diff 2>/dev/null; then
        echo -e "${GREEN}✅ No drift detected - system matches baseline!${NC}"
        echo ""
        echo -e "${BLUE}📈 System state summary:${NC}"
        
        # Show some stats
        packages=$(grep -c "^HOMEBREW_PACKAGES:" /tmp/pde-baseline-normalized.txt 2>/dev/null || echo "0")
        dotfiles=$(grep -c "^MANAGED_DOTFILES:" /tmp/pde-baseline-normalized.txt 2>/dev/null || echo "0")
        tools=$(grep -c "^TOOL_VERSIONS:" /tmp/pde-baseline-normalized.txt 2>/dev/null || echo "0")
        
        echo "   📦 Packages managed: $packages"
        echo "   📁 Dotfiles managed: $dotfiles"
        echo "   🔧 Tools tracked: $tools"
        
        # Cleanup and exit with success
        rm -f /tmp/pde-*normalized.txt /tmp/pde-drift.diff ~/.pde-current.txt
        return 0
        
    else
        echo -e "${YELLOW}⚠️  Configuration drift detected:${NC}"
        echo ""
        
        # Show colored diff
        show_colored_diff /tmp/pde-drift.diff
        
        echo ""
        echo -e "${BLUE}Legend:${NC}"
        echo -e "${GREEN}🟢 = Added (not in baseline)${NC}"
        echo -e "${RED}🔴 = Removed (missing from current)${NC}"
        echo ""
        echo -e "${CYAN}💡 Actions you can take:${NC}"
        echo "   • To update baseline: ansible-playbook playbook.yml --tags baseline"
        echo "   • To restore from baseline: ansible-playbook playbook.yml"
        echo "   • To see raw diff: diff ~/.pde-baseline.txt ~/.pde-current.txt"
        echo ""
        
        # Show drift summary
        added_count=$(grep -c "^+" /tmp/pde-drift.diff 2>/dev/null || echo "0")
        removed_count=$(grep -c "^-" /tmp/pde-drift.diff 2>/dev/null || echo "0")
        echo -e "${YELLOW}📊 Drift summary: $added_count added, $removed_count removed${NC}"
        
        # Cleanup and exit with error
        rm -f /tmp/pde-*normalized.txt /tmp/pde-drift.diff ~/.pde-current.txt
        return 1
    fi
}

# Show help
show_help() {
    echo "PDE Configuration Drift Detection"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --verbose  Show verbose output"
    echo "  -q, --quiet    Show minimal output"
    echo ""
    echo "Examples:"
    echo "  $0              # Check for drift"
    echo "  $0 --verbose    # Check with detailed output"
    echo ""
    echo "Files:"
    echo "  ~/.pde-baseline.txt  # Baseline snapshot (generated by Ansible)"
    echo "  ~/.pde-current.txt   # Current state (temporary, auto-deleted)"
    echo ""
}

# Parse command line arguments
VERBOSE=false
QUIET=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Main execution
if [[ "$QUIET" == "true" ]]; then
    # For quiet mode, capture the diff result directly
    if [ ! -f ~/.pde-baseline.txt ]; then
        echo "❌ No baseline"
        exit 1
    fi
    
    generate_current_state > /dev/null 2>&1
    normalize_snapshot ~/.pde-baseline.txt /tmp/pde-baseline-normalized.txt > /dev/null 2>&1
    normalize_snapshot ~/.pde-current.txt /tmp/pde-current-normalized.txt > /dev/null 2>&1
    
    if diff -q /tmp/pde-baseline-normalized.txt /tmp/pde-current-normalized.txt > /dev/null 2>&1; then
        echo "✅ No drift"
        rm -f /tmp/pde-*normalized.txt ~/.pde-current.txt
        exit 0
    else
        echo "⚠️  Drift detected"
        rm -f /tmp/pde-*normalized.txt ~/.pde-current.txt
        exit 1
    fi
else
    detect_drift
    exit $?
fi
