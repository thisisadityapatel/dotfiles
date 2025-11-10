#!/bin/bash

set -e

FORMULAE=(
    "docker"
    "awscli"
    "nvm"
    "cmake"
    "yarn"
    "poetry"
    "spaceship"
)

CASKS=(
    "zed"
    "cursor"
    "ghostty"
    "spotify"
    "zen-browser"
)

NPM_PACKAGES=(
    "@anthropic-ai/claude-code"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

brew_installed() {
    brew list "$1" &>/dev/null
}

cask_installed() {
    brew list --cask "$1" &>/dev/null
}

install_homebrew() {
    if command_exists brew; then
        log_info "Homebrew already installed"
    else
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
}

install_xcode() {
    if xcode-select -p &>/dev/null; then
        log_info "Xcode Command Line Tools already installed"
    else
        log_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        log_warn "Please complete the Xcode installation and run this script again"
        exit 0
    fi
}

install_formulae() {
    log_info "Installing Homebrew formulae..."
    for formula in "${FORMULAE[@]}"; do
        if brew_installed "$formula"; then
            log_info "$formula already installed"
        else
            log_info "Installing $formula..."
            brew install "$formula"
        fi
    done
}

install_casks() {
    log_info "Installing Homebrew casks..."
    for cask in "${CASKS[@]}"; do
        if cask_installed "$cask"; then
            log_info "$cask already installed"
        else
            log_info "Installing $cask..."
            brew install --cask "$cask"
        fi
    done
}

link_dotfiles() {
    log_info "Linking dotfiles..."

    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [[ -f "$DOTFILES_DIR/ghostty/config" ]]; then
        mkdir -p ~/.config/ghostty
        ln -sf "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config
        log_info "Ghostty config linked"
    fi
}

main() {
    log_info "Starting dotfiles setup..."
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS only"
        exit 1
    fi

    install_xcode
    install_homebrew
    install_formulae
    install_casks
    log_info "Setup complete."
}

main
