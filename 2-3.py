
import RPi.GPIO as GPIO
GPIO.setmode(GPIO.BCM)
pins_LED=[9, 10, 22, 27, 17, 4, 3, 2]
pins_AUX=[21,20,26,16,19,25,23,24]
values_zero=[0, 0, 0, 0, 0, 0, 0, 0]
values_ones=[1, 1, 1, 1, 1, 1, 1, 1]

GPIO.setup(pins_LED,GPIO.OUT)

GPIO.setup(pins_AUX,GPIO.IN,pull_up_down=GPIO.PUD_UP)

GPIO.output(pins_LED,values_ones)
i=0
while True:
    for i in range(8):
        if GPIO.input(pins_AUX[i]) == 0:
                GPIO.output(pins_LED[i],values_zero[i])
                i=i+1
        else:
            GPIO.output(pins_LED[i],values_ones[i])