clc;
clear;
close all;

function paths = findPaths(field, robot, target_points, target_order, disp_flag)
    [cols, rows] = size(field);

    current_position = robot;

    directions = [-1 0; 0 1; 1 0; 0 -1];
    visited = ones(cols, rows);
    visited(robot(1), robot(2)) = 0;

    % добавление большего времени преодоления клетки для целевых точек
    visited(target_points(1, 1), target_points(1, 2)) = 5;
    visited(target_points(2, 1), target_points(2, 2)) = 5;
    visited(target_points(3, 1), target_points(3, 2)) = 5;
    visited(target_points(4, 1), target_points(4, 2)) = 5;
    visited(target_points(5, 1), target_points(5, 2)) = 5;
    visited(target_points(6, 1), target_points(6, 2)) = 5;

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
                    while visited(new_current_position(1), new_current_position(2)) ~= Inf && visited(new_current_position(1), new_current_position(2)) > 1
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
                    if visited(new_current_position(1), new_current_position(2)) ~= Inf && visited(new_current_position(1), new_current_position(2)) == 1
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

            if current_position(1) > 1 && current_position(1) < cols && current_position(2) > 1 && current_position(2) < rows
                if field(current_position(1)-1, current_position(2)-1) == Inf && field(current_position(1)+1, current_position(2)-1) == Inf && field(current_position(1)-1, current_position(2)) == Inf && field(current_position(1)+1, current_position(2)) == Inf
                    for k = current_position(2):rows-9
                        visited(current_position(1)+1, k+1) = Inf;
                    end
                end
            end

            if current_position(1) > 1 && current_position(1) < cols && current_position(2) > 1 && current_position(2) < rows
                if field(current_position(1)-1, current_position(2)-1) == Inf && field(current_position(1)-1, current_position(2)+1) == Inf && field(current_position(1), current_position(2)+1) == Inf && field(current_position(1), current_position(2)-1) == Inf
                    for k = current_position(1):cols-8
                        visited(k+1, current_position(2)-1) = Inf;
                        visited(k+2, current_position(2)-1) = Inf;
                    end
                end
            end

            if current_position(1) > 1 && current_position(1) < cols && current_position(2) > 1 && current_position(2) < rows
                if field(current_position(1)+1, current_position(2)+1) == Inf && field(current_position(1)+1, current_position(2)-1) == Inf && field(current_position(1), current_position(2)+1) == Inf && field(current_position(1), current_position(2)-1) == Inf
                    for k = current_position(1):cols
                        visited(k-1, current_position(2)+1) = Inf;
                        visited(k-2, current_position(2)+1) = Inf;
                        visited(k-3, current_position(2)+1) = Inf;
                        visited(5, 3) = Inf;
                    end
                end
            end
        end

        path = [];
        sum = 0;
        current_position = target_position;
        while ~isequal(current_position, robot)
            path = [current_position; path];
            previous_position = Grid{current_position(1), current_position(2)}{1};
            sum = sum + field(current_position(1), current_position(2));
            current_position = previous_position;
        end

        path = [robot; path];
        robot = target_position;

        paths{end + 1} = path;

        if disp_flag
            disp("Робот достиг цели!!")
            disp(['Количество тактов:', num2str(sum)]);
            disp("Координаты клеток маршрута по шагам:")
            for i = 1:size(path, 1)
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
        visited(target_points(1, 1), target_points(1, 2)) = 5;
        visited(target_points(2, 1), target_points(2, 2)) = 5;
        visited(target_points(3, 1), target_points(3, 2)) = 5;
        visited(target_points(4, 1), target_points(4, 2)) = 5;
        visited(target_points(5, 1), target_points(5, 2)) = 5;
        visited(target_points(6, 1), target_points(6, 2)) = 5;

        Grid = cell(cols, rows);
        queue = {current_position};
        Grid{current_position(1), current_position(2)} = {current_position, current_position};
    end
end

function visualizePaths(field, paths, target_points, colors)
    [cols, rows] = size(field);

    figure;
    for i = 1:length(paths)
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
        for j = 1:length(target_points)
            fill([target_points(j, 1)-1 target_points(j, 1) target_points(j, 1) target_points(j, 1)-1], ...
                 [target_points(j, 2)-1 target_points(j, 2)-1 target_points(j, 2) target_points(j, 2)], 'b');
        end

        axis equal;
        xlim([0 cols])
        ylim([0 rows])
        grid on
        set(gca, 'Color', 'w');
        title(['Робот ', num2str(i)]);
        xlabel('X');
        ylabel('Y');
    end

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
    for j = 1:length(target_points)
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

    max_steps = max(cellfun(@(x) size(x, 1), paths));

    for step = 1:max_steps
        for i = 1:length(paths)
            if step <= size(paths{i}, 1)
                subplot(2, 2, i);
                fill([paths{i}(step, 1)-1 paths{i}(step, 1) paths{i}(step, 1) paths{i}(step, 1)-1], ...
                     [paths{i}(step, 2)-1 paths{i}(step, 2)-1 paths{i}(step, 2) paths{i}(step, 2)], colors{i});
                subplot(2, 2, 4);
                fill([paths{i}(step, 1)-1 paths{i}(step, 1) paths{i}(step, 1) paths{i}(step, 1)-1], ...
                    [paths{i}(step, 2)-1 paths{i}(step, 2)-1 paths{i}(step, 2) paths{i}(step, 2)], colors{i}, 'FaceAlpha', 0.5);
            end
        end
        pause(0.5);
    end
end

%размер поля
rows = 12;
cols = 11;

target_points = [1, 4; 1, 7; 1, 10; 11, 10; 11, 7; 11, 4; 6, 1];%целевые точки

robots = {[6, 1], [6, 1], [6, 1]}; % начальные позиции роботов

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

disp_flag = 1;

colors = {'y', 'g', 'm'}; % Цвета для каждого робота

% Собрать все задания для роботов
all_target_orders = cell(length(robots), 1);
for i = 1:length(robots)
    prompt = sprintf('Введите целевые точки, которые должен посетить робот %d (например, [2, 4, 5, 6, 7]): ', i);
    all_target_orders{i} = input(prompt);
end

% Найти пути для всех роботов и визуализировать их
all_paths = cell(length(robots), 1);
paths = cell(length(robots), 1);
figure; % Создаем одну фигуру для всех роботов

for i = 1:length(robots)
    all_paths{i} = findPaths(field, robots{i}, target_points, all_target_orders{i}, disp_flag);
    paths{i} = vertcat(all_paths{i}{:});
    disp(['Шаги ', num2str(i), ' робота:'])
    disp(paths{i});
end

% Визуализировать пути после сбора всех заданий
visualizePaths(field, paths, target_points, colors);