clear all
close all
%对分析得到的数据进行查看，看拟合数据是否满足要求。
Mag = 'M5'; %Mag取值为M1、M5、M25。分别表示对激励幅值为1%、5%、25%的曲线进行查看。
Command_cut = xlsread(strcat(Mag,'_Command_cut','.xlsx')); 
y_reconstructed_Command = xlsread(strcat(Mag,'_y_reconstructed_Command','.xlsx'));
Actual_cut = xlsread(strcat(Mag,'_Actual_cut','.xlsx'));
y_reconstructed_Actual = xlsread(strcat(Mag,'_y_reconstructed_Actual','.xlsx'));
Index = xlsread(strcat(Mag,'_Index','.xlsx'));
N1 = xlsread(strcat(Mag,'_N1','.xlsx'));
fmax = xlsread(strcat(Mag,'_fmax','.xlsx'));

%查看第k组的阀芯控制位移、阀芯实际位移的采样曲线和拟合曲线
k=10;
f_now = num2str(fmax(k,1));
Fs =500;
t=0:1/Fs:4*N1(1,k)/Fs-1/Fs;
if k>length(Index)
    disp(['超出实际测试的数目']);
else
    plot (t,Command_cut(1:4* N1(1,k),k),'black');    %阀芯控制位移的采样曲线
    hold on
    plot ( t,Actual_cut(1:4*N1(1,k),k),'red');        %阀芯实际位移的采样曲线
    hold on
    plot ( t,y_reconstructed_Command(1:4* N1(1,k),k),'blue'); %阀芯控制位移的拟合曲线
    hold on
    plot (t, y_reconstructed_Actual(1:4* N1(1,k),k),'green'); %阀芯实际位移的拟合曲线
    hold on
end
    xlabel('时间');
    ylabel('幅值');
    ax = gca ;
text(xlim(ax(1))/2, ylim(ax(1)),strcat("当前频率值：",f_now));    
%     text((xlim(1)+xlim(0))/2, ylim(ax(1)),strcat("当前频率值：",f_now) , 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');



