import sys
import serial
import serial.serialutil as sut

import threading
import time

SERIAL_PORT = "/dev/ttyUSB1"

##################################################
## CARICAMENTO DEL FILE CONTENENTE IL MESSAGGIO ##
##################################################

if len(sys.argv) != 2:
    path = input("Inserire il percorso del file da criptare:\n")
    print("")
else:
    path = sys.argv[1]
    
try:
    with open(path, "rb") as message_file:
        message = message_file.read()
except FileNotFoundError:
    print("File non trovato")
    sys.exit(0)

####################################
## CONNESSIONE ALLA PORTA SERIALE ##
####################################

print("Connessione alla porta seriale...")

try:
    ser = serial.Serial(port=SERIAL_PORT, baudrate=19200)
except sut.SerialException:
    print("Operazione fallita. Controllare la connessione seriale")
    sys.exit(0)

print("Aperta comunicazione seriale")

############################################
## RICEZIONE DELLA LUNGHEZZA DELLA CHIAVE ##
############################################

print("\nIn attesa dello start su FPGA...")
print("Per terminare il programma senza criptare premere ctrl+C")

try:
    n_key_len_bytes = ser.read(1)
    n_key_len = int.from_bytes(n_key_len_bytes, "big")
except KeyboardInterrupt:
    print("\nProgramma terminato")
    sys.exit(0)

if n_key_len == 0:
    n_key_len = 32

print("\nAcquisita lunghezza della chiave:", str(n_key_len), "bit")

################################
## OPERAZIONE DI CRITTOGRAFIA ##
################################

print("\nCrittografia in corso...")

cipher = b""

byte_count = 0
pending_bits = 0

while byte_count < len(message):
    while pending_bits < n_key_len - 1:
        ser.write(chr(message[byte_count]).encode("latin1"))
        byte_count += 1
        pending_bits += 8
        if byte_count == len(message):
            break
    while pending_bits >= n_key_len - 1:
        cipher += ser.read(4)
        pending_bits -= n_key_len - 1

"""ser.timeout = 0.001

def sender_loop():
    delay = 0.001 * 32.0 / n_key_len
    for value in message:
        ser.write(chr(value).encode("latin1"))
        time.sleep(delay)
    ser.write(chr(4).encode("latin1"))
    time.sleep(0.1)

sender = threading.Thread(target=sender_loop)
sender.start()

while sender.is_alive():
    cipher += ser.read(1)"""

ser.write(chr(4).encode("latin1")) #EOT

print(pending_bits)
if pending_bits != 0:
    cipher += ser.read(4)

print("Crittografia completata")

####################################
## SCRITTURA DEL FILE DEL CIFRATO ##
####################################

print("\nScrittura su file del cifrato...")

cipher_path = path[:path.rfind(".")] + "_enc" + path[path.rfind("."):]

with open(cipher_path, "wb") as cipher_file:
    cipher_file.write(cipher)
    
print("Scrittura completata con successo")
print("Il file cifrato è", cipher_path)
