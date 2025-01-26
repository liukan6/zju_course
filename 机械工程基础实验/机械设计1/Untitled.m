% t9=[1.500
% 3.000
% 4.500
% 6.000
% 7.500
% 9.000
% 10.500
% 12.000
% ];
% t1=[0.455
% 0.477
% 0.484
% 0.508
% 0.531
% 0.563
% 0.594
% 0.613
% ];
% eta=[83.853
% 91.714
% 94.465
% 95.675
% 96.393
% 96.825
% 97.131
% 97.411
% ];
% 
% figure;
% title('T_9-\eta曲线');hold on;
% xlabel('T_9/Nm');
% xlabel('\eta/%');
% plot(t9,eta,'b*-','linewidth',1.5);
%% 

% m=[300	689	15	4.2
% 206	692	14	3.9
% 155	690	13	3.6
% 110	688	13	3.6
% 91	696	13	3.5
% 78	690	13	3.5
% 73	688	13	3.4
% 72	691	13	3.5
% 67	692	14	3.5
% 48	695	14	3.5
% 33	697	15	3.3
% 22	692	16	3.3
% ];
% n=m(:,1);F=m(:,2);delta=m(:,3);f=m(:,4);
% ff=2*120*0.098*delta./F/60;
% eta=0.34;p=F/0.11/0.06;
% yy=eta*n*2*pi/60./p;
% figure;
% plot(yy,ff,'o-b','linewidth',1.5);
% xlabel('\eta n/p');
% ylabel('f');
% title('滑动轴承摩擦特性曲线');
%% 

dd=[5	10	14	17	22	13	1
5	8	14	18	26	13	3
8	14	20	24	30	17	5
8	13	20	25	33	18	6];
xx=180:-30:0;
figure;
subplot(2,1,2);
k=4;hold on;
plot(1:7,dd(k,:),'bo-','linewidth',1.5);
xlabel('标号');
ylabel('\Delta');
subplot(2,1,1);
xxx=[];yyy=[]
for i=1:7
    x=dd(k,i)*cos(xx(i)*pi/180);
    y=dd(k,i)*sin(xx(i)*pi/180);
    plot([0 x],[0 y],'b-','linewidth',1.5);hold on;
    xxx=[xxx x];yyy=[yyy y];
end
plot(xxx,yyy,'r-','linewidth',1.5)
