k1 = 3;
k2 = 1; 
ki = 3;
last_time = 0;
last_z = 0; 

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
eData = [];
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
 
while(t<8)  
    
position = readVoltage(a, 'A5');  % position
velocity = readVoltage(a,'A3'); % velocity
theta = 3 * Vref_arduino * position / 5;
vtacho = 2 * (2 * velocity * Vref_arduino / 5 - V_7805);

if (~isempty(timeData))
    last_time = timeData(end);
    last_z = zData(end); 
end

dt = toc - last_time; 
desired = 10;
z = last_z + (theta - desired)*dt; 
u = -k1*theta - k2*vtacho - ki*z;

writePWMVoltage(a, 'D6', 0);
writePWMVoltage(a, 'D9', min(abs(u) / 2, 5));

t=toc;

timeData = [timeData t];
positionData = [positionData theta];
velocityData = [velocityData vtacho];
eData = [eData u];
zData = [zData z]; 
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
%hold on
%plot(timeData,desiredData); 
title('position')

figure
plot(timeData,velocityData);
title('velocity')

figure
plot(timeData,eData);
title('input u')

figure
plot(timeData, zData)
%%
disp('Disonnect cable from Arduino to Input Power Amplifier and then press enter to stop controller');
