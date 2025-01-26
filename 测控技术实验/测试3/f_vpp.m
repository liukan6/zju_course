% 数据输入
f = [2.451, 5.208, 6.098, 6.452, 6.579, 6.667, 9.843, 13.37, 16.45, 20.00, 24.15, 27.47, 30.86]; % 频率 f (Hz)
Vp_p = [0.200, 0.472, 0.928, 3.020, 6.320, 2.760, 0.328, 0.176, 0.108, 0.092, 0.072, 0.064, 0.048]; % 峰峰值 Vp-p (V)

% 理论公式定义
theoretical_model = @(params, f) params(1) ./ ...
    sqrt((1 - (f / params(2)).^2).^2 + (2 * params(3) * (f / params(2))).^2);

% 初始参数 [A, f_n, zeta]
initial_params = [6, 6.5, 0.1];

% 使用 lsqcurvefit 进行拟合
options = optimoptions('lsqcurvefit', 'Display', 'iter', 'Algorithm', 'trust-region-reflective');
lb = [0, 0, 0]; % 下界
ub = [10, 15, 1]; % 上界
fitted_params = lsqcurvefit(theoretical_model, initial_params, f, Vp_p, lb, ub, options);

% 拟合结果
A = fitted_params(1);
f_n = fitted_params(2);
zeta = fitted_params(3);
disp(['拟合参数: A = ', num2str(A), ', f_n = ', num2str(f_n), ', zeta = ', num2str(zeta)]);

% 计算拟合曲线
f_fit = linspace(min(f), max(f), 1000);
Vp_p_fit = theoretical_model(fitted_params, f_fit);

% 绘制图像
figure;
plot(f, Vp_p, 'o', 'MarkerSize', 8, 'DisplayName', '实验数据'); % 原始数据点
hold on;
plot(f_fit, Vp_p_fit, '-', 'LineWidth', 1.5, 'DisplayName', '单共振峰拟合'); % 拟合曲线
hold off;
grid on;
xlabel('频率 f/Hz', 'FontSize', 12);
ylabel('峰峰值 V_{p-p}/V', 'FontSize', 12);
title('f-V_{p-p}拟合曲线', 'FontSize', 14);
legend('FontSize', 12, 'Location', 'best');
set(gca, 'FontSize', 12);

% 显示拟合公式
disp(['拟合公式: V_{p-p}(f) = ', num2str(A), ' / sqrt((1 - (f / ', num2str(f_n), ')^2)^2 + (2 * ', num2str(zeta), ' * (f / ', num2str(f_n), '))^2)']);
