k1 = 1;
k2 = 0.2; 
r = 5;

% Set the desired position
des_pos = 5;

km = 247.13; 
Tm = 0.55;
kt = 0.00348;
ku = 1/36; 
k0 = 0.21; 

zita = 5; 
wn = 5; 

A = [0 ku*k0/kt; 
     0 -1/Tm]; 

B = [0; kt*km/Tm]; 

C = [1 0]; 

W = [C; C*A];
Wtild = [1 0;
            -1/Tm 1]; 

aux = [zita+wn - 1/Tm; wn*zita]; 

L = inv(W)*Wtild*aux 
%L = [4; 0.1]; 
Xobs = [2; 0]; 
desired = 5;
%   The input setpoint is in Volts and can vary from 0 to 10 Volts because the position pot is refered to GND

V_7805=5.48;
Vref_arduino=5;

if ~exist('a','var') 
    a = arduino('COM5','Uno','BaudRate', 115200);
end

% OUTPUT ZERO CONTROL SIGNAL TO STOP MOTOR  %
writePWMVoltage(a, 'D6', 0)
writePWMVoltage(a, 'D9', 0)



positionData = [];
velocityData = [];
uData = [];
timeData = [];
XobsData = [];
desiredData = []; 

t=0;

% CLOSE ALL PREVIOUS FIGURES FROM SCREEN

close all

% WAIT A KEY TO PROCEED
disp(['Connect cable from Arduino to Input Power Amplifier and then press enter to start controller']);
pause()



%START CLOCK
tic
 
while(t<8)  
    
position = readVoltage(a, 'A5');  % position
theta = 3 * Vref_arduino * position / 5;

velocity = readVoltage(a,'A3'); % velocity
vtacho = 2 * (2 * velocity * Vref_arduino / 5 - V_7805);

last_time = 0;
if (~isempty(timeData))
    last_time = timeData(end);
end

dt = toc - last_time; 
% u = 7
% u = 3; 
u = -k1*Xobs(1) - k2*Xobs(2) + k1*r; 
Error = [theta; vtacho] - Xobs; 
Xobs_dot = A*Xobs + B*u + L*C*Error;
Xobs = Xobs + dt*Xobs_dot; 



writePWMVoltage(a, 'D6', 0);
writePWMVoltage(a, 'D9', min(abs(u) / 2, 5));

t=toc;

    
timeData = [timeData t];
positionData = [positionData theta];
velocityData = [velocityData vtacho];
uData = [uData u];
XobsData = [XobsData Xobs]; 

desiredData = [desiredData desired];

end

% OUTPUT ZERO CONTROL SIGNAL TO STOP MOTOR  %
writePWMVoltage(a, 'D6', 0)
writePWMVoltage(a, 'D9', 0)


disp(['End of control Loop. Press enter to see diagramms']);
pause();

%%
figure
plot(timeData,positionData);
hold on
plot(timeData,XobsData(1,:),'o'); 
title('position')
%% 

figure
plot(timeData,velocityData);
hold on
plot(timeData, XobsData(2,:)); 
title('velocity')

figure
plot(timeData,uData);
title('input u')

%%
disp('Disonnect cable from Arduino to Input Power Amplifier and then press enter to stop controller');
% pause();

