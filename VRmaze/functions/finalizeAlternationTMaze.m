function [vr] = finalizeAlternationTMaze(vr)

% Finish imaging
if vr.propertyValues{2} == 20
    if strcmpi(vr.propertyValues{7},'on')
        outputSingleScan(vr.s,0);
        vr.imagingEndTime = vr.timeElapsed;
    end
end

% Load properties
settingsRootDir = [pwd,'\TemporaryData\'];
if vr.propertyValues{2} == 0
    experimentRootDir = 'D:\Material\Virtual Maze\Maze Test\';
elseif vr.propertyValues{2} > 0 && vr.propertyValues{2} <= 4
    experimentRootDir = 'C:\Users\Goard Lab\Documents\MATLAB\Raquel\Training\';
elseif vr.propertyValues{2} == 20
    experimentRootDir = 'C:\Users\Goard Lab\Documents\MATLAB\Raquel\2P Behavior\';
end

behaviorData = [];
% Existent mouse
if exist([settingsRootDir,'temporaryFile','.mat'],'file') > 0
    % Load previous stats
    load([settingsRootDir,'temporaryFile','.mat'])
    % Concatenate recent stats
    behaviorData.mazeType = vr.mazeType;
    behaviorData.mazeContext = cat(1,behaviorData.mazeContext,vr.mazeContext(1:vr.totalTrials));
    behaviorData.sisterMaze = cat(1,behaviorData.sisterMaze,vr.sisterMaze(1:vr.totalTrials));
    behaviorData.totalTrials = cat(1,behaviorData.totalTrials,vr.totalTrials);
    x = vr.detailedCorrectErrorTrials(1:vr.totalTrials); vr.correctTrials = length(x(x==1)); vr.errorTrials = length(x(x==0));
    behaviorData.correctTrials = vr.correctTrials;
    behaviorData.errorTrials = vr.errorTrials;
    behaviorData.detailedCorrectErrorTrials = cat(1,behaviorData.detailedCorrectErrorTrials,vr.detailedCorrectErrorTrials(1:vr.totalTrials));
    behaviorData.trialStartTime = cat(1,behaviorData.trialStartTime,vr.trialStartTime(1:vr.totalTrials));
    behaviorData.trialEndTime = cat(1,behaviorData.trialEndTime,vr.trialEndTime(1:vr.totalTrials));
    behaviorData.decision = cat(1,behaviorData.decision,vr.decision(1:vr.totalTrials));
    behaviorData.decisionDelay = cat(1,behaviorData.decisionDelay,vr.decisionDelay(1:vr.totalTrials));
    behaviorData.decisionPointArrivalTime = cat(1,behaviorData.decisionPointArrivalTime,vr.decisionPointArrivalTime(1:vr.totalTrials));
    behaviorData.freeDecisions = cat(1,behaviorData.freeDecisions,vr.trialFreeDecisions(1:vr.totalTrials));
    behaviorData.reward = vr.propertyValues{3};
    behaviorData.estimatedTotalReward = behaviorData.reward*behaviorData.correctTrials/1000;
    x = max([size(behaviorData.spoutTouch,1) size(vr.spoutTouch,1)]);
    x = NaN(x,size(behaviorData.spoutTouch,2)+size(vr.spoutTouch(:,1:vr.totalTrials),2));
    x(1:size(behaviorData.spoutTouch,1),1:size(behaviorData.spoutTouch,2)) = behaviorData.spoutTouch;
    x(1:size(vr.spoutTouch,1),size(behaviorData.spoutTouch,2)+1:end) = vr.spoutTouch(:,1:vr.totalTrials);
    behaviorData.spoutTouch = x;
    behaviorData.spoutTouchTime = cat(1,behaviorData.spoutTouchTime,vr.spoutTouchTime(1:vr.totalTrials));
    % Imaging time stamps
    if vr.propertyValues{2} == 20
        if strcmpi(vr.propertyValues{7},'on')
            behaviorData.imagingTimeStamps = [vr.imagingStartTime vr.imagingEndTime];
        end
    end
    % Save
    save([experimentRootDir,datestr(date,'yymmdd'),'\',behaviorData.mouseName,'.mat'],'behaviorData');
    % Delete temporary file
    delete([settingsRootDir,'temporaryFile','.mat'])
% New mouse
else
    % Make sure there is a folder for the current experiment
    if exist([experimentRootDir,datestr(date,'yymmdd')],'dir') == 0
        mkdir(experimentRootDir,datestr(date,'yymmdd'))
    end
    % Save mouse with new name
    behaviorData.mouseName = [datestr(date,'yymmdd'),'_',datestr(now,'HH'),'h',datestr(now,'MM'),'m'];
    behaviorData.mazeType = vr.mazeType;
    behaviorData.mazeContext = vr.mazeContext(1:vr.totalTrials);
    behaviorData.sisterMaze = vr.sisterMaze(1:vr.totalTrials);
    behaviorData.totalTrials = vr.totalTrials;
    x = vr.detailedCorrectErrorTrials(1:vr.totalTrials); x1 = length(x(x==1)); x2 = length(x(x==0));
    behaviorData.correctTrials = x1;
    behaviorData.errorTrials = x2;
    behaviorData.detailedCorrectErrorTrials = vr.detailedCorrectErrorTrials(1:vr.totalTrials);
    behaviorData.trialStartTime = vr.trialStartTime(1:vr.totalTrials);
    behaviorData.trialEndTime = vr.trialEndTime(1:vr.totalTrials);
    behaviorData.decision = vr.decision(1:vr.totalTrials);
    behaviorData.decisionDelay = vr.decisionDelay(1:vr.totalTrials);
    behaviorData.decisionPointArrivalTime = vr.decisionPointArrivalTime(1:vr.totalTrials);
    behaviorData.freeDecisions = vr.trialFreeDecisions(1:vr.totalTrials);
    behaviorData.reward = vr.propertyValues{3};
    behaviorData.estimatedTotalReward = behaviorData.reward*behaviorData.correctTrials/1000;
    behaviorData.spoutTouch = vr.spoutTouch(:,1:vr.totalTrials);
    behaviorData.spoutTouchTime = vr.spoutTouchTime(1:vr.totalTrials);
    % Imaging time stamps
    if vr.propertyValues{2} == 20
        if strcmpi(vr.propertyValues{7},'on')
            behaviorData.imagingTimeStamps = [vr.imagingStartTime vr.imagingEndTime];
        end
    end
    % Save
    save([experimentRootDir,datestr(date,'yymmdd'),'\',behaviorData.mouseName,'.mat'],'behaviorData');
end

% Display mouse stats
plotAlternationTMazeStats(behaviorData)

% Notify that the current training session is finished
if strcmpi(vr.propertyValues{8},'on')
    emailNotification
end

% Delete properties
if exist([settingsRootDir,'currentSettings','.mat'],'file') > 0
    delete([settingsRootDir,'currentSettings','.mat'])
end
if exist(settingsRootDir,'dir') > 0
    rmdir(settingsRootDir)
end

