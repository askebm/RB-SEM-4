clc
clear

%OLD Values
% K_ft_motor_tourque = 2.8;
% b_ft = 0.5;
% K_ft_electroforce = 3.0;
% %-----------------
% K_fb_motor_tourque = 4.4;
% b_bt = 0.8;
% K_fb_electroforce = 3.0;

s = tf('s');

%Friction
bt = 0.5;
%Mass of corner brackets
mc = 0.075;
%Electromotive force
Ket = 0.1;
%Motor Tourque
Kmt = 1.4;
%Inductance of motor
Lt = 3.85 * 10^(-4);
%Ohmic resistance of motor
Rt = 4.79;
%Moment of inertia divided by 3 to take gearing into account.
Jt = 0.0198/3;
%Distance from rotational axis to Center Of Mass of corner brackets
r = 0.291/2;
%Gravitational constant
g = 9.82;


%% Linearize 0degrees

%Working point.
xbar = 0;
%Convert to radians
th = xbar*pi/180;

% Defining A,B,C matrices
A = [0 1 0; 
    ((-2*mc*r*g*cos(th)/3)/Jt) -bt/Jt Kmt/Jt; 
    0 -Ket/Lt -Rt/Lt];
B = [0;0;1/Lt];

% Position, Velocity, Current
C = [1 0 0];

%Convert to Transferfunction
Gs =(12/255)*( C*( inv(s*eye(3)-A) )*B )*(180/pi);

%Root Locus open loop
 rlocus_pure = figure('Name','float_me'); % Allows I3 to float the window
  rlocus(Gs);
  axIm = findall(gcf,'String','Imaginary Axis (seconds^{-1})');
  axRe = findall(gcf,'String','Real Axis (seconds^{-1})');
  set(axIm,'String', 'Im$(s)$');
  set(axRe,'String','Re$(s)$');
  xlim([-400 5])
  ylim([-15 15])
  set(rlocus_pure,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(rlocus_pure,'img/PI/rlocus_pure')

%Regulator
kp = 1;
Ti = 1/0.035;
Td = 0;
ki = kp*1/Ti;
I = 1/(s*Ti);
Hs = kp * (1 + I);

%Root Locus with Ti gain
 rlocus_int = figure('Name','float_me'); % Allows I3 to float the window
  rlocus(Hs*Gs);
  axIm = findall(gcf,'String','Imaginary Axis (seconds^{-1})');
  axRe = findall(gcf,'String','Real Axis (seconds^{-1})');
  set(axIm,'String', 'Im$(s)$');
  set(axRe,'String','Re$(s)$');
  xlim([-0.5 0])
  ylim([-5 5])
  set(rlocus_int,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(rlocus_int,'img/PI/rlocus_int')

%Regulator
kp = 3.1;
Ti = 1/0.035;
Td = 0;
ki = kp*1/Ti;
I = 1/(s*Ti);
Hs = kp * (1 + I);
  
%Step response First
sys_cl_0 = (Gs * Hs) / ( 1 + Gs * Hs);
opt = stepDataOptions('StepAmplitude',3*90);
%step(sys_cl_0,opt)

 step_0_first = figure('Name','float_me'); % Allows I3 to float the window
  step(sys_cl_0,opt)
  xlim([0 4])
  line([0 100],[0.9*270 0.9*270], 'Color','black','LineStyle','--')
  line([1 1],[0 300], 'Color','black','LineStyle','--')
  yticks([0 (0.3*270) (0.6*270) (0.9*270) 270])
  yticklabels({'0','$30\%$', '$60\%$', '$90\%$', '$100\%$'})
  set(step_0_first,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(step_0_first,'img/PI/step_0_first')
  
  
%Step response Second

%Regulator
kp = 1.6;
Ti = 1/0.2;
Td = 0;
ki = kp*1/Ti;
I = 1/(s*Ti);
Hs = kp * (1 + I);

sys_cl_1 = (Gs * Hs) / ( 1 + Gs * Hs);
opt = stepDataOptions('StepAmplitude',3*90);
%step(sys_cl_0,opt)

 step_0_second = figure('Name','float_me'); % Allows I3 to float the window
  subplot(1,2,1)
  step(sys_cl_1,opt)
  xlim([0 4])
  line([0 100],[0.9*270 0.9*270], 'Color','black','LineStyle','--')
  line([1 1],[0 300], 'Color','black','LineStyle','--')
  yticks([0 (0.3*270) (0.6*270) (0.9*270) 270])
  yticklabels({'0','$30\%$', '$60\%$', '$90\%$', '$100\%$'})
  subplot(1,2,2)
  margin(Hs*Gs)
  title('Bode Diagram')
  set(step_0_second,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(step_0_second,'img/PI/step_0_second')

%% Linearize 90degrees

%Working point.
xbar = 90;
%Convert to radians
th = xbar*pi/180;

% Defining A,B,C matrices
A = [0 1 0; 
    ((-2*mc*r*g*cos(th)/3)/Jt) -bt/Jt Kmt/Jt; 
    0 -Ket/Lt -Rt/Lt];
B = [0;(-sin(th)*th + cos(th));1/Lt];
% Position, Velocity, Current
C = [1 0 0];

%Convert to Transferfunction
Gs =(12/255)*( C*( inv(s*eye(3)-A) )*B )*(180/pi);


%Step response Second

%Regulator
kp = 1.39;
Ti = 1/0.06;
Td = 0;
ki = kp*1/Ti;
I = 1/(s*Ti);
Hs = kp * (1 + I);

sys_cl_2 = (Gs * Hs) / ( 1 + Gs * Hs);
opt = stepDataOptions('StepAmplitude',3*90);
%step(sys_cl_0,opt)

 step_0_second_90 = figure('Name','float_me'); % Allows I3 to float the window
 subplot(1,2,1)
  step(sys_cl_2,opt)
  line([0 10],[0.9*270 0.9*270], 'Color','black','LineStyle','--')
  line([1 1],[0 300], 'Color','black','LineStyle','--')
  yticks([0 (0.3*270) (0.6*270) (0.9*270) 270])
  yticklabels({'0','$30\%$', '$60\%$', '$90\%$', '$100\%$'})
 subplot(1,2,2)
  margin(Hs*Gs)
  title('Bode Diagram')
  set(step_0_second_90,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(step_0_second_90,'img/PI/step_0_second_90')
  
  %% Linearize 180degrees

%Working point.
xbar = 180;
%Convert to radians
th = xbar*pi/180;

% Defining A,B,C matrices
A = [0 1 0; 
    ((-2*mc*r*g*cos(th)/3)/Jt) -bt/Jt Kmt/Jt; 
    0 -Ket/Lt -Rt/Lt];
B = [0;(-sin(th)*th + cos(th));1/Lt];
% Position, Velocity, Current
C = [1 0 0];

%Convert to Transferfunction
Gs =(12/255)*( C*( inv(s*eye(3)-A) )*B )*(180/pi);

%Step response Second

%Regulator
kp = 1.3;
Ti = 1/0.2;
Td = 0;
ki = kp*1/Ti;
I = 1/(s*Ti);
Hs = kp * (1 + I);

sys_cl_3 = (Gs * Hs) / ( 1 + Gs * Hs);
opt = stepDataOptions('StepAmplitude',3*90);
%step(sys_cl_0,opt)

 step_0_second_180 = figure('Name','float_me'); % Allows I3 to float the window
 subplot(1,2,1)
  step(sys_cl_3,opt)
  xlim([0 10])
  line([0 10],[0.9*270 0.9*270], 'Color','black','LineStyle','--')
  line([1 1],[0 360], 'Color','black','LineStyle','--')
  yticks([0 (0.3*270) (0.6*270) (0.9*270) 270])
  yticklabels({'0','$30\%$', '$60\%$', '$90\%$', '$100\%$'})
 subplot(1,2,2)
  margin(Hs*Gs)
  title('Bode Diagram')
  set(step_0_second_180,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(step_0_second_180,'img/PI/step_0_second_180')
  
  %% Comparison
  
 comp = figure('Name','float_me'); % Allows I3 to float the window
  step(sys_cl_1,opt)
  hold on
  step(sys_cl_2,opt)
  hold on
  step(sys_cl_3,opt)
  hold off
  h = line([0 20],[0.9*270 0.9*270], 'Color','black','LineStyle','--')
  b = line([1 1],[0 400], 'Color','black','LineStyle','--')
  c = line([0 20],[270 270], 'Color','black','LineStyle','--')
  yticks([0 (0.3*270) (0.6*270) (0.9*270) 270])
  yticklabels({'0','$30\%$', '$60\%$', '$90\%$', '$100\%$'})
  set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
  legend('$0^o$','$90^o$','$180^o$','Location','east')
  xlim([0 20])
  ylim([0 320])
  set(comp,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(comp,'img/PI/comp')
  
  
  
  
%% BOTTOM frame PI tuning, with topframe at 0 degrees.
  
clc
clear

s = tf('s');

%Working point top frame.
xbar = 0;
%Convert to radians
th = xbar*pi/180;

%Friction
bb = 0.5;
%Electro force
Keb = 3.5;
%Motor Tourque
Kmb = 1.57;
%Inductance of motor
Lb = 3.85 * 10^(-4);
%Ohmic resistance of motor
Rb = 4.79;
%Moment of inertia divided by 3 to take gearing into account.
Jb = ( 0.0705 + 0.0103*sin(th)*sin(th) ) / 3;
%Gravitational constant
g = 9.82;

% Defining A,B,C matrices
A = [0 1 0; 
    0 -bb/Jb Kmb/Jb; 
    0 -Keb/Lb -Rb/Lb];
B = [0;0;1/Lb];

% Position, Velocity, Current
C = [1 0 0];

%Convert to Transferfunction
Gs =(12/255)*( C*( inv(s*eye(3)-A) )*B )*(180/pi);

%Regulator
kp = 1;
Ti = 1/0.035;
Td = 0;
ki = kp*1/Ti;
I = 1/(s*Ti);
Hs = kp * (1 + I);

%Root Locus open loop
 rlocus_pure_bot = figure('Name','float_me'); % Allows I3 to float the window
  rlocus(Gs);
  axIm = findall(gcf,'String','Imaginary Axis (seconds^{-1})');
  axRe = findall(gcf,'String','Real Axis (seconds^{-1})');
  set(axIm,'String', 'Im$(s)$');
  set(axRe,'String','Re$(s)$');
  xlim([-120 10])
  ylim([-10 10])
  set(rlocus_pure_bot,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(rlocus_pure_bot,'img/PI/rlocus_pure_bot')


%Root Locus with Ti gain
 rlocus_int_bot = figure('Name','float_me'); % Allows I3 to float the window
  rlocus(Hs*Gs);
  axIm = findall(gcf,'String','Imaginary Axis (seconds^{-1})');
  axRe = findall(gcf,'String','Real Axis (seconds^{-1})');
  set(axIm,'String', 'Im$(s)$');
  set(axRe,'String','Re$(s)$');
  xlim([-200 50])
  ylim([-150 150])
  set(rlocus_int_bot,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(rlocus_int_bot,'img/PI/rlocus_int_bot')

%Regulator
kp = 9;
Ti = 1/0.035;
Td = 0;
ki = kp*1/Ti;
I = 1/(s*Ti);
Hs = kp * (1 + I);
  
%Step response First
sys_cl_0 = (Gs * Hs) / ( 1 + Gs * Hs);
opt = stepDataOptions('StepAmplitude',3*90);
%step(sys_cl_0,opt)

 step_0_first_bot = figure('Name','float_me'); % Allows I3 to float the window
  step(sys_cl_0,opt)
  line([0 10],[0.9*270 0.9*270], 'Color','black','LineStyle','--')
  line([1 1],[0 300], 'Color','black','LineStyle','--')
  yticks([0 (0.3*270) (0.6*270) (0.9*270) 270])
  yticklabels({'0','$30\%$', '$60\%$', '$90\%$', '$100\%$'})
  set(step_0_first_bot,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(step_0_first_bot,'img/PI/step_0_first_bot')
  

%Step response Second

%Regulator
kp = 3.7;
Ti = 1/0.035;
Td = 0;
ki = kp*1/Ti;
I = 1/(s*Ti);
Hs = kp * (1 + I);

sys_cl_1 = (Gs * Hs) / ( 1 + Gs * Hs);
opt = stepDataOptions('StepAmplitude',3*90);
%step(sys_cl_0,opt)

 step_0_second_bot = figure('Name','float_me'); % Allows I3 to float the window
  subplot(1,2,1)
  step(sys_cl_1,opt)
  line([0 10],[0.9*270 0.9*270], 'Color','black','LineStyle','--')
  line([1 1],[0 300], 'Color','black','LineStyle','--')
  yticks([0 (0.3*270) (0.6*270) (0.9*270) 270])
  yticklabels({'0','$30\%$', '$60\%$', '$90\%$', '$100\%$'})
  subplot(1,2,2)
  margin(Hs*Gs)
  title('Bode Diagram')
  set(step_0_second_bot,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(step_0_second_bot,'img/PI/step_0_second_bot')

  %% BOTTOM frame PI tuning, with topframe at 90 degrees.
  
s = tf('s');

%Working point top frame.
xbar = 90;
%Convert to radians
th = xbar*pi/180;

%Friction
bb = 0.5;
%Electro force
Keb = 3.5;
%Motor Tourque
Kmb = 1.57;
%Inductance of motor
Lb = 3.85 * 10^(-4);
%Ohmic resistance of motor
Rb = 4.79;
%Moment of inertia divided by 3 to take gearing into account.
Jb = ( 0.0705 + 0.0103*sin(th)*sin(th) ) / 3;
%Gravitational constant
g = 9.82;


% Defining A,B,C matrices
A = [0 1 0; 
    0 -bb/Jb Kmb/Jb; 
    0 -Keb/Lb -Rb/Lb];
B = [0;0;1/Lb];

% Position, Velocity, Current
C = [1 0 0];

%Convert to Transferfunction
Gs =(12/255)*( C*( inv(s*eye(3)-A) )*B )*(180/pi);

%Regulator
kp = 1;
Ti = 1/0.035;
Td = 0;
ki = kp*1/Ti;
I = 1/(s*Ti);
Hs = kp * (1 + I);

%Root Locus open loop
 rlocus_pure_bot_90 = figure('Name','float_me'); % Allows I3 to float the window
  rlocus(Gs);
  axIm = findall(gcf,'String','Imaginary Axis (seconds^{-1})');
  axRe = findall(gcf,'String','Real Axis (seconds^{-1})');
  set(axIm,'String', 'Im$(s)$');
  set(axRe,'String','Re$(s)$');
  xlim([-200 50])
  ylim([-150 150])
  set(rlocus_pure_bot_90,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(rlocus_pure_bot_90,'img/PI/rlocus_pure_bot_90')


%Root Locus with Ti gain
 rlocus_int_bot_90 = figure('Name','float_me'); % Allows I3 to float the window
  rlocus(Hs*Gs);
  axIm = findall(gcf,'String','Imaginary Axis (seconds^{-1})');
  axRe = findall(gcf,'String','Real Axis (seconds^{-1})');
  set(axIm,'String', 'Im$(s)$');
  set(axRe,'String','Re$(s)$');
  xlim([-0.5 0])
  ylim([-0.05 0.05])
  set(rlocus_int_bot_90,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(rlocus_int_bot_90,'img/PI/rlocus_int_bot_90')

%Regulator
kp = 9;
Ti = 1/0.035;
Td = 0;
ki = kp*1/Ti;
I = 1/(s*Ti);
Hs = kp * (1 + I);
  
%Step response First
sys_cl_3 = (Gs * Hs) / ( 1 + Gs * Hs);
opt = stepDataOptions('StepAmplitude',3*90);
%step(sys_cl_0,opt)

 step_0_first_bot_90 = figure('Name','float_me'); % Allows I3 to float the window
  step(sys_cl_3,opt)
  line([0 10],[0.9*270 0.9*270], 'Color','black','LineStyle','--')
  line([1 1],[0 300], 'Color','black','LineStyle','--')
  yticks([0 (0.3*270) (0.6*270) (0.9*270) 270])
  yticklabels({'0','$30\%$', '$60\%$', '$90\%$', '$100\%$'})
  set(step_0_first_bot_90,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(step_0_first_bot_90,'img/PI/step_0_first_bot_90')
  

%Step response Second

%Regulator
kp = 3.7;
Ti = 1/0.035;
Td = 0;
ki = kp*1/Ti;
I = 1/(s*Ti);
Hs = kp * (1 + I);

sys_cl_4 = (Gs * Hs) / ( 1 + Gs * Hs);
opt = stepDataOptions('StepAmplitude',3*90);

 step_0_second_bot_90 = figure('Name','float_me'); % Allows I3 to float the window
 step(sys_cl_4,opt)
  line([0 10],[0.9*270 0.9*270], 'Color','black','LineStyle','--')
  line([1 1],[0 300], 'Color','black','LineStyle','--')
  yticks([0 (0.3*270) (0.6*270) (0.9*270) 270])
  yticklabels({'0','$30\%$', '$60\%$', '$90\%$', '$100\%$'})
  set(step_0_second_bot_90,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(step_0_second_bot_90,'img/PI/step_0_second_bot_90')

    %% Comparison bottom
  
 comp = figure('Name','float_me'); % Allows I3 to float the window
  step(sys_cl_1,opt)
  hold on
  step(sys_cl_4,opt)
  hold off
  h = line([0 20],[0.9*270 0.9*270], 'Color','black','LineStyle','--')
  b = line([1 1],[0 450], 'Color','black','LineStyle','--')
  c = line([0 20],[270 270], 'Color','black','LineStyle','--')
  yticks([0 (0.3*270) (0.6*270) (0.9*270) 270])
  yticklabels({'0','$30\%$', '$60\%$', '$90\%$', '$100\%$'})
  set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
  legend('$0^o$','$90^o$','Location','east')
  xlim([0 3])
  ylim([0 320])
  set(comp,'Position',[10 10 600 300]) % Must closely match the final size needed
  Plot2LaTeX(comp,'img/PI/comp_bot')
  
  