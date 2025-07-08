# 🌈 DMX Lichtsturing — Chiro Heffen 🎛️

Een gebruiksvriendelijke en functionele DMX-controller in eigen beheer, gemaakt voor het aansturen van onze lichtshow tijdens Chirowerkingen en evenementen.  
Werkt via een Raspberry Pi in **captive portal modus** zonder internet.

---

## ✨ Functies

- 🎨 Live controle over RGB, amber en stroboscoop via sliders  
- 🎞️ Tien voorgeprogrammeerde macro-effecten met pijltjes  
- 💡 Snelle presets zoals TL-licht en warm wit  
- 🔁 Instellingen worden **server-side opgeslagen** en hersteld bij herstart  
- 💻 Webinterface met Chiro Heffen-stijl en nachtthema  
- 🔌 Volledige OLA-integratie via Python backend  
- 📡 Werkt als **standalone Wi-Fi access point** met captive portal (via `lnxrouter`)

---

## 🚀 Installatie op Raspberry Pi

### 🔧 1. Repo klonen

```bash
git clone https://github.com/thomas-svrts/dmx-licht.git
cd dmx-licht
```

### 🧰 2. Alles installeren

```bash
sudo ./install-packages.sh
```

Dit script:
- Installeert alle vereisten (`ola`, `lighttpd`, `flask`, …)
- Zet webinterface in `/var/www/html/`
- Richt lighttpd correct in (proxy naar Flask API via `/api/`)
- Installeert `lnxrouter` voor captive portal
- Zet OLA-configuratie klaar

### 📡 3. Captive portal starten

```bash
sudo ./start-ap.sh
```

Dit zet een access point op genaamd `Chiro-Heffen-Licht`, zonder internet, en stuurt alle DNS-verkeer naar de webinterface (portaalpagina).
Dit wordt ook als een systemd service geinstalleerd.

---

## 🌐 Gebruik

1. Verbind met het Wi-Fi netwerk `Chiro-Heffen-Licht` via je smartphone of tablet.
2. De portaalpagina opent automatisch.
3. Pas de verlichting live aan — alles wordt onmiddellijk verzonden.

---

## 🧠 Opslag instellingen

Instellingen zoals helderheid, kleur, macro en snelheid worden opgeslagen op de Raspberry Pi in:

```
/var/lib/chirolicht/settings.json
```

Ze worden automatisch geladen bij herstart of verversen van de pagina.

---

## ⚙️ Technisch overzicht

- **Frontend**: `frontend/index.html` + `script.js` (speels, mobile-friendly, zonder verstuur-knop)
- **Backend**: `app.py` via Flask  
  - `/api/dmx/batch`: stuurt waarden naar OLA  
  - `/api/settings`: bewaart/herlaadt UI-configuratie
- **DMX-uitgang**: via `OLA` met een Enttec Open DMX USB-dongle
- **AP-mode**: via `lnxrouter`, captive portal zonder internet


---

## 📄 Extra

- Wil je nieuwe presets toevoegen? Pas `applyPreset(...)` aan in `script.js`.
- Flask en Chiro-AP start op als een systemd-service.
- Werkt ook zonder internetverbinding.

---

## 📬 Contact

Gemaakt door en voor Chiro Heffen.  
Vragen of uitbreidingen? Maak een issue aan of spreek Thomas aan 😉
