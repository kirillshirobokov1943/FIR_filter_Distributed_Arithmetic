clear; clc; close all;

%  Параметры
Fs = 1000;              % Частота дискретизации, Гц
N  = 300;               % Количество отсчетов (можно изменить по необходимости)
t  = (0:N-1)/Fs;        % Вектор времени

% Формирование входного сигнала x 
% (по величине отсчеты не должны превышать 1)
x_float = 0.4*sin(2*pi*20*t) + 0.5*sin(2*pi*350*t);

% Q1.15: 1 знаковый бит, 15 дробных. Диапазон: [-1, 1-2^-15]
x_q15 = int16(round(x_float * 2^15));
% насыщение
x_q15 = min(max(x_q15, -32768), 32767); 

%  Коэффициенты КИХ-фильтра (формат Q1.15)
h_hex = {'FFEC', 'FF9E', '010E', '0254', 'FB6E', 'F766', '114F', '38F0', ...
         '38F0', '114F', 'F766', 'FB6E', '0254', '010E', 'FF9E', 'FFEC'};
% Преобразование Hex строки в signed int16 (дополнительный код)
h_q15 = int16(cellfun(@(s) typecast(uint16(hex2dec(s)), 'int16'), h_hex));

%  Симуляция КИХ-фильтра в формате Q1.15
y_q15 = zeros(1, N, 'int16');
L = length(h_q15);

for n = 1:N
    acc = int64(0); % 64-битный аккумулятор для предотвращения переполнения при суммировании
    for k = 1:L
        idx = n - k + 1;
        if idx >= 1
            % Умножение: Q1.15 * Q1.15 -> Q2.30 (результат в int64)
            acc = acc + int64(x_q15(idx)) * int64(h_q15(k));
        end
    end
    % Преобразование Q2.30 обратно в Q1.15:
    y_val = round(double(acc) / 2^15);
    y_val = min(max(y_val, -32768), 32767);
    y_q15(n) = int16(y_val);
end


%Построение графиов
x_plot = double(x_q15) / 2^15;
y_plot = double(y_q15) / 2^15;

figure('Color', 'w');
plot(t, x_plot, 'b', 'LineWidth', 1.5, 'DisplayName', 'x (Вход)'); hold on;

plot(t, y_plot, 'r', 'LineWidth', 3,   'DisplayName', 'y (Выход)'); 
grid on;
xlabel('Время, с');
ylabel('Амплитуда');
title('Входной и выходной сигналы модели (формат Q1.15)');
legend('Location', 'best');
hold off;
savefig('Matlab_model_filtering.fig');  % Сохранение в текущей папке

%  Запись в текстовые файлы x.txt и y.txt
fid_x = fopen('x.txt', 'w');
fid_y = fopen('y.txt', 'w');

for i = 0:N-1
    % Преобразование signed int16 в 4-значное HEX представление (дополнительный код)
    hex_x = dec2hex(typecast(x_q15(i+1), 'uint16'), 4);
    hex_y = dec2hex(typecast(y_q15(i+1), 'uint16'), 4);
    
    
    fprintf(fid_x, '%s\n', hex_x);
    fprintf(fid_y, '%s\n', hex_y);
end

fclose(fid_x);
fclose(fid_y);
disp('Готово. Графики построены, файлы x.txt и y.txt сохранены в текущей директории.');