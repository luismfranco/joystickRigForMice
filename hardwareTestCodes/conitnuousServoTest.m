function conitnuousServoTest(input,time)


% % initialize arduino
% arduinoBoard = arduino('com5','uno');
% continuousServo = servo(arduinoBoard,'D9');


writePosition(continuousServo,input)
pause(time)
