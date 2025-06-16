#!/bin/bash

echo "🚀 Starting access point on wlan0, sharing internet from eth0..."
sudo lnxrouter start --wifi wlan0 --internet eth0
