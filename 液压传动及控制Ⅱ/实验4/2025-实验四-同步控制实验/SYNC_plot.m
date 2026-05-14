clear all;
%%设置关于数据列的全局变量
global Target_p_IAC Actual_P_IAC Interpolated_P_IAC Interpolated_V_IAC 
global Target_p_WRPEH Actual_P_WRPEH Interpolated_P_WRPEH Interpolated_V_WRPEH Valve_Comand_IAC Valve_Actual_IAC
global SYNC_Error_abs Fs;
Target_p_IAC=1;     %IAC从油缸Target Position目标位置所在列
Actual_P_IAC=2;     %IAC从油缸Actual Position实际位置所在列
Interpolated_P_IAC=3;       %IAC从油缸Interpolated Position插值位置所在列
Interpolated_V_IAC=4;       %IAC从油缸Interpolated Velocity插值速度所在列
Target_p_WRPEH=5;     %WRPEH主油缸Target Position目标位置所在列
Actual_P_WRPEH=6;     %WRPEH主油缸Actual Position实际位置所在列
Interpolated_P_WRPEH=7;       %WRPEH主油缸Interpolated Position插值位置所在列
Interpolated_V_WRPEH=8;       %WRPEH主油缸Interpolated Velocity插值速度所在列
SYNC_Error_abs=9;       	%同步误差的绝对值
Valve_Comand_IAC=10;         %WRPEH主油缸阀芯控制信号
Valve_Actual_IAC=11;         %WRPEH主油缸阀芯反馈信号

Fs=500;                 %控制器控制周期2ms
%%
%设置全局变量
global str1 str2 N1;
str1 = "Station3-SYNC-";
str2 = '.dbf';
N1=100;
p=["P0.2 I100","P0.2 I60","P0.2 I40","P0.2 I20","P0.2 I10"];%"P0.2","P0.3","P0.4","P0.5"
% SYNC1( p(1),'r');
SYNC1( p(2),'g');
% SYNC1( p(3),'b');
% SYNC1( p(4),'m');
% SYNC1( p(4),'c');
%%
%标注
title('位置、速度变化，误差变化')%位置、速度变化，误差变化
xlabel('时间/s')

% legend('show') % 显示图例
grid on
%%
function SYNC1(p,color)
global Target_p_IAC Actual_P_IAC Interpolated_P_IAC Interpolated_V_IAC 
global Target_p_WRPEH Actual_P_WRPEH Interpolated_P_WRPEH Interpolated_V_WRPEH Valve_Comand_IAC Valve_Actual_IAC
global SYNC_Error_abs Fs;
global str1 str2  N1;
Y1=xlsread(strcat(str1,p,str2));
[m,n]=size(Y1);         %采集数据的维度
%% 
%获取数据改变点。阶跃信号可以通过用户自定义数据所在列的数值变化获取
position1=40;   %sync moving parameter:sync position1
position2=280;  %sync moving parameter:sync position2
init_position=165; %WRPEH主油缸初始位置
index = [];             %保存数据转折的行号
index(1)=find(Y1(:,Target_p_WRPEH)==init_position,1,'last');
index(2)=find(Y1(:,Target_p_WRPEH)==position1,1,'first');
index(3)=find(Y1(:,Target_p_WRPEH)==position2,1,'last');
index(4)=find(Y1(index(3):end,Target_p_WRPEH)==position1,1,'first')+index(3);
init_Error =Y1(index(1),Actual_P_IAC)+Y1(index(1),Actual_P_WRPEH) ;
%%
color1=strcat(color,'-');
color2=strcat(color,'--');
color3=strcat(color,'-.');
color4=strcat(color,'-');
%%
t1=0:1/Fs:(index(4)-index(2)+N1)/Fs;

yyaxis left
%sync position1----sync position2----sync position1
plot(t1,Y1(index(2):index(4)+N1,Target_p_WRPEH),color1);
hold on
plot(t1,Y1(index(2):index(4)+N1,Interpolated_V_WRPEH),color2);
hold on

% ylabel('位置/mm')
% ylim([-250 250]);
% yticks(-250:50:250);

yyaxis right
%sync position1----sync position2----sync position1
plot(t1,Y1(index(2):index(4)+N1,SYNC_Error_abs),color3);
hold on
plot(t1,init_Error-Y1(index(2):index(4)+N1,Actual_P_IAC)-Y1(index(2):index(4)+N1,Actual_P_WRPEH),color4);
hold on
plot(t1,Y1(index(2):index(4)+N1,Valve_Comand_IAC),color3);
hold on

% ylabel('误差/mm')
% ylim([-0.5 0.5]);
% yticks(-0.5:0.1:0.5);


% resultall={Y1,index};%查看子函数各数据的变化
end
