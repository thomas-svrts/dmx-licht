const macroOptions = [
  "off", "macro1", "macro2", "macro3", "macro4",
  "macro5", "macro6", "macro7", "macro8", "macro9", "macro10"
];

function getMacroValue(selection) {
  switch (selection) {
    case "macro1": return 101;
    case "macro2": return 110;
    case "macro3": return 120;
    case "macro4": return 130;
    case "macro5": return 140;
    case "macro6": return 150;
    case "macro7": return 160;
    case "macro8": return 170;
    case "macro9": return 180;
    case "macro10": return 190;
    default: return 0;
  }
}

function updateUI() {
  const mode = document.getElementById("macroMode").value;
  const macroVisible = mode !== "off";

  document.getElementById("macro-channel-8").classList.toggle("hidden", !macroVisible);
  document.getElementById("manual-controls").classList.toggle("hidden", macroVisible);
}

function changeMacro(delta) {
  const select = document.getElementById("macroMode");
  let idx = macroOptions.indexOf(select.value);
  idx = Math.max(0, Math.min(macroOptions.length - 1, idx + delta));
  select.value = macroOptions[idx];
  updateUI();
  sendDMX();
}

function applyPreset(name) {
  const presets = {
    tl: {
      color: "#ffffff", amber: 0, strobe: 0, brightness: 255
    },
    warmwit: {
      color: "#ffcc88", amber: 128, strobe: 0, brightness: 255
    },
    allesuit: {
      color: "#000000", amber: 0, strobe: 0, brightness: 0
    }
  };

  const preset = presets[name];
  document.getElementById("macroMode").value = "off";
  updateUI();

  document.getElementById("color").value = preset.color;
  document.getElementById("amber").value = preset.amber;
  document.getElementById("strobe").value = preset.strobe;
  document.getElementById("brightness").value = preset.brightness;

  sendDMX();
}

function sendDMX() {
  const brightness = parseInt(document.getElementById("brightness").value);
  const mode = document.getElementById("macroMode").value;
  const payload = [{ channel: 1, value: brightness }];

  if (mode === "off") {
    const hexColor = document.getElementById("color").value;
    const r = parseInt(hexColor.substr(1, 2), 16);
    const g = parseInt(hexColor.substr(3, 2), 16);
    const b = parseInt(hexColor.substr(5, 2), 16);
    const amber = parseInt(document.getElementById("amber").value);
    const strobe = parseInt(document.getElementById("strobe").value);

    payload.push(
      { channel: 2, value: r },
      { channel: 3, value: g },
      { channel: 4, value: b },
      { channel: 5, value: amber },
      { channel: 6, value: strobe },
      { channel: 7, value: 0 },
      { channel: 8, value: 0 }
    );
  } else {
    const macroVal = getMacroValue(mode);
    const param = parseInt(document.getElementById("macroParam").value);
    payload.push(
      { channel: 7, value: macroVal },
      { channel: 8, value: param }
    );
  }

  fetch("/api/dmx/batch", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  }).catch(err => console.error("Fout bij verzenden:", err));
}

// Event listeners
document.getElementById("macroMode").addEventListener("change", () => {
  updateUI();
  sendDMX();
});

["brightness", "color", "amber", "strobe", "macroParam"].forEach(id => {
  document.getElementById(id).addEventListener("input", sendDMX);
});

// Init
updateUI();
