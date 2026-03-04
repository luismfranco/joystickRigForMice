function [vr] = runtimeMaze(vr)

% Evaluates whether to move forward, to wait for a decision, to turn after a decision is made or to finalize and restart trial
    
    % Lickometer
    vr.trialSpoutTouch = cat(1,vr.trialSpoutTouch,abs(readDigitalPin(vr.arduinoBoard,'A5')-1));

    % Decision
    if vr.askForDecision > 0 && vr.turnSpinMovement == 0 && vr.evaluateDecision == 0
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
                    % To allow only correct decisions to be made
                    if vr.trialMazeContext == 0
                        writePosition(vr.servoLock1,vr.servoLimits(1,2));           % open servo lock 1
                        if vr.freeDecisionProbability <= vr.freeDecisions
                            writePosition(vr.servoLock2,vr.servoLimits(2,2));       % open servo lock 2
                            vr.trialFreeDecisions = cat(1,vr.trialFreeDecisions,1);
                        else
                            writePosition(vr.servoLock2,vr.servoLimits(2,1));       % close servo lock 2
                            vr.trialFreeDecisions = cat(1,vr.trialFreeDecisions,0);
                        end
                    elseif vr.trialMazeContext == 1
                        if vr.freeDecisionProbability <= vr.freeDecisions
                            writePosition(vr.servoLock1,vr.servoLimits(1,2));       % open servo lock 1
                            vr.trialFreeDecisions = cat(1,vr.trialFreeDecisions,1);
                        else
                            writePosition(vr.servoLock1,vr.servoLimits(1,1));       % close servo lock 1
                            vr.trialFreeDecisions = cat(1,vr.trialFreeDecisions,0);
                        end
                        writePosition(vr.servoLock2,vr.servoLimits(2,2));           % open servo lock 2
                    end
                vr.xSpeed = 0;
                vr.ySpeed = 0;
                vr.decisionTimeStart = vr.timeElapsed;
                vr.trialDecisionPointArrivalTime = vr.timeElapsed;
                vr.lastDecision = [];
                vr.decisionPointArrival = 1;
                resetCount(vr.rotaryJoystick)
                vr.trialDecisionTrajectory = cat(1,vr.trialDecisionTrajectory,0);
            elseif vr.decisionPointArrival == 1
                % Time window for making a decision
                if isempty(vr.lastDecision) && vr.timeElapsed - vr.decisionTimeStart > vr.timeThresholdForDecision
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
                vr.trialDecisionTrajectory = cat(1,vr.trialDecisionTrajectory,c);
                % Rotating view angle
                a = vr.position(4) + ((vr.trialDecisionTrajectory(end)-vr.trialDecisionTrajectory(end-1))*((1/4)*pi/vr.countsThreshold));
                if a < 0
                    a = a + 2*pi;
                elseif a >= 2*pi
                    a = a - 2*pi;
                end
                vr.position(4) = a;
                % Evaluation of turning direction
                if vr.position(4) >= vr.viewAngle+(1/4)*pi && vr.position(4)< vr.viewAngle+(1/2)*pi
                    vr.lastDecision = 0;    % left
                elseif vr.position(4) <= vr.viewAngle+(7/4)*pi && vr.position(4) > vr.viewAngle+(3/2)*pi
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
            % Decision
            if ~isempty(vr.lastDecision)
                vr.trialDecision = vr.lastDecision;
                % Sound feedback after decision is made
                if vr.trialMazeContext == vr.lastDecision
                    sound(vr.correctDecisionSound,vr.fs);
                    vr.trialDecisionPointLeavingTime = vr.timeElapsed;
                    vr.askForDecision = vr.askForDecision - 1;
                    vr.decisionPointArrival = 0;
                    vr.armPositionAtDecision = vr.position(vr.axisDisplacement(vr.trialMazeContext+1));
                    vr.viewAngleAtDecision = vr.position(4);
                    vr.turnSpinMovement = 1;
                    vr.startTurnTime = vr.timeElapsed;
                elseif vr.trialMazeContext ~= vr.lastDecision && vr.timeElapsed - vr.decisionTimeStart > vr.timeThresholdForDecision
                    sound(vr.wrongDecisionSound,vr.fs);
                    vr.trialDecisionPointLeavingTime = vr.timeElapsed;
                    vr.askForDecision = vr.askForDecision - 1;
                    vr.decisionPointArrival = 0;
                    vr.armPositionAtDecision = vr.position(vr.axisDisplacement(vr.trialMazeContext+1));
                    vr.viewAngleAtDecision = vr.position(4);
                    vr.turnSpinMovement = 1;
                    vr.startTurnTime = vr.timeElapsed;
                end
                if vr.decisionCondition==1
                    vr.trialDecisionDelay = vr.timeElapsed-vr.trialDecisionPointArrivalTime;
                    vr.decisionCondition = 0;
                end
            end
        else
            % Continue moving forward otherwise
        end
    end
    
    % Turn
    if vr.turnSpinMovement==1
        if vr.timeElapsed-vr.startTurnTime <= vr.turnTime
            vr.position(vr.axisDisplacement(vr.trialMazeContext+1)) = vr.armPositionAtDecision + ((vr.timeElapsed-vr.startTurnTime)/vr.turnTime * str2double(vr.exper.variables.hallwayWidth));
            if vr.lastDecision==0
                vr.position(4) = vr.viewAngleAtDecision + (((1/2)*pi - vr.viewAngleAtDecision)*((vr.timeElapsed-vr.startTurnTime)/vr.turnTime));
            elseif vr.lastDecision==1
                vr.position(4) = vr.viewAngleAtDecision + (((-1/2)*pi - vr.viewAngleAtDecision)*((vr.timeElapsed-vr.startTurnTime)/vr.turnTime));
            end
        elseif vr.timeElapsed-vr.startTurnTime > vr.turnTime
            % Update view angle
            if vr.lastDecision == 0         % turn left
                vr.viewAngle = vr.viewAngle + (1/2)*pi;
            elseif vr.lastDecision == 1     % turn right
                vr.viewAngle = vr.viewAngle + (3/2)*pi;
            end
            if vr.viewAngle >= 2*pi
                vr.viewAngle = vr.viewAngle - 2*pi;
            end
            % Continue through the maze
            writePosition(vr.servoLock1,vr.servoLimits(1,1));         % close servo lock 1
            writePosition(vr.servoLock2,vr.servoLimits(2,1));         % close servo lock 2
            vr.turnSpinMovement = 0;
            vr.evaluateDecision = 1;
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
            vr.timeToArmEnd = vr.timeElapsed;
        end
    end
    
    % Evaluation of last decision
    if vr.evaluateDecision == 1
        % Correct decision
        if vr.trialMazeContext == vr.lastDecision
            if vr.askForDecision == 0
                if vr.timeElapsed-vr.timeToArmEnd > str2double(vr.exper.variables.hallwayLength)/vr.forwardSpeed
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
                vr.lastDecision = [];
            end
        end
        % Wrong decision
        if vr.trialMazeContext ~= vr.lastDecision
            if vr.timeElapsed-vr.timeToArmEnd > str2double(vr.exper.variables.hallwayLength)/vr.forwardSpeed
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
            vr.decisionPointLeavingTime = cat(1,vr.decisionPointLeavingTime,vr.trialDecisionPointLeavingTime);
            vr.trialDecisionPointArrivalTime = NaN;
            vr.trialDecisionPointLeavingTime = NaN;
            % Concatenate decision trajectory
            if isempty(vr.decisionTrajectory)
                vr.decisionTrajectory = vr.trialDecisionTrajectory;
            else
                x = max([size(vr.decisionTrajectory,1) size(vr.trialDecisionTrajectory,1)]);
                x = NaN(x,size(vr.decisionTrajectory,2)+1);
                x(1:size(vr.decisionTrajectory,1),1:size(vr.decisionTrajectory,2)) = vr.decisionTrajectory;
                x(1:size(vr.trialDecisionTrajectory,1),end) = vr.trialDecisionTrajectory;
                vr.decisionTrajectory = x;
                clear('x')
            end
            vr.trialDecisionTrajectory = [];
            % Concatenate lickometer
            if isempty(vr.spoutTouch)
                vr.spoutTouch = vr.trialSpoutTouch;
            else
                x = max([size(vr.spoutTouch,1) size(vr.trialSpoutTouch,1)]);
                x = NaN(x,size(vr.spoutTouch,2)+1);
                x(1:size(vr.spoutTouch,1),1:size(vr.spoutTouch,2)) = vr.spoutTouch;
                x(1:size(vr.trialSpoutTouch,1),end) = vr.trialSpoutTouch;
                vr.spoutTouch = x;
                clear('x')
            end
            vr.spoutTouchTime = cat(1,vr.spoutTouchTime,(vr.trialEndTime(end)-vr.trialStartTime(end))*(length(vr.trialSpoutTouch(vr.trialSpoutTouch==1))/length(vr.trialSpoutTouch)));
            vr.trialSpoutTouch = [];
            % Maze
            vr.mazeContext = cat(1,vr.mazeContext,vr.trialMazeContext);
            % Trial end
            vr.totalTrials = vr.totalTrials + 1;
            % Trial start
            vr.restartTrial = 0;
            % Random maze threshold
            if size(vr.mazeContext,1) < vr.maximumRepeatedMazes
                vr.mazeProbability = rand(1) >= 0.5;
            elseif size(vr.mazeContext,1) >= vr.maximumRepeatedMazes
                % To avoid long streak of identical mazes
                
                    % Probability for a left maze. It increases with more and more right mazes, and decreases with more and more left mazes
                    vr.mazeProbability = rand(1) >= sum(vr.mazeContext(end-vr.maximumRepeatedMazes+1:end) .* vr.repeatedMazeProbability);

                    % Disable decision bias correction if the number of last consecutive mazes exceeds maximum allowed
                    if length(find(vr.mazeContext(end-vr.maximumRepeatedMazes+1:end) == 0)) == vr.maximumRepeatedMazes
                        vr.mouseBiasCorrection = 0;
                    elseif length(find(vr.mazeContext(end-vr.maximumRepeatedMazes+1:end) == 1)) == vr.maximumRepeatedMazes
                        vr.mouseBiasCorrection = 0;
                    end

                    % Decision bias correction
                    if vr.mouseBiasCorrection == 1 && length(find(~isnan(vr.decision))) > vr.decisionBeforeBiasCorrection
                        if length(find(vr.decision==0))/length(find(vr.decision==1)) < vr.decisionBiasThreshold                     % biased to right
                            vr.mazeProbability = rand(1) > 1;
                            vr.biasedMouse = 1;
                        elseif length(find(vr.decision==0)) > vr.decisionBeforeBiasCorrection && isempty(find(vr.decision==1,1))    % biased to right
                            vr.mazeProbability = rand(1) > 1;
                            vr.biasedMouse = 1;
                        elseif length(find(vr.decision==1))/length(find(vr.decision==0)) < vr.decisionBiasThreshold                 % biased to left
                            vr.mazeProbability = rand(1) >= 0;
                            vr.biasedMouse = 1;
                        elseif length(find(vr.decision==1)) > vr.decisionBeforeBiasCorrection && isempty(find(vr.decision==0,1))    % biased to left
                            vr.mazeProbability = rand(1) >= 0;
                            vr.biasedMouse = 1;
                        end
                    elseif vr.mouseBiasCorrection == 0
                        % Re-enable decision bias correction
                        vr.mouseBiasCorrection = 1;
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
            vr.askForDecision = 1;
            vr.lastDecision = [];
            vr.decisionCondition = 1;
            vr.trialStartTime = cat(1,vr.trialStartTime,vr.timeElapsed);
            % Probability for opening both servos
            vr.freeDecisionProbability = rand(1);
        end
    end

    % End of session
    if vr.timeElapsed > vr.propertyValues{1}
        vr.experimentEnded = 1;
    end
    
    