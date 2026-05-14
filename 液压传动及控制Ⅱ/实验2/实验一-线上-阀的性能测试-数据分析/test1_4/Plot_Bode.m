%画所有测试或者部分测试的Bode图
Mag_all = ["M1","M5","M25"];    %画所有测试的幅频曲线，如果只画某个测试，Mag_all = ["M1"]
% Mag_all = ["M1"];                   %如果只画某个测试
color = ["r","g","b"]
for i = 1:length(Mag_all)
    Mag_1 = Mag_all(1,i);
    Command_fit = xlsread(strcat(Mag_1,'_Command_fit','.xlsx'));
    Actual_fit = xlsread(strcat(Mag_1,'_Actual_fit','.xlsx'));
    Y_Mag =20*log( Actual_fit(:,2) ./ Command_fit(:,2));
    yyaxis left
    plot ( Command_fit(:,4),Y_Mag,strcat(color(1,i),'-*'));
    ylim([-30 5])
    xlabel('频率（Hz）');
    ylabel('振幅比（db）');
    hold on;
    yyaxis right
    Y_Pha =(-Actual_fit(:,3) +Command_fit(:,3))/ pi * 180;
    Y_Pha = mod(Y_Pha + 360, 360); %相位差归一化到0-360度之间
    plot (Command_fit(:,4),Y_Pha,strcat(color(1,i),'-o'));
    ylim([0 330])
    ylabel('相位差（°）');
    hold on
    set(gca,'xscal','log');

    % Find -3dB bandwidth
    [~, idx_3db] = min(abs(Y_Mag + 3));
    f_3db = Command_fit(idx_3db, 4);
    
    % Find -90° phase bandwidth
    [~, idx_90] = min(abs(Y_Pha - 90));
    f_90 = Command_fit(idx_90, 4);
    
    % Find maximum magnitude ratio
    Mr = max(Y_Mag);
    
    % Display results
    fprintf('\n%s结果:\n', Mag_1);
    fprintf('-3dB 幅频宽: %.2f Hz\n', f_3db);
    fprintf('-90° 相频宽: %.2f Hz\n', f_90);
    fprintf('最大幅值比: %.2f dB\n', Mr);
end