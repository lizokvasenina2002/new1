import numpy as np
import show
size = 1000

x = np.linspace(0, size, size)
y = np.random.normal(0, 1, size)

show.my_plot(x,y)

% Задаем координаты точек (товаров)
coords = [0.15, 0.15; 0.45, 0.55; 0.45, 0.35]; % Пример координат

% Начальная позиция (текущий товар)
current_position = [0.95, 0.95]; % Замените на ваши координаты

% Инициализация переменных
num_items = size(coords, 1);
visited = false(num_items, 1); % Для отслеживания посещенных товаров

while sum(visited) < num_items
    % Инициализация массивов для расстояний и индексов
    distances = zeros(num_items, 1);
    
    % Цикл по всем товарам
    for i = 1:num_items
        if ~visited(i) % Игнорируем уже посещенные товары
            % Вычисляем расстояние от текущей позиции до товара
            distances(i) = norm(current_position - coords(i, :));
        else
            distances(i) = inf; % Присваиваем бесконечность посещенным товарам
        end
    end
    
    % Находим индекс ближайшего товара
    [min_distance, closest_index] = min(distances);
    
    % Обновляем текущую позицию
    current_position = coords(closest_index, :);
    visited(closest_index) = true; % Отмечаем товар как посещенный
    
    % Выводим информацию о ближайшем товаре
    fprintf('Ближайший товар: индекс = %d, расстояние = %.2f\n', closest_index, min_distance);
    
    % Выводим порядок индексов и расстояний
    [sorted_distances, index_order] = sort(distances);
    disp('Порядок индексов товара по удаленности и расстояния:');
    for j = 1:num_items
        if sorted_distances(j) < inf
            fprintf('Индекс: %d, Расстояние: %.2f\n', index_order(j), sorted_distances(j));
        end
    end
end

disp('Все товары были посещены.');
