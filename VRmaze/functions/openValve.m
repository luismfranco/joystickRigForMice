function openValve

arduinoBoard = arduino('com3','uno');
configurePin(arduinoBoard,'A1','DigitalOutput')
writeDigitalPin(arduinoBoard,'A1',1)
input('     press Enter to close valve ')
disp('     valve closed')

