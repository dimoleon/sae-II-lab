V_7805=5.48;
Vref_arduino=5;

if ~exist('a','var') 
    a = arduino;
end

% OUTPUT ZERO CONTROL SIGNAL TO STOP MOTOR  %
writePWMVoltage(a, 'D6', 0)
writePWMVoltage(a, 'D9', 0)

positionData = [];
velocityData = [];
uData = [];
timeData = [];
desiredData = []; 
zData = [];

t=0;

% CLOSE ALL PREVIOUS FIGURES FROM SCREEN

close all

% WAIT A KEY TO PROCEED
disp(['Connect cable from Arduino to Input Power Amplifier and then press enter to start controller']);
pause()



%START CLOCK
tic
 
while(t<5)  
    
position = readVoltage(a, 'A5');  % position
velocity = readVoltage(a,'A3'); % velocity
theta = 3 * Vref_arduino * position / 5;
vtacho = 2 * (2 * velocity * Vref_arduino / 5 - V_7805);

k1=2;
k2=0.9;

% Frequency 
w = 0.1;
%w = 0.2; 
%w = 0.4; 

% desired = 5 + 2*sin(2*pi*w*t);
desired = 5;
u = - k1*theta - k2*vtacho + k1*desired;

writePWMVoltage(a, 'D6', 0);
writePWMVoltage(a, 'D9', min(abs(u) / 2, 5));

t=toc;
    
timeData = [timeData t];
positionData = [positionData theta];
velocityData = [velocityData vtacho];
uData = [uData u]; 
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
plot(timeData,desiredData); 
title('position')

figure
plot(timeData,velocityData);
title('velocity')

figure
plot(timeData,uData);
title('input u')

%%
disp('Disonnect cable from Arduino to Input Power Amplifier and then press enter to stop controller');


