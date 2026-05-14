% 优化液压阀流量特性分析
% 本程序用于分析液压阀流量特性试验数据，
% 并计算增益、线性度、迟滞、死区、对称性和极性等关键性能参数。

close all
clear all
clc

%% 参数设置
Y1 = xlsread('flow_1.dbf','flow_1');	% 读取试验数据文件
figure_font_size = 18;                   % 图形字体大小
legend_font_size = 16;                   % 图例字体大小
line_width = 1.5;                        % 曲线线宽
marker_size = 5;                         % 曲线标记大小

% 定义各通道对应的列索引
P_A = 1;                 % A口压力列
P_B = 2;                 % B口压力列
P_P = 3;                 % P口压力列
P_T = 4;                 % T口压力列
Flow = 5;                % 流量列
Spool_dis_Command = 6;   % 阀芯控制位移列
Spool_dis_Actual = 7;    % 阀芯反馈位移列
detaP_1 = 8;             % 压差1列
detaP_2 = 9;             % 压差2列
std_pressure_diff = 35;  % 标准压差（bar）

% 获取数据维度
[m, n] = size(Y1);

%% 查找阀芯控制信号变化点
index = [];              % 保存曲线拐点的行号
j = 1;
for i = 1:m-2
    first = Y1(i, Spool_dis_Command);
    second = Y1(i+1, Spool_dis_Command);
    third = Y1(i+2, Spool_dis_Command);
    if (first == second && second ~= third) || (first ~= second && second == third) 
        index(j) = i+1;
        j = j+1;
    end  
end

%% 绘制各通道随时间变化曲线
Fs = 500;  % 采样频率 (Hz)
t = 0:1/Fs:(index(end)-index(1))/Fs;  % 时间向量

figure(1);
subplot(2,1,1);
plot(t, Y1(index(1):index(end), P_P), 'r', 'LineWidth', line_width);
hold on;
plot(t, Y1(index(1):index(end), P_A), 'g', 'LineWidth', line_width);
plot(t, Y1(index(1):index(end), P_B), 'b', 'LineWidth', line_width);
plot(t, Y1(index(1):index(end), P_T), 'k', 'LineWidth', line_width);
title('压力-时间曲线', 'FontSize', figure_font_size);
xlabel('时间 (s)', 'FontSize', figure_font_size);
ylabel('压力 (bar)', 'FontSize', figure_font_size);
legend('P口', 'A口', 'B口', 'T口', 'FontSize', legend_font_size);
grid on;

subplot(2,1,2);
plot(t, Y1(index(1):index(end), Flow), 'm', 'LineWidth', line_width);
hold on;
plot(t, Y1(index(1):index(end), Spool_dis_Command), 'c', 'LineWidth', line_width);
plot(t, Y1(index(1):index(end), Spool_dis_Actual), 'b--', 'LineWidth', line_width);
title('流量与阀芯位移-时间曲线', 'FontSize', figure_font_size);
xlabel('时间 (s)', 'FontSize', figure_font_size);
ylabel('流量 (L/min), 阀芯位移 (%)', 'FontSize', figure_font_size);
legend('流量', '阀芯指令', '阀芯实际', 'FontSize', legend_font_size);
grid on;

%% 绘制原始流量-阀芯位移曲线
figure(2);
colors = ["r", "b", "k", "g"];  % 不同阶段的颜色
markers = ['o', '+', '*', 'x']; % 不同阶段的标记
legendInfo = {};

for i = 1:2:length(index)-1
    stage = (i+1)/2;
    plot(Y1(index(i):index(i+1), Spool_dis_Command), Y1(index(i):index(i+1), Flow), ...
         'Color', colors(stage), 'LineWidth', line_width, 'Marker', markers(stage), ...
         'MarkerSize', marker_size, 'MarkerIndices', 1:20:length(index(i):index(i+1)));
    hold on;
    
    % 根据阶段生成图例
    if stage == 1
        legendInfo{end+1} = '阶段1: 0 → 100%';
    elseif stage == 2
        legendInfo{end+1} = '阶段2: 100% → 0';
    elseif stage == 3
        legendInfo{end+1} = '阶段3: 0 → -100%';
    elseif stage == 4
        legendInfo{end+1} = '阶段4: -100% → 0';
    end
end
title('原始流量-阀芯位移曲线', 'FontSize', figure_font_size);
xlabel('阀芯控制位移 (%)', 'FontSize', figure_font_size);
ylabel('流量 (L/min)', 'FontSize', figure_font_size);
legend(legendInfo, 'FontSize', legend_font_size, 'Location', 'northwest');
grid on;

%% 数据处理：基于压差校准流量
Y2 = Y1;
for i = 1:m
    if Y1(i, Spool_dis_Command) > 0
        % 正向：P-A, B-T
        Y2(i, detaP_1) = Y1(i, P_P) - Y1(i, P_A);    % 计算正向压差1
        Y2(i, detaP_2) = Y1(i, P_B) - Y1(i, P_T);    % 计算正向压差2
        if Y2(i, detaP_1) > 0  % 避免对负数开方
            Y2(i, Flow) = Y1(i, Flow) * sqrt(std_pressure_diff / Y2(i, detaP_1)); % 流量校准
        end
    elseif Y1(i, Spool_dis_Command) < 0
        % 反向：P-B, A-T
        Y2(i, detaP_1) = Y1(i, P_P) - Y1(i, P_B);    % 计算反向压差1
        Y2(i, detaP_2) = Y1(i, P_A) - Y1(i, P_T);    % 计算反向压差2
        if Y2(i, detaP_1) > 0  % 避免对负数开方
            Y2(i, Flow) = Y1(i, Flow) * sqrt(std_pressure_diff / Y2(i, detaP_1)); % 流量校准
        end
    else
        Y2(i, Flow) = Y1(i, Flow);                   % 控制信号为0，流量不变
    end
end

%% 绘制压差曲线
figure(3);
subplot(2,1,1);
for i = 1:2:length(index)-1
    stage = (i+1)/2;
    plot(Y2(index(i):index(i+1), Spool_dis_Command), Y2(index(i):index(i+1), detaP_1), ...
         'Color', colors(stage), 'LineWidth', line_width, 'Marker', markers(stage), ...
         'MarkerSize', marker_size, 'MarkerIndices', 1:20:length(index(i):index(i+1)));
    hold on;
end
title('压差1-阀芯位移曲线', 'FontSize', figure_font_size);
xlabel('阀芯控制位移 (%)', 'FontSize', figure_font_size);
ylabel('压差 (bar)', 'FontSize', figure_font_size);
legend(legendInfo, 'FontSize', legend_font_size, 'Location', 'northwest');
grid on;

subplot(2,1,2);
for i = 1:2:length(index)-1
    stage = (i+1)/2;
    plot(Y2(index(i):index(i+1), Spool_dis_Command), Y2(index(i):index(i+1), detaP_2), ...
         'Color', colors(stage), 'LineWidth', line_width, 'Marker', markers(stage), ...
         'MarkerSize', marker_size, 'MarkerIndices', 1:20:length(index(i):index(i+1)));
    hold on;
end
title('压差2-阀芯位移曲线', 'FontSize', figure_font_size);
xlabel('阀芯控制位移 (%)', 'FontSize', figure_font_size);
ylabel('压差 (bar)', 'FontSize', figure_font_size);
legend(legendInfo, 'FontSize', legend_font_size, 'Location', 'northwest');
grid on;

%% 绘制校准流量-阀芯位移曲线
figure(4);
plot_data = {};  % 用于后续性能参数分析的数据
for i = 1:2:length(index)-1
    stage = (i+1)/2;
    % 保存数据用于性能参数计算
    plot_data{stage} = [Y2(index(i):index(i+1), Spool_dis_Command), Y2(index(i):index(i+1), Flow)];
    
    % 绘制校准流量-阀芯位移曲线
    plot(Y2(index(i):index(i+1), Spool_dis_Command), Y2(index(i):index(i+1), Flow), ...
         'Color', colors(stage), 'LineWidth', line_width, 'Marker', markers(stage), ...
         'MarkerSize', marker_size, 'MarkerIndices', 1:20:length(index(i):index(i+1)));
    hold on;
end
title('校准流量-阀芯位移曲线', 'FontSize', figure_font_size);
xlabel('阀芯控制位移 (%)', 'FontSize', figure_font_size);
ylabel('校准流量 (L/min)', 'FontSize', figure_font_size);
legend(legendInfo, 'FontSize', legend_font_size, 'Location', 'northwest');
grid on;

%% 性能参数分析
% 1. 计算额定输入信号（100%）下的流量
% 查找100%和-100%阀芯位移对应的流量
pos_idx = find(abs(Y2(:, Spool_dis_Command) - 100) < 0.01, 1, 'first');
neg_idx = find(abs(Y2(:, Spool_dis_Command) + 100) < 0.01, 1, 'first');

if ~isempty(pos_idx)
    rated_flow_pos = Y2(pos_idx, Flow);
else
    rated_flow_pos = NaN;
end

if ~isempty(neg_idx)
    rated_flow_neg = abs(Y2(neg_idx, Flow));
else
    rated_flow_neg = NaN;
end

% 2. 计算各阶段增益（斜率）
gains = zeros(4, 1);
for stage = 1:4
    data = plot_data{stage};
    x = data(:, 1);  % 阀芯位移
    y = data(:, 2);  % 流量
    
    % 计算增益时过滤掉零位移点
    non_zero_idx = abs(x) > 5;  % 只考虑位移大于5%的点
    if sum(non_zero_idx) > 1
        x_filtered = x(non_zero_idx);
        y_filtered = y(non_zero_idx);
        
        % 线性拟合求增益
        p = polyfit(x_filtered, y_filtered, 1);
        gains(stage) = p(1);  % 线性拟合斜率
    end
end

% 3. 计算死区
% 找到产生显著流量的最小正负指令
flow_threshold = 0.05 * max(abs(Y2(:, Flow)));
pos_cmd = Y2(Y2(:, Spool_dis_Command) > 0, Spool_dis_Command);
pos_flow = Y2(Y2(:, Spool_dis_Command) > 0, Flow);
neg_cmd = Y2(Y2(:, Spool_dis_Command) < 0, Spool_dis_Command);
neg_flow = Y2(Y2(:, Spool_dis_Command) < 0, Flow);

% 正向死区
pos_significant_flow_idx = find(pos_flow > flow_threshold, 1, 'first');
if ~isempty(pos_significant_flow_idx)
    pos_dead_zone = pos_cmd(pos_significant_flow_idx);
else
    pos_dead_zone = NaN;
end

% 负向死区
neg_significant_flow_idx = find(abs(neg_flow) > flow_threshold, 1, 'first');
if ~isempty(neg_significant_flow_idx)
    neg_dead_zone = abs(neg_cmd(neg_significant_flow_idx));
else
    neg_dead_zone = NaN;
end

% 4. 计算迟滞
% 在相同位移下，正反向阶段流量的最大差值
% 正向（阶段1和2）
pos_side_hysteresis = calculate_hysteresis(plot_data{1}, plot_data{2});

% 负向（阶段3和4）
neg_side_hysteresis = calculate_hysteresis(plot_data{3}, plot_data{4});

% 5. 计算线性度
% 最大偏离线性拟合的百分比
linearity = zeros(4, 1);
for stage = 1:4
    data = plot_data{stage};
    x = data(:, 1);  % 阀芯位移
    y = data(:, 2);  % 流量
    
    if ~isempty(x) && ~isempty(y) && length(x) > 1
        % 线性拟合
        p = polyfit(x, y, 1);
        y_fit = polyval(p, x);
        
        % 线性度为最大拟合偏差
        max_deviation = max(abs(y - y_fit));
        y_range = max(abs(y));
        if y_range > 0
            linearity(stage) = (max_deviation / y_range) * 100;  % 百分比
        else
            linearity(stage) = NaN;
        end
    else
        linearity(stage) = NaN;
    end
end

% 6. 计算对称性
% 额定位移下负向流量与正向流量的比值
if ~isnan(rated_flow_pos) && ~isnan(rated_flow_neg) && rated_flow_pos ~= 0
    symmetry = (rated_flow_neg / rated_flow_pos) * 100;  % 百分比
else
    symmetry = NaN;
end

% 7. 计算极性
% 检查正位移时流量为正，负位移时流量为负
% 若流量符号与位移符号一致，则极性正确
mean_pos_flow = mean(Y2(Y2(:, Spool_dis_Command) > 5, Flow));
mean_neg_flow = mean(Y2(Y2(:, Spool_dis_Command) < -5, Flow));
polarity_correct = (mean_pos_flow > 0) && (mean_neg_flow < 0);

%% 显示结果
fprintf('==== 液压阀性能参数 ====\n');
fprintf('1. 额定流量 (100%%): %.2f L/min\n', rated_flow_pos);
fprintf('   额定流量 (-100%%): %.2f L/min\n', abs(rated_flow_neg));
fprintf('2. 增益 (流量/位移):\n');
for stage = 1:4
    fprintf('   阶段 %d: %.4f (L/min)/%%\n', stage, gains(stage));
end
fprintf('3. 死区:\n');
fprintf('   正向: %.2f %%\n', pos_dead_zone);
fprintf('   负向: %.2f %%\n', neg_dead_zone);
fprintf('4. 迟滞:\n');
fprintf('   正向: %.2f %%\n', pos_side_hysteresis);
fprintf('   负向: %.2f %%\n', neg_side_hysteresis);
fprintf('5. 线性度 (最大拟合偏差):\n');
for stage = 1:4
    fprintf('   阶段 %d: %.2f %%\n', stage, linearity(stage));
end
fprintf('6. 对称性 (负/正流量比): %.2f %%\n', symmetry);
fprintf('7. 极性正确: %s\n', mat2str(polarity_correct));

%% 迟滞计算辅助函数
function hysteresis = calculate_hysteresis(increasing_data, decreasing_data)
    % 将正向和反向曲线插值到相同位移点
    increasing_x = increasing_data(:, 1);
    increasing_y = increasing_data(:, 2);
    decreasing_x = decreasing_data(:, 1);
    decreasing_y = decreasing_data(:, 2);
    
    % 定义用于比较的公共位移点
    x_common = linspace(max(min(increasing_x), min(decreasing_x)), ...
                         min(max(increasing_x), max(decreasing_x)), 100);
    
    % 插值得到公共位移点的流量值
    increasing_y_interp = interp1(increasing_x, increasing_y, x_common);
    decreasing_y_interp = interp1(decreasing_x, decreasing_y, x_common);
    
    % 计算差值并取最大值
    differences = abs(increasing_y_interp - decreasing_y_interp);
    max_difference = max(differences);
    
    % 迟滞为满量程的百分比
    y_range = max(abs([increasing_y; decreasing_y]));
    if y_range > 0
        hysteresis = (max_difference / y_range) * 100;  % 百分比
    else
        hysteresis = NaN;
    end
end
