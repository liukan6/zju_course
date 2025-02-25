x = [2.153947601,2.18146992,2.220616563,2.275139834,2.33513036,2.408652267,2.492072677]; % 横坐标数据
y = [0.0738,0.1558,0.2706,0.4182,0.5986,0.8118,1.0578]; % 纵坐标数据

% 线性拟合
p = polyfit(x, y, 1); % 拟合出一次函数
y_fit = polyval(p, x); % 对x求出拟合后的y值

% 画图
R = corrcoef(y, y_fit)
R_squared = R(1,2)^2
p
plot(x, y, 'o', x, y_fit, '-'); % 画原始数据和拟合直线
xlabel('T^{2}(s^{2})'); % 添加X轴标签
ylabel('J_0(x10^{-3}kgm^{2})'); % 添加Y轴标签
title('三线摆摆动周期平方与圆盘上物体的转动惯量关系直线拟合图'); % 添加标题
legend('原始数据', '拟合直线'); % 添加图例
grid on;