import time
import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)
GPIO.setup(3,GPIO.OUT)
GPIO.setup(2,GPIO.OUT)
GPIO.setup(4,GPIO.OUT)
GPIO.setup(17,GPIO.OUT)
GPIO.setup(27,GPIO.OUT)
GPIO.setup(22,GPIO.OUT)
GPIO.setup(9,GPIO.OUT)
GPIO.setup(10,GPIO.OUT)
GPIO.setup(16,GPIO.IN,pull_up_down=GPIO.PUD_DOWN)

pins=[9, 10, 22, 27, 17, 4, 3, 2]
values_zeros=[0, 0, 0, 0, 0, 0, 0, 0]
values_ones=[1, 1, 1, 1, 1, 1, 1, 1]

GPIO.output(pins,values_zeros)

step=0

while step < 3:
    i=0
    GPIO.output(pins[i],values_ones[i])
    i=1
    while i < 7:
        GPIO.output(pins[i-1],values_zeros[i-1])
        GPIO.output(pins[i],values_ones[i])
        time.sleep(0.05)
        GPIO.output(pins[i],values_zeros[i])
        GPIO.output(pins[i+1],values_ones[i+1])
        time.sleep(0.05)
        i= i+1
        time.sleep(0.05)
    GPIO.output(pins[i],values_zeros[i])
    step = step+1

GPIO.output(pins,values_zeros)
GPIO.cleanup()