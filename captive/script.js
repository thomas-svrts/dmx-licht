function sendDMX() {
  const channel = parseInt(document.getElementById("channel").value);
  const value = parseInt(document.getElementById("value").value);

  fetch("/api/dmx", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ channel, value })
  })
  .then(res => res.json())
  .then(data => {
    document.getElementById("response").textContent = JSON.stringify(data, null, 2);
  })
  .catch(err => {
    document.getElementById("response").textContent = "❌ Fout: " + err;
  });
}
