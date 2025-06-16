#!/bin/bash

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
