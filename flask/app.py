from flask import Flask, request, jsonify
from ola.ClientWrapper import ClientWrapper
import array
import os
import json

SETTINGS_PATH = "/var/lib/chirolicht/settings.json"


app = Flask(__name__)

def send_dmx(universe, channel_values):
    # Maak een frame met 512 kanalen, allemaal 0
    frame = array.array('B', [0] * 512)

    # Zet de gevraagde kanalen
    for entry in channel_values:
        ch = entry['channel']
        val = entry['value']
        if 1 <= ch <= 512:
            frame[ch - 1] = val

    wrapper = ClientWrapper()
    client = wrapper.Client()
    client.SendDmx(universe, frame, lambda status: wrapper.Stop())
    wrapper.Run()

@app.route('/api/dmx/batch', methods=['POST'])
def set_dmx_batch():
    try:
        data = request.get_json(force=True)
        if not isinstance(data, list):
            return jsonify({"error": "Expected list of channel/value dicts"}), 400

        for entry in data:
            if 'channel' not in entry or 'value' not in entry:
                return jsonify({"error": f"Invalid entry: {entry}"}), 400
            entry['channel'] = int(entry['channel'])
            entry['value'] = int(entry['value'])

        send_dmx(0, data)
        return jsonify({"status": "ok", "channels": data})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/settings', methods=['GET', 'POST'])
def settings():
    if request.method == 'GET':
        if os.path.exists(SETTINGS_PATH):
            with open(SETTINGS_PATH, 'r') as f:
                try:
                    return jsonify(json.load(f))
                except Exception as e:
                    return jsonify({"error": "Corrupt bestand", "detail": str(e)}), 500
        else:
            return jsonify({})  # Geen instellingen bewaard

    if request.method == 'POST':
        data = request.get_json(force=True)
        try:
            with open(SETTINGS_PATH, 'w') as f:
                json.dump(data, f)
            return jsonify({"status": "ok"})
        except Exception as e:
            return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)
