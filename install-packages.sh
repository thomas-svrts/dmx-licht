#!/bin/bash

type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
  https://cli.github.com/packages stable main" | \
  sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null


echo "📦 Installing required packages..."
sudo apt update
sudo apt install -y git hostapd iptables haveged lighttpd gh python3-pip
pip3 install Flask flask-cors

sudo lighttpd-enable-mod proxy
sudo lighttpd-enable-mod proxy-http


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
sudo cp -r ./captive/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
echo "✅ Captive portal geïnstalleerd."


echo "⚙️ Configureren van lighttpd voor catch-all redirect naar index.html..."

# Zorg dat mod_rewrite actief is
if ! grep -q mod_rewrite /etc/lighttpd/lighttpd.conf; then
  echo 'server.modules += ( "mod_rewrite" )' | sudo tee -a /etc/lighttpd/lighttpd.conf
fi

# Verwijder oude rewrite-regels indien nodig
sudo sed -i '/url.rewrite-if-not-file/d' /etc/lighttpd/lighttpd.conf

# Voeg rewrite-regel toe om alle onbekende paden naar /index.html te sturen
# (behalve bestaande bestanden)
REWRITE_RULE='url.rewrite-if-not-file = ( ".*" => "/index.html" )'
if ! grep -q "url.rewrite-if-not-file" /etc/lighttpd/lighttpd.conf; then
  echo "$REWRITE_RULE" | sudo tee -a /etc/lighttpd/lighttpd.conf
fi


echo "🧾 Flask systemd-service installeren..."
sudo cp ./systemd/flask-dmx.service /etc/systemd/system/flask-dmx.service
sudo systemctl daemon-reexec
sudo systemctl enable flask-dmx
sudo systemctl start flask-dmx

# Herstart services als het al draait
sudo systemctl restart dnsmasq
sudo systemctl enable lighttpd
sudo systemctl restart lighttpd

echo "✅ lighttpd is ingesteld met rewrite en captive trigger-bestanden."
