from flask import Flask, request, jsonify
from ola.ClientWrapper import ClientWrapper

import subprocess

app = Flask(__name__)

def send_dmx(universe, channel_values):
    frame = [0] * 512
    for entry in channel_values:
        ch = entry['channel']
        val = entry['value']
        if 1 <= ch <= 512:
            frame[ch - 1] = val
    wrapper = ClientWrapper()
    client = wrapper.Client()
    client.SendDmx(universe, bytearray(frame), lambda state: wrapper.Stop())
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


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)
