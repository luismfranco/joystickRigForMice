function [vr] = initializeAlternationTMaze(vr)
    
% Initial values for subfields in the 'vr' structure array
    
    % Load properties
    settingsRootDir = [pwd,'\TemporaryData\'];
    if exist([settingsRootDir,'currentSettings','.mat'],'file') > 0
        load([settingsRootDir,'currentSettings','.mat'])
    else
        propertyNames = {'Duration','Rig','Reward','FreeDecisions','Servo1Lim','Servo2Lim','Imaging','Notification'};
        propertyValues = {600,0,10,0,[1 0.7],[0 0.3],'off','off'};
    end
    vr.propertyNames = propertyNames;
    vr.propertyValues = propertyValues;
    vr.servoLimits = [vr.propertyValues{5}; vr.propertyValues{6}];
    valveCalibrationRootDir = 'C:\Users\Goard Lab\Documents\MATLAB\Luis\';
    if exist([valveCalibrationRootDir,'valveCalibration\rig',num2str(vr.propertyValues{2}),'.mat'],'file') > 0
        load([valveCalibrationRootDir,'valveCalibration\rig',num2str(vr.propertyValues{2}),'.mat'])
        rewardTime = ((vr.propertyValues{3}-calibrationCurve(2))/calibrationCurve(1))/1000;
    else
        rewardTime = vr.propertyValues{3}/66.6667; %  equal to 0.150 ms
    end
    
    % Initializes communication with the arduino board
    vr.arduinoBoard = arduino('com3','uno','Libraries',{'RotaryEncoder','Servo'});                      % arduino object
    configurePin(vr.arduinoBoard,'A1','DigitalOutput')                                                  % solenoid valve
    vr.rotaryJoystick = rotaryEncoder(vr.arduinoBoard,'D2','D3',2000);                                  % rotary encoder                                                                     % threshold for decision
        % threshold for decision
        if     vr.propertyValues{2} == 0
            vr.countsThreshold = 50;
        elseif vr.propertyValues{2} == 1
            vr.countsThreshold = 40;
        elseif vr.propertyValues{2} == 2
            vr.countsThreshold = 30;
        elseif vr.propertyValues{2} == 3
            vr.countsThreshold = 30;
        elseif vr.propertyValues{2} == 4
            vr.countsThreshold = 30;
        elseif vr.propertyValues{2} == 20
            vr.countsThreshold = 50; 
        end
    
    configurePin(vr.arduinoBoard,'A4','DigitalOutput')                                                  % lickometer pulse
    configurePin(vr.arduinoBoard,'A5','AnalogInput')                                                    % lickometer readout
    writeDigitalPin(vr.arduinoBoard,'A4',1)                                                             % activate lickometer pulse
    vr.servoLock1 = servo(vr.arduinoBoard,'D10','MinPulseDuration',0.001,'MaxPulseDuration',0.002);     % servo lock 1
    vr.servoLock2 = servo(vr.arduinoBoard,'D11','MinPulseDuration',0.001,'MaxPulseDuration',0.002);     % servo lock 2
    writePosition(vr.servoLock1,vr.servoLimits(1,1));                                                   % close servo lock
    writePosition(vr.servoLock2,vr.servoLimits(2,1));                                                   % close servo lock

    % Session performance
    vr.totalTrials = 0;
    vr.correctTrials = 0;
    vr.errorTrials = 0;
    vr.detailedCorrectErrorTrials = [];
    vr.decision = [];
    vr.decisionDelay = [];
    vr.decisionPointArrivalTime = [];
    vr.trialStartTime = [];
    vr.trialEndTime = [];
    
    % Trial performance
    vr.trialDecision = NaN;
    vr.trialDecisionDelay = NaN;
    vr.trialDecisionPointArrivalTime = NaN;
    
    % Maze
    vr.mazeContext = [];
    vr.sisterMaze = [];
    vr.repeatedMazes = 3;
    hallwayLength = str2double(vr.exper.variables.hallwayLength);
    hallwayWidth = str2double(vr.exper.variables.hallwayWidth);
    if strcmpi(vr.mazeType,'AlternationTMaze')
        vr.axisDisplacement = [2 2];
        vr.decisionPointCoordinates = [560 1.2*hallwayLength;0 1.2*hallwayLength];
        vr.randomStartPosition = [560 5 str2double(vr.exper.variables.wallHeight)*0.25 0; 0 5 str2double(vr.exper.variables.wallHeight)*0.25 0];
        vr.trialSisterMaze = 0;
    end
        % Initial forward movement
        vr.forwardSpeed = 50;
        vr.angularSpeed = 0;
        % Random start position
        vr.mazeProbability = rand(1) >= 0.5;
        if vr.mazeProbability==0
            vr.position = vr.randomStartPosition(1,:);
            vr.viewAngle = 0;
            vr.xSpeed = 0;
            vr.ySpeed = vr.forwardSpeed;
            vr.trialMazeContext = 0;
        elseif vr.mazeProbability==1
            vr.position = vr.randomStartPosition(2,:);
            vr.viewAngle = 0;
            vr.xSpeed = 0;
            vr.ySpeed = vr.forwardSpeed;
            vr.trialMazeContext = 1;
        end

    % Decision
    vr.askForDecision = 1;
    vr.evaluateDecision = 0; 
    vr.lastDecision = NaN;
    vr.decisionPointCornerDistance = hallwayWidth/2;
    vr.decisionPointArrival = 0;
    vr.decisionTimeStart = 0;
    vr.timeThresholdForDecision = 2;
    vr.freeDecisions = vr.propertyValues{4};
    vr.freeDecisionProbability = rand(1);
    vr.trialFreeDecisions = [];
    
    % Turning
    vr.turnForwardMovement = 0;
    vr.turnSpinMovement = 0;
    vr.spinTime = 0;
    vr.spinSpeed = 2;
    
    % Reward
    vr.rewardTime = rewardTime;
    vr.solenoidValve = 0;
    vr.spoutTouch = [];
    vr.spoutTouchTime = [];
    vr.trialSpoutTouch = [];
    
    % Time out
    vr.correctDecisionTimeOut = 3;
    vr.wrongDecisionTimeOut = 6;
    
    % Restart trial
    vr.restartTrial = 0;
    
    % Sound
    fs = 10000; freq = 5000;
    t = 0:1/fs:   1-(1/fs); x1 = cos(2*pi*freq*t);                                      % correct trial
    t = 0:1/fs:0.25-(1/fs); x2 = cos(2*pi*freq*t);                                      % correct decision
    fs = 10000; freq = 10000;
    t = 0:1/fs:   2-(1/fs); y1 = sin(2*pi*freq*t); noise1 = rand(1,length(y1))*2-1;     % wrong trial
    t = 0:1/fs:0.25-(1/fs); y2 = sin(2*pi*freq*t); noise2 = rand(1,length(y2))*2-1;     % wrong decision
    vr.fs = fs;
    vr.correctTrialSound = x1;
    vr.wrongTrialSound = y1+noise1;
    vr.correctDecisionSound = x2;
    vr.wrongDecisionSound = y2+noise2;
    clear('fs','freq','t','x1','x2','y1','y2','noise1','noise2')

    % Start imaging
    if vr.propertyValues{2} == 20
        if strcmpi(vr.propertyValues{7},'on')
            vr.s = daq.createSession('ni');
            addAnalogOutputChannel(vr.s,'Dev2',0,'Voltage');
            outputSingleScan(vr.s,5);
            vr.imagingStartTime = vr.timeElapsed;
        end
    end
    
    % First trial start
    vr.trialStartTime = vr.timeElapsed;
    
    