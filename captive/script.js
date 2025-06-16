function stuurLicht() {
  const kleur = document.getElementById("kleur").value;
  const helderheid = document.getElementById("helderheid").value;

  fetch("/api/licht", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ kleur, helderheid })
  })
  .then(response => response.ok ? alert("Verzonden!") : alert("Fout bij verzenden"))
  .catch(() => alert("Server niet bereikbaar"));
}
