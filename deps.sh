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

# Set Zsh as the default shell right after install
if [[ "$SHELL" != "/bin/zsh" ]]; then
  chsh -s /bin/zsh
  echo "Zsh is now the default shell. Please restart the terminal to use Zsh."
else
  echo "Zsh is already the default shell."
fi

# Clone your terminal configuration repository directly to the home directory
TERMINAL_CONFIG_DIR="${HOME}/.terminal-config"
if [[ ! -d "$TERMINAL_CONFIG_DIR" ]]; then
  git clone "https://github.com/danielvxsp/terminal-configuration.git" "$TERMINAL_CONFIG_DIR"
  chmod -R 755 "$TERMINAL_CONFIG_DIR"
else
  echo "$TERMINAL_CONFIG_DIR already exists. Skipping clone..."
fi

# Copy .zshrc and .p10k.zsh files to $HOME directory
verboseLog "Copying Zsh configuration files..."
if [[ -f "${TERMINAL_CONFIG_DIR}/.zshrc" ]]; then
  cp "${TERMINAL_CONFIG_DIR}/.zshrc" "${HOME}/.zshrc"
  echo ".zshrc copied successfully!"
else
  echo ".zshrc file not found in the repository!"
fi

# switch to zsh for the rest of the script (I dont think it works like this but its worth a shot)
zsh

# Install Oh My Zsh in its default location (~/.oh-my-zsh)
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh is already installed."
fi

# Install Powerlevel10k in its default location (~/.oh-my-zsh/custom/themes/powerlevel10k)
if [[ ! -d "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${HOME}/.oh-my-zsh/custom/themes/powerlevel10k
  echo "Powerlevel10k installed."
else
  echo "Powerlevel10k is already installed."
fi

if [[ -f "${TERMINAL_CONFIG_DIR}/.p10k.zsh" ]]; then
  cp "${TERMINAL_CONFIG_DIR}/.p10k.zsh" "${HOME}/.p10k.zsh"
  echo ".p10k.zsh copied successfully!"
else
  echo ".p10k.zsh file not found in the repository!"
fi

# Ensure Powerlevel10k is sourced in .zshrc
if ! grep -q 'source "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"' "${HOME}/.zshrc"; then
  echo 'source "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"' >> "${HOME}/.zshrc"
fi

source ~/.zshrc

verboseLog "Zsh setup completed successfully!"
