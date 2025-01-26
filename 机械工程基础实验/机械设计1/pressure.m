% 数据初始化
dd1 = [0, 0.09,	0.16,	0.23,	0.26,	0.3,	0.2	,0.1, 0]; % 在0和180度处添加零值
dd = dd1 + 0.2;
angles = linspace(180, 0, 9); % 调整角度，使其大小与 dd 匹配

% 压力分布曲线绘制
figure;
subplot(2,1,1); hold on;
xxx = []; yyy = []; % 用于存储所有压力线顶点的x和y坐标

% 半圆参数
r = 0.2; % 半圆半径
theta = linspace(pi, 0, 100); % 半圆的角度范围

% 半圆绘制
half_circle_x = r * cos(theta); 
half_circle_y = r * sin(theta);
plot(half_circle_x, half_circle_y, 'k--', 'LineWidth', 1.5);

for i = 1:length(dd)
    % 将压力值投影到x和y方向
    x = dd(i) * cos(angles(i) * pi / 180);
    y = dd(i) * sin(angles(i) * pi / 180);
    
    % 绘制从圆心到压力顶点的线
    plot([0, x], [0, y], 'b-', 'LineWidth', 1.5); 
    xxx = [xxx, x]; 
    yyy = [yyy, y];
end

% 绘制压力分布的红色包络线
plot(xxx, yyy, 'r-', 'LineWidth', 1.5);

xlabel('X');
ylabel('Y');
title('滑动轴承压力分布曲线');
axis equal; grid on;

% 承载量曲线绘制
subplot(2,1,2); hold on;
bearing_capacity = dd1 .* sin(angles * pi / 180); % 计算承载量
plot(0:8, bearing_capacity, 'bo-', 'LineWidth', 1.5); % 绘制承载量曲线
xlabel('传感器标号');
ylabel('压力大小(MPa)');
title('滑动轴承承载量曲线');
grid on;
