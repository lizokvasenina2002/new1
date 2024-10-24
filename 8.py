import numpy as np
import matplotlib.pyplot as plt
from textwrap import wrap

# Чтение данных из файлов 
with open("data.txt","r") as data:
    data_array=np.array(data.read().split(), dtype=int) 

with open("settings.txt","r") as settings:
    data_settings= [float(i) for i in settings.read().split("\n")]

data_time=np.linspace(0,data_settings[0]*1000,data_array.size) # Перевод номеров отсчётов в секунды

data_array=data_array*data_settings[1] # Перевод показаний АЦП в Вольты

fig,ax = plt.subplots(figsize=(8,6),dpi=100)

ax.grid(color='gray', linestyle='-', linewidth=0.5, alpha=0.5) # сетка

ax.minorticks_on()
ax.grid(which='minor',color='gray',linestyle=':',  linewidth=0.5, alpha=0.5) # Доп. сетка

ax.scatter(data_time[0:data_time.size:10],data_array[0:data_array.size:10],marker='H',c='blue',s=20) # Настройка маркеров

ax.plot(data_time,data_array,label="V(t)",color='red',linewidth=2) # Пострение линии графика

ax.legend(fontsize=14) # Создание легенды

plt.xlim(data_time.min(), data_time.max() + 0.5) # Настройка максимума и минимума оси X
plt.ylim(data_array.min(), data_array.max() + 0.5) # Настройка максимума и минимума оси Y

ax.set_title("/n".join(wrap('Процесс зарядки и разрядки конденсатора в RC цепи',60)), fontsize=14, fontweight='bold') # Название графика
ax.set_ylabel("Напряжение,В", fontsize=14) # Название оси Y
ax.set_xlabel("Время,с", fontsize=14) # Название оси X

# Вывод текста в области графика
plt.text( data_time.max() / 2 + 1.33, data_array.max()/ 2 + 0.25, 'Время заряда: 5.72564 сек.' , size='large', color='black') 
plt.text(data_time.max() / 2 + 1.33, data_array.max()/ 2 + 0.35, 'Время разряда: 7.67436 cек.' , size='large', color='black')

plt.show() # Отображение графика
fig.savefig('graph.svg') # Сохранение графика в файл в формате .svg
