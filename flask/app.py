from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/api/dmx', methods=['GET', 'POST'])
def set_dmx():
    if request.method == 'GET':
        channel = request.args.get('channel')
        value = request.args.get('value')
    elif request.method == 'POST':
        data = request.get_json(force=True)
        channel = data.get('channel')
        value = data.get('value')
    else:
        return jsonify({"error": "Unsupported method"}), 405

    if not channel or not value:
        return jsonify({"error": "Missing channel or value"}), 400

    try:
        subprocess.run(["/usr/local/bin/dmx-set", str(channel), str(value)], check=True)
        return jsonify({"status": "ok", "channel": channel, "value": value})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)
