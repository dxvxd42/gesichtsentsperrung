#!/bin/bash
# Macht den Meta+L-Fehler rückgängig: kein Neustart der Anmeldung, keine 10-s-Sperrfrist.
# Bleibt: Anmeldung startet sofort (Gesicht/Fingerabdruck ohne Tastendruck, auch nach dem Aufklappen).
set -e
cd "$(dirname "$0")"
sudo install -m755 sperrbild-sofort-patch /usr/local/sbin/
sudo /usr/local/sbin/sperrbild-sofort-patch
if [ -f /etc/pam.d/kde.vor-sperrfrist ]; then
    sudo mv /etc/pam.d/kde.vor-sperrfrist /etc/pam.d/kde
fi
sudo rm -f /usr/local/sbin/gesicht-erlaubt
echo; echo "== /etc/pam.d/kde"; cat /etc/pam.d/kde
echo; grep -c sofortNeustart /usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen/LockScreenUi.qml | sed 's/^0$/alter Neustart-Teil: entfernt/'
/usr/local/sbin/sperrbild-sofort-patch --status
