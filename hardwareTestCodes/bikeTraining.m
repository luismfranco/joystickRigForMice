function bikeTraining(direction)
    
    % Decision
    decision = [];

    % Initial parameter values
    conditional = [];

    % initialize arduino
    arduinoBoard = arduino('com3','uno');
    
    configurePin(arduinoBoard,'A2','DigitalInput')  % rotaryencoder1
    configurePin(arduinoBoard,'A3','DigitalInput')  % rotaryencoder2

    servo1 = servo(arduinoBoard,'D5');              % servo1
    servo2 = servo(arduinoBoard,'D6');              % servo2
    
    % Close servos
    writePosition(servo1,0.5), writePosition(servo2,0.56)
    pause(2)
    
    % Open servos
    writePosition(servo1,0.28), writePosition(servo2,0.78)
    
    % Initiate rotation of servo3
    if strcmp(direction,'left')
        writePosition(servo1,0.65), writePosition(servo2,0.70)
    elseif strcmp(direction,'right')
        writePosition(servo1,0.35), writePosition(servo2,0.40)
    end
    
    % Sensor initial states
    b0 = readDigitalPin(arduinoBoard,'A2');
    b1 = readDigitalPin(arduinoBoard,'A3');
                
    % Loop for evaluating turning direction
    while isempty(conditional)
        
        % Reading sensor states
        a0 = readDigitalPin(arduinoBoard,'A2');
        a1 = readDigitalPin(arduinoBoard,'A3');
        % Evaluation of turning direction
        if a0~=b0
            if a0==b1
                disp('     left')
                decision = 'left';
            elseif a0~=b1
                disp('     right')
                decision = 'right';
            end
        elseif a1~=b1
            if a1==b0
                disp('     right')
                decision = 'right';
            elseif a1~=b0
                disp('     left')
                decision = 'left';
            end
        end
        % Condition to close servo locks
        if strcmp(decision,'left') || strcmp(decision,'right')
            pause(2)
            writePosition(servo1,0.5), writePosition(servo2,0.56) % close servos
            conditional = 1;
        end
        % Get previous state of sensors
        b0 = a0; b1 = a1;
        
    end

