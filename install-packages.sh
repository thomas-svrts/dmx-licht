#!/bin/bash

# 1. Repository toevoegen
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

# 2. APT-bron toevoegen
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
  https://cli.github.com/packages stable main" | \
  sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# 3. Installeren
sudo apt update
sudo apt install gh -y


echo "📦 Installing required packages..."
sudo apt update
sudo apt install -y git hostapd iptables haveged lighttpd

sudo systemctl enable lighttpd


echo "📁 Cloning linux-router repo..."
curl -o lnxrouter https://raw.githubusercontent.com/garywill/linux-router/master/lnxrouter
chmod +x lnxrouter

echo "⚙️ Making lnxrouter globally available..."
sudo cp lnxrouter /usr/local/bin/

echo "✅ Done. Use ./start-ap.sh to start your access point."
