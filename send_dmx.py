import serial
import time

try:
    print("Openen van seriële poort...")
    ser = serial.Serial('/dev/ttyUSB0', baudrate=250000)
    print(f"Seriële poort geopend: {ser.name}")
except Exception as e:
    print(f"Fout bij openen seriële poort: {e}")
    exit(1)

dmx_frame = bytearray([128] + [0] * 511)

try:
    print("Start DMX output. Ctrl+C om te stoppen.")
    frame_count = 0
    while True:
        try:
            ser.break_condition = True
            time.sleep(0.0001)
            ser.break_condition = False
            time.sleep(0.000012)

            bytes_written = ser.write(dmx_frame)
            frame_count += 1
            if frame_count % 10 == 0:
                print(f"{frame_count} frames verzonden, laatste write: {bytes_written} bytes")

            time.sleep(0.025)
        except Exception as e:
            print(f"Fout tijdens DMX frame versturen: {e}")
            break

except KeyboardInterrupt:
    print("\nDMX output gestopt door gebruiker.")

finally:
    print("Sluit seriële poort...")
    ser.close()
