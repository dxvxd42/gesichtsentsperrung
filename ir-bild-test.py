#!/usr/bin/env python3
"""IR-Kamera live ansehen – so wie Howdy das Bild bewertet.

Fenster links: Rohbild der IR-Kamera, rechts: nach CLAHE (das wertet Howdy aus).
Oben: Dunkelwert (Anteil Pixel im untersten Helligkeits-Achtel) und ob ein
Gesicht gefunden wird. Grün = Howdy würde das Bild prüfen, Rot = "zu dunkel".

Tasten:  Leertaste = Bild speichern   q / Esc = beenden
Ohne Fenster:  ir-bild-test.py --ohne-fenster   (5 Bilder speichern + Werte ausgeben)
"""
import configparser
import os
import sys
import time

import cv2
import dlib
import numpy as np

KONFIG = "/etc/howdy/config.ini"
ORDNER = os.path.expanduser("~/Bilder/ir-test")

cfg = configparser.ConfigParser()
cfg.read(KONFIG)
geraet = cfg.get("video", "device_path",
                 fallback="/dev/v4l/by-path/pci-0000:06:00.0-usb-0:2:1.2-video-index0")
grenze = cfg.getfloat("video", "dark_threshold", fallback=60)

kamera = cv2.VideoCapture(geraet, cv2.CAP_V4L2)
if not kamera.isOpened():
    sys.exit(f"Kamera {geraet} lässt sich nicht öffnen (läuft gerade Howdy?)")

clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
detektor = dlib.get_frontal_face_detector()
os.makedirs(ORDNER, exist_ok=True)


def auswerten(bild):
    grau = bild if bild.ndim == 2 else cv2.cvtColor(bild, cv2.COLOR_BGR2GRAY)
    eq = clahe.apply(grau)
    hist = cv2.calcHist([eq], [0], None, [8], [0, 256])
    hist = np.asarray(hist).ravel()
    dunkel = float(hist[0] / max(1, hist.sum()) * 100)
    gesichter = detektor(eq, 1)
    return grau, eq, dunkel, gesichter


def beschriften(grau, eq, dunkel, gesichter):
    links = cv2.cvtColor(grau, cv2.COLOR_GRAY2BGR)
    rechts = cv2.cvtColor(eq, cv2.COLOR_GRAY2BGR)
    for g in gesichter:
        cv2.rectangle(rechts, (g.left(), g.top()), (g.right(), g.bottom()), (0, 200, 0), 2)
    bild = np.hstack([links, rechts])
    bild = cv2.resize(bild, None, fx=1.5, fy=1.5)
    farbe = (0, 200, 0) if dunkel <= grenze else (0, 0, 255)
    text = f"Dunkel {dunkel:5.1f} %  (Grenze {grenze:.0f})   Gesicht: {'ja' if gesichter else 'nein'}"
    cv2.rectangle(bild, (0, 0), (bild.shape[1], 34), (0, 0, 0), -1)
    cv2.putText(bild, text, (10, 24), cv2.FONT_HERSHEY_SIMPLEX, 0.7, farbe, 2)
    return bild


def speichern(bild, dunkel):
    name = os.path.join(ORDNER, time.strftime("%H%M%S") + f"_dunkel{dunkel:.0f}.png")
    cv2.imwrite(name, bild)
    print("gespeichert:", name)


if "--ohne-fenster" in sys.argv:
    for _ in range(10):          # Kamera/Leuchte anlaufen lassen
        kamera.read()
    for i in range(5):
        ok, bild = kamera.read()
        if not ok:
            sys.exit("Kein Bild von der Kamera")
        grau, eq, dunkel, gesichter = auswerten(bild)
        print(f"Bild {i+1}: Dunkel {dunkel:5.1f} %  Gesicht: {'ja' if gesichter else 'nein'}")
        speichern(beschriften(grau, eq, dunkel, gesichter), dunkel)
        time.sleep(0.3)
    sys.exit()

print(f"Grenze aus {KONFIG}: {grenze:.0f} %. Leertaste = speichern, q = beenden")
while True:
    ok, bild = kamera.read()
    if not ok:
        print("Kein Bild von der Kamera")
        break
    grau, eq, dunkel, gesichter = auswerten(bild)
    anzeige = beschriften(grau, eq, dunkel, gesichter)
    cv2.imshow("IR-Kamera (wie Howdy sie sieht)", anzeige)
    taste = cv2.waitKey(1) & 0xFF
    if taste in (ord("q"), 27):
        break
    if taste == ord(" "):
        speichern(anzeige, dunkel)
    if cv2.getWindowProperty("IR-Kamera (wie Howdy sie sieht)", cv2.WND_PROP_VISIBLE) < 1:
        break

kamera.release()
cv2.destroyAllWindows()
