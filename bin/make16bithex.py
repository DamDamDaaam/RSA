import numpy as np
import os

def checkPrime(n):
    for i in range(2, int(np.sqrt(n) + 1)):
        if n % i == 0:
            return False
    return True

primes = []
for i in range(5, 65536):
    if checkPrime(i):
        primes.append(i)

f = open("bin/primes_16bit.hex", "w")

f.write(str(3))
for p in primes:
    f.write(os.linesep + hex(p)[2:])
for i in range(2**13 - len(primes) - 1):
    f.write(os.linesep + hex(primes[-i])[2:])
    
f.close()
