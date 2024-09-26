import RPi.GPIO as GPIO
#import sys
dac = [8, 11, 7, 1, 8, 5, 12, 6]
GPIO.setmode(GPIO.BCM)
GPIO.setup(dac,GPIO.OUT)
def decimal2binary(value):
    return [int(element) for element in bin(value)[2:].zfill(8)]
try:
    try:
        while(True):
            print("Введите любое число от 0 до 255:")
            a=input()
            if (int(a)>=0 and int(a)<256):
                GPIO.output(dac,decimal2binary(int(a)))
                print("{:.4f}".format((int(a)*3.3)/256)) 
            elif int(a)<0:
                print ("Число отрицательно")
            elif int(a)>266:
                print ("Число больше 255")
            else:
                print ("Вы ввели неверное значение")
        #if (a== 0001):
            #sys.exit()
    except ValueError:
        print ("Вы ввели неверное значение")

finally:
    GPIO.output(dac,0)
    GPIO.cleanup()