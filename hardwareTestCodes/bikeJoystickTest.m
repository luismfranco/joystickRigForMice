function bikeJoystickTest
%% Settings

% initialize arduino
arduinoBoard = arduino('com5','uno','Libraries',{'RotaryEncoder','Servo'});

% rotary encoder
rotaryJoystick = rotaryEncoder(arduinoBoard,'D2','D3',2000);

% servo locks
servo1 = servo(arduinoBoard,'D10','MinPulseDuration',0.001,'MaxPulseDuration',0.002);              % servo1
servo2 = servo(arduinoBoard,'D11','MinPulseDuration',0.001,'MaxPulseDuration',0.002);              % servo2

% Open servos
writePosition(servo1,0.50), writePosition(servo2,0.50)

% Initial parameter values
k = 1;
buttonPressed = [];
countsThreshold = 100;

% Sound for feedback on turning direction
fs = 12000; freq = 5000;
t = 0:1/fs:0.5-(1/fs); x = cos(2*pi*freq*t);                                    % right decision
t = 0:1/fs:0.5-(1/fs); y = cos(2*pi*freq*t); noise = rand(1,length(y))*2-1;     % left decision
rightDecisionSound = x;
leftDecisionSound = y+noise;


%% Testing

    % Create figure for real-time plotting of rotary state
    resetCount(rotaryJoystick)
    figure,set(gcf,'position',[150 300 1650 400])
        h = animatedline('Color','b');
        [c,~] = readCount(rotaryJoystick);
            addpoints(h,k,c)
            drawnow
        set(gca,'TickDir','out','Fontsize',10,'Fontweight','b')
        xlabel('bits','Fontsize',12,'Fontweight','b')
        ylabel('output','Fontsize',12,'Fontweight','b')
    
    % Loop for evaluating turning direction
    while isempty(buttonPressed)
        k = k+1;
        % Real-time plotting of rotary state
        [c,~] = readCount(rotaryJoystick);
            addpoints(h,k,c)
            drawnow
        % Evaluation of turning direction
        if c > countsThreshold
            sound(rightDecisionSound,fs);
            disp('     right')
            resetCount(rotaryJoystick)
        elseif c < -countsThreshold
            sound(leftDecisionSound,fs);
            disp('     left')
            resetCount(rotaryJoystick)
        end
        % Condition to stop test
        buttonPressed = get(gcf,'CurrentCharacter');
    end

    
