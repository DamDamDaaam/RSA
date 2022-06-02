import numpy as np
import os

def checkPrime(n):
    for i in range(2, int(np.sqrt(n) + 1)):
        if n % i == 0:
            return False
    return True

primes = []
for i in range(3, 65536):
    if checkPrime(i):
        primes.append(i)

f = open("bin/primes_16bit.coe", "w")
f.write("memory_initialization_radix=10;" + os.linesep + "memory_initialization_vector=2")
for p in primes:
    f.write("," + str(p))
f.write(";")
f.close()
