import serial
import os.path
import sys

#ser = serial.Serial(port="/dev/ttyUSB1", baudrate=19200)

path = input("Percorso file da criptare: ")
if not os.path.exists(path):
    print("Questo file non esiste")
    sys.exit(0)

#Ricevi il byte con la lunghezza della chiave
n_len = ser.read()
print(n_len)

#Leggi il messaggio da criptare in un array di byte
message = b""
with open(path, "rb") as f:
    message = f.read()

#Invia il messaggio all'FPGA un byte alla volta, leggendo man mano il cifrato
pack_count = 0
for msg_byte in message:
    ser.write(msg_byte)
    pack_count += 8
    while (pack_count >= n_len - 1):
        cipher += ser.read(4)
        pack_count -= n_len - 1

#Invia il carattere EOT e leggi l'ultima word di cifrato
ser.write(4) #Verificare che questo manda effettivamente EOT
cipher += ser.read(4)

#Scrivi su file il cifrato
with open("/home/michele/rsa/bin/cipher.txt", "wb") as f:
    f.write(cipher)
