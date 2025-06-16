# DMX lichtproject
# 💡 Chiroheffen Licht – Raspberry Pi DMX Access Point

Dit project maakt van een Raspberry Pi een zelfstandig Wi-Fi access point met captive portal. Gebruikers verbinden met het netwerk `chiroheffen-licht` en worden automatisch doorgestuurd naar een lokaal controlepaneel voor DMX-verlichting (bv. via een BeamZ USB-controller).

---

## ⚙️ Hardwarevereisten

- Raspberry Pi 4B (of 3B, Zero 2 W)
- microSD-kaart met Raspberry Pi OS (32-bit of 64-bit)
- Internetverbinding via **ethernet** (voor installatie)
- BeamZ USB-DMX controller (Enttec compatible)
- Eventueel: voeding, behuizing, enz.

---

## 🧩 Setup-stappen

### 1. Clone deze repository op je Raspberry Pi

git clone https://github.com/<jouw-gebruikersnaam>/dmx-licht.git
cd dmx-licht

### 2. Maak het installatiescript uitvoerbaar

chmod +x install-packages.sh


### 3. Voer de installatie uit

./install-packages.sh


Het script:
- Installeert `hostapd` en `dnsmasq`
- Kopieert configuratiebestanden uit de map `Setup/` naar het juiste systeempad
- Activeert alles bij het opstarten

### 4. Herstart je Raspberry Pi

sudo reboot

---

## 📶 Wat gebeurt er na reboot?

- De Pi zendt een Wi-Fi-netwerk uit met SSID `chiroheffen-licht`
- Toestellen die verbinden krijgen automatisch een IP-adres (192.168.4.x)
- Al het netwerkverkeer wordt omgeleid naar de Pi zelf (`192.168.4.1`)
- (Volgende stap:) de webinterface zal verschijnen

---

## 📁 Overzicht van de bestanden

dmx-licht/
├── install-packages.sh # Installatiescript
├── Setup/
│ ├── dhcpcd.conf # Statisch IP voor wlan0
│ ├── dnsmasq.conf # DHCP + DNS omleiding
│ ├── hostapd.conf # Wi-Fi access point
│ └── hostapd-default # Daemon config
└── web/ # (Toekomstige) captive portal

---

## 🚧 Volgende stap

De volgende stap is een eenvoudige captive portal bouwen in de `web/`-map met:
- Een Flask-webserver
- Een kleurkiezer + intensiteitsregelaar
- USB-DMX-uitsturing (bv. via `pyserial` of OLA)

📬 Contacteer Thomas of open een issue als je wil bijdragen.
