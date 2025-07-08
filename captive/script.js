function getMacroValue(selection) {
  switch (selection) {
    case "static": return 70;
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
  })
    .then(res => res.json())
    .then(data => {
      document.getElementById("response").textContent = JSON.stringify(data, null, 2);
    })
    .catch(err => {
      document.getElementById("response").textContent = "Error: " + err;
    });
}

// Update UI op verandering van macro-mode
document.getElementById("macroMode").addEventListener("change", () => {
  const mode = document.getElementById("macroMode").value;
  const macroVisible = mode !== "off";

  document.getElementById("macro-channel-8").classList.toggle("hidden", !macroVisible);
  document.getElementById("manual-controls").classList.toggle("hidden", macroVisible);

  sendDMX();
});

// Trigger live updates bij slider/input wijzigingen
["brightness", "color", "amber", "strobe", "macroParam"].forEach(id => {
  document.getElementById(id).addEventListener("input", sendDMX);
});
