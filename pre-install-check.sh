#!/bin/bash
# PDE Pre-Installation Check
# Purpose: Verify all prerequisites are properly installed and configured

set -euo pipefail  # Restore -e now that we'll handle grep properly

echo "🔍 PDE Pre-Installation Check"
echo "============================"

ERRORS=0
WARNINGS=0

# Function to print status
print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK") echo "✅ $message" ;;
        "WARN") echo "⚠️  $message"; WARNINGS=$((WARNINGS + 1)) ;;
        "ERROR") echo "❌ $message"; ERRORS=$((ERRORS + 1)) ;;
    esac
}

# Check 1: Operating System
echo "📋 System Information:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    MACOS_VERSION=$(sw_vers -productVersion)
    print_status "OK" "macOS $MACOS_VERSION"
else
    print_status "ERROR" "This setup is designed for macOS only"
fi

# Check 2: Homebrew
echo ""
echo "📋 Package Manager:"
if command -v brew &> /dev/null; then
    BREW_VERSION=$(brew --version | head -n1)
    print_status "OK" "$BREW_VERSION"
    
    # Check if Homebrew is in PATH
    if [[ ":$PATH:" == *":/opt/homebrew/bin:"* ]] || [[ ":$PATH:" == *":/usr/local/bin:"* ]]; then
        print_status "OK" "Homebrew is in PATH"
    else
        print_status "WARN" "Homebrew may not be in PATH. Run: eval \"\$(brew shellenv)\""
    fi
else
    print_status "ERROR" "Homebrew not found. Install with:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
fi

# Check 3: Python
echo ""
echo "📋 Python:"
if command -v python3.12 &> /dev/null; then
    PYTHON_VERSION=$(python3.12 --version)
    print_status "OK" "$PYTHON_VERSION (via Homebrew)"
    
    # Check pip
    if python3.12 -m pip --version &> /dev/null; then
        PIP_VERSION=$(python3.12 -m pip --version | cut -d' ' -f2)
        print_status "OK" "pip $PIP_VERSION"
    else
        print_status "ERROR" "pip not available for python3.12"
    fi
elif command -v python3.11 &> /dev/null; then
    PYTHON_VERSION=$(python3.11 --version)
    print_status "OK" "$PYTHON_VERSION (via Homebrew)"
    print_status "WARN" "Python 3.12 recommended for best compatibility"
elif command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    PYTHON_MAJOR=$(python3 -c "import sys; print(sys.version_info.major)")
    PYTHON_MINOR=$(python3 -c "import sys; print(sys.version_info.minor)")
    
    if [[ $PYTHON_MAJOR -eq 3 && $PYTHON_MINOR -ge 11 ]]; then
        print_status "OK" "$PYTHON_VERSION"
    else
        print_status "ERROR" "$PYTHON_VERSION is too old. Need Python 3.11+"
        echo "   Install with: brew install python@3.12"
    fi
else
    print_status "ERROR" "Python 3 not found. Install with: brew install python@3.12"
fi

# Check 4: Ansible
echo ""
echo "📋 Ansible:"
if command -v ansible-playbook &> /dev/null; then
    ANSIBLE_VERSION=$(ansible-playbook --version | head -n1)
    print_status "OK" "$ANSIBLE_VERSION"
    
    # Check ansible-core version
    ANSIBLE_CORE_VERSION=$(ansible-playbook --version | head -n1 | grep -o '\[core [0-9]\+\.[0-9]\+' | grep -o '[0-9]\+\.[0-9]\+' || echo "")
    if [[ -n "$ANSIBLE_CORE_VERSION" ]]; then
        CORE_MAJOR=$(echo $ANSIBLE_CORE_VERSION | cut -d. -f1)
        CORE_MINOR=$(echo $ANSIBLE_CORE_VERSION | cut -d. -f2)
        
        if [[ $CORE_MAJOR -gt 2 ]] || [[ $CORE_MAJOR -eq 2 && $CORE_MINOR -ge 16 ]]; then
            print_status "OK" "ansible-core $ANSIBLE_CORE_VERSION (modern version)"
        else
            print_status "WARN" "ansible-core $ANSIBLE_CORE_VERSION (older version, may have warnings)"
            echo "   Consider upgrading: brew upgrade ansible"
        fi
    else
        print_status "WARN" "Could not determine ansible-core version"
    fi
    
    # Check Python interpreter used by Ansible
    ANSIBLE_PYTHON=$(ansible-playbook --version | grep "python version" | grep -o '/[^)]*python[^)]*' || echo "unknown")
    if [[ "$ANSIBLE_PYTHON" == *"homebrew"* ]] || [[ "$ANSIBLE_PYTHON" == *"3.1"* ]]; then
        print_status "OK" "Using modern Python: $ANSIBLE_PYTHON"
    else
        print_status "WARN" "Using system Python: $ANSIBLE_PYTHON"
    fi
else
    print_status "ERROR" "Ansible not found. Install with:"
    echo "   python3.12 -m pip install --upgrade ansible"
fi

# Check 5: Required Collections
echo ""
echo "📋 Ansible Collections:"
if command -v ansible-galaxy &> /dev/null; then
    # Check community.general
    COMMUNITY_OUTPUT=$(ansible-galaxy collection list community.general 2>/dev/null)
    COMMUNITY_VERSION=$(echo "$COMMUNITY_OUTPUT" | grep -E "^community\.general" | awk '{print $2}' | head -n1)
    if [[ -n "$COMMUNITY_VERSION" ]]; then
        print_status "OK" "community.general $COMMUNITY_VERSION"
    else
        print_status "ERROR" "community.general collection not found"
        echo "   Install with: ansible-galaxy collection install community.general"
    fi
    
    # Check ansible.posix
    POSIX_OUTPUT=$(ansible-galaxy collection list ansible.posix 2>/dev/null)
    POSIX_VERSION=$(echo "$POSIX_OUTPUT" | grep -E "^ansible\.posix" | awk '{print $2}' | head -n1)
    if [[ -n "$POSIX_VERSION" ]]; then
        print_status "OK" "ansible.posix $POSIX_VERSION"
    else
        print_status "ERROR" "ansible.posix collection not found"
        echo "   Install with: ansible-galaxy collection install ansible.posix"
    fi
else
    print_status "ERROR" "ansible-galaxy command not found"
fi

# Check 6: Configuration
echo ""
echo "📋 Configuration:"
if [[ -f "vars.yml" ]]; then
    print_status "OK" "vars.yml exists"
    
    # Check if customized - extract grep result to avoid set -e issues
    PLACEHOLDER_CHECK=$(grep -c "Your Full Name\|your.email@example.com" vars.yml 2>/dev/null || echo "0")
    if [[ "$PLACEHOLDER_CHECK" -gt 0 ]]; then
        print_status "WARN" "vars.yml contains placeholder values - please customize"
    else
        print_status "OK" "vars.yml appears customized"
    fi
else
    print_status "ERROR" "vars.yml not found. Copy from: cp vars.yml.example vars.yml"
fi

# Summary
echo ""
echo "📊 Summary:"
echo "=========="
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    print_status "OK" "All checks passed! Ready to run ansible-playbook playbook.yml"
elif [[ $ERRORS -eq 0 ]]; then
    print_status "WARN" "$WARNINGS warning(s) found - you can proceed but consider fixing them"
    echo ""
    echo "🚀 Ready to run: ansible-playbook playbook.yml"
else
    print_status "ERROR" "$ERRORS error(s) and $WARNINGS warning(s) found"
    echo ""
    echo "❌ Please fix the errors above before running ansible-playbook playbook.yml"
    echo "📖 See README.md for detailed setup instructions"
    exit 1
fi
