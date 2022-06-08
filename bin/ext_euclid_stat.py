import matplotlib.pyplot as plt
import numpy as np

def euclid(a, b):
    nsteps = 0
    while b != 0:
        r = a % b
        a = b
        b = r
    if a == 1:
        return True
    return False

def ext_euclid(a, b):
    r = a % b
    t1 = 0
    t2 = 1
    t = 0
    biggest = 0
    while b != 1:
        r = a % b
        q = a // b
        t = t1 - t2 * q
        a = b
        b = r
        t1 = t2
        t2 = t
        if abs(t) > biggest:
            biggest = abs(t)
    return biggest

b = []
a = np.random.randint(1, 2**32, 10000)

for i in a:
    ran = np.random.randint(1, i)
    while not euclid(i, ran):
        ran = np.random.randint(1, i)
    b.append(ran)
b = np.array(b)

ext_euclid_vec = np.vectorize(ext_euclid)
stat = ext_euclid_vec(a, b)
values, counts = np.unique(stat, return_counts=True)

biggestest = 0
for i in range(len(a)):
    if stat[i] > biggestest:
        biggestest = stat[i]
    print(a[i], "\t", b[i], "\t", stat[i]) 
print(biggestest)
if (2*biggestest < 2**32):
    print("OK")

