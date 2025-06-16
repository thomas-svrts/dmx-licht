#!/bin/bash

echo "📦 Installing required packages..."
sudo apt update
sudo apt install -y hostapd dnsmasq

echo "🛑 Stopping services before config..."
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq

echo "📁 Copying config files..."
sudo cp Setup/dhcpcd.conf /etc/dhcpcd.conf
sudo cp Setup/dnsmasq.conf /etc/dnsmasq.conf
sudo cp Setup/hostapd.conf /etc/hostapd/hostapd.conf
sudo cp Setup/hostapd-default /etc/default/hostapd

echo "🔁 Restarting network service..."
sudo service dhcpcd restart

echo "🚀 Enabling services at boot..."
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq

echo "✅ Setup complete. Reboot to start access point."
