% 清除所有变量并关闭所有图形窗口
clear all
close all

% 读取待分析文件 'pressure.dbf' 中的 'pressure' 工作表数据
Y1 = xlsread('pressure.dbf', 'pressure');

% 定义绘图颜色，分别对应不同的阀口开度变化阶段：
% 0-8%: 红色, 8%-0: 蓝色, 0-负8%: 黑色, 负8%-0: 绿色
color = ["red", "blue", "black", "green"];

% 定义各数据列的索引（根据实际数据文件调整）
P_A = 1;            % A口压力所在列
P_B = 2;            % B口压力所在列
P_P = 3;            % P口压力所在列
P_T = 4;            % T口压力所在列
Flow = 5;           % 流量所在列
Spool_dis_Command = 6;  % 阀芯控制位移信号所在列
Spool_dis_Actual = 7;   % 阀芯反馈位移信号所在列

% 获取数据维度
[m, n] = size(Y1);

% 初始化索引数组，用于保存阀口开度变化的转折点行号
index = [];
j = 1;

% 遍历数据，检测阀芯控制位移信号的转折点
for i = 1:m-2
    first = Y1(i, Spool_dis_Command);      % 当前行的阀芯控制位移
    second = Y1(i+1, Spool_dis_Command);   % 下一行的阀芯控制位移
    third = Y1(i+2, Spool_dis_Command);    % 下两行的阀芯控制位移
    
    % 判断是否为转折点（信号变化或稳定的边界）
    if (first == second && second ~= third) || (first ~= second && second == third)
        index(j) = i + 1;  % 记录转折点行号
        j = j + 1;
    end
end

% 绘制压力增益曲线
figure;  % 新建图形窗口
hold on; % 保持图形，允许多条曲线叠加

% 分段绘制压力-阀口开度曲线（每段对应一个开度变化阶段）
for i = 1:2:length(index)-1
    % 提取当前阶段的阀口开度和压差数据
    x_data = Y1(index(i):index(i+1), Spool_dis_Command);  % 阀口开度（%）
    y_data = Y1(index(i):index(i+1), P_A) - Y1(index(i):index(i+1), P_B);  % A-B口压差（bar）
    
    % 绘制曲线，颜色按阶段顺序从color数组中选取
    plot(x_data, y_data, color((i+1)/2), 'LineWidth', 2);
end
font_size = 18;
% 添加图形标签和网格
xlabel('阀口开度（%）','FontSize', font_size);
ylabel('A-B口压差（bar）','FontSize', font_size);
title('压力增益特性曲线','FontSize', font_size);
set(gca, 'FontSize', font_size);
grid on;
hold off;

% 可选：添加图例说明各颜色对应的阶段
legend('0 → 8%', '8% → 0', '0 → -8%', '-8% → 0', 'Location', 'best','FontSize', font_size);