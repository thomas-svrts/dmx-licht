#!/bin/bash

echo "📦 Installing required packages..."
sudo apt update
sudo apt install -y hostapd dnsmasq dhcpcd5

echo "🔧 Disabling NetworkManager..."
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager

echo "🛑 Stopping services before config..."
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
sudo systemctl stop dhcpcd || true

echo "📁 Copying config files..."
sudo cp Setup/dhcpcd.conf /etc/dhcpcd.conf
sudo cp Setup/dnsmasq.conf /etc/dnsmasq.conf
sudo cp Setup/hostapd.conf /etc/hostapd/hostapd.conf
sudo cp Setup/hostapd-default /etc/default/hostapd

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
