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
values_zero=[0, 0, 0, 0, 0, 0, 0, 0]
values_ones=[1, 1, 1, 1, 1, 1, 1, 1]
GPIO.output(pins,values_zero)

while True:
    if GPIO.input(16) == 1:
        GPIO.output(pins,values_zero)
        time.sleep(0.2)
        GPIO.output(pins,values_ones)
        time.sleep(0.2)
    else:
        GPIO.output(pins,values_zero)