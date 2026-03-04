function plotSpoutTouch(inputData)
%% Settings

% Experiment
numberOfDecisions = inputData.mazeType; numberOfDecisions = length(numberOfDecisions(~isnan(numberOfDecisions)));

% Convolution
sigma = 1;
edges = -3*sigma:0.05:3*sigma;
kernel = normpdf(edges,0,sigma);

% Resampling
numberOfBins = 500;

% Plotting
trialDuration = 40;
maxLicks = 10;
xticks = 11;


%% Ploting

    % Lick rate
    resampledSpoutTouch = [];
    lickRate = [];
    spoutOpening = [];
    arrivalTime = [];
    decisionDelay = [];
    for i=1:size(inputData.spoutTouch,2)
        y = inputData.spoutTouch(:,i); y = y(~isnan(y));
        x = linspace(0,inputData.trialEndTime(i)-inputData.trialStartTime(i),length(y))';
        spoutOpening = cat(1,spoutOpening,inputData.trialEndTime(i)-inputData.trialStartTime(i)-2);
        arrivalTime = cat(1,arrivalTime,inputData.decisionPointArrivalTime(i,:)-inputData.trialStartTime(i));
        decisionDelay = cat(1,decisionDelay,arrivalTime(i,:)+inputData.decisionDelay(i,:));
        y2 = interp1(x,y,linspace(0,trialDuration,numberOfBins)');
        y2(y2>=0.5) = 1; y2(y2<0.5) = 0;
        resampledSpoutTouch = cat(2,resampledSpoutTouch,y2);
            % Convolve spout touches
            s = conv(y,kernel);
            center = ceil(length(edges)/2);
            s = s(center:length(y)+center-1);
            s2 = interp1(x,s,linspace(0,trialDuration,numberOfBins)');
            lickRate = cat(2,lickRate,s2);
            clear('s','center')
        clear('x','y','y2','s2')
    end
    lickRate(isnan(lickRate)) = 0;

    % Only trials with a response
    trialsWithResponse = inputData.decision(:,numberOfDecisions);
    trialsWithResponse = ~isnan(trialsWithResponse);                    % change this condition later on, when all decisions are made manually
    resampledSpoutTouch = resampledSpoutTouch(:,trialsWithResponse);
    lickRate = lickRate(:,trialsWithResponse);
    spoutOpening = spoutOpening(trialsWithResponse);
    arrivalTime = arrivalTime(trialsWithResponse,:);
    decisionDelay = decisionDelay(trialsWithResponse,:);
    decision = inputData.decision(trialsWithResponse,:);
    
    figure,set(gcf,'position',[450 150 850 800])
        % Lick rate
        subplot(3,1,1)
            hold on
                plot(arrivalTime(:,1)*[1 1],[0 100],'Color',[1 0.65 0.65],'LineWidth',0.5)
                plot(arrivalTime(:,2)*[1 1],[0 100],'Color',[1 0.65 0.65],'LineWidth',0.5)
                plot(arrivalTime(:,3)*[1 1],[0 100],'Color',[1 0.65 0.65],'LineWidth',0.5)
                for i=1:numberOfDecisions
                    x = decisionDelay(:,i);
                    plot(x(decision(:,i)==inputData.mazeType(i))*[1 1],[0 100],'Color',[0.65 1 0.65],'LineWidth',0.5)
                    if ~isempty(x(decision(:,i)==abs(inputData.mazeType(i)-1)))
                        plot(x(decision(:,i)==abs(inputData.mazeType(i)-1))*[1 1],[0 100],'Color',[1 0.65 1],'LineWidth',0.5)
                    end
                    clear('x')
                end
                plot(spoutOpening(decision(:,numberOfDecisions)==inputData.mazeType(numberOfDecisions))*[1 1],[0 100],'Color',[0.65 1 1],'LineWidth',0.5)
                plot(linspace(0,trialDuration,numberOfBins),lickRate,'Color',[0.65 0.65 0.65],'LineWidth',1)
                plot(linspace(0,trialDuration,numberOfBins),mean(lickRate,2),'Color','k','LineWidth',2)
            hold off
            text(0.25,maxLicks-1,'stop at corner','Fontsize',8,'Fontweight','b','HorizontalAlignment','left','Color',[0.85 0 0])
            text(0.25,maxLicks-2,'correct decision','Fontsize',8,'Fontweight','b','HorizontalAlignment','left','Color',[0 0.85 0])
            text(0.25,maxLicks-3,'wrong decision','Fontsize',8,'Fontweight','b','HorizontalAlignment','left','Color',[0.85 0 0.85])
            text(0.25,maxLicks-4,'spout opening','Fontsize',8,'Fontweight','b','HorizontalAlignment','left','Color',[0 0 0.85])
            set(gca,'TickDir','out','XLim',[0 trialDuration],'YLim',[0 maxLicks],'Fontsize',10,'Fontweight','b')
            xlabel('time (s)','Fontsize',12,'Fontweight','b')
            ylabel('licks/s','Fontsize',12,'Fontweight','b')
            title([inputData.mouseName,' ',inputData.date],'Fontsize',12,'Fontweight','b')
        % Raster
        subplot(3,1,[2 3])
            hold on
                imagesc(resampledSpoutTouch'), colormap([1 1 1;0.65 0.65 0.65])
                for i=1:size(resampledSpoutTouch,2)
                    plot(arrivalTime(i,1)*(numberOfBins/trialDuration)*[1 1],[i-0.5 i+0.5],'Color',[1 0 0],'LineWidth',1)
                    plot(arrivalTime(i,2)*(numberOfBins/trialDuration)*[1 1],[i-0.5 i+0.5],'Color',[1 0 0],'LineWidth',1)
                    plot(arrivalTime(i,3)*(numberOfBins/trialDuration)*[1 1],[i-0.5 i+0.5],'Color',[1 0 0],'LineWidth',1)
                    for j=1:numberOfDecisions
                        if decision(i,j)==inputData.mazeType(j)
                            plot(decisionDelay(i,j)*(numberOfBins/trialDuration)*[1 1],[i-0.5 i+0.5],'Color',[0 1 0],'LineWidth',1)
                        elseif decision(i,j)==abs(inputData.mazeType(j)-1)
                            plot(decisionDelay(i,j)*(numberOfBins/trialDuration)*[1 1],[i-0.5 i+0.5],'Color',[1 0 1],'LineWidth',1)
                        end
                    end
                    if decision(i,numberOfDecisions)==inputData.mazeType(numberOfDecisions)
                        plot(spoutOpening(i)*(numberOfBins/trialDuration)*[1 1],[i-0.5 i+0.5],'Color',[0 1 1],'LineWidth',1)
                    end
                end
            hold off
            set(gca,'TickDir','out','Box','off','YDir','reverse','XLim',[0.5 numberOfBins],'YLim',[0.5 size(resampledSpoutTouch,2)+0.5],'XTick',linspace(1,numberOfBins,xticks),'XTickLabel',linspace(0,trialDuration,xticks),'Fontsize',10,'Fontweight','b')
            xlabel('time (s)','Fontsize',12,'Fontweight','b')
            ylabel('trials','Fontsize',12,'Fontweight','b')



