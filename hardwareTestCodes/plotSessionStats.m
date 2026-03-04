function plotSessionStats(behaviorData)

figure, set(gcf,'Position',[160 120 1600 800])
    subplot(4,4,[1 5 9 13])
        x = behaviorData.decision(:,1);
        y = behaviorData.trialSubMaze(:,1);
        y = y(1:length(x)); % remove this line later on: finalizeMaze code has been already fixed.
        idx1 = find(x==y);
        idx2 = find(x~=y & ~isnan(x));
        hold on
            p1 = NaN(size(x)); p1(idx1) = x(idx1);
            scatter(p1,1:length(p1),50,'g')
            p2 = NaN(size(x)); p2(idx2) = x(idx2);
            scatter(p2,1:length(p2),50,'m')
        hold off
        set(gca,'Box','off','TickDir','out','XLim',[-1 2],'XTick',[0 1],'XTickLabel',{'left';'right'},'YLim',[0 behaviorData.totalTrials])
        text(-0.85,0.950*behaviorData.totalTrials,'correct','FontSize',10,'FontWeight','bold','Color','g')
        text(-0.85,0.925*behaviorData.totalTrials,'error','FontSize',10,'FontWeight','bold','Color','m')
        xlabel('decision','FontSize',12,'FontWeight','bold')
        ylabel('trials','FontSize',12,'FontWeight','bold')
        title('decisions','FontSize',12,'FontWeight','bold')
    lickometer = subplot(4,4,[2 6 10 14]);
        z = behaviorData.spoutTouch';
        for i=~isnan(p1)
            a = z(i,:);
            a(a==1) = 3;
            z(i,:) = a;
            clear('a')
        end
        for i=~isnan(p2)
            a = z(i,:);
            a(a==1) = 2;
            z(i,:) = a;
            clear('a')
        end
        imagesc(z), colormap(lickometer,[1 1 1;0.5 0.5 0.5;1 0 1;0 1 0])
        set(gca,'Box','off','YDir','normal','TickDir','out')
        xlabel('frames','FontSize',12,'FontWeight','bold')
        ylabel('trials','FontSize',12,'FontWeight','bold')
        title('lickometer','FontSize',12,'FontWeight','bold')
    subplot(4,4,[4 8])
        boxplot(behaviorData.decisionDelay(:,1))
        set(gca,'Box','off','TickDir','out')      
        ylabel('time (s)','FontSize',12,'FontWeight','bold')
        title('decision delay','FontSize',12,'FontWeight','bold')
    pieChart = subplot(4,4,[3 7]);
        a1 = length(find(p1==0))/behaviorData.totalTrials; a2 = length(find(p1==1))/behaviorData.totalTrials;
        pie([a1 a2 1-a1-a2])
        colormap(pieChart,[1 0 0;0 0 1;1 1 1])
        labels = {'left','right','no response'};
        legend(labels,'Location','southoutside','Orientation','horizontal')
        title('decision ratio','FontSize',12,'FontWeight','bold')
    responses = subplot(6,4,[23 24]);
        r = p1; r(~isnan(r)) = 1; r(isnan(r)) = 0;
        imagesc(r'), colormap(responses,[1 1 1;0.5 0.5 0.5])
        set(gca,'Box','off','TickDir','out','YTickLabel',[])
        xlabel('trials','FontSize',12,'FontWeight','bold')
    subplot(6,4,[15 16 19 20])
        sigma = 1;
        edges = -3*sigma:0.05:3*sigma;
        kernel = normpdf(edges,0,sigma);
        s = conv(r,kernel);
        center = ceil(length(edges)/2);
        s = s(center:length(r)+center-1);
        plot(s,'k')
        set(gca,'Box','off','TickDir','out','XLim',[0 behaviorData.totalTrials],'YLim',[0 20],'YTick',[0 20],'YTickLabel',{'NR';'R'})
        title('responses','FontSize',12,'FontWeight','bold')
        
        
        
        
        
        
        
        
        
        
        