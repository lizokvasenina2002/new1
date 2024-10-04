import RPi.GPIO as GPIO
import time
GPIO.setmode(GPIO.BCM)
dac = [8, 11, 7, 1, 0, 5, 12, 6]
comp = 14
troyka = 13


GPIO.setup(comp, GPIO.IN)
GPIO.setup(dac, GPIO.OUT, initial = GPIO.LOW)
GPIO.setup(troyka, GPIO.OUT, initial = GPIO.HIGH)

def decimal2binary(N):
    return[int(i) for i in bin(N)[2:].zfill(8)]

def adc(V):
    S = decimal2binary(V)
    GPIO.output(dac, S)
    return(S)


try:
    while True:
        for V in range (256):
            #time.sleep(0.0007)
            S = adc(V)
            time.sleep(0.001)
            CV = GPIO.input(comp)
            if CV == 1:
                print(V, S, 3.3 / 256 * V)
                break
finally:
    GPIO.output(dac, 0)
    GPIO.cleanup()

robot =  [1.5, 2.5];
punktnaznachenia = [4.5, 9.5];

rows = 10;
cols = 10;
field = ones(rows, cols);
field(4, 3) = Inf;
field(4, 4) = Inf;
field(4, 5) = Inf;
field(3, 5) = Inf;
field(5, 8) = Inf;
field(5, 9) = Inf;
field(5, 10) = Inf;
field(6, 10) = Inf;
field(8, 4) = Inf;
field(8, 2) = Inf;
field(8, 3) = Inf;
field(3, 3) = Inf;
[rows, cols] = size(field);
disp(field);

figure;
hold on; 

for r = 1:rows
    for c = 1:cols
        if field(r, c) == Inf
            fill([c-1 c c c-1], [r-1 r-1 r r], 'k')
        else
            fill([c-1 c c c-1], [r-1 r-1 r r], 'w')
        end
    end
end
axis equal; % Установить равные масштабы для осей
xlim([0 cols])
ylim([0 rows])
% Включение сетки
grid on
set(gca, 'Color', 'w'); 
title('Квадратное поле');
xlabel('X');
ylabel('Y');
plot(punktnaznachenia(1), punktnaznachenia(2), 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b'); % Начальная точка
plot(robot(1), robot(2), 'rx', 'MarkerSize', 10); % Позиция робота

%current_position = robot;%текущая позиция

for r = 1:rows
    for c = 1:cols
        if field(r, c) == Inf
            fprintf("Клетка (%d, %d) является препятствием.\n", r, c)
        else
            if r > 1 && field(r-1, c) ~= Inf
                fprintf("Из клетки (%d, %d) можно перейти в верхнюю клетку (%d, %d).\n", r, c, r-1, c);
            end
            if rows < r && field(r+1, c) ~= Inf
                fprintf("Из клетки (%d, %d) можно перейти в нижнюю клетку (%d, %d).\n", r, c, r+1, c);
            end
            if c > 1 && field(r, c-1) ~= Inf
                fprintf("Из клетки (%d, %d) можно перейти в левую клетку (%d, %d).\n", r, c, r, c-1);
            end
            if cols < c && field(r, c+1) ~= Inf
                fprintf("Из клетки (%d, %d) можно перейти в правую клетку (%d, %d).\n", r, c, r, c+1);
            end
            
        end
    end
end
