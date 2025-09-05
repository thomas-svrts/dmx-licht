#!/bin/bash

echo "+++++ Starting access point on wlan0, catching all dns..."

# Start lnxrouter (zonder --share als je internet niet wil delen)
sudo lnxrouter \
  --ap wlan0 Chiro-Heffen-Licht \
  -g 10.10.0.1 \
  -n \
  --isolate-clients \
  --hostname chiro-ap \
  --tp 80
