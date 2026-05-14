%对阀芯控制正弦信号进行拟合,拟合函数：a + b*sin(2*pi*d*t+c);用Command_fit函数的1-4列分别存储a,b,c,d。
function fit_sin = fit_sin(y,fs,fmax)
N  = length(y);
t  = (0:1/fs:N/fs-1/fs)';

cfun    = @(d) [ones(size(t)), sin(2*pi*d*t), cos(2*pi*d*t)]\y;
sumerr2 = @(d) sum((y - [ones(size(t)), sin(2*pi*d*t), cos(2*pi*d*t)] * cfun(d)) .^ 2);
dopt    = fminbnd(sumerr2, fmax*0.9, fmax*1.1);
abb     = cfun(dopt);

a = abb(1);
b = norm(abb([2 3]));
c = acos(abb(2) / b);
d = dopt;

y_1 = a + b*sin(2*pi*d*t+c);
y_2 = a + b*sin(2*pi*d*t-c);
y_sum_1= sum( (y-  y_1).^ 2);
y_sum_2= sum( (y-  y_2).^ 2);
if y_sum_1< y_sum_2
    c = acos(abb(2) / b);
else
    c = -acos(abb(2) / b);
end
fit_sin = [a,b,c,d];
end

