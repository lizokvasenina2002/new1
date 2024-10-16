import RPi.GPIO as GPIO
import time
GPIO.setmode(GPIO.BCM)
dac = [8, 11, 7, 1, 0, 5, 12, 6]
comp = 14
troyka = 13


GPIO.setup(comp, GPIO.IN)
GPIO.setup(dac, GPIO.OUT, initial = GPIO.LOW)
GPIO.setup(troyka, GPIO.OUT, initial = GPIO.HIGH)

def decimal2binary(N):
    return[int(i) for i in bin(N)[2:].zfill(8)]



def adc():
    V = 0
    for i in range (8):
        S = 2 ** (7 - i)
        GPIO.output(dac, decimal2binary(V + S))
        time.sleep(0.001)
        CV = GPIO.input(comp)
        if CV == 0:
            V += S
    return(V, 3.3 / 256* V)


try:
    while True:
        print(adc())
finally:
    GPIO.output(dac, 0)
    GPIO.cleanup()
