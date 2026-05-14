function plot_Force(filename,sheet,color1)%读取的文件名，表名，设置画线颜色
Y1 = xlsread(filename,sheet);
[m,n]=size(Y1);
target=[500,1000,1500,2000,2500,2000,1500,1000,500];%设置目标力
[m1,n1]=size(target);
targrtV=3;%目标力在哪一列
RealV=4;%实际力在哪一列
first=[];%达到目标力序列的第一个点
last=[];%达到目标力序列的最后一个点
i=1;
for k=1:n1

    for i=i:m
        if Y1(i,targrtV)==target(k)
            first(k)=i;
            break
        end
    end
    for i=i:m-1
        if Y1(i,targrtV)==target(k) && Y1((i+1),targrtV)==target(k)
           last(k)=i+1;
        else
            break
        end
    end

end

N1=200;%画力的转折点前N1个点
N2=3500;%画力的转折点后N2个点
N=N1+N2;
t1=0.002;
X=ones(n1-1,N+1);%设置时间轴
for i2=1:(n1-1)
X(i2,:)=t1*N*(i2-1):t1:t1*N*i2;
plot(X(i2,:),Y1(last(i2)-N1:last(i2)+N2,targrtV),'b');
hold on
plot(X(i2,:),Y1(last(i2)-N1:last(i2)+N2,RealV),color1);
hold on
end