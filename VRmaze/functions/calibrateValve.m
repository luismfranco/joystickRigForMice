function calibrateValve(rigNumber)

% Settings
time =        [0.010 0.020 0.030 0.040 0.050 0.080 0.100 0.150];
repetitions = [  300   150   100    80    70    50    40    30];
desiredVolume = 10;

arduinoBoard = arduino('com3','uno');
configurePin(arduinoBoard,'A1','DigitalOutput')

volume = []; currentVolume = 3;
for j=1:length(repetitions)
    for i=1:repetitions(j)
        writeDigitalPin(arduinoBoard,'A1',1)
        pause(time(j))
        writeDigitalPin(arduinoBoard,'A1',0)
    end
    a = input(['     enter current liquid level [',num2str(j),'/',num2str(length(repetitions)),']: ']);
    volume = cat(2,volume,(currentVolume-a)/repetitions(j));
    currentVolume = a;
    clear('a')
end

% % Manual switch
% volume = []; currentVolume = 3;
% a = [2.75 2.5 2.1 1.8 1.45 1 0.6 0];
% for i=1:length(repetitions)
%     volume = cat(2,volume,(currentVolume-a(i))/repetitions(i));
%     currentVolume = a(i);
% end


%% Plot

time = time*1000;
volume = volume*1000;
p = polyfit(time,volume,1);
fitTime = linspace(0,time(end));
fitVolume = polyval(p,fitTime);
desiredTime = (desiredVolume-p(2))/p(1);

figure,
    hold on
        plot(time,volume,'k')
        plot(fitTime,fitVolume,'--b')
        scatter(desiredTime,desiredVolume,75,'r','filled')
        plot([desiredTime desiredTime],[0 desiredVolume],'--r')
        plot([0 desiredTime],[desiredVolume desiredVolume],'--r')
        text(desiredTime+5,desiredVolume*0.5,[num2str(desiredTime),' ms'],'Fontsize',10,'Fontweight','b','Color','r')
    hold off
    set(gca,'Box','off','TickDir','out','YLim',[0 15],'XTick',time,'Fontsize',10,'Fontweight','b','LineWidth',1)
    xlabel('time (ms)','Fontsize',12,'Fontweight','b')
    ylabel('volume ({\mu}L)','Fontsize',12,'Fontweight','b')
    
    
%% Save

if rigNumber == 10
    valveCalibrationRootDir = 'C:\Users\Widefield-Stimulus\Documents\MATLAB\Luis\';
else
    valveCalibrationRootDir = 'C:\Users\Goard Lab\Documents\MATLAB\Luis\';
end

calibrationCurve = p;

if exist([valveCalibrationRootDir,'valveCalibration'],'dir') == 0
    mkdir(valveCalibrationRootDir,'valveCalibration')
    save([valveCalibrationRootDir,'valveCalibration\rig',num2str(rigNumber),'.mat'],'calibrationCurve');
else
    save([valveCalibrationRootDir,'valveCalibration\rig',num2str(rigNumber),'.mat'],'calibrationCurve');
end


