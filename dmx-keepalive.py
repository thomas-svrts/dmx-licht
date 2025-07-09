#!/usr/bin/env python3
import json
import os
import time
from ola.ClientWrapper import ClientWrapper

SETTINGS_PATH = "/var/lib/chirolicht/settings.json"
UNIVERSE = 0
DEFAULT_FRAME = [0] * 512
DEFAULT_FRAME[0] = 175  # kanaal 1: dimmer
DEFAULT_FRAME[1] = 80   # rood
DEFAULT_FRAME[2] = 60   # groen
DEFAULT_FRAME[3] = 30   # blauw
DEFAULT_FRAME[4] = 90   # amber

def should_send_fallback(settings):
    """Bepaal of er GEEN actieve instellingen zijn."""
    if not settings:
        return True

    keys = ['dimmer', 'red', 'green', 'blue', 'amber', 'strobo', 'macro', 'speed']
    for key in keys:
        try:
            val = int(settings.get(key, 0))
            if val > 0:
                return False
        except Exception:
            continue
    return True

def send_dmx_frame(frame):
    wrapper = ClientWrapper()
    client = wrapper.Client()
    client.SendDmx(UNIVERSE, frame, lambda _: wrapper.Stop())
    wrapper.Run()

while True:
    try:
        if os.path.exists(SETTINGS_PATH):
            with open(SETTINGS_PATH, 'r') as f:
                settings = json.load(f)
        else:
            settings = {}

        if should_send_fallback(settings):
            send_dmx_frame(DEFAULT_FRAME)

    except Exception as e:
        print(f"[KEEPALIVE] Fout bij verwerken: {e}")

    time.sleep(5)
