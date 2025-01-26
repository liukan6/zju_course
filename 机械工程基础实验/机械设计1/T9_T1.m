% 数据输入
T9 = [1.500, 3.000, 4.500, 6.000, 7.500, 9.000, 10.500, 12.000]; % 封闭力矩
T1 = [0.863, 0.902, 0.930, 0.949, 0.984, 1.020, 1.039, 1.094];   % 电动机输出转矩
eta = [0.65152, 0.83619, 0.89073, 0.91749, 0.93207, 0.94166, 0.94923, 0.95334]; % 效率

% 绘制 T9-T1 曲线
figure;
plot(T9, T1, '-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'blue');
grid on;
title('T_9-T_1 曲线');
xlabel('封闭力矩 T_9');
ylabel('电动机输出转矩 T_1');
legend('T_9-T_1', 'Location', 'NorthWest');

% 绘制 T9-\eta 曲线
figure;
plot(T9, eta, '-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'blue');
grid on;
title('T_9-\eta 曲线');
xlabel('封闭力矩 T_9');
ylabel('效率 \eta');
legend('T_9-\eta', 'Location', 'NorthWest');
