clear all;
clc;
close all;

%% 设置关于数据列的全局变量
global Target_p Actual_P Interpolated_P Interpolated_V Valve_Comand Valve_Actual Pp Pa Pb Pt Fs;
Target_p=1;      %Target Position油缸目标位置所在列
Actual_P=2;      %Actual Position油缸实际位置所在列
Interpolated_P=3;%Interpolated Position油缸插值位置所在列
Interpolated_V=4;%Interpolated Velocity油缸插值速度所在列
Valve_Comand=5;  %阀芯控制信号
Valve_Actual=6;  %阀芯反馈信号
Pp=7;            %P口压力
Pa=8;            %A口压力
Pb=9;            %B口压力
Pt=10;           %T口压力
Fs=500;          %控制器控制周期2ms

%% 设置全局变量 (用于文件命名等)
global str1 str2 N1_global; % N1_global 以区分函数参数 N1_val
str1 = "";
str2 = '.dbf';
N1_global = 50; % N1 在您的原始代码中作为全局变量使用

% 图形参数
p_identifiers = {"4","5","6","6.5","7","8"}; 
colors = { 
    [1 0 0],         % 红
    [0 0.8 0],       % 绿
    [0 0 1],         % 蓝
    [1 0 1],         % 品红
    [0.8 0.8 0],     % 黄 (较暗)
    [0 0 0],         % 黑
    [0.5 0.5 0.5],   % 灰
    [0 0.5 0.5]      % 青
};
legendEntries = {'Kv=4','Kv=5','Kv=6','Kv=6.5','Kv=7','Kv=8'};

%% 主绘图逻辑
figure;
hold on;
legendHandles = gobjects(length(p_identifiers), 1); % 预分配图例句柄数组

for i = 1:length(p_identifiers)
    current_p_id  = p_identifiers{i};
    current_color = colors{i};
    
    % 调用绘图函数, 注意 N1_global 和 Fs 作为参数传递
    legendHandles(i) = MoveABS1(current_p_id, current_color, Fs, N1_global, ...
                                Target_p, Actual_P, Interpolated_P, Interpolated_V);
end
hold off;


%% 标注
title('位置、速度变化，误差变化');
xlabel('时间/s');

legend(legendHandles, legendEntries,"Location", "northwest",'Interpreter', 'none');

grid on;
axis tight;

%% 绘图函数定义
function firstPlotHandle = MoveABS1(p_file_id, baseColor, Fs_val, N1_val, ...
                                     col_Target_P, col_Actual_P, col_Interpolated_P, col_Interpolated_V)

    global str1 str2; % 用于构建文件路径

    filePath = strcat(str1, p_file_id, str2);

    try
        Y1 = xlsread(filePath); 
    catch ME
        warning('读取文件失败: %s\n%s', filePath, ME.message);
        firstPlotHandle = gobjects(1); % 返回无效句柄
        return;
    end

    if isempty(Y1)
        warning('文件为空或无法读取: %s', filePath);
        firstPlotHandle = gobjects(1);
        return;
    end
    
    [m,n] = size(Y1); %采集数据的维度

    % 定义在原始代码中硬编码的目标值
    A_target = 50;
    B_target = 250;

    %获取数据改变点。阶跃信号可以通过用户自定义数据所在列的数值变化获取
    index = zeros(4, 1); %保存数据转折的行号 (预分配)
    try
        index(1)=find(Y1(:,col_Target_P)==B_target,1,'first')-1;
        if isempty(index(1)), error('在 Target_P 列中找不到 B_target (index(1))'); end

        index(2)=find(Y1(:,col_Interpolated_P)==B_target,1,'first');
        if isempty(index(2)), error('在 Interpolated_P 列中找不到 B_target (index(2))'); end
        
        temp_idx3 = find(Y1(index(2):end, col_Target_P) == A_target, 1, 'first');
        if isempty(temp_idx3), error('在 Target_P 列中找不到 A_target (index(3))'); end
        index(3) = temp_idx3 + index(2) -1;

        temp_idx4 = find(Y1(index(3):end, col_Interpolated_P) == A_target, 1, 'first');
        if isempty(temp_idx4), error('在 Interpolated_P 列中找不到 A_target (index(4))'); end
        index(4) = temp_idx4 + index(3) -1;
    catch ME
        warning('在文件 %s 中寻找改变点时出错: %s. 跳过此文件.', filePath, ME.message);
        firstPlotHandle = gobjects(1);
        return;
    end
    
    % 验证索引以防止 N1_val 造成的越界错误
    if any(index < 1) || ...
       (index(1)-N1_val < 1) || (index(2)+N1_val > m) || ...
       (index(3)-N1_val < 1) || (index(4)+N1_val > m) || ...
       index(2) <= index(1) || index(4) <= index(3)
        warning('索引无效或数据不足 (N1 padding) %s. 跳过此文件.', filePath);
        firstPlotHandle = gobjects(1);
        return;
    end

    style1 = '-';   % 实线
    style2 = '--';  % 虚线
    style3 = '-.';  % 点划线

    % 时间向量
    range1 = (index(1)-N1_val):(index(2)+N1_val);
    t1 = (0:1/Fs_val:(length(range1)-1)/Fs_val)';

    range2 = (index(3)-N1_val):(index(4)+N1_val);
    startTime_t2 = t1(end) + (1/Fs_val);
    t2 = (startTime_t2:1/Fs_val:(startTime_t2 + (length(range2)-1)/Fs_val))';

    %% 左Y轴: 位置和插值速度
    yyaxis left;
    %正向50-250，实际位置、插值速度
    plot(t1, Y1(range1, col_Actual_P), ...
                           'Color', baseColor, 'LineStyle', style1, 'Marker', 'none', 'LineWidth', 1.2);
    hold on;
    plot(t1, Y1(range1, col_Interpolated_V), ...
         'Color', baseColor, 'LineStyle', style2, 'Marker', 'none', 'HandleVisibility', 'off'); 
    %反向250-50，实际位置、插值速度
    firstPlotHandle = plot(t2, Y1(range2, col_Actual_P), ...
         'Color', baseColor, 'LineStyle', style1, 'Marker', 'none', 'HandleVisibility', 'off', 'LineWidth', 1.2);
    plot(t2, Y1(range2, col_Interpolated_V), ...
         'Color', baseColor, 'LineStyle', style2, 'Marker', 'none', 'HandleVisibility', 'off');
    
    ylabel('位置/mm、速度/mm/s'); % 左轴标签
    ylim([-270 270]); 2
    yticks(-250:50:250);
    hold off;

    %% 右Y轴: 误差
    yyaxis right;
    %正向50-250，误差
    error_forward = Y1(range1, col_Interpolated_P) - Y1(range1, col_Actual_P);
    plot(t1, error_forward, ...
         'Color', baseColor, 'LineStyle', style3, 'Marker', 'none', 'HandleVisibility', 'off');
    hold on;
    %反向250-50，误差
    error_backward = Y1(range2, col_Interpolated_P) - Y1(range2, col_Actual_P);
    plot(t2, error_backward, ...
         'Color', baseColor, 'LineStyle', style3, 'Marker', 'none', 'HandleVisibility', 'off');

    ylabel('误差/mm'); % 右轴标签
    ylim([-0.6 0.6]);
    yticks(-0.5:0.1:0.5);
    ax = gca;
    ax.YAxis(1).Color = 'k'; % 左轴颜色
    ax.YAxis(2).Color = baseColor; % 右轴颜色与线条颜色匹配，增强可读性
    
    hold off;
end