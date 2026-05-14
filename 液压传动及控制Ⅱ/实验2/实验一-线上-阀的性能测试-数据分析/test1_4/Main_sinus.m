close all
clear all
%对待分析文件进行处理，并保存处理后的过程文件。同学们可以根据自己的理解进行更改查看等。
Mag = 'M25'; %Mag取值为M1、M5、M25。分别表示对激励幅值为1%、5%、25%的曲线进行分析。
Y1 = xlsread('sinus_25.dbf','sinus_25');    %输入待分析数据的文件名，导出的表名和文件名一致
%sinus_1_1.dbf为激励幅值为1%时的测试，sinus5_2.dbf为激励幅值为5%时的测试，sinus_25.dbf为激励幅值为25%时的测试
P_A=1;  %A口压力所在列
P_B=2;  %B口压力所在列
P_P=3;  %C口压力所在列
P_T=4;  %T口压力所在列
Flow=5; %流量所在列
Spool_dis_Command=6;    %阀芯控制位移所在列
Spool_dis_Actual=7;     %阀芯反馈位移所在列
Fs = 500;               %采样频率500
[m,n]=size(Y1);         %采集数据的维度


%获取阀芯控制信号改变点,便于对后续数据段进行分段处理
Index=[];               %记录阀芯控制信号转变的行号
j=1;
for i=1:m-2
    first = Y1(i,Spool_dis_Command);
    second =  Y1(i+1,Spool_dis_Command);
    third = Y1(i+2,Spool_dis_Command);
    if first == 0 && second == 0 && third ~= 0
        Index(j,1)=i+1;
    elseif first ~= 0 && second == 0 && third == 0
        Index(j,2)=i+1;
        j=j+1;
    end
end

%对第k段阀芯控制信号进行fft分析，得到第k段信号的大致频率主值，存在Index里。
for k=1:length(Index(:,1))
    % 对第k段信号进行分析
    x = Y1(Index(k,1):Index(k,2),Spool_dis_Command);      %待分析信号
    % 执行FFT变换
    N = length(x);  %信号长度
    X = fft(x,N);
    X = abs (X/N);
    X = X(1:round(N/2)+1);
    X(2:end-1)=2*X(2:end-1);
   
    % %如果想画频谱图，可以把下面代码取消注释
    % n = 0:length(X)-1;
    % f = n * Fs / N;
    % plot(f,X);
    
    % 找到最大功率谱线的索引
    [~,I] = max(X);
    % 计算主频率
    fmax(k,1) = (I-1)*(Fs/N);
    % 输出主频率
    %disp(['主频率: ', num2str(fmax(k,1)), ' Hz']);
end

%对第k段信号进行删减（删减得到对应频率下2-5个周期的采样数据），删减后的阀芯控制信号存于Command_cut，删减后的阀芯实际信号存于Actual_cut。
%拟合函数：a+b*sin(2*pi*d*t+c);阀芯控制信号拟合后的系数存于Command_fit。阀芯实际信号拟合后的系数存于Actual_fit。1-4列分别存储a,b,c,d。
for k=1:length(Index(:,1))    
    N1(1,k) = round(Fs/fmax(k,1));          %计算看看第k段信号，一个周期大致有几个采样点
    N2 = N1(1,k);
    i=1;
    %对第k段信号进行删减，对信号采集后大致第2-5个周期的信号进行后续拟合分析
    for i=1: 4* N2
        Command_cut(i,k) = Y1(Index(k,1)+i-1+ N2,Spool_dis_Command);
        Actual_cut(i,k)  = Y1(Index(k,1)+i-1+ N2,Spool_dis_Actual);
    end
    
    % 对阀芯控制正弦信号进行拟合,拟合函数：a + b*sin(2*pi*d*t+c);用Command_fit函数的1-4列分别存储a,b,c,d。
    Command_fit(k,1:4) = fit_sin(Command_cut(1:4* N2,k),Fs,fmax(k,1));
    Actual_fit(k,1:4) = fit_sin(Actual_cut(1:4* N2,k),Fs,fmax(k,1));


    
    t  = (0:1/Fs:4* N2/Fs-1/Fs)';
    y_reconstructed_Command(1:4* N2,k) = Command_fit(k,1) + Command_fit(k,2)*sin(2*pi*Command_fit(k,4)*t+Command_fit(k,3));
    y_reconstructed_Actual(1:4* N2,k) = Actual_fit(k,1) + Actual_fit(k,2)*sin(2*pi*Actual_fit(k,4)*t+Actual_fit(k,3));
    
end

xlswrite(strcat(Mag,'_Y1.xlsx'), Y1);
xlswrite(strcat(Mag,'_Index.xlsx'), Index);
xlswrite(strcat(Mag,'_N1.xlsx'), N1);
xlswrite(strcat(Mag,'_fmax.xlsx'), fmax);
xlswrite(strcat(Mag,'_Command_cut.xlsx'), Command_cut);
xlswrite(strcat(Mag,'_Actual_cut.xlsx'), Actual_cut);
xlswrite(strcat(Mag,'_Command_fit.xlsx'), Command_fit);
xlswrite(strcat(Mag,'_Actual_fit.xlsx'), Actual_fit);
xlswrite(strcat(Mag,'_y_reconstructed_Command.xlsx'), y_reconstructed_Command);
xlswrite(strcat(Mag,'_y_reconstructed_Actual.xlsx'),  y_reconstructed_Actual);