% 数据输入
X_positive = [5, 4.5, 4, 3.5, 3, 2.5, 2, 1.5, 1, 0.5, 0]; % 正向 X 数据
VO_positive = [412, 380, 340, 304, 260, 228, 184, 140, 100, 58.2, 0]; % 正向 VO 数据

X_negative = [0, -0.5, -1, -1.5, -2, -2.5, -3, -3.5, -4, -4.5, -5]; % 负向 X 数据
VO_negative = [0, 64.2, 102, 142, 184, 224, 264, 304, 344, 380, 420]; % 负向 VO 数据

% 绘图
figure;
hold on; % 保持图像不被覆盖
plot(X_positive, VO_positive, '-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'Color', [0, 0.4470, 0.7410]); % 绘制正向曲线
plot(X_negative, VO_negative, '-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'Color', [0.8500, 0.3250, 0.0980]); % 绘制负向曲线
hold off;

% 图形设置
grid on;
xlabel('X/mm', 'FontSize', 12);
ylabel('V_{O(p-p)}/mV', 'FontSize', 12);
title('差动变压器静态性能 V-X 曲线', 'FontSize', 14);
set(gca, 'FontSize', 12);
legend({'正向曲线', '负向曲线'}, 'FontSize', 12); % 添加图例
