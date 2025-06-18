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

  const baseChannel = 1; // eventueel aanpassen
  const payload = [
    { channel: baseChannel, value: r },
    { channel: baseChannel + 1, value: g },
    { channel: baseChannel + 2, value: b },
    { channel: baseChannel + 3, value: brightness }
  ];

  fetch("/api/dmx/batch", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  })
    .then(res => res.json())
    .then(data => {
      document.getElementById("response").textContent =
        JSON.stringify(data, null, 2);
    })
    .catch(err => {
      document.getElementById("response").textContent = "❌ Fout: " + err;
    });
}

