#!/bin/bash

#make rule to redirect all http requests to captive portal page
iptables -i wlan0 -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination "10.10.0.1:80"
echo "+++++ Captive portal draait op http://10.10.0.1"


echo "+++++ Starting access point on wlan0, catching all dns..."

# Start lnxrouter (zonder --share als je internet niet wil delen)
sudo lnxrouter \
  --ap wlan0 Chiro-Heffen-Licht \
  -g 10.10.0.1 \
  -n \
  --catch-dns \
  --isolate-clients \
  --country BE	\
  --hostname chiro-ap


#remove rule
iptables -i wlan0 -t nat -D PREROUTING -p tcp --dport 80 -j DNAT --to-destination "192.168.$IPNUM.1:$CAPTIVE_PORT"

echo "+++++ Captive portal gestopt "
