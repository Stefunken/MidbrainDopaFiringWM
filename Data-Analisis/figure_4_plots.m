function figure_4_plots(e,results_folder,HC_K,LC_K)
%% Some pre-requisites
baseline = 0;
align = {'ProbeDown','StimOn1','PushKey'}; % Events
j = 2;
eAl = alignSpikes(e,align{j}); % Aligning Spikes to SO1
binWidth = {.25 .25, .25}; % Window size for each alineation
TimeAxis = ['{ (-0.5+binWidth{j}/2):0.05:(1.5-binWidth{j}/2),' ...
    '  (-1.5+binWidth{j}/2):0.05:(4.5-binWidth{j}/2),' ...
    '  (-0.1+binWidth{j}/2):0.05:(1.0-binWidth{j}/2) }'];

gap  = .1;    % Temporal gap between plot (Left-Center)
gap_rew = .3; % (Center-Right)
y = [-1 .8];  % For figure purposes -- Event Marks
xRew = [8.0 8.0]+ gap_rew;
xStim = [3.0 3.0 3.5 3.5];
xStim2 = [6.5 6.5 7.0 7.0];
y2 = [0 .8 .8 0];
y1 = [0 -.45 -.45 0];
mygray = [.9 .9 .9];

figure_size = [8.5 2.5];
font_size = 15;
font_legend = 12;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig4A, Difficulty Modulation

y = [-.48 .9];
y2 = [0 .9 .9 0];
y1 = [0 -.48 -.48 0];

figure('visible','off'),clf
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])

subplot(1,3,1)
    set(gca,'FontSize',font_size,'LineWidth',1)
    hold on;
    j=2;
    timeAxis = eval(TimeAxis);
    displace(2) = timeAxis{1}(end)+abs(timeAxis{2}(1))+ gap + binWidth{j};
    displace(3) = displace(2) + timeAxis{2}(end) + abs(timeAxis{3}(1)) + gap_rew + binWidth{j};
    timeAx      = timeAxis{j} + displace(j);
    area(xStim,y2,'EdgeColor',mygray,'FaceColor',mygray)
    area(xStim,y1,'EdgeColor',mygray,'FaceColor',mygray)

    % Select the trial types.
    highConf = [select(eAl,'reward',1,'clase', HC_K(1,:)),select(eAl,'reward',1,'clase', HC_K(2,:))];%'stimFreq1',10); % Select the stimulus classes.
    lowConf = select(eAl,'reward',1,'clase', LC_K);

    highConf_SO1 = [highConf.normalized_response_f1]'; % Significancy Test
    lowConf_SO1 = [lowConf.normalized_response_f1]';
    [~,p_Conf_SO1] = ttest2(highConf_SO1,lowConf_SO1);
    disp('---------------------------------------');
    disp(['Difficulty Modulation at F1 Low > High: ' num2str(mean(highConf_SO1)) ' > ' num2str(mean(lowConf_SO1)) ' p = ' num2str(p_Conf_SO1)]);

    % Obtain the mean firing rates and error regions.
    highConfFR = cell2mat({highConf.normalized_response_pd}');
    highConfStderr = std(highConfFR)./sqrt(size(highConfFR,1));
    lowConfFR = cell2mat({lowConf.normalized_response_pd}');
    lowConfStderr = std(lowConfFR)./sqrt(size(lowConfFR,1));

    % Plot the results.
    lowConfLeg = shadedErrorBar(timeAx,mean(lowConfFR),lowConfStderr,{'LineWidth',2,'color',[.2,.6,1]});
    highConfLeg = shadedErrorBar(timeAx,mean(highConfFR),highConfStderr,{'LineWidth',2,'color',[.2,.2,1]});

    [hleg,icons,~,~]  = legend([highConfLeg.mainLine lowConfLeg.mainLine],'Low Difficulty', 'High Difficulty') ;
    plot([-.2 9],[baseline baseline],':k','linewidth',2)

    set(gca,'xcolor',[0 0 0],'ycolor',[0 0 0])
    set(hleg,'Position',[0.2 0.83 0.1 0.1])
    set(hleg,'box','off')
    set(hleg,'FontSize',font_legend)
    set(icons(:),'LineWidth',6); 
    axis([2.6 3.9 -.5 1.3])
    ylabel('z-score','FontSize',font_size)
    xlabel('Time from f1 (s)','FontSize',font_size)
    set(gca,'XTick',[3 3.5])
    set(gca,'XTickLabel',{'0', '0.5' },'FontSize',font_size)
    set(gca,'YTick',[-.5 0 .5 1])
    set(gca,'YTickLabel',{'-.5','0', '.5','1' },'FontSize',font_size)

subplot(1,3,2)
    set(gca,'FontSize',font_size,'LineWidth',1)
    hold on
    j=2;
    timeAxis = eval(TimeAxis);
    displace(2) = timeAxis{1}(end)+abs(timeAxis{2}(1))+ gap + binWidth{j};
    displace(3) = displace(2) + timeAxis{2}(end) + abs(timeAxis{3}(1)) + gap_rew + binWidth{j};
    timeAx      = timeAxis{j} + displace(j);
    area(xStim2,y2,'EdgeColor',mygray,'FaceColor',mygray)
    area(xStim2,y1,'EdgeColor',mygray,'FaceColor',mygray)

    highConf = [select(eAl,'reward',1,'clase', HC_K(1,:)),select(eAl,'reward',1,'clase', HC_K(2,:))]; % Select the stimulus classes.
    lowConf = select(eAl,'reward',1,'clase', LC_K);

    highConf_SO2 = [highConf.normalized_response_f2]'; % Significancy Test
    lowConf_SO2 = [lowConf.normalized_response_f2]';
    [~,p_Conf_SO2] = ttest2(highConf_SO2,lowConf_SO2);
    disp(['Difficulty Modulation at F2 Low > High: ' num2str(mean(highConf_SO2)) ' > ' num2str(mean(lowConf_SO2)) ' p = ' num2str(p_Conf_SO2)]);

    % Obtain the mean firing rates.
    highConfFR = cell2mat({highConf.normalized_response_pd}');
    highConfStderr = std(highConfFR)./sqrt(size(highConfFR,1));
    lowConfFR = cell2mat({lowConf.normalized_response_pd}');
    lowConfStderr = std(lowConfFR)./sqrt(size(lowConfFR,1));

    % Plot the results.
    shadedErrorBar(timeAx,mean(lowConfFR),lowConfStderr,{'LineWidth',2,'color',[.2,.6,1]});
    shadedErrorBar(timeAx,mean(highConfFR),highConfStderr,{'LineWidth',2,'color',[.2,.2,1]});

    plot([-.2 9],[baseline baseline],':k','linewidth',2)

    set(gca,'xcolor',[0 0 0],'ycolor',[0 0 0])
    axis([6.1 7.4 -.5 1.3])
    xlabel('Time from f2 (s)','FontSize',font_size)
    set(gca,'XTick',[6.5 7])
    set(gca,'XTickLabel',{'0', '0.5' },'FontSize',font_size)
    set(gca,'YTick',[-.5 0 .5 1])
    set(gca,'YTickLabel',{'-.5','0', '.5','1' },'FontSize',font_size)

subplot(1,3,3)
    set(gca,'FontSize',font_size,'LineWidth',1)
    hold on;
    plot(xRew,y,'color',mygray,'linewidth',4)
    j=3;
    timeAxis = eval(TimeAxis);
    displace(2) = timeAxis{1}(end)+abs(timeAxis{2}(1))+ gap + binWidth{j};
    displace(3) = displace(2) + timeAxis{2}(end) + abs(timeAxis{3}(1)) + gap_rew + binWidth{j};
    timeAx      = timeAxis{j} + displace(j);

    % Select the trial types.
    highConf = [select(eAl,'reward',1,'clase', HC_K(1,:)),select(eAl,'reward',1,'clase', HC_K(2,:))]; % Select the stimulus classes.
    lowConf = select(eAl,'reward',1,'clase', LC_K);

    % Obtain the mean firing rates.
    highConfFR = cell2mat({highConf.normalized_kd_align_rew}');
    highConfStderr = std(highConfFR)./sqrt(size(highConfFR,1));
    lowConfFR = cell2mat({lowConf.normalized_kd_align_rew}');
    lowConfStderr = std(lowConfFR)./sqrt(size(lowConfFR,1));

    % Plot the results.
    shadedErrorBar(timeAx,mean(lowConfFR),lowConfStderr,{'LineWidth',2,'color',[.2,.6,1]});
    shadedErrorBar(timeAx,mean(highConfFR),highConfStderr,{'LineWidth',2,'color',[.2,.2,1]});

    plot([-.2 10.2],[baseline baseline],':k','linewidth',2)
    axis([8.0 9.2 -.5 1.3])

    xlabel('Time from PB (s)','FontSize',font_size)
    set(gca,'XTick',[xRew(1) xRew(1)+0.5])
    set(gca,'XTickLabel',{'0', '0.5' },'FontSize',font_size)
    set(gca,'YTick',[-.5 0 .5 1])
    set(gca,'YTickLabel',{'-.5','0', '.5','1' },'FontSize',font_size)
    xlabel('Time from PB (s)','FontSize',font_size)

print([results_folder '/Fig4A_Difficulty'],'-dpdf','-r600');
print([results_folder '/Fig4A_Difficulty'],'-depsc2');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig4B Correct-Error

figure('visible','off'),clf
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])

subplot(1,3,1)
    set(gca,'FontSize',font_size,'LineWidth',1)
    hold on;
    j=2;
    timeAxis = eval(TimeAxis);
    displace(2) = timeAxis{1}(end)+abs(timeAxis{2}(1))+ gap + binWidth{j};
    displace(3) = displace(2) + timeAxis{2}(end) + abs(timeAxis{3}(1)) + gap_rew + binWidth{j};
    timeAx      = timeAxis{j} + displace(j);
    area(xStim,y2,'EdgeColor',mygray,'FaceColor',mygray)
    area(xStim,y1,'EdgeColor',mygray,'FaceColor',mygray)

    % Select trial types
    correct = select(eAl,'clase',[1 12] , 'reward',1);% Select the stimulus classes.
    errores = select(eAl,'clase',[1 12],'reward',0);

    % Obtain the mean firing rates and the error regions
    correctFR = cell2mat({correct.normalized_response_pd}');
    correctStderr = std(correctFR)./sqrt(size(correctFR,1));
    erroresFR = cell2mat({errores.normalized_response_pd}');
    erroresStderr = std(erroresFR)./sqrt(size(erroresFR,1));

    % Plot the results.
    errorLeg = shadedErrorBar(timeAx,mean(erroresFR),erroresStderr,{'LineWidth',2,'color',[1,.2,.2]});
    hitLeg = shadedErrorBar(timeAx,mean(correctFR),correctStderr,{'LineWidth',2,'color',[.2,.2,1]});

    plot([-.2 9],[baseline baseline],':k','linewidth',2);
    [hleg,icons,~,~]  = legend([hitLeg.mainLine errorLeg.mainLine],'Correct', 'Error') ;
    
    set(gca,'xcolor',[0 0 0],'ycolor',[0 0 0]) % Axis and Legend Properties
    set(hleg,'Position',[0.165 0.86 0.1 0.1])
    set(hleg,'box','off')
    set(hleg,'FontSize',font_legend)
    set(icons(:),'LineWidth',6); 
    axis([2.6 3.9 -.5 1])
    ylabel('z-score','FontSize',font_size)
    xlabel('Time from f1 (s)','FontSize',font_size)
    set(gca,'XTick',[3 3.5])
    set(gca,'XTickLabel',{'0', '0.5' },'FontSize',font_size)
    set(gca,'YTick',[-.5 0 .5 1])
    set(gca,'YTickLabel',{'-.5','0', '.5','1' },'FontSize',font_size)

subplot(1,3,2)
    set(gca,'FontSize',font_size,'LineWidth',1)
    hold on;
    j=2;
    timeAxis = eval(TimeAxis);
    displace(2) = timeAxis{1}(end)+abs(timeAxis{2}(1))+ gap + binWidth{j};
    displace(3) = displace(2) + timeAxis{2}(end) + abs(timeAxis{3}(1)) + gap_rew + binWidth{j};
    timeAx      = timeAxis{j} + displace(j);
    area(xStim2,y2,'EdgeColor',mygray,'FaceColor',mygray)
    area(xStim2,y1,'EdgeColor',mygray,'FaceColor',mygray)

    correct = select(eAl,'clase',[1 12] , 'reward',1);% Select the stimulus classes.
    errores = select(eAl,'clase',[1 12],'reward',0);

    % Obtain the mean firing rates and the error regions
    correctFR = cell2mat({correct.normalized_response_pd}');
    correctStderr = std(correctFR)./sqrt(size(correctFR,1));
    erroresFR = cell2mat({errores.normalized_response_pd}');
    erroresStderr = std(erroresFR)./sqrt(size(erroresFR,1));

    % Plot the results
    shadedErrorBar(timeAx,mean(erroresFR),erroresStderr,{'LineWidth',2,'color',[1,.2,.2]});
    shadedErrorBar(timeAx,mean(correctFR),correctStderr,{'LineWidth',2,'color',[.2,.2,1]});

    plot([-.2 9],[baseline baseline],':k','linewidth',2)

    set(gca,'xcolor',[0 0 0],'ycolor',[0 0 0]) % Axis Properties
    axis([6.1 7.4 -.5 1])
    xlabel('Time from f2 (s)','FontSize',font_size)
    set(gca,'XTick',[6.5 7])
    set(gca,'XTickLabel',{'0', '0.5' },'FontSize',font_size)
    set(gca,'YTick',[-.5 0 .5 1])
    set(gca,'YTickLabel',{'-.5','0', '.5','1' },'FontSize',font_size)

subplot(1,3,3)
    set(gca,'FontSize',font_size,'LineWidth',1)
    hold on;

    plot(xRew,y,'color',mygray,'linewidth',4)
    j=3;
    timeAxis = eval(TimeAxis);
    displace(2) = timeAxis{1}(end)+abs(timeAxis{2}(1))+ gap + binWidth{j};
    displace(3) = displace(2) + timeAxis{2}(end) + abs(timeAxis{3}(1)) + gap_rew + binWidth{j};
    timeAx      = timeAxis{j} + displace(j);

    % Select the trial types.
    correct = select(eAl,'clase',[1 12] , 'reward',1); % Select the stimulus classes.
    errores = select(eAl,'clase',[1 12],'reward',0);

    % Obtain the mean firing rates and error regions
    correctFR = cell2mat({correct.normalized_kd_align_rew}');
    correctStderr = std(correctFR)./sqrt(size(correctFR,1));
    erroresFR = cell2mat({errores.normalized_kd_align_rew}');
    erroresStderr = std(erroresFR)./sqrt(size(erroresFR,1));

    % Plot the results.
    shadedErrorBar(timeAx,mean(erroresFR),erroresStderr,{'LineWidth',2,'color',[1,.2,.2]});
    shadedErrorBar(timeAx,mean(correctFR),correctStderr,{'LineWidth',2,'color',[.2,.2,1]});

    plot([-.2 10.2],[baseline baseline],':k','linewidth',2)
    axis([8.0 9.2 -1 1])

    xlabel('Time from PB (s)','FontSize',font_size) % Axis Properties
    set(gca,'XTick',[xRew(1) xRew(1)+0.5])
    set(gca,'XTickLabel',{'0', '0.5' },'FontSize',font_size)
    set(gca,'YTick',[-1 0 1])
    set(gca,'YTickLabel',{'-1','0','1' },'FontSize',font_size)
    xlabel('Time from PB (s)','FontSize',font_size)

print([results_folder '/Fig4B_correct_error'],'-dpdf','-r600');
print([results_folder '/Fig4B_correct_error'],'-depsc2');

close