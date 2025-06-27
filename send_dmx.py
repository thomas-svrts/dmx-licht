import serial
import time

# Open de Enttec seriële poort — pas aan als jouw device anders heet
ser = serial.Serial('/dev/ttyUSB0', baudrate=250000)

# DMX frame: kanaal 1 op 128, rest op 0
dmx_frame = bytearray([128] + [0] * 511)

try:
    print("DMX output gestart. Druk Ctrl+C om te stoppen.")
    while True:
        # DMX break + MAB
        ser.break_condition = True
        time.sleep(0.0001)  # 100 µs break
        ser.break_condition = False
        time.sleep(0.000012)  # 12 µs MAB

        # Stuur frame
        ser.write(dmx_frame)

        # Wacht ~25 ms = 40 fps
        time.sleep(0.025)

except KeyboardInterrupt:
    print("DMX output gestopt.")
    ser.close()
