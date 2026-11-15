#!/usr/bin/env bash
# Schritt 3: weitere Gesichtsaufnahmen einlernen und Erkennungszeit messen.
# Als normaler Benutzer starten (NICHT mit sudo).
set -euo pipefail
if [[ $EUID -eq 0 ]]; then echo "Bitte ohne sudo starten."; exit 1; fi

aufnahme() {  # $1 = Name, $2 = Anweisung
  echo
  echo "== Aufnahme: $2 =="
  read -rp "Enter drücken, wenn du so sitzt ..."
  printf '%s\n' "$1" | sudo howdy add
}

aufnahme "etwas weiter weg"   "zurückgelehnt, ca. eine Armlänge weg, gerade in die Kamera"
aufnahme "Kopf leicht links"  "Kopf ein kleines Stück nach links gedreht, Blick zur Kamera"
aufnahme "Kopf leicht rechts" "Kopf ein kleines Stück nach rechts gedreht, Blick zur Kamera"

echo
echo "== Eingelernte Aufnahmen =="
sudo howdy list

echo
echo "== Zeitmessung (3 Durchgänge, jeweils in die Kamera schauen) =="
for i in 1 2 3; do
  read -rp "Durchgang $i: Enter drücken und in die Kamera schauen ..."
  start=$(date +%s.%N)
  if sudo /usr/bin/python /usr/lib/howdy/compare.py "$USER" >/dev/null 2>&1; then erg="erkannt"; else erg="NICHT erkannt"; fi
  echo "   $erg nach $(python3 -c "import time;print(f'{time.time()-$start:.1f}')") Sekunden"
done
echo
echo "Fertig. Kopier Claude die Zeiten, wenn du willst."
