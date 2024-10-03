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

def adc(V):
    S = decimal2binary(V)
    GPIO.output(dac, S)
    return(S)


try:
    while True:
        for V in range (256):
            #time.sleep(0.0007)
            S = adc(V)
            time.sleep(0.001)
            CV = GPIO.input(comp)
            if CV == 1:
                print(V, S, 3.3 / 256 * V)
                break
finally:
    GPIO.output(dac, 0)
    GPIO.cleanup()
