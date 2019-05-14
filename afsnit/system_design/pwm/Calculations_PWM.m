clc
clear

V = 12;
R = 4.7;
L = 26.7*17.5*10^-6;
tau = L/R;

leng = 2*5*tau*3;

t = 0:0.000001:leng;
t2 = 0:0.000001:5*tau;
t3 = 10*tau:0.000001:15*tau;
t4 = 20*tau:0.000001:25*tau;

i = (V/R)*(1-exp((-R*t2)/L));
i2 = (V/R)*(1-exp((-R*(t3-5*tau))/L));
i3 = (V/R)*(1-exp((-R*(t4-5*tau))/L));

y = 0.5*max(i)*square(2*pi*t / (2*5*tau)) + 0.5*max(i);

% current = figure('Name','float_me','Position',[10 10 0.7*600 0.7*200]);
% plot(t,i);
% xlim([0 5*10^(-4)])
% line([0 6*tau],[2.53648 2.53648],'LineStyle','--','Color','k');
% title('Current through motor');
% ylabel('(ampere)');
% xlabel('time');
% xticks([tau 2*tau 3*tau 4*tau 5*tau])
% xticklabels(["$\tau$","$2\tau$","$3\tau$","$4\tau$","$5\tau$"])
% 
% Plot2LaTeX(current,'img/current');

linecolor = [0.8500, 0.3250, 0.0980];

curpwm = figure('Name','float_me','Position',[10 10 0.7*600 0.7*200]);
plot(t,y)
hold on
plot(t2, i, 'Color', linecolor)
hold on
plot(t3, i, 'Color', linecolor)
hold on
plot(t4, i, 'Color', linecolor)
hold off
line([5*tau 5*tau],[0 max(i)],'Color',linecolor)
line([5*tau 10*tau],[0 0],'Color',linecolor)
line([15*tau 15*tau],[0 max(i)],'Color',linecolor)
line([15*tau 20*tau],[0 0],'Color',linecolor)
line([25*tau 25*tau],[0 max(i)],'Color',linecolor)
title('Current and PWM');
ylabel('V / A');
xlabel('time');
xticks([tau 2*tau 3*tau 4*tau 5*tau 6*tau 7*tau 8*tau 9*tau 10*tau 12*tau 14*tau  16*tau  18*tau  20*tau 22*tau 24*tau 26*tau])
xticklabels(["$\tau$","$2\tau$","$3\tau$","$4\tau$","$5\tau$","$6\tau$","$7\tau$","$8\tau$","$9\tau$","$10\tau$","$12\tau$","$14\tau$","$16\tau$","$18\tau$","$20\tau$","$22\tau$","$24\tau$","$26\tau$"])

ylim([0 max(i)+0.5])
xlim([0 25*tau])

legend('Voltage [V]','Current [A]')


Plot2LaTeX(curpwm,'img/curpwm');


