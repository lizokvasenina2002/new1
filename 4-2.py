# 4-2-triangle.py

import RPi.GPIO as GPIO
import time

# Настраиваем режим обращения к GPIO
GPIO.setmode(GPIO.BCM)

# Объявляем список GPIO-пинов для DAC
dac = [2, 3, 4, 17, 27, 22, 10, 9]

# Настраиваем эти пины как выходы
GPIO.setup(dac, GPIO.OUT)

def dec2bin(value):
    """Функция перевода десятичного числа в двоичное представление"""
    return [int(bit) for bit in format(value, '08b')]

try:
    # Запрашиваем период треугольного сигнала у пользователя
    period = float(input("Введите период треугольного сигнала (в секундах): "))
    half_period = period / 2

    while True:
        # Формируем восходящую часть треугольного сигнала
        for value in range(256):
            GPIO.output(dac, dec2bin(value))
            time.sleep(half_period / 256)  # Задержка для формирования сигнала

        # Формируем нисходящую часть треугольного сигнала
        for value in range(255, -1, -1):
            GPIO.output(dac, dec2bin(value))
            time.sleep(half_period / 256)  # Задержка для формирования сигнала

finally:
    # Подавим 0 на все пины dac и очистим настройки GPIO
    GPIO.output(dac, [0]*8)
    GPIO.cleanup()
