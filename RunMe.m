clc
clear
t = [0:0.01:10];
x = 0.2*t + cos(2*pi*t) + 0.4*cos(10*pi*t);
thr = 0.2;
y = EMD(x,t,thr);

% Plot figure
figure(1);
subplot(1+size(y,1),1,1);
plot(t,x);
ylabel('x(t)');

for i = 1: size(y,1)
    subplot(1+size(y,1),1,1+i);
    plot(t,y(i,:));
    if(i~=size(y,1))
        ylabel(sprintf('IMF%d',i));
    else
       ylabel('x_{0}(t)(trend)');
    end
end

xlabel('t(sec)');
