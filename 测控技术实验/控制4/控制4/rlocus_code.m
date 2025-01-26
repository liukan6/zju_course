num1=5;
den1=[0.1 0.2 0];
former=tf(num1,den1);

num2=5;
den2=[0.008 0.2 0];
improved=tf(num2,den2);

rlocus(former,'b',improved,'r');
axis([-27 1 -14 14]);
