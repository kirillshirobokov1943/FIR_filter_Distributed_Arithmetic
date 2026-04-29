clear; clc; close all;

%%  Чтение файла x.txt
filename_x = 'x.txt';
fid = fopen(filename_x, 'r');
if fid == -1
    error('Файл %s не найден в текущей директории.', filename_x);
end
%% Считываем все строки (игнорируя пустые места)
raw_data_x = textscan(fid, '%s');
fclose(fid);
% Преобразование в массив x (формат Q1.15 в Double)
x = hex_to_q15_double(raw_data_x{1});

%%  Чтение файла y_out.txt
filename_y = 'y_out.txt';
fid = fopen(filename_y, 'r');
if fid == -1
    error('Файл %s не найден в текущей директории.', filename_y);
end
%% Считываем все строки
raw_data_y = textscan(fid, '%s');
fclose(fid);
%% Преобразование в массив y_out (формат Q1.15 в Double)
y_out = hex_to_q15_double(raw_data_y{1});

%%  Построение графиков
figure('Color', 'w');

%% График x (стандартная толщина линии)
plot(x, 'b-', 'LineWidth', 1.5, 'DisplayName', 'x (Вход)'); hold on;

%% График y_out (толстая линия)
plot(y_out, 'r-', 'LineWidth', 3,   'DisplayName', 'y\_out (Выход)');

grid on;
xlabel('Номер отсчета');
ylabel('Амплитуда');
title('Входной и выходной сигналы дизайна (Q1.15)');
legend('Location', 'best');
hold off;
savefig('DA_filtering.fig');

disp(['Загружено отсчетов x: ', num2str(length(x))]);
disp(['Загружено отсчетов y: ', num2str(length(y_out))]);

%% Вспомогательная функция преобразования
function data_double = hex_to_q15_double(hex_strings)
    %%  Преобразование Hex строк в десятичные числа (возвращает unsigned double)
    vals_unsigned = hex2dec(hex_strings);
    
    %%  Приведение к типу uint16
    vals_uint16 = uint16(vals_unsigned);
    
    %%  Интерпретация битов как знакового int16 (дополнительный код
    vals_signed_int16 = typecast(vals_uint16, 'int16');
    
    %% Масштабирование для формата Q1.15 -
    %% Формат Q1.15 имеет 15 бит дробной части, значит делим на 2^15 (32768)
    data_double = double(vals_signed_int16) / 2^15;
end