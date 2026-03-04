function startAlternationTMaze(mazeType,mouseName,varargin)

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
    experimentRootDir = [pwd,'\Maze Test\'];
elseif propertyValues{2} > 0 && propertyValues{2} <= 4
    experimentRootDir = 'C:\Users\Goard Lab\Documents\MATLAB\Raquel\Training\';    
elseif propertyValues{2} == 20
    experimentRootDir = 'C:\Users\Goard Lab\Documents\MATLAB\Raquel\2P Behavior\';
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
    propertyValues{5} = [1 0.7];
    propertyValues{6} = [0 0.3];
elseif propertyValues{2} == 1
    propertyValues{5} = [1 0.75];
    propertyValues{6} = [0 0.35];
elseif propertyValues{2} == 2
    propertyValues{5} = [1 0.7];
    propertyValues{6} = [0 0.35];
elseif propertyValues{2} == 3
    propertyValues{5} = [0.9 0.6];
    propertyValues{6} = [0 0.4];
elseif propertyValues{2} == 4
    propertyValues{5} = [1 0.55];
    propertyValues{6} = [0 0.38];
elseif propertyValues{2} == 20
    propertyValues{5} = [1 0.6];
    propertyValues{6} = [0 0.4];
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
    behaviorData.sisterMaze = [];
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
    behaviorData.freeDecisions = [];
    behaviorData.reward = [];
    behaviorData.estimatedTotalReward = [];
    behaviorData.spoutTouch = [];
    behaviorData.spoutTouchTime = [];
end

% Save a temporary file for mouse stats (outside the sync folder)
save([settingsRootDir,'temporaryFile','.mat'],'behaviorData');

% Load the specified maze:
% AlternationTMaze: randomly alternating between R-to-L and L-to-R mazes

load([mazeType,'.mat'])

% Display message
fprintf('\n')
    disp(['       Session started at: ',datestr(now,'HH'),'h ',datestr(now,'MM'),'m'])
fprintf('\n')

% Run virtual reality maze
run(exper)

% Debug servos
debugServos

