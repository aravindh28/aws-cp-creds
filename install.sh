#!/bin/bash
# install.sh - One-command setup for aws-cp-creds

echo "Installing AWS Academy Credentials Auto-Updater..."

# Download the script from GitHub
echo "Downloading update-aws-creds.sh..."
curl -fsSL https://raw.githubusercontent.com/aravindh28/aws-cp-creds/main/update-aws-creds.sh -o ~/update-aws-creds.sh

if [ $? -ne 0 ]; then
    echo "Error: Failed to download update-aws-creds.sh"
    exit 1
fi

chmod +x ~/update-aws-creds.sh
echo "Script installed to ~/update-aws-creds.sh"

# Detect shell and config file
if [ -f ~/.zshrc ]; then
    SHELL_CONFIG=~/.zshrc
elif [ -f ~/.bash_profile ]; then
    SHELL_CONFIG=~/.bash_profile
elif [ -f ~/.bashrc ]; then
    SHELL_CONFIG=~/.bashrc
else
    echo "Error: Could not find shell config file"
    exit 1
fi

# Check if alias already exists
if grep -q "alias aws-cp-creds=" "$SHELL_CONFIG"; then
    echo "Alias already exists in $SHELL_CONFIG"
else
    echo "" >> "$SHELL_CONFIG"
    echo "# AWS Academy Credentials Auto-Updater" >> "$SHELL_CONFIG"
    echo "alias aws-cp-creds='~/update-aws-creds.sh'" >> "$SHELL_CONFIG"
    echo "Alias added to $SHELL_CONFIG"
fi

echo ""
echo "Installation complete."
echo "Open a new terminal window, or run: source $SHELL_CONFIG"