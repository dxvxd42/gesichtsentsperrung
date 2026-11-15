#!/usr/bin/env bash
# Schritt 4: Howdy-Diagnosebericht kurz einschalten, 3x messen, wieder ausschalten.
# Ändert nichts dauerhaft. Als normaler Benutzer starten (NICHT mit sudo).
set -uo pipefail
if [[ $EUID -eq 0 ]]; then echo "Bitte ohne sudo starten."; exit 1; fi

sudo sed -i 's/^end_report = false/end_report = true/' /etc/howdy/config.ini
trap 'sudo sed -i "s/^end_report = true/end_report = false/" /etc/howdy/config.ini; echo "(Diagnose wieder ausgeschaltet)"' EXIT

for i in 1 2 3; do
  echo
  read -rp "Durchgang $i: Enter drücken und in die Kamera schauen ..."
  sudo /usr/bin/python /usr/lib/howdy/compare.py "$USER" 2>/dev/null \
    | grep -E 'Starting up|Opening the camera|Importing|Searching|Total|Frames searched|Dark frames|Certainty' \
    || echo "   NICHT erkannt"
done
echo
echo "Bitte die Ausgabe an Claude schicken."
