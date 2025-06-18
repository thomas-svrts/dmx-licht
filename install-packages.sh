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





echo "⚙️ Configureren van lighttpd voor frontend-rewrites en backend API proxy..."

# Zorg dat mod_rewrite en proxy modules in de config staan
if ! grep -q 'mod_rewrite' /etc/lighttpd/lighttpd.conf; then
  echo 'server.modules += ( "mod_rewrite" )' | sudo tee -a /etc/lighttpd/lighttpd.conf
fi
if ! grep -q 'mod_proxy' /etc/lighttpd/lighttpd.conf; then
  echo 'server.modules += ( "mod_proxy", "mod_proxy_http" )' | sudo tee -a /etc/lighttpd/lighttpd.conf
fi

# Oude regels verwijderen
sudo sed -i '/url.rewrite\s*=/,/)/d' /etc/lighttpd/lighttpd.conf
sudo sed -i '/\$HTTP\["url"\] =~ "\^\/api\/"/,/}/d' /etc/lighttpd/lighttpd.conf

# Nieuwe rewrite + proxy toevoegen
sudo tee -a /etc/lighttpd/lighttpd.conf > /dev/null <<EOF
url.rewrite = (
  "^/script.js$" => "\$0",
  "^/api/.*$" => "\$0",
  ".*" => "/index.html"
)

\$HTTP["url"] =~ "^/api/" {
  proxy.server  = ( "" => ( "flask" => ( "host" => "127.0.0.1", "port" => 5000 ) ) )
}
EOF





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
