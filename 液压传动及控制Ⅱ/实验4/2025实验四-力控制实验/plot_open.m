function plot_Force(filename,sheet,color1,open_loop_velocity)%读取的文件名，表名，设置画线颜色
Y1 = xlsread(filename,sheet);
% Y1 = xlsread('open-1.dbf','open-1');% 调试用
% color1='k';% 调试用
% open_loop_velocity=20;% 调试用
valve_standard_velocity=200;
direction_dependent_gain=1.4;
valve_offset=0.8;
valve_stand_Plus=open_loop_velocity/valve_standard_velocity*100+valve_offset;
valve_stand_Minus=-open_loop_velocity/valve_standard_velocity*direction_dependent_gain*100+valve_offset;
[m,n]=size(Y1);
target=[valve_offset,valve_stand_Plus,valve_offset,valve_stand_Minus,valve_offset];%设置目标阀口开度
[m1,n1]=size(target);
targrtV=6;%目标阀口开度在哪一列
% RealV=4;%实际力在哪一列
first=[];%达到阀口开度序列的第一个点
last=[];%达到阀口开度序列的最后一个点
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

N1=450;%画阀口开度转折点前N1个点
N2=600;%画阀口开度转折点后N2个点
N=N1+N2;
t1=0.002;
X=ones(n1-1,N+1);%设置时间轴
for i2=1:n1-1
X(i2,:)=t1*N*(i2-1):t1:t1*N*i2;
plot(X(i2,:),Y1(last(i2)-N1:last(i2)+N2,targrtV),color1);
hold on
% plot(X(i2,:),Y1(last(i2)-N1:last(i2)+N2,RealV),color1);
% hold on
end