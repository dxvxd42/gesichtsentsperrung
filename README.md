# Gesichtsentsperrung mit IR-Kamera unter KDE Plasma 6 (Arch/CachyOS)

Persönliche Einrichtung von [Howdy](https://github.com/boltgolt/howdy) 3.0.1 mit IR-Kamera am
KDE-Sperrbildschirm – inklusive Selbstreparatur nach Updates. Getestet auf einem Lenovo ThinkPad
(IR-Kamera als `/dev/video2`, 640×360 GREY) mit Plasma 6.8, OpenCV 5, Synaptics-Fingerabdruckleser.
Alles ist auf dieses Gerät zugeschnitten; für andere Geräte bitte Pfade/Werte anpassen.

## Inhalt

| Pfad | Zweck |
|---|---|
| `1-installieren.sh` … `4-diagnose.sh` | Einrichtung Schritt für Schritt: Pakete installieren, IR-Leuchte konfigurieren, Gesicht anlernen, PAM für den Sperrbildschirm, Diagnose (fps, Trefferquote) |
| `ir-emitter.ini` | Gefundene Steuerbefehle für die IR-Leuchte (`linux-enable-ir-emitter`) |
| `pkgbuilds/` | Angepasste AUR-PKGBUILDs: `howdy-git` (Tag v3.0.1, baut aus `howdy/`), `linux-enable-ir-emitter` (erkennt OpenCV 4/5 selbst), `python-dlib` (ohne CUDA). `PKGBUILD.orig` = AUR-Original |
| `autoreparatur/` | pacman-Hook + systemd-Dienst: prüft nach jedem Update dlib, `pam_howdy.so`, IR-Leuchte und baut kaputte Pakete selbst neu (Benachrichtigung per `notify-send`) |
| `sperrbild-sofort/` | Sperrbildschirm startet Gesicht + Fingerabdruck sofort, ohne Tastendruck (auch direkt nach dem Aufklappen) |

## Sperrbildschirm „sofort“

Plasma startet die Anmeldung erst, wenn die Oberfläche durch Taste/Maus sichtbar wird.
`sperrbild-sofort-patch` fügt in `LockScreenUi.qml` einen kleinen Timer ein, der
`authenticator.startAuthenticating()` jede Sekunde aufruft, solange gesperrt ist.

- Nach jedem Update von `plasma-desktop` läuft der Patch per pacman-Hook erneut; vorher wird das
  Ergebnis mit `qmllint` geprüft, bei Fehlern bleibt das Original.
- Lässt sich die Datei nicht mehr anpassen, schaltet sich eine Notlösung ein: nach dem Aufwachen
  drückt `sperrbild-taste` über `/dev/uinput` einmal kurz Shift.
- **Wichtig:** `authenticator.stopAuthenticating()` nicht verwenden – das beendet den PAM-Worker
  endgültig, danach funktioniert nicht einmal mehr das Passwort.
- Nebenwirkung: Nach Meta+L entsperrt das Gesicht nach wenigen Sekunden wieder, wenn man vor der Kamera sitzt.

Installation: `sperrbild-sofort/installieren.sh`, entfernen: `sperrbild-sofort/rueckgaengig.sh`.

## Hinweise

- `blas-openblas` statt Referenz-BLAS beschleunigt dlib deutlich (Gesichtskodierung 340 → 47 ms/Bild).
- Im Login-Manager wird Howdy bewusst nicht verwendet (KWallet braucht das Passwort).
- Das Passwort funktioniert immer weiterhin als Ausweg.
- Gesichtsmodelle liegen unter `/etc/howdy/models` und sind nicht Teil dieses Repos.
