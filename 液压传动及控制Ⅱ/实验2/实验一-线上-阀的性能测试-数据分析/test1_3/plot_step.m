clear all;
close all;
clc;

% 读取数据文件
Y1 = xlsread('step.dbf', 'step');  % 待分析文件的文件名和表名
color = ["red", "blue", "black", "green"];  % 定义绘图颜色（正负阶跃区分）

% 定义数据列索引
P_A = 1;       % A口压力所在列
P_B = 2;       % B口压力所在列
P_P = 3;       % P口压力所在列
P_T = 4;       % T口压力所在列
Flow = 5;      % 流量所在列
Spool_dis_Command = 6;  % 阀芯控制位移信号（%）
Spool_dis_Actual = 7;   % 阀芯反馈位移信号（%）
detaP_1 = 8;   % 自定义列（未使用）
detaP_2 = 9;   % 自定义列（未使用）

[m, n] = size(Y1);  % 获取数据维度

%% 1. 提取阶跃信号转折点
index = [];  % 保存阶跃转折点的行号
j = 1;
for i = 1:m-2
    first = Y1(i, Spool_dis_Command);
    second = Y1(i+1, Spool_dis_Command);
    third = Y1(i+2, Spool_dis_Command);
    % 检测阶跃信号的起点或终点（0→非0，或非0→0）
    if (first == 0 && second == 0 && third ~= 0) || (first ~= 0 && second == 0 && third == 0)
        index(j) = i + 1;
        j = j + 1;
    end
end

%% 2. 分段保存阶跃数据
Fs = 500;  % 采样频率（Hz）
N = 15;    % 每段阶跃数据的点数
t = (0:N) / Fs * 1000;  % 时间轴（单位：ms）

for i = 1:2:length(index)
    Y_step_i(:, 1) = Y1(index(i):index(i)+N, Spool_dis_Command);  % 控制信号
    Y_step_i(:, 2) = Y1(index(i):index(i)+N, Spool_dis_Actual);   % 反馈信号
    filename = strcat('step_', num2str(i), '.xlsx');
    if exist(filename, 'file') == 2
        delete(filename);  % 避免重复写入
    end
    xlswrite(filename, Y_step_i);  % 保存分段数据
end

%% 3. 绘制正向阶跃响应（25%, 50%, 100%）
figure('Name', '正向阶跃响应', 'Color', 'white');
set(gca, 'FontSize', 18);  % 统一字号
hold on;
grid on;

for k = 1:2:5  % 处理正向阶跃（k=1,3,5对应25%,50%,100%）
    filename = strcat('step_', num2str(k), '.xlsx');
    Y_step = xlsread(filename);
    
    % 绘制控制信号（红色）和反馈信号（蓝色）
    plot(t, Y_step(:, 1), 'r', 'LineWidth', 1.5);
    plot(t, Y_step(:, 2), 'b', 'LineWidth', 1.5);
    
    % 计算性能参数
    [Mp, tr, tp, ts, SteadyStateError] = GetPerfomanceOfStepResponseRise(t, Y_step(:, 2), Y_step(end, 1));
    
    % 显示结果
    if k == 1
        disp('-----阶跃幅度 = 25%-----');
    elseif k == 3
        disp('-----阶跃幅度 = 50%-----');
    elseif k == 5
        disp('-----阶跃幅度 = 100%-----');
    end
    disp(['超调量 Mp = ', num2str(Mp, '%.2f'), '%']);
    disp(['上升时间 tr = ', num2str(tr, '%.2f'), ' ms']);
    disp(['峰值时间 tp = ', num2str(tp, '%.2f'), ' ms']);
    disp(['稳态时间 ts = ', num2str(ts, '%.2f'), ' ms']);
    disp(['稳态误差 SteadyStateError = ', num2str(SteadyStateError, '%.2f')]);
end

% 图形标注
xlabel('时间（ms）', 'FontSize', 18, 'FontWeight', 'bold');
ylabel('阀口开度（%）', 'FontSize', 18, 'FontWeight', 'bold');
title('正向阶跃响应特性', 'FontSize', 18, 'FontWeight', 'bold');
legend('控制信号', '反馈信号', 'Location', 'best');

%% 4. 绘制负向阶跃响应（-100%, -50%, -25%）
figure('Name', '负向阶跃响应', 'Color', 'white');
set(gca, 'FontSize', 18);
hold on;
grid on;

for k = 7:2:11  % 处理负向阶跃（k=7,9,11对应-100%,-50%,-25%）
    filename = strcat('step_', num2str(k), '.xlsx');
    Y_step = xlsread(filename);
    
    plot(t, Y_step(:, 1), 'r', 'LineWidth', 1.5);
    plot(t, Y_step(:, 2), 'b', 'LineWidth', 1.5);
    
    [Mp, tr, tp, ts, SteadyStateError] = GetPerfomanceOfStepResponseDrop(t, Y_step(:, 2), Y_step(end, 1));
    
    if k == 7
        disp('-----阶跃幅度 = -100%-----');
    elseif k == 9
        disp('-----阶跃幅度 = -50%-----');
    elseif k == 11
        disp('-----阶跃幅度 = -25%-----');
    end
    disp(['超调量 Mp = ', num2str(Mp, '%.2f'), '%']);
    disp(['上升时间 tr = ', num2str(tr, '%.2f'), ' ms']);
    disp(['峰值时间 tp = ', num2str(tp, '%.2f'), ' ms']);
    disp(['稳态时间 ts = ', num2str(ts, '%.2f'), ' ms']);
    disp(['稳态误差 SteadyStateError = ', num2str(SteadyStateError, '%.2f')]);
end

xlabel('时间（ms）', 'FontSize', 18, 'FontWeight', 'bold');
ylabel('阀口开度（%）', 'FontSize', 18, 'FontWeight', 'bold');
title('负向阶跃响应特性', 'FontSize', 18, 'FontWeight', 'bold');
legend('控制信号', '反馈信号', 'Location', 'best');

%% 性能分析函数（正向阶跃）
function [Mp, tr, tp, ts, SteadyStateError] = GetPerfomanceOfStepResponseRise(t, y, stepvalue)
    % 输入：时间轴t，反馈信号y，阶跃幅值stepvalue
    % 输出：超调量Mp，上升时间tr，峰值时间tp，稳态时间ts，稳态误差
    
    % 超调量Mp和峰值时间tp
    [OverShoot, OverShootindex] = max(y);
    tp = t(OverShootindex);
    Mp = (OverShoot - stepvalue) / stepvalue * 100;
    
    % 上升时间tr（10%~90%）
    index1 = find(y >= stepvalue * 0.1, 1, 'first');
    index2 = find(y >= stepvalue * 0.9, 1, 'first');
    tr = t(index2) - t(index1);
    
    % 稳态时间ts（进入±5%误差带）
    index1 = find(y <= stepvalue * 1.05, 1, 'first');
    index2 = find(y >= stepvalue * 0.95, 1, 'first');
    index = max(index1, index2);
    ts = t(index);
    
    % 稳态误差（取稳态区均值与目标值的差）
    SteadyStateError = mean(y(index:end)) - stepvalue;
end

%% 性能分析函数（负向阶跃）
function [Mp, tr, tp, ts, SteadyStateError] = GetPerfomanceOfStepResponseDrop(t, y, stepvalue)
    % 输入：时间轴t，反馈信号y，阶跃幅值stepvalue（负值）
    % 输出：超调量Mp，下降时间tr，峰值时间tp，稳态时间ts，稳态误差
    
    % 超调量Mp和峰值时间tp（负向阶跃的“峰值”实际为谷值）
    [UnderShoot, UnderShootindex] = min(y);
    tp = t(UnderShootindex);
    Mp = (stepvalue - UnderShoot) / abs(stepvalue) * 100;
    
    % 下降时间tr（90%~10%）
    index1 = find(y <= stepvalue * 0.9, 1, 'first');
    index2 = find(y <= stepvalue * 0.1, 1, 'first');
    tr = t(index2) - t(index1);
    
    % 稳态时间ts（进入±5%误差带）
    index1 = find(y <= stepvalue * 0.95, 1, 'last');
    index2 = find(y >= stepvalue * 1.05, 1, 'last');
    index = max(index1, index2);
    ts = t(index);
    
    % 稳态误差
    SteadyStateError = mean(y(index:end)) - stepvalue;
end