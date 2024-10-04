#!/usr/bin/env bash

verboseLog() {
  echo "$1"
}

# Check if pacman or dnf is available for Arch or Fedora-based systems
if command -v pacman &>/dev/null; then
  package_manager="pacman"
  install_cmd="sudo pacman -S --noconfirm"
elif command -v dnf &>/dev/null; then
  package_manager="dnf"
  install_cmd="sudo dnf install -y"
else
  echo "Unsupported system. This script only supports Arch or Fedora-based systems."
  exit 1
fi

# Check for sudo privileges
if sudo -v; then
  echo "Successful"
else
  echo "Insufficient privileges"
  exit 1
fi

verboseLog "Installing dependencies..."
$install_cmd git curl zsh kitty

# Set ZDOTDIR for user-specific Zsh configuration
export ZDOTDIR="${HOME}/.config/zshconf"
mkdir -p "$ZDOTDIR"

# Clone your terminal configuration repository
if [[ ! -d "$ZDOTDIR" ]]; then
  git clone "https://github.com/danielvxsp/terminal-configuration.git" "$ZDOTDIR"
  chmod -R 755 "$ZDOTDIR"
else
  echo "$ZDOTDIR already exists. Skipping clone..."
fi

# Copy .zshrc and .p10k.zsh files to ZDOTDIR
verboseLog "Copying Zsh configuration files..."
if [[ -f "${ZDOTDIR}/.zshrc" ]]; then
  cp "${ZDOTDIR}/.zshrc" "${HOME}/.zshrc"
  echo ".zshrc copied successfully!"
else
  echo ".zshrc file not found in the repository!"
fi

if [[ -f "${ZDOTDIR}/.p10k.zsh" ]]; then
  cp "${ZDOTDIR}/.p10k.zsh" "${HOME}/.p10k.zsh"
  echo ".p10k.zsh copied successfully!"
else
  echo ".p10k.zsh file not found in the repository!"
fi

# Install Oh My Zsh in its default location (~/.oh-my-zsh)
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh is already installed."
fi

# Install Powerlevel10k in its default location (~/.oh-my-zsh/custom/themes/powerlevel10k)
if [[ ! -d "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k"
  echo "Powerlevel10k installed."
else
  echo "Powerlevel10k is already installed."
fi

# Ensure Powerlevel10k is sourced in .zshrc
if ! grep -q 'source "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"' "${HOME}/.zshrc"; then
  echo 'source "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"' >> "${HOME}/.zshrc"
fi

# Ensure .p10k.zsh is sourced
if ! grep -q 'source "${HOME}/.p10k.zsh"' "${HOME}/.zshrc"; then
  echo 'source "${HOME}/.p10k.zsh"' >> "${HOME}/.zshrc"
  echo ".p10k.zsh sourced successfully!"
fi

# Set Zsh as the default shell
if [[ "$SHELL" != "/bin/zsh" ]]; then
  chsh -s /bin/zsh
  echo "Zsh is now the default shell. Please restart the terminal to use Zsh."
else
  echo "Zsh is already the default shell."
fi

# Load the Zsh configuration
source "${HOME}/.zshrc"

verboseLog "Zsh and Powerlevel10k setup completed successfully!"
