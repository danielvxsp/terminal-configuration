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
  verboseLog "Authentication successful"
else
  verboseLog "Insufficient privileges"
  exit 1
fi

verboseLog "Installing dependencies..."
$install_cmd git curl zsh kitty

# Clone your terminal configuration repository directly to the home directory
TERMINAL_CONFIG_DIR="${HOME}/.terminal-config"
if [[ ! -d "$TERMINAL_CONFIG_DIR" ]]; then
  git clone "https://github.com/danielvxsp/terminal-configuration.git" "$TERMINAL_CONFIG_DIR"
  chmod -R 755 "$TERMINAL_CONFIG_DIR"
else
  verboseLog "$TERMINAL_CONFIG_DIR already exists. Skipping clone..."
fi

# Copy .zshrc and .p10k.zsh files to $HOME directory
verboseLog "Copying Zsh and Powerlevel10k configuration files..."
if [[ -f "${TERMINAL_CONFIG_DIR}/.zshrc" ]]; then
  cp "${TERMINAL_CONFIG_DIR}/.zshrc" "${HOME}/.zshrc"
  verboseLog ".zshrc copied successfully!"
else
  verboseLog ".zshrc file not found in the repository!"
fi

if [[ -f "${TERMINAL_CONFIG_DIR}/.p10k.zsh" ]]; then
  cp "${TERMINAL_CONFIG_DIR}/.p10k.zsh" "${HOME}/.p10k.zsh"
  verboseLog ".p10k.zsh copied successfully!"
else
  verboseLog ".p10k.zsh file not found in the repository!"
fi

# Set Zsh as the default shell if not already
if [[ "$SHELL" != "/bin/zsh" ]]; then
  chsh -s /bin/zsh
  echo "Zsh is now the default shell. Please restart the terminal to use Zsh."
else
  verboseLog "Zsh is already the default shell."
fi

# Install Oh My Zsh if not already installed
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
  verboseLog "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  verboseLog "Oh My Zsh is already installed."
fi

# Install Powerlevel10k if not already installed
if [[ ! -d "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${HOME}/.oh-my-zsh/custom/themes/powerlevel10k
  verboseLog "Powerlevel10k installed."
else
  verboseLog "Powerlevel10k is already installed."
fi

# Ensure Powerlevel10k is sourced in .zshrc
if ! grep -q 'source "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"' "${HOME}/.zshrc"; then
  echo 'source "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"' >> "${HOME}/.zshrc"
  verboseLog "Powerlevel10k theme sourced in .zshrc."
fi

# Copy Kitty config files from the repository to .config/kitty
KITTY_CONFIG_DIR="${HOME}/.config/kitty"
if [[ -d "${TERMINAL_CONFIG_DIR}/kitty" ]]; then
  mkdir -p "$KITTY_CONFIG_DIR"
  cp -r "${TERMINAL_CONFIG_DIR}/kitty/." "$KITTY_CONFIG_DIR"
  verboseLog "Kitty config files copied to ${KITTY_CONFIG_DIR}."
else
  verboseLog "Kitty config files not found in the repository."
fi

# Optionally delete the cloned repository
read -p "Do you want to delete the terminal configuration repo? (y/n): " delete_repo
if [[ $delete_repo == "y" ]]; then
  rm -rf "$TERMINAL_CONFIG_DIR"
  verboseLog "Terminal configuration repository deleted."
else
  verboseLog "Terminal configuration repository retained."
fi

source ~/.zshrc

verboseLog "Zsh setup completed successfully!"
