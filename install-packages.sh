#!/bin/bash

echo "📦 Installing required packages..."
sudo apt update
sudo apt install -y dnsmasq dhcpcd5 raspberrypi-kernel-headers build-essential libnl-3-dev libnl-genl-3-dev pkg-config git curl wget

echo "🔧 Disabling NetworkManager..."
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager

echo "🛑 Stopping potential conflicts..."
sudo systemctl stop hostapd || true
sudo systemctl stop dnsmasq || true
sudo systemctl stop dhcpcd || true

echo "📁 Copying config files..."
sudo cp setup/dhcpcd.conf /etc/dhcpcd.conf
sudo cp setup/dnsmasq.conf /etc/dnsmasq.conf
sudo cp setup/hostapd.conf /etc/hostapd/hostapd.conf
sudo cp setup/hostapd-default /etc/default/hostapd

echo "🧱 Downloading patched hostapd (pritambaral fork)..."
cd /tmp
git clone https://github.com/pritambaral/hostapd-rtl871xdrv.git
cd hostapd-rtl871xdrv

echo "⬇️ Downloading base hostapd source..."
wget http://w1.fi/releases/hostapd-2.4.tar.gz
tar zxvf hostapd-2.4.tar.gz

echo "🧩 Applying patch..."
cd hostapd-2.4
patch -p1 -i ../rtlxdrv.patch
cd hostapd
cp defconfig .config
echo CONFIG_DRIVER_RTW=y >> .config
echo CONFIG_LIBNL32=y >> .config

echo "🛠️ Building hostapd..."
make

echo "✅ Installing hostapd binary..."
sudo cp hostapd /usr/sbin/hostapd
sudo chmod +x /usr/sbin/hostapd

echo "🧹 Cleaning up..."
cd ~
rm -rf /tmp/hostapd-rtl871xdrv

echo "🔁 Enabling and starting services..."
sudo systemctl unmask hostapd
sudo systemctl enable dhcpcd
sudo systemctl enable dnsmasq
sudo systemctl enable hostapd
sudo systemctl start dhcpcd
sudo systemctl start dnsmasq
sudo systemctl start hostapd

echo "🚀 Reboot to finish setup!"
