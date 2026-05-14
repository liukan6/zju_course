clear all;
clf; % Clear the current figure
%% 设置关于数据列的全局变量
global Target_p_IAC Actual_P_IAC Interpolated_P_IAC Interpolated_V_IAC
global Target_p_WRPEH Actual_P_WRPEH Interpolated_P_WRPEH Interpolated_V_WRPEH Valve_Comand_IAC Valve_Actual_IAC
global SYNC_Error_abs Fs;
Target_p_IAC=1;       % IAC从油缸Target Position目标位置所在列
Actual_P_IAC=2;       % IAC从油缸Actual Position实际位置所在列
Interpolated_P_IAC=3; % IAC从油缸Interpolated Position插值位置所在列
Interpolated_V_IAC=4; % IAC从油缸Interpolated Velocity插值速度所在列
Target_p_WRPEH=5;     % WRPEH主油缸Target Position目标位置所在列
Actual_P_WRPEH=6;     % WRPEH主油缸Actual Position实际位置所在列
Interpolated_P_WRPEH=7;% WRPEH主油缸Interpolated Position插值位置所在列
Interpolated_V_WRPEH=8;% WRPEH主油缸Interpolated Velocity插值速度所在列
SYNC_Error_abs=9;     % 同步误差的绝对值
Valve_Comand_IAC=10;  % WRPEH主油缸阀芯控制信号
Valve_Actual_IAC=11;  % WRPEH主油缸阀芯反馈信号

Fs=500;               % 控制器控制周期2ms
%%
% 设置全局变量和绘图参数
global str1 str2 N1; % N1 is also used in SYNC1
str1 = "";
str2 = '.dbf';
N1=100; % N1 needs to be accessible by SYNC1

p_values = ["30","40","50","60","80","100","120","150","200","250"];
% 定义一组互不相同的颜色
colors = {
    [1,0,0],         % Red
    [0,0.8,0],       % Green
    [0,0,1],         % Blue
    [0.75,0,0.75],   % Purple (Magenta-like)
    [1,0.65,0],      % Orange
    [0.3,0.75,0.93], % Light Blue (Sky Blue)
    [0.5,0.5,0.5],   % Gray
    [0.6,0.4,0.2],   % Brown
    [1,0.75,0.8],    % Pink
    [0,0,0]          % Black
};

% 检查颜色数量是否足够
if length(colors) < length(p_values)
    error('Not enough distinct colors defined for the number of p_values.');
end

legendEntries = cell(1, length(p_values));
legendHandles = gobjects(1, length(p_values)); % Pre-allocate for graphics handles

hold on; % Hold the plot to overlay multiple lines
for i = 1:length(p_values)
    current_p_value = p_values(i);
    current_color = colors{i}; % Use the RGB color from the cell array
    legendEntries{i} = sprintf('integrator=%s', current_p_value); % Create legend text

    % Call SYNC1, which will plot lines and return the handle of the first plotted line
    legendHandles(i) = SYNC1(current_p_value, current_color);
end
hold off;

%%
% 标注
title('位置、速度变化，误差变化');
xlabel('时间/s (Time/s)');
ylabel('位置/速度|计算误差 '); % Combined YLabel

% 创建图例
% Filter out invalid handles first, in case some SYNC1 calls failed
validMask = isgraphics(legendHandles);
if any(validMask)
    legend(legendHandles(validMask), legendEntries(validMask), 'Location', 'best', 'Interpreter', 'none');
else
    disp('No data plotted, legend will not be shown.');
end
grid on;

%%
function firstPlotHandle = SYNC1(p, baseColor) % baseColor is now an RGB array
% Declare globals used in this function
global Target_p_IAC Actual_P_IAC Interpolated_P_IAC Interpolated_V_IAC
global Target_p_WRPEH Actual_P_WRPEH Interpolated_P_WRPEH Interpolated_V_WRPEH Valve_Comand_IAC Valve_Actual_IAC
global SYNC_Error_abs Fs;
global str1 str2 N1; % Ensure N1 is declared if used from global scope

% --- Default return for error cases ---
firstPlotHandle = gobjects(1); % Return an invalid handle if function fails early

% --- File Reading ---
try
    Y1=xlsread(strcat(p,str2)); % Consider readmatrix for newer MATLAB versions
catch ME
    warning('Failed to read file %s.dbf: %s', p, ME.message);
    return; % Exit function if file read fails
end

if isempty(Y1)
    warning('File %s.dbf is empty or could not be read.', p);
    return;
end

[m,n]=size(Y1); %采集数据的维度

%%
%获取数据改变点。阶跃信号可以通过用户自定义数据所在列的数值变化获取
position1=40;   %sync moving parameter:sync position1
position2=280;  %sync moving parameter:sync position2
init_position=165; %WRPEH主油缸初始位置

% Find indices, with error checking
index = zeros(1,4); % Pre-allocate
try
    index(1)=find(Y1(:,Target_p_WRPEH)==init_position,1,'last');
    if isempty(index(1)), error('init_position not found.'); end
    index(2)=find(Y1(:,Target_p_WRPEH)==position1,1,'first');
    if isempty(index(2)), error('position1 (first) not found.'); end
    index(3)=find(Y1(:,Target_p_WRPEH)==position2,1,'last');
    if isempty(index(3)), error('position2 (last) not found.'); end
    index(4)=find(Y1(index(3):end,Target_p_WRPEH)==position1,1,'first')+index(3)-1; % Adjusted for 1-based indexing from subset
    if isempty(index(4)) || index(4) < index(3) , error('position1 (second) after position2 not found.'); end
catch ME
    warning('Error finding indices in file %s.dbf: %s', p, ME.message);
    return; % Exit function if indices are not found
end

% Check for sufficient data range given N1
if (index(2) < 1) || (index(4)+N1 > m)
    warning('Data range for plotting is invalid after N1 padding for file %s.dbf.', p);
    return;
end

init_Error = Y1(index(1),Actual_P_IAC) + Y1(index(1),Actual_P_WRPEH);

%%
% Define line styles explicitly. baseColor is an RGB array.
% We don't use strcat(color, '-') anymore.
solid_line = '-';
dashed_line = '--';
dash_dot_line = '-.';

%%
% Time vector and data ranges
plot_range = index(2):(index(4)+N1);
if isempty(plot_range) || plot_range(1) < 1 || plot_range(end) > m
    warning('Calculated plot_range is invalid for file %s.dbf.', p);
    return;
end
t1 = (0:1/Fs:(length(plot_range)-1)/Fs)'; % Ensure t1 is a column vector

% --- Left Y-Axis ---
yyaxis left;
% sync position1----sync position2----sync position1
% Plot the first line (solid) and get its handle for the legend
plot(t1, Y1(plot_range, Target_p_WRPEH), 'Color', baseColor, 'LineStyle', solid_line, 'LineWidth', 0.5);
hold on; % Hold for current axis
firstPlotHandle = plot(t1, Y1(plot_range, Interpolated_V_WRPEH), 'Color', baseColor, 'LineStyle', dashed_line, 'HandleVisibility', 'off');

% Optional: Set left Y-axis properties
% ylabel('位置/mm (Position/mm)');
% ylim([-50 300]); % Adjust based on your data range for Target_p_WRPEH
% yticks(0:50:300); % Example ticks

ax_left = gca; % Get current axes
ax_left.YColor = baseColor * 0.7; % Make axis color a bit darker than line for distinction, or choose 'k'

hold off; % Release hold for current left axis

% --- Right Y-Axis ---
yyaxis right;
% sync position1----sync position2----sync position1
% Plot calculated error
calculated_error = init_Error - Y1(plot_range, Actual_P_IAC) - Y1(plot_range, Actual_P_WRPEH);
plot(t1, calculated_error, 'Color', baseColor, 'LineStyle', solid_line, 'LineWidth', 0.5, 'HandleVisibility', 'off'); % Changed to solid for visibility, adjust if needed

% If you wanted to plot SYNC_Error_abs (original was commented out):
% plot(t1,Y1(plot_range,SYNC_Error_abs), 'Color', baseColor, 'LineStyle', dash_dot_line, 'HandleVisibility','off');

% Optional: Set right Y-axis properties
% ylabel('计算同步误差/mm (Calculated Sync Error/mm)');
% ylim([-5 5]); % Adjust based on your error data range
% yticks(-5:1:5); % Example ticks

ax_right = gca; % Get current axes for right Y-axis
ax_right.YColor = baseColor * 0.7; % Match styling if desired

% Ensure the overall figure hold state is respected by not calling hold off here globally.
% The hold on/off within yyaxis blocks manage holds for those specific axes activations.
end