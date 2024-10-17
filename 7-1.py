import RPi.GPIO as a
import matplotlib.pyplot as b
import time
a.setmode(a.BCM)
dac = [8,11,7,1,0,5,12,6]
comp = 14 
troyka = 13

a.setup(troyka, a.OUT, initial = a.HIGH)
a.setup(comp, a.IN)
a.setup(dac, a.OUT, initial = a.LOW)

def tobin(N):
    return[int(i) for i in bin(N)[2:].zfill(8)]
def abc():
    V= 0
    for i in range (8):
        S =2 ** (7- i)
        a.output(dac, tobin(V+S))
        time.sleep(0.01)
        CV =a.input(comp)
        if CV == 0:
            V += S 
    return(V)
list  =[]
try:
    k=0
    a.output(troyka,1)
    start =time.time()
    while k < 200 :
        list.append(abc())
        k +=1
    finish = time.time()
finally: 
    a.output(dac, 0)
    a.cleanup()
print(list)
print(finish - start)
b.plot(list)
b.show()
lists = [str(i) for i in list]
with open ('data.txt', 'w') as  outf:
    outf.write("\n".join(lists))
with open ('settings.txt', 'w') as outf:
    outf.write(str(finish - start))
