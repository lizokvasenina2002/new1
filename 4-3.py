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



import time

def adc():
    # Эта функция должна возвращать значение напряжения от 0 до 3.3 В
    # Замените это значение вашим реальным считыванием от ADC
    return 0  # или счетчик ADC

def set_leds(voltage):
    # Преобразуем напряжение в количество светодиодов
    if voltage <= 0:
        led_count = 0
    elif voltage >= 3.3:
        led_count = 8
    else:
        led_count = int((voltage / 3.3) * 8)  # Пропорционально к 8 светодиодам

    # Здесь вызываем функцию, которая управляет светодиодами
    # Например, ваша функция из прошлого занятия
    control_leds(led_count)

def control_leds(count):
    # Ваша логика для управления светодиодами
    # Например, включение/выключение светодиодов
    print(f"Включено светодиодов: {count}")

try:
    while True:
        voltage = adc()  # Получаем значение напряжения
        set_leds(voltage)  # Устанавливаем светодиоды на основе напряжения
        time.sleep(1)  # Задержка для предотвращения слишком частых обновлений
except KeyboardInterrupt:
    print("Остановка программы.")


def update_leds(voltage):
    num_leds_on = int((voltage / 3.3) * 8)  # Преобразование напряжения в количество светодиодов
    for i in range(8):
        leds[i].value = i < num_leds_on
