# импорт библиотек
import RPi.GPIO as GPIO
import time
import matplotlib.pyplot as plt

# настройка работы пинов 
GPIO.setmode(GPIO.BCM)

# объявление переменных
leds = [2, 3, 4, 17, 27, 22, 10, 9]
#leds = [9, 10, 22, 27, 17, 4, 3, 2]
dac = [8, 11, 7, 1, 0, 5, 12, 6]
comp = 14
troyka = 13
#maxV = 3.3
#minV = 0
data_exp = []
start_time = 0
stop_time = 0

GPIO.setup(leds, GPIO.OUT, initial = GPIO.LOW)
GPIO.setup(dac, GPIO.OUT, initial = GPIO.LOW)
GPIO.setup(comp, GPIO.IN)
GPIO.setup(troyka, GPIO.OUT, initial=GPIO.LOW)

# функция перевода в двоичный код
def tobin(N):

    return[int(i) for i in bin(N)[2:].zfill(8)]

# функция вывода информации ЦАП
def num2dac(value):

    signal = tobin(value)
    GPIO.output(dac, signal)

    return signal

# описание функции преобразования информации с тройки
def adc():

    V=0

    for i in range (8):

        buff = 2**(7-i)
        GPIO.output(dac,num2dac(V+buff))
        time.sleep(0.005)
        compValue = GPIO.input(comp)
        GPIO.output(leds,tobin(V))  

        if compValue == 0:

            V += buff 
    troyka_volt = 3.3/256*V
    return(troyka_volt )

# исполнительная программа
try:
        # подача питания на конденсатор и фиксация времени начала эксперемента
        GPIO.output(troyka,1)
        start_time = time.time()

        #заряд конденсатора
        while adc() < 3:

            print("Значение заряда: ",adc(),"В")
            data_exp.append(int(adc()))

        # отключение питания конденсатора
        GPIO.output(troyka,0)
            
        # разряд конденсатора
        while adc() > 0.3:

            print("Значение заряда: ",adc(),"В")
            data_exp.append(int(adc()))

        # фиксация времени конца эксперемента
        stop_time = time.time()

        # перевод значений напряжения в строку для записи в файл
        data_exp_str = [str(item) for item in data_exp]
        # перевод значений шага квантования и частоты дискритизации в строку для записи в файл
        data_f_str = str(len(data_exp_str)/(stop_time - start_time))
        data_t_str = str((stop_time - start_time)/len(data_exp_str))

        # запись данных во внешний файл
        with open('data.txt','w') as outfile:
            outfile.write("\n".join(data_exp_str))
            #outfile.write("\n")

        with open('settings.txt','w') as outfile:
            outfile.write("Шаг квантования:")
            outfile.write(data_t_str)
            outfile.write("\n")
            outfile.write("Часота дискретизации:")
            outfile.write(data_f_str)

        # вывод общего времени эксперемента
        print("Время эксперемента: ", stop_time - start_time,"сек")

        # вывод графика данных
        plt.plot(data_exp)
        plt.show()

# подача 0 на все GPIO выходы и сброс настроек GPIO
finally:

    GPIO.output(dac, 0)
    GPIO.output(leds, 0)
    GPIO.cleanup()





%%%%%%%%%%%%
import RPi.GPIO as a
import matplotlib.pyplot as b
import time
a.setmode(a.BCM)
dac = [8,11,7,1,0,5,12,6]
comp = 14 
troyka = 13

a.setup(troyka, a.OUT, initial = a.HIGH)
a.setup(comp, a.IN)
a.setup(dac, a.OUT, initial = a.LOW)

def tobin(N):
    return[int(i) for i in bin(N)[2:].zfill(8)]
def abc():
    V= 0
    for i in range (8):
        S =2 ** (7- i)
        a.output(dac, tobin(V+S))
        time.sleep(0.01)
        CV =a.input(comp)
        if CV == 0:
            V += S 
    return(V)
list  =[]
try:
    k=0
    a.output(troyka,1)
    start =time.time()
    while k < 200 :
        list.append(abc())
        k +=1
    finish = time.time()
finally: 
    a.output(dac, 0)
    a.cleanup()
print(list)
print(finish - start)
b.plot(list)
b.show()
lists = [str(i) for i in list]
with open ('data.txt', 'w') as  outf:
    outf.write("\n".join(lists))
with open ('settings.txt', 'w') as outf:
    outf.write(str(finish - start))
