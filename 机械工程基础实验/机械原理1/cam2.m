% 提供的凸轮半径数据
radii = [56.30730243, 57.92949628, 59.36594474, 60.73175054, 61.73794784, ...
         62.2179564, 62.24784352, 62.04092199, 61.89009797, 61.81658386, ...
         61.73830939, 61.68594566, 61.63237686, 61.59863278, 61.54379875, ...
         61.48076995, 61.4190068, 61.35091705, 61.28843152, 61.25896646, ...
         61.19461366, 60.9814943, 60.22514045, 58.78854358, 57.16541526, ...
         55.45037815, 53.73986479, 52.10469752, 50.72408641, 49.86233675, ...
         49.59999999, 49.7965078, 50.30649761, 51.47306466, 52.92080783, ...
         54.57529337];
angles = 0:10:350; % 更新后的角度位置

% 滚子和基圆参数
roller_radius = 8;
base_radius = 49.6;
outer_circle_radius = 98.18; % 摆动从动件的圆半径

% 计算凸轮轮廓的 x 和 y 坐标
cam_x = radii .* cosd(angles);
cam_y = radii .* sind(angles);
cam_x = [cam_x, cam_x(1)]; % 封闭凸轮轮廓
cam_y = [cam_y, cam_y(1)];

% 开始绘图
figure;
hold on;
axis equal;
title('凸轮轮廓及摆动从动件');


% 绘制基圆
theta = linspace(0, 2*pi, 100);
plot(base_radius * cos(theta), base_radius * sin(theta), 'k--', 'LineWidth', 1.5);

% 绘制凸轮轮廓
plot(cam_x, cam_y, 'k', 'LineWidth', 2);

% 绘制外部摆动从动件圆
plot(outer_circle_radius * cos(theta), outer_circle_radius * sin(theta), 'k:', 'LineWidth', 1.5);

% 偏置角度
alpha = 75;
b=-5;
% 初始化滚子圆心轨迹坐标
roller_centers_x = [];
roller_centers_y = [];

% 在每个位置绘制黑白滚子从动件
for i = 1:length(radii)
    % 计算当前滚子中心坐标
    roller_center_x = (radii(i) + roller_radius) * cosd(angles(i));
    roller_center_y = (radii(i) + roller_radius) * sind(angles(i));
    roller_centers_x = [roller_centers_x, roller_center_x];
    roller_centers_y = [roller_centers_y, roller_center_y];
    
    % 绘制滚子
    theta = linspace(0, 2*pi, 50);
    roller_x = roller_radius * cos(theta) + roller_center_x;
    roller_y = roller_radius * sin(theta) + roller_center_y;
    
    fill(roller_x, roller_y, 'w'); % 白色滚子
    
    % 在滚子从动件圆心处绘制半径为69.05的圆
%     if i == 9
% outer_roller_circle_radius = 69.05; % 定义外围圆的半径
% theta = linspace(0, 2*pi, 100);
% outer_roller_x = outer_roller_circle_radius * cos(theta) + roller_center_x;
% outer_roller_y = outer_roller_circle_radius * sin(theta) + roller_center_y;
% plot(outer_roller_x, outer_roller_y, 'k--', 'LineWidth', 1);
%     end
    % 绘制从动件连线
    plot([0, roller_center_x], [0, roller_center_y], 'k');
     
    % 绘制外圈到滚子中心的连线
    outer_circle_x = outer_circle_radius * cosd(angles(mod(i+b,36)+1));
    outer_circle_y = outer_circle_radius * sind(angles(mod(i+b,36)+1));
    plot([outer_circle_x, roller_center_x], [outer_circle_y, roller_center_y], 'k:'); % 虚线
    
end

% 绘制滚子中心点的虚线轨迹
plot(roller_centers_x, roller_centers_y, 'k:');

hold off;
