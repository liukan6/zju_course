clear all;
%%设置关于数据列的全局变量
global Target_p Actual_P Interpolated_P Interpolated_V Valve_Comand Valve_Actual Pp Pa  Pb Pt Fs;
Target_p=1;     %Target Position油缸目标位置所在列
Actual_P=2;     %Actual Position油缸实际位置所在列
Interpolated_P=3;       %Interpolated Position油缸插值位置所在列
Interpolated_V=4;       %Interpolated Velocity油缸插值速度所在列
Valve_Comand=5;         %阀芯控制信号
Valve_Actual=6;         %阀芯反馈信号
Pp=7;                   %P口压力
Pa=8;                   %A口压力
Pb=9;                   %B口压力
Pt=10;                  %T口压力
Fs=500;                 %控制器控制周期2ms
%%
%设置全局变量
global str1 str2 N1;
str1 = "Moveabs";
str2 = '.dbf';
N1=50;
p=["P4.5-DDG1.4","P4.5-DDG1.5","P4.5-DDG1.6","P5-DDG1.7"];
MoveABS1( p(1),'r');
MoveABS1( p(2),'g');
MoveABS1( p(3),'b');
MoveABS1( p(4),'m');

%%
%标注
title('位置、速度变化，误差变化')%位置、速度变化，误差变化
xlabel('时间/s')

% legend('show') % 显示图例
grid on
%%
function MoveABS1(p,color)
global Target_p Actual_P Interpolated_P Interpolated_V ValueA IAC_Apre IAC_Pos_following_error IAC_valve_cmd Fs;
global str1 str2   strup strdown N1;
Y1=xlsread(strcat(str1,p,str2));
[m,n]=size(Y1);         %采集数据的维度
%% 
%获取数据改变点。阶跃信号可以通过用户自定义数据所在列的数值变化获取
A=50;
B=250;
index = [];             %保存数据转折的行号
index(1)=find(Y1(:,Target_p)==B,1,'first')-1;
index(2)=find(Y1(:,Interpolated_P)==B,1,'first');
index(3)=find(Y1(index(2):end,Target_p)==A,1,'first')+index(2);
index(4)=find(Y1(index(3):end,Interpolated_P)==A,1,'first')+index(3);
%%
color1=strcat(color,'-');
color2=strcat(color,'--');
color3=strcat(color,'-.');
color4=strcat(color,':');
%%
t1=0:1/Fs:(index(2)-index(1)+2*N1)/Fs;
t2=(0:1/Fs:(index(4)-index(3)+2*N1)/Fs)+(index(2)-index(1)+2*N1)/Fs;

yyaxis left
%正向50-250，实际位置、插值速度
plot(t1,Y1(index(1)-N1:index(2)+N1,Actual_P),color1);
hold on
plot(t1,Y1(index(1)-N1:index(2)+N1,Interpolated_V),color2);
hold on
%反向250-50，实际位置、插值速度
plot(t2,Y1(index(3)-N1:index(4)+N1,Actual_P),color1);
hold on
plot(t2,Y1(index(3)-N1:index(4)+N1,Interpolated_V),color2);
hold on
ylabel('位置/mm')
ylim([-250 250]);
yticks(-250:50:250);

yyaxis right
%正向50-250，误差
plot(t1,Y1(index(1)-N1:index(2)+N1,Interpolated_P)-Y1(index(1)-N1:index(2)+N1,Actual_P),color3);
hold on
%反向250-50，误差
plot(t2,Y1(index(3)-N1:index(4)+N1,Interpolated_P)-Y1(index(3)-N1:index(4)+N1,Actual_P),color3);
hold on
ylabel('误差/mm')
ylim([-0.5 0.5]);
yticks(-0.5:0.1:0.5);


% resultall={Y1,index};%查看子函数各数据的变化
end
