#!/bin/bash
sudo apt purge -y dnsmasq dhcpcd5 hostapd



echo "📦 Installing required packages..."
sudo apt update
sudo apt install -y git dnsmasq iptables

echo "📁 Cloning linux-router repo..."
git clone https://github.com/garywill/linux-router.git ~/linux-router

echo "⚙️ Making lnxrouter globally available..."
sudo cp ~/linux-router/lnxrouter /usr/local/bin/
sudo chmod +x /usr/local/bin/lnxrouter

echo "✅ Done. Use ./start-ap.sh to start your access point."
