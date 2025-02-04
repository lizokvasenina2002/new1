clc;
clear;
close all;

% Глобальные переменные для хранения ссылок на управляющие элементы и других данных
global edit1 edit2 edit3 field robots target_points disp_flag paths all_paths colors visualization_fig axes_handles current_steps;

% Определение функций
function paths = findPaths(field, robot, target_points, target_order, disp_flag)
    [cols, rows] = size(field);

    current_position = robot;

    directions = [-1 0; 0 1; 1 0; 0 -1];
    visited = ones(cols, rows);
    %visited(robot(1), robot(2)) = 0;

    % добавление большего времени преодоления клетки для целевых точек
    for i = 1:size(target_points, 1)
        visited(target_points(i, 1), target_points(i, 2)) = 5;
    end

    for r = 1:rows
        for c = 1:cols
            if field(c, r) == Inf
                visited(c, r) = Inf;
            end
        end
    end

    Grid = cell(cols, rows);
    queue = {current_position};
    Grid{current_position(1), current_position(2)} = {current_position, current_position};
    target_index = 1;

    paths = {};
    total_time = 0;

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
                    while visited(new_current_position(1), new_current_position(2)) ~= Inf && visited(new_current_position(1), new_current_position(2)) > 1 && field(new_current_position(1), new_current_position(2)) ~= Inf
                        Grid{new_current_position(1), new_current_position(2)} = {new_current_position, new_current_position};
                        queue{end + 1} = new_current_position;
                        visited(new_current_position(1), new_current_position(2)) = visited(new_current_position(1), new_current_position(2)) - 1;
                        if disp_flag
                            disp("Матрица посещений:");
                            disp(rot90(visited));
                            disp("Откуда и куда пришёл робот:");
                            disp(Grid{new_current_position(1), new_current_position(2)});
                        end
                    end
                    if visited(new_current_position(1), new_current_position(2)) ~= Inf && visited(new_current_position(1), new_current_position(2)) == 1 && field(new_current_position(1), new_current_position(2)) ~= Inf
                        Grid{new_current_position(1), new_current_position(2)} = {current_position, new_current_position};
                        queue{end + 1} = new_current_position;
                        visited(new_current_position(1), new_current_position(2)) = visited(new_current_position(1), new_current_position(2)) - 1;
                        if disp_flag
                            disp("Матрица посещений:");
                            disp(rot90(visited));
                            disp("Откуда и куда пришёл робот:");
                            disp(Grid{new_current_position(1), new_current_position(2)});
                        end
                    end

                end
            end

            %для нижней целевой точки
            if current_position(1) > 1 && current_position(1) < cols && current_position(2) > 1 && current_position(2) < rows
                if field(current_position(1)-1, current_position(2)-1) == Inf && field(current_position(1)+1, current_position(2)-1) == Inf && field(current_position(1)-1, current_position(2)) == Inf && field(current_position(1)+1, current_position(2)) == Inf
                    for k = current_position(2):rows-9
                        visited(current_position(1)+1, k+1) = Inf;
                    end
                end
            end

            %для левых целевых точек
            if current_position(1) > 1 && current_position(1) < cols && current_position(2) > 1 && current_position(2) < rows
                if field(current_position(1)-1, current_position(2)-1) == Inf && field(current_position(1)-1, current_position(2)+1) == Inf && field(current_position(1), current_position(2)+1) == Inf && field(current_position(1), current_position(2)-1) == Inf
                    for k = current_position(1):cols-8
                        visited(k+1, current_position(2)-1) = Inf;
                        visited(k+2, current_position(2)-1) = Inf;
                    end
                end
            end

            %для правых целевых точек
            if current_position(1) > 1 && current_position(1) < cols && current_position(2) > 1 && current_position(2) < rows
                if field(current_position(1)+1, current_position(2)+1) == Inf && field(current_position(1)+1, current_position(2)-1) == Inf && field(current_position(1), current_position(2)+1) == Inf && field(current_position(1), current_position(2)-1) == Inf
                    for k = current_position(1):cols
                        visited(k-1, current_position(2)+1) = Inf;
                        visited(k-2, current_position(2)+1) = Inf;
                        visited(k-3, current_position(2)+1) = Inf;
                    end
                end
            end
        end

        % Найти обратный путь от целевой точки до начальной
        reverse_path = [];
        current_position = target_position;

        while ~isequal(current_position, robot)
            if visited(current_position(1), current_position(2)) ~= 1
                reverse_path = [reverse_path; current_position];
                previous_position = Grid{current_position(1), current_position(2)}{1};
                current_position = previous_position;
            end
        end

        %ПРОЙТИСЬ ПРЯМЫМ ПУТЁМ ОТ НАЧАЛЬНОЙ ПОЗИЦИИ ДО ЦЕЛЕВОЙ ТОЧКИ С ПОДСЧЁТОМ ВРЕМЕНИ
        % Инвертировать путь и добавить начальную позицию
        path = flipud(reverse_path);
        path = [robot; path];

        sum = 0;
        % Вычислить время для прямого пути
        current_time = total_time;
        for i = 2:size(path, 1)
            current_time = current_time + 1;
            path(i, 3) = current_time;
            sum = sum + 1;

            % Увеличиваем время на 1 такт, пока значение в field > 1
            while field(path(i, 1), path(i, 2)) > 1
                current_time = current_time + 1;
                field(path(i, 1), path(i, 2)) = field(path(i, 1), path(i, 2)) - 1;
                path = [path; path(i, :)];
                path(end, 3) = current_time;
                sum = sum + 1;
            end

            % Обновляем позицию робота и препятствия вокруг него
            inf_coords = updateObstaclesAroundRobot(field, path(i, 1:2));

        end

        % Обновляем начальную позицию робота
        robot = target_position;

        % Сохраняем путь
        paths{end + 1} = path;

        % Обновляем общее время
        total_time = current_time;

        if disp_flag
            disp("Робот достиг цели!!")
            disp(['Количество тактов:', num2str(sum)]);
            disp("Координаты клеток маршрута по шагам:")
            for i = 1:size(path, 1)
                disp(['Шаг', num2str(i), ':(', num2str(path(i, 1)), ',', num2str(path(i, 2)), ',', num2str(path(i, 3)), ')'])
            end
        end

        current_position = target_position;
        visited = ones(cols, rows);
        %visited(current_position(1), current_position(2)) = 0;

        for r = 1:rows
            for c = 1:cols
                if field(c, r) == Inf
                    visited(c, r) = Inf;
                end
            end
        end
        for i = 1:size(target_points, 1)
            visited(target_points(i, 1), target_points(i, 2)) = 5;
        end

        Grid = cell(cols, rows);
        queue = {current_position};
        Grid{current_position(1), current_position(2)} = {current_position, current_position};
    end
    disp(['Общее время для каждого робота:', num2str(total_time)]);
end

function inf_coords = updateObstaclesAroundRobot(field, robot)
     % Удаляем препятствия с предыдущей позиции
    for r = 1:size(field, 1)
        for c = 1:size(field, 2)
            if field(r, c) == Inf && (r ~= robot(1) || c ~= robot(2))
                field(r, c) = 1;
            end
        end
    end

    % Добавляем препятствия вокруг текущей позиции робота
    if robot(1) > 1
        field(robot(1)-1, robot(2)) = Inf;
    end
    if robot(1) < size(field, 1)
        field(robot(1)+1, robot(2)) = Inf;
    end
    if robot(2) > 1
        field(robot(1), robot(2)-1) = Inf;
    end
    if robot(2) < size(field, 2)
        field(robot(1), robot(2)+1) = Inf;
    end
    if robot(1) > 1 && robot(2) > 1
        field(robot(1)-1, robot(2)-1) = Inf;
    end
    if robot(1) < size(field, 1) && robot(2) > 1
        field(robot(1)+1, robot(2)-1) = Inf;
    end
    if robot(1) < size(field, 1) && robot(2) < size(field, 2)
        field(robot(1)+1, robot(2)+1) = Inf;
    end
    if robot(2) < size(field, 2) && robot(1) > 1
        field(robot(1)-1, robot(2)+1) = Inf;
    end

    % Устанавливаем позицию робота как Inf
    field(robot(1), robot(2)) = Inf;

    % Выводим матрицу field в командное окно
    disp("Матрица field:");
    disp(rot90(field));

    [rows, cols] = find(field == Inf);

    % Объединить координаты в массив
    inf_coords = [rows, cols];

    % Вывести массив в командное окно
    disp('Координаты клеток с значением Inf:');
    disp(inf_coords);
end

function visualizePaths(robot_index, field, paths, target_points, colors, visualization_fig, current_step)
    global axes_handles current_steps;

    [cols, rows] = size(field);

    figure(visualization_fig);
    axes(axes_handles(robot_index));
    hold on;

    % Находит максимальное количество точек в пути среди всех роботов
    max_steps = size(paths{robot_index}, 1);

    for step = current_step:max_steps
        if step <= size(paths{robot_index}, 1)
            axes(axes_handles(robot_index));
            fill([paths{robot_index}(step, 1)-1 paths{robot_index}(step, 1) paths{robot_index}(step, 1) paths{robot_index}(step, 1)-1], ...
                 [paths{robot_index}(step, 2)-1 paths{robot_index}(step, 2)-1 paths{robot_index}(step, 2) paths{robot_index}(step, 2)], colors{robot_index});
            axes(axes_handles(4));
            fill([paths{robot_index}(step, 1)-1 paths{robot_index}(step, 1) paths{robot_index}(step, 1) paths{robot_index}(step, 1)-1], ...
                [paths{robot_index}(step, 2)-1 paths{robot_index}(step, 2)-1 paths{robot_index}(step, 2) paths{robot_index}(step, 2)], colors{robot_index}, 'FaceAlpha', 0.5);
        end
        drawnow; % Обновление графика
        pause(1);
    end
    current_steps(robot_index) = step; % Сохраняем текущий шаг для возобновления
end

% Размер поля
rows = 12;
cols = 11;

target_points = [1, 4; 1, 7; 1, 10; 11, 10; 11, 7; 11, 4; 6, 1]; % Целевые точки

robots = {[6, 1], [6, 1], [6, 1]}; % Начальные позиции роботов

field = ones(cols, rows);

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

for i = 1:size(target_points, 1)
    field(target_points(i, 1), target_points(i, 2)) = 5;
end

disp_flag = 1;

colors = {'y', 'g', 'm'}; % Цвета для каждого робота

% Создание фигуры для ввода заданий и визуализации
visualization_fig = figure('Name', 'Ввод заданий и визуализация путей', 'Position', [100, 100, 1200, 800]);

% Создание панели для элементов управления
control_panel = uipanel(visualization_fig, 'Position', [0.01 0.6 0.3 0.35], 'Title', 'Ввод заданий для роботов');

uicontrol('Style', 'text', 'Parent', control_panel, 'Position', [0, 200, 80, 20], 'String', 'Робот 1');
uicontrol('Style', 'text', 'Parent', control_panel, 'Position', [0, 150, 80, 20], 'String', 'Робот 2');
uicontrol('Style', 'text', 'Parent', control_panel, 'Position', [0, 100, 80, 20], 'String', 'Робот 3');

edit1 = uicontrol('Style', 'edit', 'Parent', control_panel, 'Position', [80, 200, 150, 20]);
edit2 = uicontrol('Style', 'edit', 'Parent', control_panel, 'Position', [80, 150, 150, 20]);
edit3 = uicontrol('Style', 'edit', 'Parent', control_panel, 'Position', [80, 100, 150, 20]);

button1 = uicontrol('Style', 'pushbutton', 'Parent', control_panel, 'String', 'Найти путь', 'Position', [240, 200, 100, 20], 'Callback', @(src, event) findPathCallback(1));
button2 = uicontrol('Style', 'pushbutton', 'Parent', control_panel, 'String', 'Найти путь', 'Position', [240, 150, 100, 20], 'Callback', @(src, event) findPathCallback(2));
button3 = uicontrol('Style', 'pushbutton', 'Parent', control_panel, 'String', 'Найти путь', 'Position', [240, 100, 100, 20], 'Callback', @(src, event) findPathCallback(3));

% Создание панели для визуализации
visualization_panel = uipanel(visualization_fig, 'Position', [0.35 0.05 0.64 0.9], 'Title', 'Визуализация путей');

% Создание осей для визуализации
axes_handles = zeros(1, 4);
for i = 1:4
    axes_handles(i) = subplot(2, 2, i, 'Parent', visualization_panel);
    hold on;
end

% Инициализация полей с целевыми точками и препятствиями
for i = 1:4
    axes(axes_handles(i));
    for r = 1:rows
        for c = 1:cols
            if field(c, r) == Inf
                fill([c-1 c c c-1], [r-1 r-1 r r], 'k')
            else
                fill([c-1 c c c-1], [r-1 r-1 r r], 'w')
            end
        end
    end
    for j = 1:length(target_points)
        fill([target_points(j, 1)-1 target_points(j, 1) target_points(j, 1) target_points(j, 1)-1], ...
             [target_points(j, 2)-1 target_points(j, 2)-1 target_points(j, 2) target_points(j, 2)], 'b');
    end
    axis equal;
    xlim([0 cols])
    ylim([0 rows])
    grid on
    set(gca, 'Color', 'w');
    if i <= 3
        title(['Робот ', num2str(i)]);
    else
        title('Все пути');
    end
    xlabel('X');
    ylabel('Y');
end

% Основной цикл для асинхронного ввода данных и визуализации
paths = cell(length(robots), 1); % Для хранения путей всех роботов
all_paths = cell(length(robots), 1); % Для хранения всех путей
current_steps = ones(1, length(robots)); % Начальный шаг визуализации для каждого робота

function findPathCallback(robot_index)
    global edit1 edit2 edit3 field robots target_points disp_flag paths all_paths colors visualization_fig current_steps;

    % Ввод целевых точек для текущего робота
    input_str = get(eval(['edit' num2str(robot_index)]), 'String');
    target_orders = str2num(input_str); %#ok<ST2NM>
    if isempty(target_orders)
        fprintf('Некорректный ввод. Повторите попытку.\n');
        return;
    end

    % Поиск пути для текущего робота
    disp(['Поиск пути для робота ', num2str(robot_index)]);
    all_paths{robot_index} = findPaths(field, robots{robot_index}, target_points, target_orders, disp_flag);
    paths{robot_index} = vertcat(all_paths{robot_index}{:});

    % Обновить начальную позицию робота для следующего задания
    robots{robot_index} = paths{robot_index}(end, 1:2);

    % Очистка поля ввода
    set(eval(['edit' num2str(robot_index)]), 'String', '');

    % Проверка на пересечение траекторий и добавление ожидания
    for i = 1:length(paths)
        for j = i+1:length(paths)
            for k = 1:size(paths{i}, 1)
                for l = 1:size(paths{j}, 1)
                    % Проверка на пересечение координат Inf на одном и том же такте
                    if paths{i}(k, 3) == paths{j}(l, 3) || paths{i}(k, 3) == paths{j}(l, 3) + 1
                        inf_coords_i = updateObstaclesAroundRobot(field, paths{i}(k, 1:2));
                        inf_coords_j = updateObstaclesAroundRobot(field, paths{j}(l, 1:2));

                        % Проверка на пересечение координат Inf
                        if any(ismember(inf_coords_j, [paths{i}(k, 1), paths{i}(k, 2)], 'rows')) && ...
                                any(ismember(inf_coords_i, inf_coords_j, 'rows')) && ...
                                any(ismember(inf_coords_i, [paths{j}(l, 1), paths{j}(l, 2)], 'rows'))
                            % Добавляем ожидание для второго робота
                            paths{j} = [paths{j}(1:l-1, :); paths{j}(l, :) + [0, 0, 1]; paths{j}(l:end, :) + [0, 0, 1]];
                        end
                    end
                end
            end
        end
    end

    % Проверка на посещение целевых точек и добавление ожидания
    for i = 1:length(paths)
        for j = i+1:length(paths)
            for k = 1:size(paths{i}, 1)
                for l = 1:size(paths{j}, 1)
                    % Проверка на посещение целевой точки
                    if ismember([paths{i}(k, 1), paths{i}(k, 2)], target_points, 'rows') && ...
                            ismember([paths{j}(l, 1), paths{j}(l, 2)], target_points, 'rows')
                        % Проверка на пересечение времени
                        if paths{i}(k, 3) == paths{j}(l, 3)
                            % Добавляем ожидание для второго робота
                            paths{j} = [paths{j}(1:l-1, :); paths{j}(l, :) + [0, 0, 1]; paths{j}(l:end, :) + [0, 0, 1]];
                        end
                    end
                end
            end
        end
    end

    % Инициализация времени для каждого робота
    for i = 1:length(paths)
        paths{i}(:, 3) = 0:(size(paths{i}, 1)-1);
    end

    for i = 1:length(robots)
        disp(['Шаги ', num2str(i), ' робота:'])
        disp(paths{i});
    end

    % Запуск визуализации
    visualizePaths(robot_index, field, paths, target_points, colors, visualization_fig, current_steps(robot_index));
end
