import sys
import time
import serial
import serial.serialutil as sut

SERIAL_PORT = "/dev/ttyUSB1"

################################################
## CARICAMENTO DEL FILE CONTENENTE IL CIFRATO ##
################################################

if len(sys.argv) != 2:
    path = input("Inserire il percorso del file da decriptare:\n")
    print("")
else:
    path = sys.argv[1]
    
try:
    with open(path, "rb") as cipher_file:
        cipher = cipher_file.read()
except FileNotFoundError:
    print("File non trovato")
    sys.exit(0)

####################################
## CONNESSIONE ALLA PORTA SERIALE ##
####################################

print("Connessione alla porta seriale...")

try:
    ser = serial.Serial(port=SERIAL_PORT, baudrate=19200, timeout=0.02)
except sut.SerialException:
    print("Operazione fallita. Controllare la connessione seriale")
    sys.exit(0)

print("Aperta comunicazione seriale")

##################################
## ATTESA PRESSIONE TASTO START ##
##################################

print("\nPremere start su FPGA, quindi premere invio sul pc per avviare l'operazione")

input("")

##############################################
## TRASMISSIONE DELLA LUNGHEZZA DEL CIFRATO ##
##############################################

print("\nTrasmissione della lunghezza del cifrato...")

cipher_len = len(cipher) // 4
cipher_len_bytes = cipher_len.to_bytes(4, "big")
for cl_byte in cipher_len_bytes:
    ser.write(chr(cl_byte).encode("latin1"))

print("Trasmissione completata")

##################################
## OPERAZIONE DI DECRITTOGRAFIA ##
##################################

print("\nDecrittografia in corso...")

message = ""
words = []

for i in range(4, len(cipher) + 1, 4):
    words.append(cipher[i - 4 : i])

for word in words:
    for word_byte in word:
        ser.write(chr(word_byte).encode("latin1"))
    message += ser.read(4).decode("latin1")

print("Decrittografia completata")

###############################################
## SCRITTURA SU FILE DEL MESSAGGIO IN CHIARO ##
###############################################

print("\nScrittura su file del messaggio in chiaro")

first_null_index = message.find(chr(0))
if first_null_index != -1:
    message = message[:first_null_index]

decrypted_path = path[:path.rfind(".")] + "_dec" + path[path.rfind("."):]

with open(decrypted_path, "w") as decrypted_file:
    decrypted_file.write(message)
    
print("Scrittura completata con successo")
print("Il file decriptato è", decrypted_path)
