import serial
import time

ser = serial.Serial(port="/dev/ttyUSB1", baudrate=9600)
to_send = "Sting riconoscibile Sting riconoscibile String riconoscibile String riconoscibile String riconoscibile String riconoscibile'+-;:,.-_?!%&^"
message = b""
encoded_to_send = to_send.encode()

#ser.write(encoded_to_send)

with open("/home/michele/rsa/bin/cipher.txt", "wb") as file:
    for character in to_send:
        ser.write(character.encode())
        file.write(ser.read())

print(message.decode())
