#!/usr/bin/env bash
# Einmalig: automatische Prüfung/Reparatur nach Updates einrichten.
set -euo pipefail
cd "$(dirname "$0")"
tmp=$(mktemp)
sed "s/^BENUTZER=__BENUTZER__.*/BENUTZER=$(id -un)/" gesicht-reparatur > "$tmp"
sudo install -m 755 -o root -g root "$tmp" /usr/local/sbin/gesicht-reparatur
rm -f "$tmp"
sudo install -m 644 gesicht-reparatur.service /etc/systemd/system/gesicht-reparatur.service
sudo install -d /etc/pacman.d/hooks
sudo install -m 644 95-gesicht-reparatur.hook /etc/pacman.d/hooks/95-gesicht-reparatur.hook
sudo systemctl daemon-reload
echo
echo "Test-Lauf (prüft jetzt einmal, baut nur bei Problemen):"
sudo systemctl start gesicht-reparatur.service
sudo tail -n 5 /var/log/gesicht-reparatur.log
echo
echo "Eingerichtet. Ab jetzt läuft die Prüfung nach jedem pacman-Update automatisch."
echo "Manuell prüfen:  gesicht-reparatur --pruefen"
