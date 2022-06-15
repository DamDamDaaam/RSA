def fastModExp(a, n, m):
    r = 1
    while n > 0:
        if n & 1 == 1:
            r = (r * a) % m
        a = (a * a) % m
        n >>= 1
    return r
   
a = int(input("Messaggio da criptare: "))
n = int(input("Chiave: "))
m = int(input("Modulo: "))

print("\nMessaggio criptato: ", fastModExp(a, n, m))
