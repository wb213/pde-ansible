# Personal Development Environment (PDE)

[English](#english) | [中文](#中文)

---

## English

### Overview

A simple Ansible-based boilerplate for setting up a personal development environment. This project provides automated configuration for essential development tools and shell environment across different platforms.

### System Requirements

- **macOS**: 10.15+ (Catalina or later)
- **Linux**: RHEL/Fedora 8+, Ubuntu 18.04+, Debian 10+

### ⚠️ WARNING

- **macOS**: Fresh installations not tested - this configuration was migrated from an existing environment
- **Linux**: Installation not fully tested - I will verify this later

### Usage

#### 1. Install Prerequisites

**macOS:**
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python and Ansible
brew install python@3.12 ansible

# Install required collections
ansible-galaxy collection install community.general ansible.posix
```

**Linux (RHEL/Fedora):**
```bash
sudo dnf install python3 python3-pip ansible
ansible-galaxy collection install community.general ansible.posix
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt update && sudo apt install python3 python3-pip ansible
ansible-galaxy collection install community.general ansible.posix
```

#### 2. Configure Settings

```bash
# Copy example configuration
cp vars.yml.example vars.yml

# Edit with your information
vim vars.yml
```

Required settings:
```yaml
git_user_name: "Your Full Name"
git_user_email: "your.email@example.com"
```

#### 3. Backup Configuration Files

**⚠️ Important**: Back up your existing configuration files before running the setup. This process will modify shell configurations but won't affect installed packages.

```bash
# Backup important files
cp ~/.zprofile ~/.zprofile.backup
cp ~/.zshrc ~/.zshrc.backup
cp -r ~/.config ~/.config.backup
```

**Emergency Recovery**: Set up an emergency recovery method (e.g., configure a key binding in WezTerm to start a bash shell session) in case configuration errors prevent zsh from starting properly.

#### 4. Run Setup

```bash
# Check prerequisites
./pre-install-check.sh

# Run the setup
ansible-playbook playbook.yml

# Restart terminal or reload configuration
source ~/.zshrc
```

### Future Plans

- Migrate to Nix for language-specific configurations
- Optimize project structure and organization
- Improve cross-platform compatibility

---

## 中文

### 项目概述

基于 Ansible 的个人开发环境配置模板。本项目提供跨平台的开发工具和 Shell 环境自动化配置。

### 系统要求

- **macOS**: 10.15+ (Catalina 或更高版本)
- **Linux**: RHEL/Fedora 8+, Ubuntu 18.04+, Debian 10+

### ⚠️ 警告

- **macOS**: 未在全新安装的 Mac 上测试 - 此配置从现有环境迁移而来
- **Linux**: 安装未经充分验证 - 后续会进行测试

### 使用步骤

#### 1. 安装前置条件

**macOS:**
```bash
# 安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 Python 和 Ansible
brew install python@3.12 ansible

# 安装必需的集合
ansible-galaxy collection install community.general ansible.posix
```

**Linux (RHEL/Fedora):**
```bash
sudo dnf install python3 python3-pip ansible
ansible-galaxy collection install community.general ansible.posix
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt update && sudo apt install python3 python3-pip ansible
ansible-galaxy collection install community.general ansible.posix
```

#### 2. 配置设置

```bash
# 复制示例配置
cp vars.yml.example vars.yml

# 编辑你的信息
vim vars.yml
```

必需设置:
```yaml
git_user_name: "你的全名"
git_user_email: "your.email@example.com"
```

#### 3. 备份配置文件

**⚠️ 重要**: 运行安装前请备份现有配置文件。此过程会修改 shell 配置，但不会影响已安装的软件包。

```bash
# 备份重要文件
cp ~/.zprofile ~/.zprofile.backup
cp ~/.zshrc ~/.zshrc.backup
cp -r ~/.config ~/.config.backup
```

**紧急恢复**: 设置紧急恢复方法（例如在 WezTerm 中配置快捷键启动 bash shell 会话），以防配置错误导致 zsh 无法正常启动。

#### 4. 运行安装

```bash
# 检查前置条件
./pre-install-check.sh

# 运行安装
ansible-playbook playbook.yml

# 重启终端或重新加载配置
source ~/.zshrc
```

### 未来计划

- 迁移到 Nix 管理语言相关配置
- 优化项目结构和组织方式
- 改进跨平台兼容性


