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

if [ ! -s ~/update-aws-creds.sh ]; then
    echo "Error: Downloaded update-aws-creds.sh is missing or empty"
    exit 1
fi

chmod 700 ~/update-aws-creds.sh
echo "Script installed to ~/update-aws-creds.sh"

# Detect shell and config file
if [ -f ~/.zshrc ]; then
    SHELL_CONFIG=~/.zshrc
elif [ -f ~/.bash_profile ]; then
    SHELL_CONFIG=~/.bash_profile
elif [ -f ~/.bashrc ]; then
    SHELL_CONFIG=~/.bashrc
else
    # No config file exists, create one based on current shell
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_CONFIG=~/.zshrc
        touch "$SHELL_CONFIG"
        echo "Created $SHELL_CONFIG"
    else
        SHELL_CONFIG=~/.bash_profile
        touch "$SHELL_CONFIG"
        echo "Created $SHELL_CONFIG"
    fi
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