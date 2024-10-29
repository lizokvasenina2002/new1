clc;
clear;
close all;

function oneRobotStep(field, robot, target_points, target_order, disp_flag, color, subplot_idx, paths, robots, colors, line_styles)
    [cols, rows] = size(field);

    current_position = robot;

    directions = [-1 0; 0 1; 1 0; 0 -1];
    visited = ones(cols, rows);
    visited(robot(1), robot(2)) = 0;

    for r = 1:rows
        for c = 1:cols
            if field(c, r) == Inf
                visited(c, r) = Inf;
            end
        end
    end

    subplot(2, 2, subplot_idx);
    hold on;

    for r = 1:rows
        for c = 1:cols
            if field(c, r) == Inf
                fill([c-1 c c c-1], [r-1 r-1 r r], 'k')
            else
                fill([c-1 c c c-1], [r-1 r-1 r r], 'w')
            end
        end
    end

    fill([current_position(1)-1 current_position(1) current_position(1) current_position(1)-1], ...
            [current_position(2)-1 current_position(2)-1 current_position(2) current_position(2)], 'r');

    for i = 1 : length(target_points)
        fill([target_points(i, 1)-1 target_points(i, 1) target_points(i, 1) target_points(i, 1)-1], ...
                [target_points(i, 2)-1 target_points(i, 2)-1 target_points(i, 2) target_points(i, 2)], 'b');
        if isequal(target_points (i, :),robot)
            fill([current_position(1)-1 current_position(1) current_position(1) current_position(1)-1], ...
                [current_position(2)-1 current_position(2)-1 current_position(2) current_position(2)], 'r');
        end
    end

    axis equal;
    xlim([0 cols])
    ylim([0 rows])
    grid on
    set(gca, 'Color', 'w');
    title(['Робот ', num2str(subplot_idx)]);
    xlabel('X');
    ylabel('Y');
    %set(gcf, 'Position', get(0, 'Screensize')); % Устанавливаем размер фигуры на весь экран

    Grid = cell(cols, rows);
    queue = {current_position};
    Grid{current_position(1), current_position(2)} = {current_position, current_position};
    target_index = 1;

    while target_index <= length(target_order)
        target_position = target_points(target_order(target_index), :);

        while ~isempty(queue)
            current_position = queue{1};
            queue(1) = [];
            if isequal(current_position, target_position)
                target_index = target_index + 1;
                break;
            end

            for direction_idx = 1:size(directions, 1)
                new_current_position = current_position + directions(direction_idx, :);
                if new_current_position(1) >= 1 && new_current_position(1) <= cols && new_current_position(2) >= 1 && new_current_position(2) <= rows
                    if field(new_current_position(1), new_current_position(2)) ~= Inf && visited(new_current_position(1), new_current_position(2)) == 1
                        visited(new_current_position(1), new_current_position(2)) = 0;
                        Grid{new_current_position(1), new_current_position(2)} = {current_position, new_current_position};
                        queue{end + 1} = new_current_position;

                        if disp_flag
                            disp("Матрица посещений:");
                            disp(rot90(visited));
                            disp("Откуда и куда пришёл робот:");
                            disp(Grid{new_current_position(1), new_current_position(2)});
                        end
                    end

                    fill([current_position(1)-1 current_position(1) current_position(1) current_position(1)-1], ...
                        [current_position(2)-1 current_position(2)-1 current_position(2) current_position(2)], 'r');
                    pause(0.01);
                end
            end


%для нижней целевой точки
            if current_position(1) > 1 && current_position(1) < cols && current_position(2) > 1 && current_position(2) < rows % проверка на границу
                if field(current_position(1)-1, current_position(2)-1) == Inf && field(current_position(1)+1, current_position(2)-1) == Inf && field(current_position(1)-1, current_position(2)) == Inf && field(current_position(1)+1, current_position(2)) == Inf
                    for k = current_position(2):rows-9
                        visited(current_position(1)+1, k+1) = Inf;
                    end
                end
            end

%для левых целевых точек
            if current_position(1) > 1 && current_position(1) < cols && current_position(2) > 1 && current_position(2) < rows % проверка на границу
                if field(current_position(1)-1, current_position(2)-1) == Inf && field(current_position(1)-1, current_position(2)+1) == Inf && field(current_position(1), current_position(2)+1) == Inf && field(current_position(1), current_position(2)-1) == Inf
                    for k = current_position(1):cols-8
                        visited(k+1, current_position(2)-1) = Inf;
                        visited(k+2, current_position(2)-1) = Inf;
                    end
                end
            end

            %для правых целевых точек
            if current_position(1) > 1 && current_position(1) < cols && current_position(2) > 1 && current_position(2) < rows % проверка на границу
                if field(current_position(1)+1, current_position(2)+1) == Inf && field(current_position(1)+1, current_position(2)-1) == Inf && field(current_position(1), current_position(2)+1) == Inf && field(current_position(1), current_position(2)-1) == Inf
                    for k = current_position(1):cols
                        visited(k-1, current_position(2)+1) = Inf;
                        visited(k-2, current_position(2)+1) = Inf;
                        visited(k-3, current_position(2)+1) = Inf;
                    end
                end
            end

        end

        % Построение обратного пути
        path = [];
        sum = 0; % суммируются такты

        % Начинаем с текущей позиции и идем обратно до начальной позиции
        current_position = target_position;
        while ~isequal(current_position, robot)
            path = [current_position; path]; % добавление текущей позиции в начало массива path (вертикальное объявление матриц)
            previous_position = Grid{current_position(1), current_position(2)}{1}; % получаем предыдущую позицию робота из матрицы Grid ({1} первый элемент содержит координаты предыдущей позиции)
            sum = sum + field(current_position(1), current_position(2)); % обновление общей суммы
            current_position = previous_position;
        end

        path = [robot; path]; % добавление начальной позиции робота в начало массива path
        robot = target_position;
        % Отображаем путь
        for i = 1:size(path, 1)
            fill([path(i, 1)-1 path(i, 1) path(i, 1) path(i, 1)-1], ...
                 [path(i, 2)-1 path(i, 2)-1 path(i, 2) path(i, 2)], color);
            pause(0.1);
        end

        fill([target_position(1)-1 target_position(1) target_position(1) target_position(1)-1], ...
             [target_position(2)-1 target_position(2)-1 target_position(2) target_position(2)], 'b'); % отображение конечной точки

        if disp_flag
            disp("Робот достиг цели!!")
            disp(['Количество тактов:', num2str(sum)]);

            disp("Координаты клеток маршрута по шагам:")
            for i = 1:size(path, 1) % проходим по всем строкам массива path, (size количество строк(т.е. количество позиций в пути))
                disp(['Шаг', num2str(i), ':(', num2str(path(i, 1)), ',', num2str(path(i, 2)), ')'])
            end
        end

        current_position = target_position;
        visited = ones(cols, rows);
        visited(current_position(1), current_position(2)) = 0;
        for r = 1:rows
            for c = 1:cols
                if field(c, r) == Inf
                    visited(c, r) = Inf;
                end
            end
        end

        % Очистка поля после того как робот дошёл до какой-либо целевой точки
        for r = 1:rows
            for c = 1:cols
                if field(c, r) == Inf
                    fill([c-1 c c c-1], [r-1 r-1 r r], 'k')
                else
                    fill([c-1 c c c-1], [r-1 r-1 r r], 'w')
                end
            end
        end

        for i = 1 : length(target_points)
            fill([target_points(i, 1)-1 target_points(i, 1) target_points(i, 1) target_points(i, 1)-1], ...
                    [target_points(i, 2)-1 target_points(i, 2)-1 target_points(i, 2) target_points(i, 2)], 'b');
            if isequal(target_points (i, :),robot)
                fill([current_position(1)-1 current_position(1) current_position(1) current_position(1)-1], ...
                    [current_position(2)-1 current_position(2)-1 current_position(2) current_position(2)], 'r');
            end
        end

        Grid = cell(cols, rows);
        queue = {current_position};
        Grid{current_position(1), current_position(2)} = {current_position, current_position};

        % Сохранение пути
        paths{subplot_idx} = [paths{subplot_idx}; path];
        disp(['Путь для робота ', num2str(subplot_idx), ':']);
        disp(paths{subplot_idx});
        robots{subplot_idx} = target_position;

        % Отображение всех путей на subplot(2, 2, 4)
        subplot(2, 2, 4);
            hold on;
            for i = 1:length(robots)
                for j = 1:size(paths{i}, 1)
                    %plot([paths{i}(j, 1)-1 paths{i}(j, 1)], [paths{i}(j, 2)-1 paths{i}(j, 2)], line_styles{i}, 'Color', colors{i}, 'LineWidth', 2);
                    plot([paths{i}(j, 1)-1 paths{i}(j, 1)], [paths{i}(j, 2)-1 paths{i}(j, 2)], line_styles{i}, 'Color', colors{i}, 'LineWidth', 2);
                end
            end
            for j = 1 : length(target_points)
                fill([target_points(j, 1)-1 target_points(j, 1) target_points(j, 1) target_points(j, 1)-1], ...
                        [target_points(j, 2)-1 target_points(j, 2)-1 target_points(j, 2) target_points(j, 2)], 'b');
            end
            axis equal;
            xlim([0 cols])
            ylim([0 rows])
            grid on
            set(gca, 'Color', 'w');
            title('Все пути');
            xlabel('X');
            ylabel('Y');
    end
    %disp("Все точки посещены!");
    %new_position = current_position;
    
end

%размер поля
rows = 12;
cols = 11;

target_points = [1, 4; 1, 7; 1, 10; 11, 10; 11, 7; 11, 4; 6, 1];%целевые точки

robots = {[6, 1], [6, 1], [6, 1]}; % начальные позиции роботов
target_orders = {[2, 4, 5, 6, 7], [1, 3, 7], [5, 7]}; % порядок посещения целевых точек для каждого робота

field = ones(cols, rows);
field(robots{1}(1), robots{1}(2)) = 0;
field(robots{2}(1), robots{2}(2)) = 0;
field(robots{3}(1), robots{3}(2)) = 0;
field(1, 1) = Inf;
field(2, 1) = Inf;
field(3, 1) = Inf;
field(4, 1) = Inf;
field(5, 1) = Inf;
field(7, 1) = Inf;
field(8, 1) = Inf;
field(9, 1) = Inf;
field(10, 1) = Inf;
field(11, 1) = Inf;
field(1, 2) = Inf;
field(2, 2) = Inf;
field(3, 2) = Inf;
field(4, 2) = Inf;
field(5, 2) = Inf;
field(7, 2) = Inf;
field(8, 2) = Inf;
field(9, 2) = Inf;
field(10, 2) = Inf;
field(11, 2) = Inf;
field(1, 3) = Inf;
field(2, 3) = Inf;
field(10, 3) = Inf;
field(11, 3) = Inf;

field(1, 5) = Inf;
field(2, 5) = Inf;
field(10, 5) = Inf;
field(11, 5) = Inf;

field(1, 6) = Inf;
field(2, 6) = Inf;
field(10, 6) = Inf;
field(11, 6) = Inf;

field(1, 8) = Inf;
field(2, 8) = Inf;
field(10, 8) = Inf;
field(11, 8) = Inf;

field(1, 9) = Inf;
field(2, 9) = Inf;
field(10, 9) = Inf;
field(11, 9) = Inf;

field(1, 11) = Inf;
field(2, 11) = Inf;
field(10, 11) = Inf;
field(11, 11) = Inf;

field(1, 12) = Inf;
field(2, 12) = Inf;
field(10, 12) = Inf;
field(11, 12) = Inf;

field(6, 4) = Inf;
field(6, 5) = Inf;
field(6, 6) = Inf;
field(6, 7) = Inf;
field(6, 8) = Inf;
field(6, 9) = Inf;
field(6, 10) = Inf;

disp_flag = 0;

colors = {'y', 'g', 'c'}; % Цвета для каждого робота
line_styles = {'-', '--', ':'}; % Стили линий для каждого робота

% Инициализация графиков для каждого робота
figure;
for i = 1:length(robots)
    subplot(2, 2, i);
    hold on;
    for r = 1:rows
        for c = 1:cols
            if field(c, r) == Inf
                fill([c-1 c c c-1], [r-1 r-1 r r], 'k')
            else
                fill([c-1 c c c-1], [r-1 r-1 r r], 'w')
            end
        end
    end
    fill([robots{i}(1)-1 robots{i}(1) robots{i}(1) robots{i}(1)-1], ...
            [robots{i}(2)-1 robots{i}(2)-1 robots{i}(2) robots{i}(2)], 'r');
    for j = 1 : length(target_points)
        fill([target_points(j, 1)-1 target_points(j, 1) target_points(j, 1) target_points(j, 1)-1], ...
                [target_points(j, 2)-1 target_points(j, 2)-1 target_points(j, 2) target_points(j, 2)], 'b');
    end
    axis equal;
    xlim([0 cols])
    ylim([0 rows])
    grid on
    set(gca, 'Color', 'w');
    title(['Robot ', num2str(i)]);
    xlabel('X');
    ylabel('Y');
end

% инициализация массивов для хранения путей
paths = cell(length(robots), 1);
for i = 1:length(robots)
    paths{i} = [];
end

% инициализация четвёртого графика
subplot(2, 2, 4);
hold on;
for r = 1:rows
    for c = 1:cols
        if field(c, r) == Inf
            fill([c-1 c c c-1], [r-1 r-1 r r], 'k')
        else
            fill([c-1 c c c-1], [r-1 r-1 r r], 'w')
        end
    end
end
for j = 1 : length(target_points)
    fill([target_points(j, 1)-1 target_points(j, 1) target_points(j, 1) target_points(j, 1)-1], ...
            [target_points(j, 2)-1 target_points(j, 2)-1 target_points(j, 2) target_points(j, 2)], 'b');
end
axis equal;
xlim([0 cols])
ylim([0 rows])
grid on
set(gca, 'Color', 'w');
title('All paths');
xlabel('X');
ylabel('Y');

% одновременное движение роботов
max_steps = 0;
for i = 1:length(target_orders)
    if length(target_orders{i}) > max_steps
        max_steps = length(target_orders{i});
    end
end

for step = 1:max_steps
    for j = 1:length(robots)
        if step <= length(target_orders{j})
            oneRobotStep(field, robots{j}, target_points, target_orders{j}(step), disp_flag, colors{j}, j, paths, robots, colors, line_styles);
            % Обновление начальной позиции робота после каждого шага
            robots{j} = target_points(target_orders{j}(step), :);
        end
    end
    pause(0.1);
end
