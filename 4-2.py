import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BCM)
dac = [8, 11, 7, 1, 8, 5, 12, 6]
GPIO.setup(dac, GPIO.OUT)

def decimal2binary(N):
    return [int(element) for element in bin(N)[2:].zfill(8)]

print ("Задайте период сигнала:")

t=int(input())
step = t/(512 * 8)
v = 0
try:
    while True:
        # Формируем восходящую часть треугольного сигнала
        for i in range(0, 256):
            for j in range(len(dac)):
                GPIO.output(dac[j],int(decimal2binary(i)[j]))
                time.sleep(step)
            v = 0 + i*(3.3/256)
            print("Уровень сигнала:", "{:.4f}".format(v)) 

        # Формируем нисходящую часть треугольного сигнала
        for i in range(255, -1, -1):
            for j in range(len(dac)):
                GPIO.output(dac[j],int(decimal2binary(i)[j]))
                time.sleep(step) 
            v = (3.3 -(3.3/256)) - (255-i)*(3.3/256)
            print("Уровень сигнала:", "{:.4f}".format(v)) 

finally:
    GPIO.output(dac,0)
    GPIO.cleanup()