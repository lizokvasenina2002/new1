import RPi.GPIO as GPIO
import time
GPIO.setmode(GPIO.BCM)
dac = [8, 11, 7, 1, 0, 5, 12, 6]
comp = 14
troyka = 13
leds = [2, 3, 4, 17, 27, 22, 10, 9]

GPIO.setup(leds, GPIO.OUT, initial = GPIO.LOW)
GPIO.setup(comp, GPIO.IN)
GPIO.setup(dac, GPIO.OUT, initial = GPIO.LOW)
GPIO.setup(troyka, GPIO.OUT, initial = GPIO.HIGH)

def decimal2binary(N):
    return[int(i) for i in bin(N)[2:].zfill(8)]


def adc():
    V = 0
    for i in range (0,8,1):
        S = 2 ** (7 - i)
        GPIO.output(dac, decimal2binary(V + S))
        time.sleep(0.001)
        CV = GPIO.input(comp)
        if CV == 0:
            V += S


        if V >= 30*i:
            GPIO.output(leds[i], 1)
        else:
            GPIO.output(leds[i], 0)

    return(V, 3.3 / 256* V)


try:
    while True:
        print(adc())
finally:
    GPIO.output(dac, 0)
    GPIO.cleanup()
