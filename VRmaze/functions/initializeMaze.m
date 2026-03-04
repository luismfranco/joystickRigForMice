function [vr] = initializeMaze(vr)
    
% Initial values for subfields in the 'vr' structure array
    
    % Load properties
    settingsRootDir = [pwd,'\TemporaryData\'];
    if exist([settingsRootDir,'currentSettings','.mat'],'file') > 0
        load([settingsRootDir,'currentSettings','.mat'])
    else
        propertyNames = {'Duration','Rig','Reward','FreeDecisions','Servo1Lim','Servo2Lim','Imaging','Notification'};
        propertyValues = {600,0,10,0,[1 0.6],[0 0.4],'off','off'};
    end
    vr.propertyNames = propertyNames;
    vr.propertyValues = propertyValues;
    vr.servoLimits = [vr.propertyValues{5}; vr.propertyValues{6}];
    if vr.propertyValues{2} == 10
        valveCalibrationRootDir = 'C:\Users\Widefield-Stimulus\Documents\MATLAB\Luis\';
    else
        valveCalibrationRootDir = 'C:\Users\Goard Lab\Documents\MATLAB\Luis\';
    end
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
        elseif vr.propertyValues{2} == 10
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
    vr.decisionPointLeavingTime = [];
    vr.trialStartTime = [];
    vr.trialEndTime = [];
    
    % Trial performance
    vr.trialDecision = NaN;
    vr.trialDecisionDelay = NaN;
    vr.trialDecisionPointArrivalTime = NaN;
    vr.trialDecisionPointLeavingTime = NaN;
    
    % Maze
    vr.mazeContext = [];
    vr.maximumRepeatedMazes = 8;
    % Bias correction
    x1 = 0.3*(1/vr.maximumRepeatedMazes);
    x2 = 1.5*(1/vr.maximumRepeatedMazes);
    D = (x2-x1)/(vr.maximumRepeatedMazes-1);
    vr.repeatedMazeProbability = x1;
    for i=1:vr.maximumRepeatedMazes-1
        a = vr.repeatedMazeProbability(end) + D;
        vr.repeatedMazeProbability = cat(1,vr.repeatedMazeProbability,a);
        clear('a')
    end
    clear('x1','x2','D')
    hallwayLength = str2double(vr.exper.variables.hallwayLength);
    hallwayWidth = str2double(vr.exper.variables.hallwayWidth);
    if strcmpi(vr.mazeType,'LandR')
        vr.axisDisplacement = [2 2];
        vr.decisionPointCoordinates = [0 2.125*hallwayLength;200 2.125*hallwayLength];
        vr.randomStartPosition = [0 5 str2double(vr.exper.variables.wallHeight)*0.25 0; 200 5 str2double(vr.exper.variables.wallHeight)*0.25 0];    
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
    vr.lastDecision = [];
    vr.decisionPointCornerDistance = hallwayWidth/2;
    vr.decisionPointArrival = 0;
    vr.decisionTimeStart = 0;
    vr.timeThresholdForDecision = 3;
    vr.decisionCondition = 1;
    vr.decisionTrajectory = [];
    vr.trialDecisionTrajectory = [];
    vr.freeDecisions = vr.propertyValues{4};
    vr.freeDecisionProbability = rand(1);
    vr.trialFreeDecisions = [];
    vr.decisionBiasThreshold = 0.5;
    vr.mouseBiasCorrection = 1;
    vr.decisionBeforeBiasCorrection = 5;
    
    % Turning
    vr.turnSpinMovement = 0;
    vr.turnTime = 0.5;
    
    % Reward
    vr.rewardTime = rewardTime;
    vr.solenoidValve = 0;
    vr.spoutTouch = [];
    vr.spoutTouchTime = [];
    vr.trialSpoutTouch = [];
    
    % Time out
    vr.correctDecisionTimeOut = 3;
    vr.wrongDecisionTimeOut = 3;
    
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
    if strcmpi(vr.propertyValues{7},'on')
        % Widefield
        if vr.propertyValues{2} == 10
            vr.s = daq.createSession('ni');
            addAnalogOutputChannel(vr.s,'Dev1',0,'Voltage');
            outputSingleScan(vr.s,0);
            % Acquisition waveform
            oneCycle = cat(2,5*ones([1 75]),zeros([1 25]));
            totalSamples = propertyValues{1}*vr.s.Rate;
            numCycles = ceil(totalSamples/length(oneCycle));
            outputMat = repmat(oneCycle,[1 numCycles+50]);
            queueOutputData(vr.s,outputMat');
            vr.s.startBackground();
            vr.imagingStartTime = vr.timeElapsed;
        end
        % Two-photon
        if vr.propertyValues{2} == 20
            vr.s = daq.createSession('ni');
            addAnalogOutputChannel(vr.s,'Dev2',0,'Voltage');
            outputSingleScan(vr.s,5);
            vr.imagingStartTime = vr.timeElapsed;
        end
    end
    
    % First trial start
    vr.trialStartTime = vr.timeElapsed;
    
    