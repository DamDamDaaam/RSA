import serial

ser = serial.Serial(port="/dev/ttyUSB1", baudrate=19200)
current_string = input("Scrivere q per uscire. Scrivere esadecimale per inviare.\n")

while current_string not in ["quit", "q"]:
    value = int(current_string, 16)
    ser.write(chr(value).encode("latin1"))
    current_string = input("")

#1b 00 e5 f9 fb 01 e3 f4 2c
