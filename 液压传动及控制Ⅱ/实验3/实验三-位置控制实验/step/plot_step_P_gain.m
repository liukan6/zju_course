function plot_step_P_gain(filename,sheet,color,N1)
Y1=xlsread(filename,sheet);
%% 调试用
% Y1 = xlsread('P_0.8.dbf','P_0.8');
% color='r';
% N1=500;
%% 参数设置
Target_p=1;         %Target Position油缸目标位置所在列
Actual_P=2;         %Actual Position油缸实际位置所在列
Interpolated_P=3;   %Interpolated Position油缸插值位置所在列
Interpolated_V=4;   %Interpolated Velocity油缸插值速度所在列
ValueA=5;           %用户自定义数据所在列
IAC_Apre=6;         %IAC_Apre所在列
IAC_Pos_following_error=7;     %IAC_Pos_following error所在列
IAC_valve_cmd=8;    %IAC_valve_cmd所在列
Fs=500;             %控制器控制周期2ms
[m,n]=size(Y1);         %采集数据的维度

%% 
A=500000;
B=510000;
index = [];             %保存数据转折的行号
j=1;
Target_column=ValueA;
for i=1:m-2
    first = Y1(i,Target_column);
    second =  Y1(i+1,Target_column);
    third = Y1(i+2,Target_column);
    if first == second && second ~= third 
        index(j)=i+1;
        j=j+1;
    end
end

t1=0:1/Fs:N1/Fs-1/Fs;
plot(t1,Y1(index(1):index(1)+N1-1,ValueA)./10000,'blue');
hold on
plot(t1,Y1(index(1):index(1)+N1-1,Actual_P),color);
hold on


