#!/usr/bin/env bash
# Schritt 2: IR-Strahler dauerhaft einschalten, Howdy einrichten, Gesicht einlernen,
# testen und erst bei Erfolg für den KDE-Sperrbildschirm freischalten.
# Als normaler Benutzer starten (NICHT mit sudo).
set -euo pipefail
cd "$(dirname "$0")"
if [[ $EUID -eq 0 ]]; then echo "Bitte ohne sudo starten."; exit 1; fi

IRDEV=/dev/v4l/by-path/pci-0000:06:00.0-usb-0:2:1.2-video-index0
IRCONF="/etc/linux-enable-ir-emitter/pci-0000:06:00.0-usb-0:2:1.2-video-index0.ini"

echo "== 1/5 IR-Strahler-Einstellung speichern (Befehl 2 100 beim Start) =="
sudo install -m 644 ir-emitter.ini "$IRCONF"
sudo systemctl enable linux-enable-ir-emitter
sudo systemctl restart linux-enable-ir-emitter
systemctl is-failed --quiet linux-enable-ir-emitter && { echo "Dienst fehlgeschlagen:"; systemctl status linux-enable-ir-emitter --no-pager; exit 1; }

echo "== 2/5 Howdy auf IR-Kamera einstellen =="
sudo sed -i \
  -e "s|^device_path = .*|device_path = $IRDEV|" \
  -e "s|^dark_threshold = .*|dark_threshold = 90|" \
  /etc/howdy/config.ini
sudo grep -E '^(device_path|dark_threshold) ' /etc/howdy/config.ini

echo
echo "== 3/5 Gesicht einlernen =="
echo "Schau gerade in die Kamera. Bei der Frage nach einem Namen einfach Enter."
sudo howdy add

echo
echo "== 4/5 Test: Erkennung ohne Fenster =="
echo "Schau wieder in die Kamera ..."
if sudo /usr/bin/python /usr/lib/howdy/compare.py "$USER"; then
  echo ">> Gesicht erkannt."
else
  echo ">> Test fehlgeschlagen (Code $?). Sperrbildschirm wird NICHT umgestellt."
  echo "   Sag Claude Bescheid und kopier die Ausgabe."
  exit 1
fi

echo
echo "== 5/5 Für den Sperrbildschirm freischalten =="
# Eigene Kopie in /etc hat Vorrang vor /usr/lib/pam.d/kde; Passwort bleibt als Ausweg.
sudo tee /etc/pam.d/kde >/dev/null <<'EOF'
#%PAM-1.0
# Gesichtserkennung (Howdy) zuerst, bei Misserfolg normales Passwort
auth       sufficient                  pam_howdy.so

auth       include                     system-local-login

account    include                     system-local-login

password   include                     system-local-login

session    include                     system-local-login
EOF
echo
echo "Fertig. Teste mit Meta+L (Bildschirm sperren): in die Kamera schauen,"
echo "ggf. einmal Enter drücken. Das Passwort funktioniert weiterhin."
echo "Rückgängig machen:  sudo rm /etc/pam.d/kde"
