rk#!/bin/bash

echo "📦 Installing required packages..."
sudo apt update
sudo apt install -y dnsmasq dhcpcd5 raspberrypi-kernel-headers build-essential libnl-3-dev libnl-genl-3-dev pkg-config git curl wget


echo "🔧 Disabling NetworkManager..."
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager

echo "🛑 Stopping services before config..."
sudo systemctl stop hostapd || true
sudo systemctl stop dnsmasq || true
sudo systemctl stop dhcpcd || true

echo "📁 Copying config files..."
sudo cp setup/dhcpcd.conf /etc/dhcpcd.conf
sudo cp setup/dnsmasq.conf /etc/dnsmasq.conf
sudo cp setup/hostapd.conf /etc/hostapd/hostapd.conf
sudo cp setup/hostapd-default /etc/default/hostapd

echo "⚙️ remove old patched hostapd..."
sudo apt purge -y hostapd

echo "🧱 Cloning and building patched hostapd..."
git clone --depth 1 https://github.com/oblique/create_ap.git
cd create_ap/hostapd || exit 1
make
cd ../../
sudo cp create_ap/hostapd/hostapd /usr/sbin/hostapd
sudo chmod +x /usr/sbin/hostapd
rm -rf create_ap

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
