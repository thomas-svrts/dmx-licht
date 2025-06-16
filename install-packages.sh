#!/bin/bash

echo "📦 Installing required packages..."
sudo apt update
sudo apt install -y \
    dnsmasq dhcpcd5 git curl wget \
    build-essential libnl-3-dev libnl-genl-3-dev pkg-config

echo "🔧 Disabling NetworkManager (if present)..."
sudo systemctl stop NetworkManager 2>/dev/null || true
sudo systemctl disable NetworkManager 2>/dev/null || true

echo "🛑 Stopping conflicting services..."
sudo systemctl stop hostapd || true
sudo systemctl stop dnsmasq || true
sudo systemctl stop dhcpcd || true

echo "📁 Copying network configuration files..."
sudo cp setup/dhcpcd.conf /etc/dhcpcd.conf
sudo cp setup/dnsmasq.conf /etc/dnsmasq.conf
sudo cp setup/hostapd.conf /etc/hostapd/hostapd.conf
sudo cp setup/hostapd-default /etc/default/hostapd

echo "🐧 Cloning Raspberry Pi's official hostapd fork..."
cd /tmp
git clone --depth 1 https://github.com/RPi-Distro/hostapd.git
cd hostapd/hostapd

echo "🧱 Configuring and building hostapd..."
cp defconfig .config
echo CONFIG_DRIVER_NL80211=y >> .config
make

echo "✅ Installing compiled hostapd..."
sudo cp hostapd /usr/sbin/hostapd
sudo chmod +x /usr/sbin/hostapd

echo "🧹 Cleaning up..."
cd ~
rm -rf /tmp/hostapd

echo "🔁 Enabling and starting services..."
sudo systemctl unmask hostapd
sudo systemctl enable dhcpcd
sudo systemctl enable dnsmasq
sudo systemctl enable hostapd
sudo systemctl start dhcpcd
sudo systemctl start dnsmasq
sudo systemctl start hostapd

echo "🚀 Done! Reboot your Pi to activate the access point."
