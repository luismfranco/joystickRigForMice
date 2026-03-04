function startMaze(mazeType,mouseName,varargin)

% Default maze type and mouse name
if nargin < 1
    mazeType = 'LandR';
    mouseName = [datestr(date,'yymmdd'),'_',datestr(now,'HH'),'h',datestr(now,'MM'),'m'];
elseif nargin < 2
    mouseName = [datestr(date,'yymmdd'),'_',datestr(now,'HH'),'h',datestr(now,'MM'),'m'];
end

% Properties
propertyNames = {'Duration','Rig','Reward','FreeDecisions','Servo1Lim','Servo2Lim','Imaging','Notification'};
propertyValues = {600,0,10,1,[1 0.6],[0 0.4],'off','off'};
if mod(length(varargin),2)~=0
    fprintf('\n')
        disp('       Error: wrong number of property input arguments')
    fprintf('\n')
    return
else
    for i=1:2:length(varargin)
        % check that property names are correct
        if ~ischar(varargin{i})
            fprintf('\n')
                disp('       Error: invalid property name.')
            fprintf('\n')
            return
        end
        % get property name
        idx = find(strcmpi(propertyNames,varargin{i}));
        % check that property values are correct
        if idx <= 6
            if ~isnumeric(varargin{i+1})
                fprintf('\n')
                    disp('       Error: invalid property value.')
                fprintf('\n')
                return
            end
        elseif idx > 6
            if strcmpi(varargin{i+1},'on') || strcmpi(varargin{i+1},'off')
                % correct property value
            else
                fprintf('\n')
                    disp('       Error: invalid property value.')
                fprintf('\n')
                return
            end
        end
        % change property values
        if idx ~= 0
            propertyValues{idx} = varargin{i+1};
        else
            % keep default value
        end
        clear('idx')
    end
end

% Make sure there is a folder for the current experiment
if propertyValues{2} == 0
    experimentRootDir = 'D:\Material\Virtual Maze\Maze Test\';
elseif propertyValues{2} > 0 && propertyValues{2} <= 4
    experimentRootDir = 'C:\Users\Goard Lab\Documents\MATLAB\Luis\Training\';
elseif propertyValues{2} == 10
    experimentRootDir = 'C:\Users\Widefield-Stimulus\Documents\MATLAB\Luis\WF Behavior\';
elseif propertyValues{2} == 20
    experimentRootDir = 'C:\Users\Goard Lab\Documents\MATLAB\Luis\2P Behavior\';
end

if exist([experimentRootDir,datestr(date,'yymmdd')],'dir') == 0
    mkdir(experimentRootDir,datestr(date,'yymmdd'))
end
% Current folder for temporarily storing settings
settingsRootDir = [pwd,'\TemporaryData\'];
if exist(settingsRootDir,'dir') == 0
    mkdir(settingsRootDir)
end

% Servo Limits for each rig
if propertyValues{2} == 0
    propertyValues{5} = [1 0.6];
    propertyValues{6} = [0 0.4];
elseif propertyValues{2} == 1
    propertyValues{5} = [1 0.65];
    propertyValues{6} = [0 0.35];
elseif propertyValues{2} == 2
    propertyValues{5} = [1 0.65];
    propertyValues{6} = [0 0.35];
elseif propertyValues{2} == 3
    propertyValues{5} = [1 0.60];
    propertyValues{6} = [0 0.40];
elseif propertyValues{2} == 4
    propertyValues{5} = [1 0.60];
    propertyValues{6} = [0 0.35];
elseif propertyValues{2} == 10
    propertyValues{5} = [1 0.65];
    propertyValues{6} = [0 0.35];
elseif propertyValues{2} == 20
    propertyValues{5} = [1 0.60];
    propertyValues{6} = [0 0.40];
end

% Save a temporary file for current settings (outside the sync folder)
save([settingsRootDir,'currentSettings','.mat'],'propertyNames','propertyValues');

% Load existent mouse
if exist([experimentRootDir,datestr(date,'yymmdd'),'\',mouseName,'.mat'],'file') > 0
    load([experimentRootDir,datestr(date,'yymmdd'),'\',mouseName,'.mat'])
else
    behaviorData = [];
    % Mouse
    behaviorData.mouseName = num2str(mouseName);
    % Maze
    behaviorData.mazeType = [];
    behaviorData.mazeContext = [];
    % Session performance
    behaviorData.totalTrials = [];
    behaviorData.correctTrials = [];
    behaviorData.errorTrials = [];
    behaviorData.detailedCorrectErrorTrials = [];
    behaviorData.trialStartTime = [];
    behaviorData.trialEndTime = [];
    behaviorData.decision = [];
    behaviorData.decisionDelay = [];
    behaviorData.decisionPointArrivalTime = [];
    behaviorData.decisionPointLeavingTime = [];
    behaviorData.decisionTrajectory = [];
    behaviorData.freeDecisions = [];
    behaviorData.reward = [];
    behaviorData.estimatedTotalReward = [];
    behaviorData.spoutTouch = [];
    behaviorData.spoutTouchTime = [];
    if strcmpi(propertyValues{7},'on')
        if propertyValues{2} == 10 || propertyValues{2} == 20
            behaviorData.imagingTimeStamps = [];
        end
    end
end

% Save a temporary file for mouse stats (outside the sync folder)
save([settingsRootDir,'temporaryFile','.mat'],'behaviorData');

% Load the specified maze:
% LandR: randomly alternating L and R

if propertyValues{2}==10
    load(['C:\Users\Widefield-Stimulus\Dropbox\BehaviorRig\Luis\behaviorRigCodes\experiments\',mazeType,'.mat'])
elseif propertyValues{2}==0
    load(['D:\Material\Virtual Maze\ViRMEn\experiments\',mazeType,'.mat'])
else
    load(['C:\Users\Goard Lab\Dropbox\BehaviorRig\Luis\behaviorRigCodes\experiments\',mazeType,'.mat'])
end

% Display message
fprintf('\n')
    disp(['       Session started at: ',datestr(now,'HH'),'h ',datestr(now,'MM'),'m'])
fprintf('\n')

% Run virtual reality maze
run(exper)

% Debug servos
debugServos

