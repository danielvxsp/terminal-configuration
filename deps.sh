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

export ZDOTDIR="/opt/zshconf" # Install config to a dedicated directory
sudo git clone "https://github.com/danielvxsp/terminal-configuration.git" "$ZDOTDIR"
sudo chmod -R 755 "$ZDOTDIR"
sudo mkdir -p "${ZDOTDIR}/user"
sudo chmod 777 "${ZDOTDIR}/user"

# Determine the location for user-specific configuration
cfg_location="${XDG_CONFIG_HOME:-${HOME}/.config}/zsh"
if [[ ! -d "$cfg_location" ]]; then
  mkdir -p "$cfg_location"
fi

# Create a soft link for user configuration
ln -s "$cfg_location" "${ZDOTDIR}/user/$USER"
chmod -R 700 "${ZDOTDIR}/user/$USER"

# Create completions directory
sudo chmod 777 "${ZDOTDIR}/completions"
mkdir -p "${ZDOTDIR}/completions/$USER"
chmod 700 "${ZDOTDIR}/completions/$USER"

echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set Zsh as the default shell
chsh -s /bin/zsh

echo "Oh My Zsh installed successfully!"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZDOTDIR}/powerlevel10k"

# Update the .zshrc file to use Powerlevel10k
echo 'source "$ZDOTDIR/powerlevel10k/powerlevel10k.zsh-theme"' >> "${cfg_location}/.zshrc"

# Load config files to apply changes
source "${cfg_location}/.zshrc"
source "${cfg_location}/.p10k.zsh"

verboseLog "Installing Kitty terminal configuration..."

# Install Kitty configuration from the repo into ~/.config/kitty
kitty_config_location="${XDG_CONFIG_HOME:-${HOME}/.config}/kitty"
if [[ ! -d "$kitty_config_location" ]]; then
  mkdir -p "$kitty_config_location"
fi

# Copy or clone the Kitty config from the repo
git clone "https://github.com/danielvxsp/terminal-configuration.git" "${kitty_config_location}"
sudo chmod -R 755 "${kitty_config_location}"

echo "Kitty configuration installed successfully!"

echo "Setup completed successfully!"
