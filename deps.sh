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

export ZDOTDIR="${HOME}/.config/zshconf"  # Move config to a user-specific directory
if [[ ! -d "$ZDOTDIR" ]]; then
  git clone "https://github.com/danielvxsp/terminal-configuration.git" "$ZDOTDIR"
  chmod -R 755 "$ZDOTDIR"
else
  echo "$ZDOTDIR already exists. Skipping clone..."
fi

mkdir -p "${ZDOTDIR}/user"

# Determine the location for user-specific configuration
cfg_location="${XDG_CONFIG_HOME:-${HOME}/.config}/zsh"
if [[ ! -d "$cfg_location" ]]; then
  mkdir -p "$cfg_location"
fi

# Create a soft link for user configuration
ln -sf "$cfg_location" "${ZDOTDIR}/user/$USER"
chmod -R 700 "${ZDOTDIR}/user/$USER"

# Create completions directory
mkdir -p "${ZDOTDIR}/completions/$USER"
chmod 700 "${ZDOTDIR}/completions/$USER"

echo "Installing Oh My Zsh..."
if [[ ! -d "${ZDOTDIR}/ohmyzsh" ]]; then
  git clone "https://github.com/ohmyzsh/ohmyzsh.git" "${ZDOTDIR}/ohmyzsh"
else
  echo "Oh My Zsh already installed."
fi

# Set Zsh as the default shell (if not already set)
if [[ "$SHELL" != "/bin/zsh" ]]; then
  chsh -s /bin/zsh
fi

echo "Oh My Zsh installed successfully!"

if [[ ! -d "${ZDOTDIR}/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZDOTDIR}/powerlevel10k"
else
  echo "Powerlevel10k already installed."
fi

# Update the .zshrc file to use Powerlevel10k
if ! grep -q 'source "$ZDOTDIR/powerlevel10k/powerlevel10k.zsh-theme"' "${cfg_location}/.zshrc"; then
  echo 'source "$ZDOTDIR/powerlevel10k/powerlevel10k.zsh-theme"' >> "${cfg_location}/.zshrc"
fi

# Load config files to apply changes
source "${cfg_location}/.zshrc"

verboseLog "Installing Kitty terminal configuration..."

# Install Kitty configuration from the repo into ~/.config/kitty
kitty_config_location="${XDG_CONFIG_HOME:-${HOME}/.config}/kitty"

# Ensure the Kitty config directory exists
if [[ ! -d "$kitty_config_location" ]]; then
  mkdir -p "$kitty_config_location"
fi

# Copy only the Kitty config files from the repo, not the entire repo
if [[ -d "${ZDOTDIR}/kitty" ]]; then
  cp -r "${ZDOTDIR}/kitty/." "$kitty_config_location/"
  echo "Kitty configuration installed successfully!"
else
  echo "Kitty folder not found in the repository!"
fi

chmod -R 755 "$kitty_config_location"

echo "Kitty configuration installed successfully!"
echo "Setup completed successfully!"
