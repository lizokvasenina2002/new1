clc;
clear;
close all;

% Глобальные переменные для хранения ссылок на элементы управления и других данных
global field robots target_points disp_flag disp_flag2 paths all_paths colors visualization_fig axes_handles current_steps current_times start_time start_tic;

% Определение функций
function paths = findPaths(field, robot, target_points, target_order, disp_flag, disp_flag2, start_tick)
    [cols, rows] = size(field);

    current_position = robot;

    directions = [-1 0; 0 1; 1 0; 0 -1];
    visited = ones(cols, rows);

    % Добавление большего времени преодоления клетки для целевых точек
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
    total_time = start_tick;

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

            % Для нижней целевой точки
            if current_position(1) > 1 && current_position(1) < cols && current_position(2) > 1 && current_position(2) < rows
                if field(current_position(1)-1, current_position(2)-1) == Inf && field(current_position(1)+1, current_position(2)-1) == Inf && field(current_position(1)-1, current_position(2)) == Inf && field(current_position(1)+1, current_position(2)) == Inf
                    for k = current_position(2):rows-9
                        visited(current_position(1)+1, k+1) = Inf;
                    end
                end
            end

            % Для левых целевых точек
            if current_position(1) > 1 && current_position(1) < cols && current_position(2) > 1 && current_position(2) < rows
                if field(current_position(1)-1, current_position(2)-1) == Inf && field(current_position(1)-1, current_position(2)+1) == Inf && field(current_position(1), current_position(2)+1) == Inf && field(current_position(1), current_position(2)-1) == Inf
                    for k = current_position(1):cols-8
                        visited(k+1, current_position(2)-1) = Inf;
                        visited(k+2, current_position(2)-1) = Inf;
                    end
                end
            end

            % Для правых целевых точек
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
            inf_coords = updateObstaclesAroundRobot(field, path(i, 1:2), disp_flag);
        end

        % Обновляем начальную позицию робота
        robot = target_position;

        % Сохраняем путь
        paths{end + 1} = path;

        % Обновляем общее время
        total_time = current_time;

        if disp_flag2
            disp("Робот достиг цели!!")
            disp(['Количество тактов:', num2str(sum)]);
            disp("Координаты клеток маршрута по шагам:")
            for i = 1:size(path, 1)
                disp(['Шаг', num2str(i), ':(', num2str(path(i, 1)), ',', num2str(path(i, 2)), ',', num2str(path(i, 3)), ')'])
            end
        end

        current_position = target_position;
        visited = ones(cols, rows);

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
    if disp_flag2
        disp(['Общее время для каждого робота:', num2str(total_time)]);
    end
end

function inf_coords = updateObstaclesAroundRobot(field, robot, disp_flag)
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

    if disp_flag
        % Выводим матрицу field в командное окно
        disp("Матрица field:");
        disp(rot90(field));
    end
    [rows, cols] = find(field == Inf);

    % Объединить координаты в массив
    inf_coords = [rows, cols];

    if disp_flag
        % Вывести массив в командное окно
        disp('Координаты клеток с значением Inf:');
        disp(inf_coords);
    end
end

function visualizePaths(field, paths, target_points, colors, visualization_fig)
    global axes_handles current_steps current_times start_time;

    [cols, rows] = size(field);

    figure(visualization_fig);

    % Находит максимальное количество шагов среди всех роботов
    max_steps = max(cellfun(@(path) size(path, 1), paths));

    % Цикл по каждому шагу и визуализация путей для всех роботов
    for step = 1:max_steps
        for robot_index = 1:length(paths)
            if step <= size(paths{robot_index}, 1)
                % Обновление индивидуального субплота для каждого робота
                axes(axes_handles(robot_index));
                fill([paths{robot_index}(step, 1)-1 paths{robot_index}(step, 1) paths{robot_index}(step, 1) paths{robot_index}(step, 1)-1], ...
                     [paths{robot_index}(step, 2)-1 paths{robot_index}(step, 2)-1 paths{robot_index}(step, 2) paths{robot_index}(step, 2)], colors{robot_index});

                % Обновление субплота наложения
                axes(axes_handles(4));
                fill([paths{robot_index}(step, 1)-1 paths{robot_index}(step, 1) paths{robot_index}(step, 1) paths{robot_index}(step, 1)-1], ...
                     [paths{robot_index}(step, 2)-1 paths{robot_index}(step, 2)-1 paths{robot_index}(step, 2) paths{robot_index}(step, 2)], colors{robot_index}, 'FaceAlpha', 0.5);
            end
        end
        drawnow; % Обновление графика
        pause(0.3); % Пауза для визуализации шага
    end
end

% Размер поля
rows = 12;
cols = 11;

target_points = [1, 4; 1, 7; 1, 10; 11, 10; 11, 7; 11, 4; 6, 1]; % Целевые точки

robots = {[6, 1], [6, 1], [6, 1]}; % Начальные позиции роботов

field = ones(cols, rows);

field([1:5, 7:11], 1) = Inf;
field([1:5, 7:11], 2) = Inf;
field([1:2, 10:11], 3) = Inf;
field([1:2, 10:11], [5:6, 8:9, 11:12]) = Inf;
field(6, 4:10) = Inf;

for i = 1:size(target_points, 1)
    field(target_points(i, 1), target_points(i, 2)) = 5;
end

disp_flag = 0;
disp_flag2 = 1; % Включаем дополнительный флаг для вывода

colors = {'y', 'g', 'm'}; % Цвета для каждого робота

% Создание фигуры для визуализации
visualization_fig = figure('Name', 'Визуализация путей', 'Position', [100, 100, 1200, 800]);

% Создание панели для визуализации
visualization_panel = uipanel(visualization_fig, 'Position', [0.05 0.05 0.9 0.9], 'Title', 'Визуализация путей');

% Создание осей для визуализации
axes_handles = zeros(1, 4);
for i = 1:4
    axes_handles(i) = subplot(2, 2, i, 'Parent', visualization_panel);
    hold on;
end

% Инициализация поля с целевыми точками и препятствиями
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
    xlim([0 cols]);
    ylim([0 rows]);
    grid on;
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

global current_times; % Объявляет глобальную переменную для отслеживания текущего времени каждого робота
current_times = zeros(1, length(robots)); % Инициализировать текущее время для каждого робота

start_time = []; % Инициализация времени начала выполнения задания
start_tic = []; % Инициализация тактов начала выполнения задания

% Функция для генерации случайного задания
function target_order = generateRandomTask(num_targets)
    target_order = randperm(num_targets); % Генерация случайного порядка целевых точек
end

% Асинхронное выполнение функции updateRobotPosition
function startAsyncVisualization(paths, colors, visualization_fig, axes_handles)
    % Создание таймера для асинхронной визуализации
    max_steps = max(cellfun(@(path) size(path, 1), paths));
    t = timer('ExecutionMode', 'fixedRate', 'Period', 0.1, 'TasksToExecute', max_steps, ...
              'TimerFcn', @(~, ~) updateRobotPositions(paths, colors, visualization_fig, axes_handles));

    start(t);
end

function updateRobotPositions(paths, colors, visualization_fig, axes_handles)
    global current_steps;

    figure(visualization_fig);

    % Получение текущего шага
    step = min(current_steps);

    for robot_index = 1:length(paths)
        if step <= size(paths{robot_index}, 1)
            % Обновление индивидуального субплота для каждого робота
            axes(axes_handles(robot_index));
            fill([paths{robot_index}(step, 1)-1 paths{robot_index}(step, 1) paths{robot_index}(step, 1) paths{robot_index}(step, 1)-1], ...
                 [paths{robot_index}(step, 2)-1 paths{robot_index}(step, 2)-1 paths{robot_index}(step, 2) paths{robot_index}(step, 2)], colors{robot_index});

            % Обновление субплота наложения
            axes(axes_handles(4));
            fill([paths{robot_index}(step, 1)-1 paths{robot_index}(step, 1) paths{robot_index}(step, 1) paths{robot_index}(step, 1)-1], ...
                 [paths{robot_index}(step, 2)-1 paths{robot_index}(step, 2)-1 paths{robot_index}(step, 2) paths{robot_index}(step, 2)], colors{robot_index}, 'FaceAlpha', 0.5);
        end
    end

    drawnow; % Обновление графика
    pause(0.1); % Пауза для визуализации шага

    % Увеличиваем шаг
    current_steps = current_steps + 1;
end

%очистка предыдущего пути только для текущего робота
function clearPreviousPath(robot_index, field, target_points, axes_handles)
    global colors;

    % Очистка предыдущего пути только для текущего робота
    axes(axes_handles(robot_index));
    cla; % Очистка текущего субплота

    % Перерисовка непреодолимых препятствий
    [cols, rows] = size(field);
    for r = 1:rows
        for c = 1:cols
            if field(c, r) == Inf
                fill([c-1 c c c-1], [r-1 r-1 r r], 'k');
            else
                fill([c-1 c c c-1], [r-1 r-1 r r], 'w');
            end
        end
    end

    % Перерисовка целевых точек
    for j = 1:length(target_points)
        fill([target_points(j, 1)-1 target_points(j, 1) target_points(j, 1) target_points(j, 1)-1], ...
             [target_points(j, 2)-1 target_points(j, 2)-1 target_points(j, 2) target_points(j, 2)], 'b');
    end

    % Настройка осей и сетки
    axis equal;
    xlim([0 cols]);
    ylim([0 rows]);
    grid on;
    set(gca, 'Color', 'w');
    title(['Робот ', num2str(robot_index)]);
    xlabel('X');
    ylabel('Y');

    % Очистка предыдущего пути только для текущего робота
    axes(axes_handles(4));
    cla; % Очистка текущего субплота

    % Перерисовка непреодолимых препятствий
    [cols, rows] = size(field);
    for r = 1:rows
        for c = 1:cols
            if field(c, r) == Inf
                fill([c-1 c c c-1], [r-1 r-1 r r], 'k');
            else
                fill([c-1 c c c-1], [r-1 r-1 r r], 'w');
            end
        end
    end

    % Перерисовка целевых точек
    for j = 1:length(target_points)
        fill([target_points(j, 1)-1 target_points(j, 1) target_points(j, 1) target_points(j, 1)-1], ...
             [target_points(j, 2)-1 target_points(j, 2)-1 target_points(j, 2) target_points(j, 2)], 'b');
    end

    % Настройка осей и сетки
    axis equal;
    xlim([0 cols]);
    ylim([0 rows]);
    grid on;
    set(gca, 'Color', 'w');
    title('Все пути');
    xlabel('X');
    ylabel('Y');
end

function step = getTimerStep(robot_index)
    % для получения текущего шага таймера
    % используется глобальная переменная для хранения текущего шага
    global current_steps;
    step = current_steps(robot_index);
    current_steps(robot_index) = current_steps(robot_index) + 1;
end

% Основной цикл для генерации заданий и визуализации
num_targets = size(target_points, 1); % Количество целевых точек
for robot_index = 1:length(robots)
    % Генерация случайного задания
    target_order = generateRandomTask(6); % Изменено на 6

    % Вывод начальной позиции робота
    if disp_flag2
        disp(['Начальная позиция робота ', num2str(robot_index), ': (', num2str(robots{robot_index}(1)), ',', num2str(robots{robot_index}(2)), ')']);
    end

    % Вывод задания для текущего робота
    if disp_flag2
        disp(['Задание для робота ', num2str(robot_index), ':']);
        for i = 1:length(target_order)
            disp(['Целевая точка ', num2str(i), ': (', num2str(target_points(target_order(i), 1)), ',', num2str(target_points(target_order(i), 2)), ')']);
        end
    end

    % Поиск пути для текущего робота
    if disp_flag2
        disp(['Поиск пути для робота ', num2str(robot_index)]);
    end

    % Инициализация времени и тактов для текущего робота
    if isempty(start_time)
        start_time = tic;
        start_tic = 0;
    end
    current_start_time = toc(start_time);
    current_start_tic = start_tic;

    if robot_index == 1
        start_tic = current_start_tic;
    else
        start_tic = current_steps(robot_index - 1);
    end

    % Очистка предыдущего пути только для текущего робота
    clearPreviousPath(robot_index, field, target_points, axes_handles);

    all_paths{robot_index} = findPaths(field, robots{robot_index}, target_points, target_order, disp_flag, disp_flag2, start_tic);
    paths{robot_index} = vertcat(all_paths{robot_index}{:});

    % Обновляем начальную позицию робота для следующего задания
    robots{robot_index} = paths{robot_index}(end, 1:2);

    % Обновить глобальное текущее время до конца текущего пути робота.
    current_times(robot_index) = paths{robot_index}(end, 3) + 1;

    % Проверка на пересечение траекторий и добавление ожидания
    for i = 1:length(paths)
        for j = i+1:length(paths)
            for k = 1:size(paths{i}, 1)
                for l = 1:size(paths{j}, 1)
                    % Проверка на пересечение координат Inf на одном и том же такте
                    if paths{i}(k, 3) == paths{j}(l, 3) || paths{i}(k, 3) == paths{j}(l, 3) + 1
                        inf_coords_i = updateObstaclesAroundRobot(field, paths{i}(k, 1:2), disp_flag);
                        inf_coords_j = updateObstaclesAroundRobot(field, paths{j}(l, 1:2), disp_flag);

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

    % Вывод шагов только для текущего робота
    if disp_flag2
        disp(['Шаги ', num2str(robot_index), ' робота:'])
        disp(paths{robot_index});
    end
end

% Запуск асинхронной визуализации для всех роботов
startAsyncVisualization(paths, colors, visualization_fig, axes_handles);

% Уведомление о выполнении задания
for robot_index = 1:length(robots)
    if disp_flag2
        fprintf('Задание для робота %d выполнено\n', robot_index);
    end

    % Записываем время выполнения задания
    end_time = toc(start_time);
    minutes = floor(end_time / 60);
    seconds = floor(end_time - minutes * 60);
    if disp_flag2
        fprintf('Время выполнения задания для робота %d: %02d:%02d\n', robot_index, minutes, seconds);
    end

    % Вывод времени выполнения задания в тактах
    total_ticks = paths{robot_index}(end, 3);
    if disp_flag2
        fprintf('Время выполнения задания для робота %d в тактах: %d\n', robot_index, total_ticks);
    end
end
