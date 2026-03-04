function plotSessionStats(behaviorData)
%% Settings

% Decision
timeToDecisionPoint = 3;
decisionWindow = 3;

% Trials
if length(behaviorData.totalTrials) == 1
    window = 1:behaviorData.totalTrials;
elseif length(behaviorData.totalTrials) > 1
    window = 1+behaviorData.totalTrials(end-1):behaviorData.totalTrials(end-1)+behaviorData.totalTrials(end);
end

% Resampling
numberOfBins = 330;
trialDuration = 11;
xticks = 12;


%% Plot
    
        % Data
        f = behaviorData.freeDecisions(window);
        d = behaviorData.decision(window);
        c = behaviorData.detailedCorrectErrorTrials(window);
        x1 = find(f==1);        % free
        x2 = find(~isnan(d));   % decision
        x3 = find(c==1);        % correct
        x4 = find(c==0);        % wrong
        x5 = find(d==0);        % left
        x6 = find(d==1);        % right
        x7 = find(isnan(d));    % no response
        x8 = find(f==0);        % blocked
        
        % Decision delay
        dd1 = behaviorData.decisionDelay(window,1); dd1 = dd1(intersect(x2,x1));    % free decisions
        dd2 = behaviorData.decisionDelay(window,1); dd2 = dd2(intersect(x2,x8));    % blocked decisions
        
        % Lickometer
        resampledSpoutTouch = [];
        for i=window %1:size(behaviorData.spoutTouch(:,window),2)
            y = behaviorData.spoutTouch(:,i); y = y(~isnan(y));
            x = linspace(0,behaviorData.trialEndTime(i)-behaviorData.trialStartTime(i),length(y))';
            y2 = interp1(x,y,linspace(0,trialDuration,numberOfBins)');
            y2(y2>=0.5) = 1; y2(y2<0.5) = 0;
            resampledSpoutTouch = cat(2,resampledSpoutTouch,y2);
            clear('x','y','y2')
        end
        scaledSpoutTouch = resampledSpoutTouch;
        
        % Performance
            
            % All decisions + no responses
            y1 = intersect(x2,x3); y1 = length(y1);     % correct decision
            y2 = intersect(x2,x4); y2 = length(y2);     % wrong decision
            y3 = intersect(x5,x3); y3 = length(y3);     % correct left
            y4 = intersect(x6,x3); y4 = length(y4);     % correct right
            y5 = intersect(x5,x4); y5 = length(y5);     % wrong left
            y6 = intersect(x6,x4); y6 = length(y6);     % wrong right
            y7 = length(x7);                            % no response
            allTrialsCorrectFraction = y1/(y1+y2+y7);
            allTrialsWrongFraction = y2/(y1+y2+y7);
            allTrialsCorrectLeft = y3/(y3+y4+y5+y6+y7);
            allTrialsCorrectRight = y4/(y3+y4+y5+y6+y7);
            allTrialsWrongLeft = y5/(y3+y4+y5+y6+y7);
            allTrialsWrongRight = y6/(y3+y4+y5+y6+y7);
            noResponse = y7/(y3+y4+y5+y6+y7);
            
            %Free decisions
            if ~isempty(x1)
                % Free decisions only
                y1 = intersect(x1,x2); y1 = intersect(y1,x3); y1 = length(y1);     % free correct decision
                y2 = intersect(x1,x2); y2 = intersect(y2,x4); y2 = length(y2);     % free wrong decision
                y3 = intersect(x1,x3); y3 = intersect(y3,x5); y3 = length(y3);     % free correct left
                y4 = intersect(x1,x3); y4 = intersect(y4,x6); y4 = length(y4);     % free correct right
                y5 = intersect(x1,x4); y5 = intersect(y5,x5); y5 = length(y5);     % free wrong left
                y6 = intersect(x1,x4); y6 = intersect(y6,x6); y6 = length(y6);     % free wrong right
                freeDecisionCorrectFraction = y1/(y1+y2);
                freeDecisionWrongFraction = y2/(y1+y2);
                freeDecisionCorrectLeft = y3/(y3+y4+y5+y6);
                freeDecisionCorrectRight = y4/(y3+y4+y5+y6);
                freeDecisionWrongLeft = y5/(y3+y4+y5+y6);
                freeDecisionWrongRight = y6/(y3+y4+y5+y6);
            elseif isempty(x1)
                % For cases when all trials are blocked for free decisions
                fprintf('\n')
                    disp('     There were no free decisions in this session.')
                fprintf('\n')
                freeDecisionCorrectFraction = y1/(y1+y2);
                freeDecisionWrongFraction = y2/(y1+y2);
                freeDecisionCorrectLeft = y3/(y3+y4+y5+y6);
                freeDecisionCorrectRight = y4/(y3+y4+y5+y6);
                freeDecisionWrongLeft = y5/(y3+y4+y5+y6);
                freeDecisionWrongRight = y6/(y3+y4+y5+y6);
            end
            clear('y1','y2','y3','y4','y5','y6','y7')
        
                
    % Figure
    figure, set(gcf,'Position',[160 120 1600 800])
    
        % Lickometer
        lickometer = subplot(4,4,[1 5 9 13]);
            colors = [1 1 1;0.6 0.6 0.6;1 0 0; 0 0 1;1 0.5 0;0 0.5 1];
            for i=intersect(x5,x3)              % all correct left
                a = resampledSpoutTouch(:,i);
                a(a==1) = 2;
                scaledSpoutTouch(:,i) = a;
                clear('a')
            end
            for i=intersect(x6,x3)              % all correct right
                a = resampledSpoutTouch(:,i);
                a(a==1) = 3;
                scaledSpoutTouch(:,i) = a;
                clear('a')
            end
            for i=intersect(x5,x4)              % all wrong left
                a = resampledSpoutTouch(:,i);
                a(a==1) = 4;
                scaledSpoutTouch(:,i) = a;
                clear('a')
            end
            for i=intersect(x6,x4)              % all wrong right
                a = resampledSpoutTouch(:,i);
                a(a==1) = 5;
                scaledSpoutTouch(:,i) = a;
                clear('a')
            end
            indices = [1;2];
            for i=2:5
                if ~isempty(find(scaledSpoutTouch==i,1))
                    indices = cat(1,indices,i+1);
                end
            end
            clear('resampledSpoutTouch')
            hold on
                imagesc(scaledSpoutTouch'), colormap(lickometer,colors(indices,:))
                plot((numberOfBins/trialDuration)*[timeToDecisionPoint timeToDecisionPoint],[0 behaviorData.totalTrials(end)+0.5],'Color',[0.6 0.6 0.6])
                plot((numberOfBins/trialDuration)*[timeToDecisionPoint+decisionWindow timeToDecisionPoint+decisionWindow],[0 behaviorData.totalTrials(end)+0.5],'Color',[0.6 0.6 0.6])
                scatter((numberOfBins/trialDuration)*(behaviorData.decisionDelay(intersect(x2,x3),1)+3),intersect(x2,x3),10,[0 0.9 0],'filled')     % correct
                scatter((numberOfBins/trialDuration)*(behaviorData.decisionDelay(intersect(x2,x4),1)+3),intersect(x2,x4),10,[0.9 0 0.9],'filled')   % wrong
%                 scatter((numberOfBins/trialDuration)*(behaviorData.decisionDelay(intersect(x6,x3),1)+1),intersect(x6,x3),10,[0 0 1],'filled')       % correct right
%                 scatter((numberOfBins/trialDuration)*(behaviorData.decisionDelay(intersect(x5,x3),1)+1),intersect(x5,x3),10,[1 0 0],'filled')       % correct left
%                 scatter((numberOfBins/trialDuration)*(behaviorData.decisionDelay(intersect(x6,x4),1)+1),intersect(x6,x4),10,[0 0.9 0.9],'filled')   % wrong right
%                 scatter((numberOfBins/trialDuration)*(behaviorData.decisionDelay(intersect(x5,x4),1)+1),intersect(x5,x4),10,[0.9 0.9 0],'filled')   % wrong left
            hold off
            set(gca,'TickDir','out','Box','off','YDir','reverse','XLim',[0.5 numberOfBins],'YLim',[0.5 size(scaledSpoutTouch,2)+0.5],'XTick',linspace(1,numberOfBins,xticks),'XTickLabel',linspace(0,trialDuration,xticks))
            xlabel('time (s)','Fontsize',12,'Fontweight','b')
            ylabel('trial','Fontsize',12,'Fontweight','b')
            title('responses and lickometer','FontSize',12,'FontWeight','bold')
            clear('scaledSpoutTouch','colors','indices')
            
        % Decision ratio
        pieChart = subplot(4,4,[3 7]);
            colors = [1 0 0; 0 0 1;1 0.5 0;0 0.5 1;1 1 1];
            labels = {'correctLeft','correctRight','wrongLeft','wrongRight','noResponse'};
            indices = [];
            decisionRatio = [];
            if allTrialsCorrectLeft > 0
                decisionRatio = cat(1,decisionRatio,allTrialsCorrectLeft);
                indices = cat(1,indices,1);
            end
            if allTrialsCorrectRight > 0
                decisionRatio = cat(1,decisionRatio,allTrialsCorrectRight);
                indices = cat(1,indices,2);
            end
            if allTrialsWrongLeft > 0
                decisionRatio = cat(1,decisionRatio,allTrialsWrongLeft);
                indices = cat(1,indices,3);
            end
            if allTrialsWrongRight > 0
                decisionRatio = cat(1,decisionRatio,allTrialsWrongRight);
                indices = cat(1,indices,4);
            end
            if noResponse > 0
                decisionRatio = cat(1,decisionRatio,noResponse);
                indices = cat(1,indices,5);
            end
            pie(decisionRatio)
            colormap(pieChart,colors(indices,:))
            legend(labels(indices),'Location','southoutside')
            title('all trials','FontSize',12,'FontWeight','bold')
            clear('colors','labels','indices','decisionRatio')
    
        % Estimated reward
        subplot(4,4,[10 14]);
            % Data
            reward = behaviorData.reward(end)*0.001*cumsum(c);   % in mL
            correctTrials = cumsum(c); correctTrials = correctTrials./(1:length(correctTrials))';
            idx = find(reward>=1.1,1);
            % Left Y axis
            yyaxis left
            plot(reward,'b')
            if ~isempty(idx)
                hold on
                    plot([idx idx],[0 reward(idx)],'--','Color',[1 0.5 0])
                    plot([0 idx],[reward(idx) reward(idx)],'--','Color',[1 0.5 0])
                    text(idx/2,0.95*reward(idx),'1.1 mL','FontSize',10,'Color',[1 0.5 0],'HorizontalAlignment','center')
                hold off
            end
            set(gca,'YColor',[0 0 1])
            ylabel('estimated reward (mL)','FontSize',12,'FontWeight','bold','Color','b')
            text(0.1*length(reward),0.05*max(reward),'10 \muL/correct','FontSize',10,'Color','b','HorizontalAlignment','left')
            text(0.95*length(reward),0.95*max(reward),[num2str(max(reward)),' mL'],'FontSize',10,'Color','b','HorizontalAlignment','right')
            % Right Y axis
            yyaxis right
            plot(correctTrials,'k')
            set(gca,'YColor',[0 0 0],'YLim',[0 1])
            ylabel('correct/trials ratio','FontSize',12,'FontWeight','bold','Color','k')
            % X axis and general properties
            set(gca,'Box','off','TickDir','out','XLim',[0 length(reward)])     
            xlabel('trial number','FontSize',12,'FontWeight','bold')
            clear('reward','correctTrials')
    
        % Performance over time
        subplot(4,4,[2 6])
            a1 = zeros(length(c)); a1(intersect(x5,x3)) = 1; a1 = cumsum(a1);
            a2 = zeros(length(c)); a2(intersect(x6,x3)) = 1; a2 = cumsum(a2);
            a3 = zeros(length(c)); a3(intersect(x5,x4)) = 1; a3 = cumsum(a3);
            a4 = zeros(length(c)); a4(intersect(x6,x4)) = 1; a4 = cumsum(a4);
            a5 = zeros(length(c)); a5(x7) = 1;               a5 = cumsum(a5);
            hold on
                plot(a1,'Color',[1 0 0])
                plot(a2,'Color',[0 0 1])
                plot(a3,'Color',[1 0.5 0])
                plot(a4,'Color',[0 0.5 1])
                plot(a5,'Color',[0.6 0.6 0.6])
                y = ylim;
                if ~isempty(idx)
                    plot([idx idx],[0 y(2)],'--','Color',[0 0 0.6])
                end
            hold off
            set(gca,'Box','off','TickDir','out','XLim',[0 length(a1)])
            xlabel('trial number','FontSize',12,'FontWeight','bold')
            ylabel('number of responses','FontSize',12,'FontWeight','bold')
            text(0.1*length(a1),0.95*y(2),'correctLeft','FontSize',10,'Color',[1 0 0],'HorizontalAlignment','left')
            text(0.1*length(a1),0.90*y(2),'correctRight','FontSize',10,'Color',[0 0 1],'HorizontalAlignment','left')
            text(0.1*length(a1),0.85*y(2),'wrongLeft','FontSize',10,'Color',[1 0.5 0],'HorizontalAlignment','left')
            text(0.1*length(a1),0.80*y(2),'wrongRight','FontSize',10,'Color',[0 0.5 1],'HorizontalAlignment','left')
            text(0.1*length(a1),0.75*y(2),'noResponse','FontSize',10,'Color',[0.6 0.6 0.6],'HorizontalAlignment','left')
            clear('a1','a2','a3','a4','a5','y','idx')
        
        % Trials with responses and free decision
            % Response delay
            subplot(4,4,[4 8])
                hold on
                    scatter(0.75+0.5*rand(length(dd2),1),dd2,50,[0.7 0.7 0.7])    
                    scatter(0.75+0.5*rand(length(dd1),1),dd1,50,[0.3 0.3 0.3])
                    plot([0.75 1.25],[mean(dd1) mean(dd1)],'Color',[0.3 0.3 0.3],'LineWidth',2)
                    plot([1 1],[mean(dd1)-std(dd1) mean(dd1)+std(dd1)],'Color',[0.3 0.3 0.3],'LineWidth',2)
                    plot([0.95 1.05],[mean(dd1)+std(dd1) mean(dd1)+std(dd1)],'Color',[0.3 0.3 0.3],'LineWidth',2)
                    plot([0.95 1.05],[mean(dd1)-std(dd1) mean(dd1)-std(dd1)],'Color',[0.3 0.3 0.3],'LineWidth',2)
                    text(0.1,1.875,'free','FontSize',10,'FontWeight','bold','Color',[0.3 0.3 0.3],'HorizontalAlignment','left')
                    text(0.1,1.75,'blocked','FontSize',10,'FontWeight','bold','Color',[0.7 0.7 0.7],'HorizontalAlignment','left')
                hold off
                set(gca,'Box','off','TickDir','out','XTick',[],'XLim',[0 3],'YLim',[0 2])      
                ylabel('response delay, time (s)','FontSize',12,'FontWeight','bold')
            
        % Decision ratio
        pieChart = subplot(4,4,[11 15]);
            colors = [1 0 0; 0 0 1;1 0.5 0;0 0.5 1];
            labels = {'correctLeft','correctRight','wrongLeft','wrongRight'};
            indices = [];
            decisionRatio = [];
            if freeDecisionCorrectLeft > 0
                decisionRatio = cat(1,decisionRatio,freeDecisionCorrectLeft);
                indices = cat(1,indices,1);
            end
            if freeDecisionCorrectRight > 0
                decisionRatio = cat(1,decisionRatio,freeDecisionCorrectRight);
                indices = cat(1,indices,2);
            end
            if freeDecisionWrongLeft > 0
                decisionRatio = cat(1,decisionRatio,freeDecisionWrongLeft);
                indices = cat(1,indices,3);
            end
            if freeDecisionWrongRight > 0
                decisionRatio = cat(1,decisionRatio,freeDecisionWrongRight);
                indices = cat(1,indices,4);
            end
            pie(decisionRatio)
            colormap(pieChart,colors(indices,:))
            legend(labels(indices),'Location','southoutside')
            title('free decisions','FontSize',12,'FontWeight','bold')
            clear('colors','labels','indices','decisionRatio')
            
        % Correct/wrong ratio
        pieChart = subplot(4,4,[12 16]);
            colors = [0 0.9 0;0.9 0 0.9];
            labels = {'correct','wrong'};
            indices = [];
            decisionRatio = [];
            if freeDecisionCorrectFraction > 0
                decisionRatio = cat(1,decisionRatio,freeDecisionCorrectFraction);
                indices = cat(1,indices,1);
            end
            if freeDecisionWrongFraction > 0
                decisionRatio = cat(1,decisionRatio,freeDecisionWrongFraction);
                indices = cat(1,indices,2);
            end
            pie(decisionRatio)
            colormap(pieChart,colors(indices,:))
            legend(labels(indices),'Location','southoutside')
            title('free decisions','FontSize',12,'FontWeight','bold')
            clear('colors','labels','indices','decisionRatio')


