#!/bin/bash
# Sperrbildschirm: Gesicht + Fingerabdruck sofort, ohne Tastendruck, auch direkt nach dem Aufklappen.
set -e
cd "$(dirname "$0")"
sudo install -m755 sperrbild-sofort-patch sperrbild-taste /usr/local/sbin/
sudo install -m755 sperrbild-sofort.sleep /usr/lib/systemd/system-sleep/sperrbild-sofort
sudo install -m644 95-sperrbild-sofort.hook /etc/pacman.d/hooks/95-sperrbild-sofort.hook
sudo /usr/local/sbin/sperrbild-sofort-patch

echo; echo "== /etc/pam.d/kde"; cat /etc/pam.d/kde
echo; /usr/local/sbin/sperrbild-sofort-patch --status
echo; echo "Fertig. Gilt ab dem nächsten Sperren."
