import numpy as np
import numpy.random as r
import matplotlib.pyplot as plt
import scipy.optimize as so

randa = r.randint(0, 2**32, 1000000)
randb = r.randint(0, 2**32, 1000000)

def gaus(x, N, mu, sigma):
    return N * np.exp(-((x - mu)/sigma)**2/2.)

def count_euclid_steps(a, b):
    nsteps = 0
    while b != 0:
        r = a % b
        a = b
        b = r
        nsteps += 1
    return nsteps

ces_vect = np.vectorize(count_euclid_steps)
steps_stat = ces_vect(randa, randb)
values, counts = np.unique(steps_stat, return_counts=True)
print(values)
print(counts)

params, errors = so.curve_fit(gaus, values, counts, p0=[10000., 20., 5.])
x = np.arange(0, 40, 0.1)
print(params)

fig, ax = plt.subplots()
ax.scatter(values, counts)
ax.plot(x, gaus(x, *params))
plt.show()
