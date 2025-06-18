import socket

def send_artnet_packet(channel_values):
    ARTNET_HEADER = b'Art-Net\x00'
    OP_OUTPUT = (0x5000).to_bytes(2, 'little')
    prot_ver = (14).to_bytes(2, 'big')
    seq = b'\x00'
    phys = b'\x00'
    universe = (0).to_bytes(2, 'little')  # Universe 0
    length = len(channel_values).to_bytes(2, 'big')
    
    packet = (
        ARTNET_HEADER +
        OP_OUTPUT +
        prot_ver +
        seq +
        phys +
        universe +
        length +
        bytes(channel_values)
    )

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.sendto(packet, ("127.0.0.1", 6454))
    sock.close()

# ⚠️ DMX kanaal 1 = waarde 255, rest 0
dmx_data = [255] + [0]*511
send_artnet_packet(dmx_data)
