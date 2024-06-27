#!/bin/bash

set -e

# Function to detect the Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    elif type lsb_release >/dev/null 2>&1; then
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO=$DISTRIB_ID
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
    elif [ -f /etc/fedora-release ]; then
        DISTRO="fedora"
    elif [ -f /etc/centos-release ]; then
        DISTRO="centos"
    else
        DISTRO="unknown"
    fi
    echo $DISTRO
}

# Function to install Firefox based on the detected distribution
install_firefox() {
    case $1 in
        ubuntu|debian|linuxmint)
            sudo apt update
            sudo apt install -y software-properties-common
            sudo add-apt-repository -y ppa:mozillateam/ppa
            echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | sudo tee /etc/apt/preferences.d/mozilla-firefox
            echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox
            sudo apt update
            sudo apt install -y firefox
            ;;
        fedora)
            sudo dnf install -y firefox
            ;;
        centos|rhel)
            sudo dnf install -y firefox
            ;;
        arch|manjaro)
            sudo pacman -Sy firefox
            ;;
        opensuse*)
            sudo zypper install -y MozillaFirefox
            ;;
        *)
            echo "Unsupported distribution. Please install Firefox manually."
            exit 1
            ;;
    esac
}

# Main script
echo "Detecting Linux distribution..."
DISTRO=$(detect_distro)
echo "Detected distribution: $DISTRO"

echo "Installing Firefox..."
install_firefox $DISTRO

# Verify Firefox installation
if command -v firefox &> /dev/null; then
    firefox_version=$(firefox --version)
    echo "Firefox installed successfully. Version: $firefox_version"
else
    echo "Error: Firefox installation failed or Firefox is not in the system PATH."
    exit 1
fi

echo "Installation complete!"
