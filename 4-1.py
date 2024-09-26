# 4-1-dac.py

import RPi.GPIO as GPIO

# Объявляем переменную dac - список GPIO-пинов для DAC
dac = [2, 3, 4, 17, 27, 22, 10, 9]

# Настраиваем режим обращения к GPIO
GPIO.setmode(GPIO.BCM)

# Настраиваем все 8 GPIO-пинов из списка dac на выход
GPIO.setup(dac, GPIO.OUT)

def decimal_to_binary_list(value):
    """Функция перевода десятичного числа в список 0 и 1"""
    return [int(bit) for bit in format(value, '08b')]

try:
    while True:
        # Бесконечно запрашиваем ввод числа от 0 до 255
        user_input = input("Введите число от 0 до 255 (или 'q' для выхода): ")
        
        # Проверка на выход
        if user_input.lower() == 'q':
            break
        
        # Обработка ошибок ввода
        if not user_input.isdigit():
            print("Ошибка: введите числовое значение.")
            continue
        
        value = int(user_input)

        if value < 0:
            print("Ошибка: введите неотрицательное значение.")
            continue
        elif value > 255:
            print("Ошибка: введите значение, не превышающее 255.")
            continue
        
        # Применяем двоичное представление введённого числа к GPIO-пинам
        GPIO.output(dac, decimal_to_binary_list(value))
        
        # Расчет и вывод предполагаемого значения напряжения на выходе ЦАП
        voltage = value * (3.3 / 255)  # Предполагаем, что опорное напряжение 3.3В
        print(f"Предполагаемое значение напряжения на выходе ЦАП: {voltage:.2f} В")

finally:
    # Подавим 0 на все пины dac и очистим настройки GPIO
    GPIO.output(dac, [0]*8)
    GPIO.cleanup()
