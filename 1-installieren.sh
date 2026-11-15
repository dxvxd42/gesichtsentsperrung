#!/usr/bin/env bash
# Schritt 1: fertig gebaute Pakete installieren und IR-Strahler einrichten.
# Als normaler Benutzer starten (NICHT mit sudo).
set -euo pipefail
cd "$(dirname "$0")"

if [[ $EUID -eq 0 ]]; then echo "Bitte ohne sudo starten."; exit 1; fi

echo "== 1/3 Pakete installieren (howdy 3.0.1 + linux-enable-ir-emitter 6.1.2) =="
sudo pacman -U --needed \
  howdy-git/howdy-git-3.0.1-1-x86_64.pkg.tar.zst \
  linux-enable-ir-emitter/linux-enable-ir-emitter-6.1.2-1-x86_64.pkg.tar.zst

echo
echo "== 2/3 IR-Strahler einrichten =="
echo "Gleich öffnet sich ein Fenster mit dem Kamerabild."
echo " - Setz dich nah vor die Kamera, Raum gut beleuchtet."
echo " - Wenn gefragt wird, ob der Strahler blinkt:"
echo "   ins Fenster klicken und Y (ja) oder N (nein) drücken."
echo " - NICHT abbrechen, auch wenn länger 'Searching...' steht."
read -rp "Bereit? Enter drücken ..."
# sudo verliert sonst die Fenster-Berechtigung (XAUTHORITY) -> kein Kamerafenster
sudo env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" GDK_BACKEND=x11 \
  linux-enable-ir-emitter --verbose --device /dev/video2 --width 640 --height 360 configure

echo
echo "== 3/3 Dienst aktivieren (Strahler nach Start/Standby wieder an) =="
sudo systemctl enable --now linux-enable-ir-emitter

echo
echo "Fertig mit Schritt 1. Sag Claude Bescheid, dann wird das IR-Bild geprüft."
