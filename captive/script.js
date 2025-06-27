document.querySelectorAll('input[type="range"]').forEach(el => {
  el.addEventListener("input", () => {
    document.getElementById(el.id + "Value").textContent = el.value;
  });
});

function sendDMX() {
  const hexColor = document.getElementById("color").value;
  const brightness = parseInt(document.getElementById("brightness").value);
  const amber = parseInt(document.getElementById("amber").value);
  const strobe = parseInt(document.getElementById("strobe").value);
  const macro = parseInt(document.getElementById("macro").value);
  const macroSpeed = parseInt(document.getElementById("macroSpeed").value);

  const r = parseInt(hexColor.substr(1, 2), 16);
  const g = parseInt(hexColor.substr(3, 2), 16);
  const b = parseInt(hexColor.substr(5, 2), 16);

  const payload = [
    { channel: 1, value: brightness },
    { channel: 2, value: r },
    { channel: 3, value: g },
    { channel: 4, value: b },
    { channel: 5, value: amber },
    { channel: 6, value: strobe },
    { channel: 7, value: macro },
    { channel: 8, value: macroSpeed }
  ];

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
