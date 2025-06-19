# DMX lichtproject
# 💡 Chiroheffen Licht – Raspberry Pi DMX Access Point

Dit project maakt van een Raspberry Pi een zelfstandig Wi-Fi access point met captive portal. Gebruikers verbinden met het netwerk `chiroheffen-licht` en worden automatisch doorgestuurd naar een lokaal controlepaneel voor DMX-verlichting (bv. via een BeamZ USB-controller).

---

## ⚙️ Hardwarevereisten

- Raspberry Pi 4B (of 3B, Zero 2 W)
- microSD-kaart met Raspberry Pi OS (32-bit of 64-bit)
- Internetverbinding via **ethernet** (voor installatie)
- BeamZ USB-DMX controller (siudi 9s )
- Eventueel: voeding, behuizing, enz.

---

## 🧩 Setup-stappen

### 1. Clone deze repository op je Raspberry Pi

```bash
git clone https://github.com/thomas-svrts/dmx-licht.git
cd dmx-licht
```

### 2. Maak het installatiescript uitvoerbaar

```bash
chmod +x install-packages.sh
```

### 3. Voer de installatie uit

```bash
./install-packages.sh
```

Het script:
- Installeert `hostapd` en `dnsmasq`
- Kopieert configuratiebestanden uit de map `Setup/` naar het juiste systeempad
- Activeert alles bij het opstarten

### 4. Herstart je Raspberry Pi

```bash
sudo reboot
```

---

## 📶 Wat gebeurt er na reboot?

- De Pi zendt een Wi-Fi-netwerk uit met SSID `chiroheffen-licht`
- Toestellen die verbinden krijgen automatisch een IP-adres (192.168.4.x)
- Al het netwerkverkeer wordt omgeleid naar de Pi zelf (`192.168.4.1`)
- (Volgende stap:) de webinterface zal verschijnen

---

## 📁 Overzicht van de bestanden

dmx-licht/
├── install-packages.sh              # Installatiescript
├── Setup/
│   ├── dhcpcd.conf                  # Statisch IP voor wlan0
│   ├── dnsmasq.conf                 # DHCP + DNS omleiding
│   ├── hostapd.conf                 # Wi-Fi access point
│   └── hostapd-default              # Daemon config
├── web/                             # Captive portal frontend
│   ├── index.html                   # Webinterface (kleurkiezer, sliders)
│   └── script.js                    # DMX-bediening via REST
└── api/                             # Flask-backend voor DMX
    ├── app.py                       # REST-server met endpoint `/api/dmx`
    └── dmx_set.sh                   # Script dat DMX-waarden doorstuurt

---

## 🔌 Status USB-DMX-integratie

Er is een tweede programma in ontwikkeling (`siudi_logger.c`) dat USB-verkeer met de BeamZ/DMXsoft-controller via `libusb` monitort en probeert na te bootsen:

- ✅ Device wordt correct herkend (Vendor ID 0x6244, Product ID 0x0591)
- ✅ Control transfers worden correct gestuurd en gelogd
- ✅ Interface geclaimd en geconfigureerd
- ❌ BULK transfers falen momenteel met timeout – DMX-verzending nog niet gelukt
- 🛠 Er wordt verder onderzocht welke exacte init- of timingsequentie vereist is

Voorlopige logoutput wordt bijgehouden in een aparte branch (`usb-debug`) met volledige tijdstempels per USB-transfer.

---

## 🌐 Webinterface en backend

De captive portal bevat een eenvoudige HTML/JS-webinterface waarmee gebruikers hun lichtinstellingen kunnen bepalen via sliders of kleurkiezers. De interface stuurt de waarden door naar een Flask-backend via een REST POST-request naar `/api/dmx`.

De Flask-backend draait op poort 5000 maar wordt via `lighttpd` intern geproxied naar `/api` op poort 80 (via reverse proxy), zodat alles lokaal blijft zonder CORS-problemen.

Elke inkomende DMX-request roept een shellscript aan (`dmx_set.sh`) dat uiteindelijk de DMX-uitgang aanstuurt (via `libusb` of een nog te kiezen backend).

De backend wordt als systemd-service mee opgestart en automatisch geïnstalleerd via `install-packages.sh`.

---

## 🚧 Volgende stap

De volgende stap is de communicatie met de DMX-controller volledig werkend krijgen:
- De BULK-transfer debuggen
- Alternatieven testen zoals `usbip` of virtuele dongle-emulatie
- Eventueel fallback voorzien via OLA of pyserial

📬 Contacteer Thomas of open een issue als je wil bijdragen.
