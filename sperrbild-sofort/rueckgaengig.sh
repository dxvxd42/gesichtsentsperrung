#!/bin/bash
sudo rm -f /etc/pacman.d/hooks/95-sperrbild-sofort.hook /usr/lib/systemd/system-sleep/sperrbild-sofort
sudo /usr/local/sbin/sperrbild-sofort-patch --zurueck
[ -f /etc/pam.d/kde.vor-sperrfrist ] && sudo mv /etc/pam.d/kde.vor-sperrfrist /etc/pam.d/kde
sudo rm -f /usr/local/sbin/sperrbild-sofort-patch /usr/local/sbin/sperrbild-taste /usr/local/sbin/gesicht-erlaubt
echo "Zurückgesetzt."
