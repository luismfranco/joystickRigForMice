function trainingWheels(direction)

    % Settings
    counter = 0;
    change = 0;
    previousMovement = [];
    currentMovement = [];
    decisionMade = 0;
    voltageThreshold = 0.5;
    
    % Initial parameter values
    conditional = [];

    % initialize arduino
    arduinoBoard = arduino('com3','uno');
    
    configurePin(arduinoBoard,'A2','DigitalInput')  % rotaryencoder1
    configurePin(arduinoBoard,'A3','DigitalInput')  % rotaryencoder2
    configurePin(arduinoBoard,'A0','DigitalInput')  % joystick

    servo1 = servo(arduinoBoard,'D10');              % servo1
    servo2 = servo(arduinoBoard,'D11');              % servo2
    servo3 = servo(arduinoBoard,'D9');               % servo3
    
    % Open servos
    writePosition(servo1,0.35), writePosition(servo2,0.75)
    
    % Initiate rotation of servo3
    if strcmp(direction,'left')
        writePosition(servo3,0.40)
    elseif strcmp(direction,'right')
        writePosition(servo3,0.60)
    end
    
    % Joystick initial state
    baselineVoltage = readVoltage(arduinoBoard,'A0');       % reads voltage from joystick
    
    % Loop for evaluating turning direction
    while isempty(conditional)
        
        % Reading joystick state
        joystickVoltage = readVoltage(arduinoBoard,'A0');
        
        % Has a decision been made?
        if decisionMade == 0
            if joystickVoltage < baselineVoltage - voltageThreshold || joystickVoltage > baselineVoltage + voltageThreshold
                % Decision made
                decisionMade = 1;
                % Sensor initial states
                b0 = readDigitalPin(arduinoBoard,'A2');
                b1 = readDigitalPin(arduinoBoard,'A3');
            end
        end
        
        % Stop rotation condition
        if decisionMade == 1
            % Reading sensor states
            a0 = readDigitalPin(arduinoBoard,'A2');
            a1 = readDigitalPin(arduinoBoard,'A3');
            % Evaluation of turning direction
            if a0~=b0
                if a0==b1
                    previousMovement = currentMovement;
                    currentMovement = 'left';
                    change = 1;
                    disp('     left')
                elseif a0~=b1
                    previousMovement = currentMovement;
                    currentMovement = 'right';
                    change = 1;
                    disp('     right')
                end
            elseif a1~=b1
                if a1==b0
                    previousMovement = currentMovement;
                    currentMovement = 'right';
                    change = 1;
                    disp('     right')
                elseif a1~=b0
                    previousMovement = currentMovement;
                    currentMovement = 'left';
                    change = 1;
                    disp('     left')
                end
            end
            if strcmp(currentMovement,direction) && strcmp(previousMovement,currentMovement) && change==1
                counter = counter + 1;
            end
            % A change in movement occured
            change = 0;
            % Condition to stop rotation
            if counter==2
                writePosition(servo3,0.5)
                writePosition(servo1,0.08), writePosition(servo2,0.98)
                pause(0.1)
                conditional = 1;
            end
            % Get previous state of sensors
            b0 = a0; b1 = a1;
        end
        
    end

