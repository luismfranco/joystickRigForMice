function bikeJoystickTest

    % initialize arduino
    arduinoBoard = arduino('com3','uno'); configurePin(arduinoBoard,'A2','DigitalInput'), configurePin(arduinoBoard,'A3','DigitalInput')

    % servo lock
    servo1 = servo(arduinoBoard,'D10');              % servo1
    servo2 = servo(arduinoBoard,'D11');              % servo2
    
    % Open servos
    writePosition(servo1,0.25), writePosition(servo2,0.75)
    
    % Initial parameter values
    k = 1;
    counter = 0;
    buttonPressed = [];

%     % Sound for feedback on turning direction
%     fs = 12000; freq = 5000;
%     t = 0:1/fs:0.5-(1/fs); x = cos(2*pi*freq*t);                                    % right decision
%     t = 0:1/fs:0.5-(1/fs); y = cos(2*pi*freq*t); noise = rand(1,length(y))*2-1;     % left decision
%     rightDecisionSound = x;
%     leftDecisionSound = y+noise;

    % Create figure for real-time plotting of sensor states
    figure,set(gcf,'position',[150 300 1650 400])
        h0 = animatedline('Color','b');
        h1 = animatedline('Color','r');
        b0 = readDigitalPin(arduinoBoard,'A2');
        b1 = readDigitalPin(arduinoBoard,'A3');
            addpoints(h0,k,b0)
            drawnow
            addpoints(h1,k,b1)
            drawnow
        set(gca,'TickDir','out','Fontsize',10,'Fontweight','b')
        xlabel('bits','Fontsize',12,'Fontweight','b')
        ylabel('output','Fontsize',12,'Fontweight','b')
    
    % Loop for evaluating turning direction
    while isempty(buttonPressed)
        k = k+1;
        
        % Real-time plotting of sensor states
        a0 = readDigitalPin(arduinoBoard,'A2');
        a1 = readDigitalPin(arduinoBoard,'A3');
            addpoints(h0,k,a0)
            drawnow
            addpoints(h1,k,a1)
            drawnow

        % Evaluation of turning direction
        if a0~=b0
            if a0==b1
                counter = counter+1;
                disp('     right')
            elseif a0~=b1
                counter = counter-1;
                disp('     left')
            end
        elseif a1~=b1
            if a1==b0
                counter = counter-1;
                disp('     left')
            elseif a1~=b0
                counter = counter+1;
                disp('     right')
            end
        end

        % Threshold for decision
        if counter > 0
%             sound(rightDecisionSound,fs);
            counter = 0;
        elseif counter < -0
%             sound(leftDecisionSound,fs);
            counter = 0;
        end

        % Get previous state of sensors
        b0 = a0; b1 = a1;

        % Condition to stop test
        buttonPressed = get(gcf,'CurrentCharacter');

    end

