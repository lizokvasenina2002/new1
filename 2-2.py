import time
import RPi.GPIO as GPIO

pins=[8, 11, 2, 1, 0, 5, 12, 6]
number=[1,1,1,1,1,1,1,1]

GPIO.setmode(GPIO.BCM)
GPIO.setup(pins,GPIO.OUT)

GPIO.output(pins,number)
time.sleep(20)



GPIO.cleanup()