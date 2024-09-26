import RPi.GPIO as GPIO
GPIO.setmode(GPIO.BCM)
GPIO.setup(24, GPIO.OUT)
GPIO.setup(9,GPIO.OUT)

d = GPIO.PWM(24, 100)
p = GPIO.PWM(9, 100)
p.start(0)
d.start(0)
 
print("Введите заполнение ШИМ (%):")

try:
    
    while True:

        a=int(input())
        n = int(a)
        p.ChangeDutyCycle(n)
        d.ChangeDutyCycle(n)

finally:

    p.stop()
    GPIO.cleanup()
