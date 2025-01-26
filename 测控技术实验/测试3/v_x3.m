% 数据输入
X1 = [-2.5, -2.25, -2, -1.75, -1.5, -1.25, -1, -0.75, -0.5, -0.25, 0]; % 第一段 X 数据
V1 = [96.4, 84.6, 74.8, 63.8, 54.6, 44.6, 35.6, 26.1, 18.0, 9.2, 1.6]; % 第一段 V 数据
X2 = [0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5]; % 第二段 X 数据
V2 = [1.6, -6.1, -13.4, -21.2, -29.1, -36.5, -44.3, -52.6, -61.0, -70.0, -79.7]; % 第二段 V 数据

% 合并数据
X = [X1, X2(2:end)]; % 合并 X 数据，避免重复 0
V = [V1, V2(2:end)]; % 合并 V 数据

% 绘制图像
figure;
plot(X, V, '-o', 'LineWidth', 1.5, 'MarkerSize', 6); % 使用折线和点绘制
grid on;
xlabel('位移 X (mm)', 'FontSize', 12);
ylabel('电压 V (mV)', 'FontSize', 12);
title('V-X 特性曲线', 'FontSize', 14);
set(gca, 'FontSize', 12);

% 添加注释
text(X1(1), V1(1), sprintf('(%g, %.1f)', X1(1), V1(1)), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
text(X2(end), V2(end), sprintf('(%g, %.1f)', X2(end), V2(end)), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'FontSize', 10);

% 标示 0 处的特殊点
hold on;
scatter(0, 1.6, 50, 'red', 'filled', 'DisplayName', '0点');
legend('数据点及曲线', '0点', 'FontSize', 12, 'Location', 'best');
hold off;
