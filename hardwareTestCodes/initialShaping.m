function initialShaping(mouseName,duration)

% Settings
movement = 0;
countsThreshold = 100;
responseWindow = 4;
pauseAfterDecision = 1;
setInterval = 4;
trialInterval = 1;
rewardTime = 0.05;
detailedDecisions = [];
experimentRootDir = 'C:\Users\franco\Documents\MATLAB\UCSB\Behavior\Virtual Maze\Experiments\';   % For testing in Lab PC only

% Initialize arduino 
arduinoBoard = arduino('com5','uno','Libraries',{'RotaryEncoder','Servo'});         % arduino object
configurePin(arduinoBoard,'A1','DigitalOutput')                                     % solenoid valve
rotaryJoystick = rotaryEncoder(arduinoBoard,'D2','D3',2000);                        % rotary encoder
servoLock1 = servo(arduinoBoard,'D10');                                             % servo lock 1
servoLock2 = servo(arduinoBoard,'D11');                                             % servo lock 2
configurePin(arduinoBoard,'A4','DigitalOutput')                                     % lickometer pulse
configurePin(arduinoBoard,'A5','AnalogInput')                                       % lickometer read
writePosition(servoLock1,1);                                                        % close servo lock 1
writePosition(servoLock2,0);                                                        % close servo lock 2
writeDigitalPin(arduinoBoard,'A4',1)                                                % activate lickometer pulse

% Sound
fs = 12000; freq = 5000;
t = 0:0.1/fs:0.1-(1/fs); x1 = cos(2*pi*freq*t);                                      % start trial
t = 0:0.1/fs:0.1-(1/fs); x2 = sin(2*pi*freq*t);                                      % start trial
t = 0:  1/fs:0.1-(1/fs); y1 = cos(2*pi*freq*t);                                      % correct decision
t = 0:  1/fs:0.1-(1/fs); y2 = cos(2*pi*freq*t); noise2 = rand(1,length(y2))*2-1;     % wrong decision
startLeftTrialSound = x1;
startRightTrialSound = x2;
correctDecisionSound = y1;
wrongDecisionSound = y2+noise2;
clear('freq','t','x1','x2','y1','y2','noise2')
    
    
%% Task

sessionStartTime = clock;
while etime(clock,sessionStartTime) < duration
    % Start trial
    if movement == 0
        sound(startLeftTrialSound,fs);
        pause(1)
    elseif movement == 1
        sound(startRightTrialSound,fs);
        pause(1)
    end
    for i=1:5
        % Open servos
        if movement == 0
            writePosition(servoLock1,1);         % open servo lock 1
            writePosition(servoLock2,0.20);      % open servo lock 2
        elseif movement == 1
            writePosition(servoLock1,0.80);      % open servo lock 1
            writePosition(servoLock2,0   );      % open servo lock 2
        end
        % start time
        trialStartTime = clock;
        resetCount(rotaryJoystick)              % rotary encoder initial state
        trialDecision = [];
        while etime(clock,trialStartTime) < responseWindow && isempty(trialDecision)
            % Read from rotary encoder
            [c,~] = readCount(rotaryJoystick);
            % Evaluation of turning direction
            if c > countsThreshold
                trialDecision = 1;    % right
                disp('     right')
            elseif c < -countsThreshold
                trialDecision = 0;    % left
                disp('     left')
            end
        end
        % Sound
        if trialDecision == movement
            detailedDecisions = cat(1,detailedDecisions,trialDecision);
            sound(correctDecisionSound,fs);
            % Reward
            writeDigitalPin(arduinoBoard,'A1',1)    % solenoid valve opens
            pause(rewardTime)
            writeDigitalPin(arduinoBoard,'A1',0)    % solenoid valve closes
        elseif isempty(trialDecision)
            detailedDecisions = cat(1,detailedDecisions,NaN(1,1));
            sound(wrongDecisionSound,fs);
        elseif trialDecision ~= movement
            detailedDecisions = cat(1,detailedDecisions,trialDecision);
            sound(wrongDecisionSound,fs);
        end
        % Close servos
        pause(pauseAfterDecision)
        writePosition(servoLock1,1);                                 % close servo lock 1
        writePosition(servoLock2,0);                                 % close servo lock 2
        % Pause
        pause(trialInterval)
    end
    % change joytisck rotation
    movement = abs(movement-1);
    pause(setInterval)
end

% Open servos
writePosition(servoLock1,0.80);                                 % close servo lock 1
writePosition(servoLock2,0.20);                                 % close servo lock 2


%% Save data

behaviorData.mouseName = mouseName;
behaviorData.maze = 'initialShaping';
behaviorData.detailedDecisions = detailedDecisions;

% Make sure there is a folder
if exist([experimentRootDir,datestr(date,'yymmdd')],'dir') == 0
    mkdir(experimentRootDir,datestr(date,'yymmdd'))
end
% Save
save([experimentRootDir,datestr(date,'yymmdd'),'\',behaviorData.mouseName,'.mat'],'behaviorData');


