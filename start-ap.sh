#!/bin/bash

# Alleen redirectregels voor captive portal
# sudo iptables -t nat -F
sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80  -j DNAT --to-destination 10.10.0.1:80
sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 443 -j REDIRECT --to-ports 80

echo "✅ Captive portal draait op http://10.10.0.1"


echo "🚀 Starting access point on wlan0, catching all dns..."

# Start lnxrouter (zonder --share als je internet niet wil delen)
sudo lnxrouter \
  --ap wlan0 Chiro-Heffen-Licht \
  -g 10.10.0.1 \
  -n \
  --catch-dns \
  --isolate-clients \
  --country BE	\
  --hostname chiro-ap



