% 数据输入
X = [5, 4.5, 4, 3.5, 3, 2.5, 2, 1.5, 1, 0.5, 0, -0.5, -1, -1.5, -2, -2.5, -3, -3.5, -4, -4.5, -5]; % X 数据
Vave = [-853, -785, -708, -634, -562, -483, -409, -346, -268, -184, -105, -22.8, 60.7, 143, 230, 312, 346, 447, 528, 604, 684]; % Vave 数据

% 绘图
figure;
plot(X, Vave, '-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'Color', [0, 0.4470, 0.7410]); % 绘制曲线
grid on;
xlabel('X/mm', 'FontSize', 12);
ylabel('V_{O(p-p)}/mV', 'FontSize', 12);
title('差动变压器静态性能 V-X 曲线', 'FontSize', 14);
set(gca, 'FontSize', 12);
