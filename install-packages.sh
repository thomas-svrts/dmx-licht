#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
  https://cli.github.com/packages stable main" | \
  sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

echo 'deb http://apt.openlighting.org/raspbian bullseye main' | sudo tee /etc/apt/sources.list.d/ola.list

curl http://apt.openlighting.org/ola.gpg | sudo apt-key add -



echo "📦 Installing required packages..."
sudo apt update
sudo apt install -y git hostapd iptables haveged lighttpd gh python3-pip ola ola-python
pip3 install Flask flask-cors

sudo lighttpd-enable-mod proxy
sudo lighttpd-enable-mod proxy-http

sudo adduser pi olad


cd /etc/ola/
sudo tee ./ola-ftdidmx.conf > /dev/null <<EOL
enabled = true
frequency = 30
EOL
sudo tee ./ola-usbserial.conf > /dev/null <<EOF
device_dir = /dev
device_prefix = ttyUSB
device_prefix = cu.usbserial-
device_prefix = ttyU
enabled = false
pro_fps_limit = 190
tri_use_raw_rdm = false
ultra_fps_limit = 40
EOF
sudo tee /ola-opendmx.conf > /dev/null <<EOF
device = /dev/dmx0
enabled = false
EOF
sudo killall -s SIGHUP olad
sudo service olad restart
sleep 5




echo "📁 Cloning linux-router repo..."
curl -o lnxrouter https://raw.githubusercontent.com/garywill/linux-router/master/lnxrouter
chmod +x lnxrouter
chmod +x flask/app.py

echo "⚙️ Making lnxrouter globally available..."
cp lnxrouter /usr/local/bin/


echo "🌐 Configureren van dnsmasq voor captive portal..."


# Zorg dat basisconfig leeg/veilig is
sudo rm -f /etc/dnsmasq.conf
echo "interface=wlan0" | sudo tee /etc/dnsmasq.conf > /dev/null
echo "dhcp-range=10.10.0.10,10.10.0.50,12h" | sudo tee -a /etc/dnsmasq.conf > /dev/null
echo "address=/#/10.10.0.1" | sudo tee -a /etc/dnsmasq.conf > /dev/null





echo "📁 Deploying captive portal files to /var/www/html..."
sudo mkdir -p /var/www/html
sudo cp -r $SCRIPT_DIR/captive/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
echo "✅ Captive portal geïnstalleerd."

sudo mkdir -p /var/lib/chirolicht/
sudo chown pi:pi /var/lib/chirolicht/



echo "⚙️ Configureren van lighttpd voor frontend-rewrites en backend API proxy..."

# Zorg dat mod_rewrite en proxy modules in de config staan
if ! grep -q 'mod_rewrite' /etc/lighttpd/lighttpd.conf; then
  echo 'server.modules += ( "mod_rewrite" )' | sudo tee -a /etc/lighttpd/lighttpd.conf
fi
if ! grep -q 'mod_proxy' /etc/lighttpd/lighttpd.conf; then
  echo 'server.modules += ( "mod_proxy" )' | sudo tee -a /etc/lighttpd/lighttpd.conf
fi

# Oude regels verwijderen
sudo sed -i '/url.rewrite\s*=/,/)/d' /etc/lighttpd/lighttpd.conf
sudo sed -i '/\$HTTP\["url"\] =~ "\^\/api\/"/,/}/d' /etc/lighttpd/lighttpd.conf

# Nieuwe rewrite + proxy toevoegen
sudo tee -a /etc/lighttpd/lighttpd.conf > /dev/null <<EOF
url.rewrite = (
  "^/script.js$" => "\$0",
  "^/logo.jpg$" => "\$0",
  "^/logo.png$" => "\$0",
  "^/api/.*$" => "\$0",
  ".*" => "/index.html"
)

\$HTTP["url"] =~ "^/api/" {
  proxy.server  = ( "" => ( "flask" => ( "host" => "127.0.0.1", "port" => 5000 ) ) )
}
EOF






ola_dev_info | grep FT232R
DMX_DEVICE_NUMBER=$(ola_dev_info | grep FT232R | grep -oP '(?<=Device )(\d+)')
DMX_PORT_NUMBER=$(ola_dev_info | grep FT232R | grep -oP '(?<=port )(\d)')
DMX_UNIVERSE=0
ola_patch -d $DMX_DEVICE_NUMBER -p $DMX_PORT_NUMBER -u $DMX_UNIVERSE






echo "🧾 Flask systemd-service installeren..."
sudo cp $SCRIPT_DIR/systemd/flask-dmx.service /etc/systemd/system/flask-dmx.service
sudo systemctl daemon-reexec
sudo systemctl enable flask-dmx
sudo systemctl restart flask-dmx

echo "🧾 Chiro AP als systemd-service installeren..."
sudo cp $SCRIPT_DIR/systemd/chiro-ap.service /etc/systemd/system/chiro-ap.service
sudo systemctl daemon-reexec
sudo systemctl enable chiro-ap
sudo systemctl restart chiro-ap

echo "🧾 reset cron job als systemd-service installeren..."
sudo cp $SCRIPT_DIR/systemd/dmx-keepalive.service /etc/systemd/system/dmx-keepalive.service
sudo systemctl daemon-reexec
sudo systemctl enable dmx-keepalive
sudo systemctl restart dmx-keepalive


# Herstart services als het al draait
sudo systemctl restart dnsmasq
sudo systemctl enable lighttpd
sudo systemctl restart lighttpd

echo "✅ lighttpd is ingesteld met rewrite en captive trigger-bestanden."

