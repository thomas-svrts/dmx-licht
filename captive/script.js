document.getElementById("brightness").addEventListener("input", () => {
  document.getElementById("brightnessValue").textContent =
    document.getElementById("brightness").value;
});

function sendDMX() {
  const hexColor = document.getElementById("color").value;
  const brightness = parseInt(document.getElementById("brightness").value);

  const r = parseInt(hexColor.substr(1, 2), 16);
  const g = parseInt(hexColor.substr(3, 2), 16);
  const b = parseInt(hexColor.substr(5, 2), 16);

  const baseChannel = 1;
  const payload = [
    { channel: baseChannel, value: r },
    { channel: baseChannel + 1, value: g },
    { channel: baseChannel + 2, value: b },
    { channel: baseChannel + 3, value: brightness }
  ];

  // Toon de verzonden payload
  let debugOutput = "📤 Verzonden payload:\n" + JSON.stringify(payload, null, 2) + "\n\n";

  fetch("/api/dmx/batch", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  })
    .then(async (res) => {
      debugOutput += `📥 HTTP status: ${res.status} ${res.statusText}\n`;

      let text = await res.text();
      try {
        const json = JSON.parse(text);
        debugOutput += "\n✅ JSON response:\n" + JSON.stringify(json, null, 2);
      } catch (e) {
        debugOutput += "\n❌ Response is geen geldige JSON:\n" + text;
      }

      document.getElementById("response").textContent = debugOutput;
    })
    .catch((err) => {
      debugOutput += "\n❌ Netwerkfout:\n" + err;
      document.getElementById("response").textContent = debugOutput;
    });
}


