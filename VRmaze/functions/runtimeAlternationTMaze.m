function [vr] = runtimeAlternationTMaze(vr)

% Evaluates whether to move forward, to wait for a decision, to turn after a decision is made or to finalize and restart trial
    
    % Lickometer
    vr.trialSpoutTouch = cat(1,vr.trialSpoutTouch,abs(readDigitalPin(vr.arduinoBoard,'A5')-1));

    % Decision
    if vr.askForDecision > 0 && vr.turnForwardMovement == 0 && vr.turnSpinMovement == 0 && vr.evaluateDecision == 0
        % When moving north or east (+x or +y)
        if vr.viewAngle == 0 || vr.viewAngle == (3/2)*pi
            vr.stopConditional = 1;
        % When moving west or south (-x or -y)
        elseif vr.viewAngle == (1/2)*pi || vr.viewAngle == pi
            vr.stopConditional = -1;
        end
        if vr.stopConditional*vr.position(vr.axisDisplacement(vr.trialMazeContext+1)) > abs(vr.decisionPointCoordinates(vr.trialMazeContext+1,vr.axisDisplacement(vr.trialMazeContext+1)))-vr.decisionPointCornerDistance
            % Time spent at corners before making a decision
            if vr.decisionPointArrival == 0
                % Stop and wait for a decision to be made
                    % Wrong decision blocked for first maze and probability for free decisions in sister maze
                    if vr.trialMazeContext == 0
                        writePosition(vr.servoLock1,vr.servoLimits(1,2));           % open servo lock 1
                        if vr.trialSisterMaze == 1 && vr.freeDecisionProbability <= vr.freeDecisions
                            writePosition(vr.servoLock2,vr.servoLimits(2,2));       % open servo lock 2
                            vr.trialFreeDecisions = cat(1,vr.trialFreeDecisions,1);
                        elseif vr.trialSisterMaze == 0 || vr.freeDecisionProbability > vr.freeDecisions
                            writePosition(vr.servoLock2,vr.servoLimits(2,1));       % close servo lock 2
                            vr.trialFreeDecisions = cat(1,vr.trialFreeDecisions,0);
                        end
                    elseif vr.trialMazeContext == 1
                        if vr.trialSisterMaze == 1 && vr.freeDecisionProbability <= vr.freeDecisions
                            writePosition(vr.servoLock1,vr.servoLimits(1,2));       % open servo lock 1
                            vr.trialFreeDecisions = cat(1,vr.trialFreeDecisions,1);
                        elseif vr.trialSisterMaze == 0 || vr.freeDecisionProbability > vr.freeDecisions
                            writePosition(vr.servoLock1,vr.servoLimits(1,1));       % close servo lock 1
                            vr.trialFreeDecisions = cat(1,vr.trialFreeDecisions,0);
                        end
                        writePosition(vr.servoLock2,vr.servoLimits(2,2));           % open servo lock 2
                    end
                vr.xSpeed = 0;
                vr.ySpeed = 0;
                vr.decisionTimeStart = vr.timeElapsed;
                vr.trialDecisionPointArrivalTime = vr.timeElapsed;
                vr.lastDecision = NaN;
                vr.decisionPointArrival = 1;
                resetCount(vr.rotaryJoystick)
            elseif vr.decisionPointArrival == 1
                % Time window for making a decision
                if vr.timeElapsed - vr.decisionTimeStart > vr.timeThresholdForDecision
                    % Failed to make a decision (restart trial)
                    sound(vr.wrongTrialSound,vr.fs);
                    writePosition(vr.servoLock1,vr.servoLimits(1,1));       % close servo lock 1
                    writePosition(vr.servoLock2,vr.servoLimits(2,1));     	% close servo lock 2
                    vr.position(3) = 1000;
                    vr.trialTimeOut = vr.wrongDecisionTimeOut;
                    vr.timeOutStart = vr.timeElapsed;
                    vr.askForDecision = 0;
                    vr.decisionPointArrival = 0;
                    vr.detailedCorrectErrorTrials = cat(1,vr.detailedCorrectErrorTrials,0);
                    vr.restartTrial = 1;
                else
                    % Continue waiting otherwise
                end
                % Read from rotary encoder sensors
                [c,~] = readCount(vr.rotaryJoystick);
                % Evaluation of turning direction
                if c > vr.countsThreshold
                    vr.lastDecision = 0;    % left
                elseif c < -vr.countsThreshold
                    vr.lastDecision = 1;    % right
                end
                % Read decision from keyboard
                decisionKeyboard = vr.keyPressed;
                % Evaluation of keyboard decision
                if decisionKeyboard == 65
                    vr.lastDecision = 0;    % left
                elseif decisionKeyboard == 68
                    vr.lastDecision = 1;    % right
                end
            end
            % Resume moving forward after a decision is made
            if ~isnan(vr.lastDecision)
                vr.trialDecision = vr.lastDecision;
                vr.trialDecisionDelay = vr.timeElapsed-vr.trialDecisionPointArrivalTime;
                vr.askForDecision = vr.askForDecision - 1;
                % Move on maze arm only after a correct decision on first maze or after any decision on sister maze
                if vr.trialMazeContext ~= vr.lastDecision && vr.trialSisterMaze == 0
                    % Wrong decision on first maze (restart trial)
                    sound(vr.wrongTrialSound,vr.fs);
                    writePosition(vr.servoLock1,vr.servoLimits(1,1));       % close servo lock 1
                    writePosition(vr.servoLock2,vr.servoLimits(2,1));     	% close servo lock 2
                    vr.position(3) = 1000;
                    vr.trialTimeOut = vr.wrongDecisionTimeOut;
                    vr.timeOutStart = vr.timeElapsed;
                    vr.askForDecision = 0;
                    vr.decisionPointArrival = 0;
                    vr.detailedCorrectErrorTrials = cat(1,vr.detailedCorrectErrorTrials,0);
                    vr.restartTrial = 1;
                else
                    % Sound feedback after decision is made
                    if vr.trialMazeContext == vr.lastDecision
                        sound(vr.correctDecisionSound,vr.fs);
                    elseif vr.trialMazeContext ~= vr.lastDecision
                        sound(vr.wrongDecisionSound,vr.fs);
                    end
                    % Continue moving on maze arm
                    vr.turnForwardMovement = 1;
                    vr.startTurnTime = vr.timeElapsed;
                    if vr.axisDisplacement(vr.trialMazeContext+1) == 1
                        if vr.viewAngle  == (1/2)*pi
                            vr.xSpeed = -vr.forwardSpeed;
                            vr.ySpeed = 0;
                        elseif vr.viewAngle  == (3/2)*pi
                            vr.xSpeed = vr.forwardSpeed;
                            vr.ySpeed = 0;
                        end
                    elseif vr.axisDisplacement(vr.trialMazeContext+1) == 2
                        if vr.viewAngle  == 0
                            vr.xSpeed = 0;
                            vr.ySpeed = vr.forwardSpeed;
                        elseif vr.viewAngle  == pi
                            vr.xSpeed = 0;
                            vr.ySpeed = -vr.forwardSpeed;
                        end
                    end
                end
            end
        else
            % Continue moving forward otherwise
        end
    end
    
    % Turn
        % Initial forward movement after a decision is made and before spinning 90° degrees (or (1/2)*pi)
        if vr.turnForwardMovement == 1
            if vr.timeElapsed-vr.startTurnTime > (vr.decisionPointCornerDistance+(1/2)*str2double(vr.exper.variables.hallwayWidth))/vr.forwardSpeed
                vr.xSpeed = 0;
                vr.ySpeed = 0;
                vr.turnSpinMovement = 1;
                vr.spinTime = vr.timeElapsed;
                vr.turnForwardMovement = 0;
                if vr.lastDecision == 0         % turn left
                    vr.viewAngle = vr.viewAngle + (1/2)*pi;
                    vr.angularSpeed = vr.spinSpeed;
                elseif vr.lastDecision == 1     % turn right
                    vr.viewAngle = vr.viewAngle + (3/2)*pi;
                    vr.angularSpeed = -vr.spinSpeed;
                end
                if vr.viewAngle >= 2*pi
                    vr.viewAngle = vr.viewAngle - 2*pi;
                end
            else
                % Continue moving forward otherwise
            end
        end
        % Subsequent 90° degrees (or (1/2)*pi) spinning movement
        if vr.turnSpinMovement == 1
            if vr.timeElapsed-vr.spinTime > (1/2)*pi/vr.spinSpeed   
                if vr.viewAngle  == 0
                    vr.xSpeed = 0;
                    vr.ySpeed = vr.forwardSpeed;
                elseif vr.viewAngle  == (1/2)*pi
                    vr.xSpeed = -vr.forwardSpeed;
                    vr.ySpeed = 0;
                elseif vr.viewAngle  == pi
                    vr.xSpeed = 0;
                    vr.ySpeed = -vr.forwardSpeed;
                elseif vr.viewAngle  == (3/2)*pi
                    vr.xSpeed = vr.forwardSpeed;
                    vr.ySpeed = 0;
                end
                vr.angularSpeed = 0;
                vr.turnSpinMovement = 0;
                vr.decisionPointArrival = 0;
                writePosition(vr.servoLock1,vr.servoLimits(1,1));         % close servo lock 1
                writePosition(vr.servoLock2,vr.servoLimits(2,1));         % close servo lock 2
                vr.evaluateDecision = 1;
                vr.timeToArmEnd = vr.timeElapsed;
            end
        end
    
    % Evaluation of last decision
    if vr.evaluateDecision == 1
        % Correct decision
        if vr.trialMazeContext == vr.lastDecision
            if vr.askForDecision == 0
                if vr.timeElapsed-vr.timeToArmEnd > 0.7*str2double(vr.exper.variables.hallwayLength)/vr.forwardSpeed
                    % Reward
                    vr.xSpeed = 0;
                    vr.ySpeed = 0;
                    vr.timeOutStart = vr.timeElapsed;
                    vr.trialTimeOut = vr.correctDecisionTimeOut;
                    sound(vr.correctTrialSound,vr.fs);
                    writeDigitalPin(vr.arduinoBoard,'A1',1)    % solenoid valve opens
                    vr.solenoidValve = 1;                    
                    vr.decisionPointArrival = 0;
                    vr.detailedCorrectErrorTrials = cat(1,vr.detailedCorrectErrorTrials,1);
                    vr.evaluateDecision = 0;
                    vr.restartTrial = 1;
                end
            else
                % Continue navigating otherwise
                vr.evaluateDecision = 0;
                vr.lastDecision = NaN;
            end
        end
        % Wrong decision
        if vr.trialMazeContext ~= vr.lastDecision
            if vr.timeElapsed-vr.timeToArmEnd > 0.7*str2double(vr.exper.variables.hallwayLength)/vr.forwardSpeed
                % Restart trial
                vr.xSpeed = 0;
                vr.ySpeed = 0;
                vr.position(3) = 1000;
                vr.timeOutStart = vr.timeElapsed;
                vr.trialTimeOut = vr.wrongDecisionTimeOut;
                sound(vr.wrongTrialSound,vr.fs);
                vr.decisionPointArrival = 0;
                vr.detailedCorrectErrorTrials = cat(1,vr.detailedCorrectErrorTrials,0);
                vr.evaluateDecision = 0;
                vr.restartTrial = 1;
            end
        end
    end
        
    % Restart trial
    if vr.restartTrial == 1
        if vr.solenoidValve == 1
            if vr.timeElapsed-vr.timeOutStart > vr.rewardTime
                writeDigitalPin(vr.arduinoBoard,'A1',0)    % solenoid valve closes
                vr.solenoidValve = 0;
            end
        end        
        % Wait until time out is completed before restarting trial
        if vr.timeElapsed-vr.timeOutStart > vr.trialTimeOut
            % Trial end time
            vr.trialEndTime = cat(1,vr.trialEndTime,vr.timeElapsed);
            % Concatenate stats
            vr.decision = cat(1,vr.decision,vr.trialDecision);
            vr.trialDecision = NaN;
            vr.decisionDelay = cat(1,vr.decisionDelay,vr.trialDecisionDelay);
            vr.trialDecisionDelay = NaN;
            vr.decisionPointArrivalTime = cat(1,vr.decisionPointArrivalTime,vr.trialDecisionPointArrivalTime);
            vr.trialDecisionPointArrivalTime = NaN;
            % Concatenate lickometer
            if isempty(vr.spoutTouch)
                vr.spoutTouch = vr.trialSpoutTouch;
            else
                x = max([size(vr.spoutTouch,1) size(vr.trialSpoutTouch,1)]);
                x = NaN(x,size(vr.spoutTouch,2)+1);
                x(1:size(vr.spoutTouch,1),1:size(vr.spoutTouch,2)) = vr.spoutTouch;
                x(1:size(vr.trialSpoutTouch,1),end) = vr.trialSpoutTouch;
                vr.spoutTouch = x;
            end
            vr.spoutTouchTime = cat(1,vr.spoutTouchTime,(vr.trialEndTime(end)-vr.trialStartTime(end))*(length(vr.trialSpoutTouch(vr.trialSpoutTouch==1))/length(vr.trialSpoutTouch)));
            vr.trialSpoutTouch = [];
            % Maze
            vr.mazeContext = cat(1,vr.mazeContext,vr.trialMazeContext);
            vr.sisterMaze = cat(1,vr.sisterMaze,vr.trialSisterMaze);
            % Trial end
            vr.totalTrials = vr.totalTrials + 1;
            % Trial start
            vr.restartTrial = 0;
            % Random selection of maze
            if vr.detailedCorrectErrorTrials(end)==0 || vr.trialSisterMaze == 1
                % First maze
                vr.randomStartPosition = [560 5 str2double(vr.exper.variables.wallHeight)*0.25 0;   0 5 str2double(vr.exper.variables.wallHeight)*0.25 0]; 
                vr.trialSisterMaze = 0;
                if size(vr.mazeContext,1) < 2*vr.repeatedMazes
                    vr.mazeProbability = rand(1) >= 0.5;
                elseif size(vr.mazeContext,1) >= 2*vr.repeatedMazes
                    if vr.mazeContext(end) == 0
                        if vr.mazeContext(end-2) == 0
                            if vr.mazeContext(end-4) == 0                   % L L L
                                vr.mazeProbability = rand(1) >= 0;
                            elseif vr.mazeContext(end-2) == 1
                                vr.mazeProbability = rand(1) >= 0.25;       % R L L
                            end
                        elseif vr.mazeContext(end-2) == 1   
                            if vr.mazeContext(end-4) == 0                   % L R L
                                vr.mazeProbability = rand(1) >= 0.375;
                            elseif vr.mazeContext(end-4) == 1               % R R L
                                vr.mazeProbability = rand(1) >= 0.5;
                            end
                        end
                    elseif vr.mazeContext(end) == 1
                        if vr.mazeContext(end-2) == 1           
                            if vr.mazeContext(end-4) == 1                   % R R R
                                vr.mazeProbability = rand(1) > 1;
                            elseif vr.mazeContext(end-4) == 0
                                vr.mazeProbability = rand(1) >= 0.75;       % L R R
                            end
                        elseif vr.mazeContext(end-2) == 0
                            if vr.mazeContext(end-4) == 1                   % R L R
                                vr.mazeProbability = rand(1) >= 0.625;
                            elseif vr.mazeContext(end-4) == 0
                                vr.mazeProbability = rand(1) >= 0.5;        % L L R
                            end
                        end
                    end
                end
                % Selection of random maze
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
            elseif vr.detailedCorrectErrorTrials(end)==1 && vr.trialSisterMaze==0
                % Sister maze
                vr.randomStartPosition = [840 5 str2double(vr.exper.variables.wallHeight)*0.25 0; 280 5 str2double(vr.exper.variables.wallHeight)*0.25 0];
                vr.trialSisterMaze = 1;
                if vr.trialMazeContext(end) == 0
                    vr.position = vr.randomStartPosition(1,:);
                    vr.viewAngle = 0;
                    vr.xSpeed = 0;
                    vr.ySpeed = vr.forwardSpeed;
                    vr.trialMazeContext = 1;
                elseif vr.trialMazeContext(end) == 1
                    vr.position = vr.randomStartPosition(2,:);
                    vr.viewAngle = 0;
                    vr.xSpeed = 0;
                    vr.ySpeed = vr.forwardSpeed;
                    vr.trialMazeContext = 0;
                end
            end
            vr.askForDecision = 1;
            vr.lastDecision = NaN;
            vr.trialStartTime = cat(1,vr.trialStartTime,vr.timeElapsed);
            % Open both servos
            vr.freeDecisionProbability = rand(1);
        end
    end

    % End of session
    if vr.timeElapsed > vr.propertyValues{1}
        vr.experimentEnded = 1;
    end
    
    