rk#!/bin/bash

echo "📦 Installing required packages..."
sudo apt update
sudo apt install -y dnsmasq dhcpcd5 raspberrypi-kernel-headers wget curl


echo "🔧 Disabling NetworkManager..."
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager

echo "🛑 Stopping services before config..."
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
sudo systemctl stop dhcpcd || true

echo "📁 Copying config files..."
sudo cp setup/dhcpcd.conf /etc/dhcpcd.conf
sudo cp setup/dnsmasq.conf /etc/dnsmasq.conf
sudo cp setup/hostapd.conf /etc/hostapd/hostapd.conf
sudo cp setup/hostapd-default /etc/default/hostapd

echo "⚙️ Installing patched hostapd..."
sudo apt purge -y hostapd
wget -O hostapd https://github.com/oblique/create_ap/releases/download/v0.4.6/hostapd
sudo mv hostapd /usr/sbin/hostapd
sudo chmod +x /usr/sbin/hostapd


echo "🔁 Enabling services..."
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq
sudo systemctl enable dhcpcd

echo "🚀 Starting services..."
sudo systemctl start dhcpcd
sudo systemctl start dnsmasq
sudo systemctl start hostapd

echo "✅ Setup complete. You can now reboot."
