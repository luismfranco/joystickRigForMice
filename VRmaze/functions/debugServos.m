function debugServos

arduinoBoard = arduino('com3','uno');
servo1 = servo(arduinoBoard,'D10','MinPulseDuration',0.001,'MaxPulseDuration',0.002);      % servo 1
servo2 = servo(arduinoBoard,'D11','MinPulseDuration',0.001,'MaxPulseDuration',0.002);      % servo 2
writePosition(servo1,0.75);                                                                % open servo 1
writePosition(servo2,0.25);                                                                % open servo 2
pause(1)