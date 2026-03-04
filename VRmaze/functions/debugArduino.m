function debugArduino

arduinoBoard = arduino('com3','uno');

configurePin(arduinoBoard,'A0','AnalogInput')       % joystick
configurePin(arduinoBoard,'A1','DigitalOutput')     % solenoid valve
configurePin(arduinoBoard,'A2','DigitalInput')      % rotary encoder sensor 1
configurePin(arduinoBoard,'A3','DigitalInput')      % rotary encoder sensor 2
configurePin(arduinoBoard,'A4','DigitalOutput')     % lickometer pulse
configurePin(arduinoBoard,'A5','AnalogInput')       % lickometer read

% Joystick
disp('     ')
for i=1:10
    j = readVoltage(arduinoBoard,'A0');             % reads voltage from joystick
    disp(['     joystick = ',num2str(j)])
end
disp('     ')

% Lickometer
writeDigitalPin(arduinoBoard,'A4',1)                % test lickometer pulse
l = abs(readDigitalPin(arduinoBoard,'A5')-1);       % lickometer read
disp(['     lickometer on = ',num2str(l)])
pause (0.5)
writeDigitalPin(arduinoBoard,'A4',0)                % test lickometer pulse
l = abs(readDigitalPin(arduinoBoard,'A5')-1);       % lickometer read
disp(['     lickometer off = ',num2str(l)])
disp('     ')

% Solenoid valve
writeDigitalPin(arduinoBoard,'A1',1)                % open solenoid valve
disp('     solenoid on')
pause(0.10)
writeDigitalPin(arduinoBoard,'A1',0)                % open solenoid valve
disp('     solenoid off')
disp('     please clean drop from spout')
disp('     ')

% Servos
disp('     testing servos...')
servo1 = servo(arduinoBoard,'D10');                 % servo 1
servo2 = servo(arduinoBoard,'D11');                 % servo 2
writePosition(servo1,0.75);                         % move servo 1
writePosition(servo2,0.25);                         % move servo 2
pause(0.5)
writePosition(servo1,0.50);                         % move servo 1
writePosition(servo2,0.50);                         % move servo 2
pause(0.5)
writePosition(servo1,0.75);                         % move servo 1
writePosition(servo2,0.25);                         % move servo 2
disp('     ')

