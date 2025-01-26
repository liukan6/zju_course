% 提供的凸轮半径数据
radii = [61.25837338, 62.96385955, 64.58981104, 66.00028395, 67.25123883, ...
         68.21417527, 68.82432097, 69.1130473, 69.01808878, 68.57731623, ...
         67.79889206, 66.75318425, 65.457472, 63.99286442, 62.38053588, ...
         60.72333522, 58.99883646, 57.39611931, 55.83551101, 54.45490265, ...
         53.09387574, 52.0553549, 51.1276991, 50.41503408, 49.8824731, ...
         49.61973771, 49.59996861, 49.80711996, 50.2811249, 51.01529645, ...
         51.96260172, 53.17261065, 54.49294317, 56.0557595, 57.6618555, ...
         59.35145887];
angles = linspace(0, 350, length(radii)); % 对应的角度位置

% 滚子和基圆参数
roller_radius = 3.75;
base_radius = 49.6;
offset = 18;

% 计算凸轮轮廓的 x 和 y 坐标
cam_x = radii .* cosd(angles);
cam_y = radii .* sind(angles);
cam_x = [cam_x, cam_x(1)];
cam_y = [cam_y, cam_y(1)];
% 开始绘图
figure;
hold on;
axis equal;
title('凸轮轮廓及滚子从动件');

% 绘制基圆
theta = linspace(0, 2*pi, 100);
plot(base_radius * cos(theta), base_radius * sin(theta), 'k--', 'LineWidth', 1.5);

% 绘制凸轮轮廓
plot(cam_x, cam_y, 'k', 'LineWidth', 2);
alpha = 75;
% 在每个位置绘制黑白滚子从动件
for i = 1:length(radii)
    % 计算当前滚子中心坐标
    roller_center_x = (radii(i) + roller_radius) * cosd(angles(i));
    roller_center_y = (radii(i) + roller_radius) * sind(angles(i));
    
    % 绘制滚子
    theta = linspace(0, 2*pi, 50);
    roller_x = roller_radius * cos(theta) + roller_center_x;
    roller_y = roller_radius * sin(theta) + roller_center_y;
    
    fill(roller_x, roller_y, 'w'); % 白色滚子
    
    % 绘制从动件连线
    plot([offset*cosd(angles(i)+alpha), roller_center_x], [offset*sind(angles(i)+alpha), roller_center_y], 'k');
    plot([offset*cosd(angles(i) + alpha), offset*cosd(angles(mod(i, 36) + 1) + alpha)], ...
     [offset*sind(angles(i) + alpha), offset*sind(angles(mod(i, 36) + 1) + alpha)], 'k');

end

hold off;
