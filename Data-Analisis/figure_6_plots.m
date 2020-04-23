function figure_6_plots(e,results_folder)

[e_zscore,timeAx_zscore] = compute_z_score_delay(e);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
correct=select(e_zscore,'reward',1);

m=mean(cell2mat({correct.zscore}'));
se=std(cell2mat({correct.zscore}'))/sqrt(length(correct));

binWidthPos = .25;
positions = [-.5 .25 1.25 2.25 3.25]; % center stim is .3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig7C TOP, zscore delay all neurons

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xStim = [3.0 3.0 3.5 3.5];
xStim2 = [6.5 6.5 7.0 7.0];
y2 = [0 .7 .7 0];
y1 = [0 -.5 -.5 0];
mygray = [.9 .9 .9];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% figure properties
figure_size = [8 2.5];
font_size = 15;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

area(xStim,y2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim,y1,'EdgeColor',mygray,'FaceColor',mygray)

area(xStim2,y2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y1,'EdgeColor',mygray,'FaceColor',mygray)

for i=1:5
    if i==1
        plot([positions(i)+3-binWidthPos/2 positions(i)+3+binWidthPos/2], [.78 .78], 'color',[1 .5 0], 'LineWidth',5 )        
    else
        plot([positions(i)+3-binWidthPos/2 positions(i)+3+binWidthPos/2], [.78 .78], 'k', 'LineWidth',5 )
        
    end
end

     h=shadedErrorBar(timeAx_zscore,m,se,{'LineWidth',2,'color',[.2,.2,1]});
     
    [hleg,icons,~,~]  = legend(h.mainLine,'Correct trials') ;
    
plot([-.2 9],[0 0],':k','linewidth',2)
     
set(gca,'xcolor',[0 0 0],'ycolor',[0 0 0])
set(hleg,'Location','South')

set(hleg,'box','off')
set(hleg,'FontSize',font_size)
set(icons(:),'LineWidth',6); %// Or whatever
axis([2.1 6.6 -.3 .85])

ylabel('z-score','FontSize',font_size)
xlabel('Time from f1 (s)','FontSize',font_size)
 
set(gca,'xcolor','k') 
set(gca,'XTick',positions+3)
set(gca,'XTickLabel',{'-.5', '.25' ,'1.25','2.25','3.25'},'FontSize',font_size) 
set(gca, 'XAxisLocation', 'top')

%print([results_folder '/Fig6C_Top_z_score-all_neurons'],'-dpdf','-r600');
print([results_folder '/Fig6C_Top_z_score-all_neurons'],'-depsc2');

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig7C BOTTOM, Linear regression 5 positions 
n_f1 = 6;
range_f1 = [10 14 18 24 30 34];        

vect = cell(6,1);
for f1=1:n_f1
     correct=select(e_zscore,'reward',1,'StimFreq1',[range_f1(f1) range_f1(f1)]); 
     
     vect{f1,1} = [correct.p1;correct.p2;correct.p3;correct.p4;correct.p5];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure properties
figure_size = [8 1.4];
font_size = 10;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

for i = 1:5

    for f1=1:n_f1     
          responseSO_f1 = vect{f1,1}(i,:);    
          n_hits_class(1,f1) = size(responseSO_f1,2);
          mean_hits(1,f1) = mean(responseSO_f1);  
          std_hits(1,f1) = std(responseSO_f1);    
    end
    
    subplot(1,5,i)    
    hold on
    % linear regression
    whichstats = {'rsquare','tstat','fstat'};
    yFit = mean_hits;
    xFit = range_f1;
    stats = regstats(yFit,xFit,'linear',whichstats);

    slope = stats.tstat.beta(2);
    b     = stats.tstat.beta(1);
    
    % plots the results
        for f1=1:6
            stderrF1 = std_hits(1,f1)/sqrt(n_hits_class(1,f1));
            f1_handle(1,f1)= errorbar(xFit(1,f1),yFit(1,f1),stderrF1,'.','MarkerSize',12,'LineWidth',.8,'color',[0 0 1]);
        end
        
        
        hFit = line(xFit(1:end),xFit(1:end)*slope+b,'linestyle','-','LineWidth',1);
    

    axis([0 40 -.25 .65])
    xlabel({'f1 (Hz)'},'FontSize',font_size)

    
    if i==1
        ylabel('z-score','FontSize',font_size)
        lr=text(-35,-.35,{'   Linear','Regression'},'FontSize',12,'Color','r');
        set(lr,'Rotation',90);

    end
    

    set(gca,'xcolor','k') 
   
 if i==2
  t=title(['r^2 = 0.49'],'Color','r');%; ['p = ' num2str(stats.fstat.pval, '%.2f')]}); 
 else
 t=title(['r^2 = ' num2str(stats.rsquare, '%.2f')],'Color','r');%; ['p = ' num2str(stats.fstat.pval, '%.2f')]}); 
 end
    
end

%print([results_folder '/Fig6C_Bottom_Linear_Reg_zscore_5positions'],'-dpdf','-r600');
print([results_folder '/Fig6C_Bottom_Linear_Reg_zscore_5positions'],'-depsc2','-r600');

close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
%% ONE WAY ANOVA 5 POSITIONS
for i_n=1%:size(e,2)
% figure properties
figure_size = [8 1.4];
font_size = 10;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Response during delay by f1
figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

for i = 1:5

    for f1=1:n_f1
          responseSO_f1 = vect{f1,1}(i,:);
          n_hits_class(1,f1) = size(responseSO_f1,2);
          mean_hits(1,f1) = mean(responseSO_f1);  
          std_hits(1,f1) = std(responseSO_f1);      
    end
    
    
    groups = [];

    names = [repmat({'10hz'}, 1, n_hits_class(1,1)) repmat({'14hz'}, 1, n_hits_class(1,2)) repmat({'18hz'}, 1, n_hits_class(1,3)) ...
    repmat({'24hz'}, 1, n_hits_class(1,4)) repmat({'30hz'}, 1, n_hits_class(1,5)) repmat({'34hz'}, 1, n_hits_class(1,6))];
    for f1=1:6 
        groups = [groups vect{f1,1}(i,:)];
    end
     p = anova1(groups, names,'off');
%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(1,5,i)  
    hold on
     yFit = mean_hits;
     xFit = range_f1;
     
    % plots the results
        for f1=1:6
            stderrF1 = std_hits(1,f1)/sqrt(n_hits_class(1,f1));
            f1_handle(1,f1)= errorbar(xFit(1,f1),yFit(1,f1),stderrF1,'.','MarkerSize',12,'LineWidth',.8,'color',[0 0 1]);
        end      
    axis([0 40 -.25 .65])

    xlabel({'f1 (Hz)'},'FontSize',font_size)

    if i==1
        ylabel('z-score','FontSize',font_size)
        lr=text(-35,-.15,{'ANOVA'},'FontSize',12,'Color','r');
        set(lr,'Rotation',90);

    end
    
    set(gca,'xcolor','k')
  
    t=title(['p = ' num2str(p, '%.2f')],'Color','r'); 

    
end
    print([result_folder '/ANOVA-z-score-5positions-neurons-ALL '],'-dpdf','-r600');
close
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Fig6A, zscore delay 2 example neurons

xStim = [3.0 3.0 3.5 3.5];
xStim2 = [6.5 6.5 7.0 7.0];
y2 = [0 1.6 1.6 0];
y1 = [0 -.8 -.8 0];
mygray = [.9 .9 .9];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% figure properties
figure_size = [4.5 2.5];
font_size = 15;
font_legend = 12;
line_width2 = 3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig6A TOP, neuron 8

correct=select(e_zscore(8),'reward',1);
m=mean(cell2mat({correct.zscore}'));
se=std(cell2mat({correct.zscore}'))/sqrt(length(correct));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

area(xStim,y2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim,y1,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y1,'EdgeColor',mygray,'FaceColor',mygray)

    h=shadedErrorBar(timeAx_zscore,m,se,{'LineWidth',2,'color',[.2,.2,1]});     
    [hleg,icons,~,~]  = legend(h.mainLine,'Correct trials') ;
    
plot([-.2 9],[0 0],':k','linewidth',2)
  
set(gca,'xcolor',[0 0 0],'ycolor',[0 0 0])
set(hleg,'Location','North')

set(hleg,'box','off')
set(hleg,'FontSize',font_size)
set(icons(:),'LineWidth',6); %// Or whatever
axis([2.1 6.6 -1 1.8])

ylabel('z-score','FontSize',font_size)
xlabel('Time from f1 (s)','FontSize',font_size)
 
set(gca,'xcolor','k') 
set(gca,'XTick',[3 4 5 6])
set(gca,'XTickLabel',{'0','1','2','3'},'FontSize',font_size) 
set(gca, 'XAxisLocation', 'top')

%print([results_folder '/Fig6A_bottom_zscore_neuron_8'],'-dpdf','-r600');
print([results_folder '/Fig6A_bottom_zscore_neuron_8'],'-depsc2');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %% Fig6A BOTTOM, neuron 5

correct=select(e_zscore(5),'reward',1);
m=mean(cell2mat({correct.zscore}'));
se=std(cell2mat({correct.zscore}'))/sqrt(length(correct));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

area(xStim,y2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim,y1,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y1,'EdgeColor',mygray,'FaceColor',mygray)

    h=shadedErrorBar(timeAx_zscore,m,se,{'LineWidth',2,'color',[.2,.2,1]});     
    [hleg,icons,~,~]  = legend(h.mainLine,'Correct trials') ;
    
plot([-.2 9],[0 0],':k','linewidth',2)
   
set(gca,'xcolor',[0 0 0],'ycolor',[0 0 0])
set(hleg,'Location','North')

set(hleg,'box','off')
set(hleg,'FontSize',font_size)
set(icons(:),'LineWidth',6); %// Or whatever
axis([2.1 6.6 -1 1.8])

ylabel('z-score','FontSize',font_size)
xlabel('Time from f1 (s)','FontSize',font_size)
 
set(gca,'xcolor','k') 
set(gca,'XTick',[3 4 5 6])
set(gca,'XTickLabel',{'0','1','2','3'},'FontSize',font_size) 
set(gca, 'XAxisLocation', 'top')

%print([results_folder '/Fig6A_top_zscore_neuron_5'],'-dpdf','-r600');
print([results_folder '/Fig6A_top_zscore_neuron_5'],'-depsc2');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig6B LEFT BOTTOM, neuron 5 by f1

f1_range = [10 14 18 24 30 34];
n_f1 = size(f1_range,2);
correct = cell(1,n_f1);
m = zeros(n_f1,size(timeAx_zscore,2));
for  i_f1=1:n_f1   
correct{1,i_f1} = select(e_zscore(5),'reward',1,'stimFreq1',f1_range(1,i_f1)); % Select the stimulus classes.
m(i_f1,:)=mean(cell2mat({correct{1,i_f1}.zscore}'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

area(xStim,y2+.5,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim,y1-.5,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y2+.5,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y1-.5,'EdgeColor',mygray,'FaceColor',mygray)

for i_f1=1:n_f1
indLeg(i_f1) = plot(timeAx_zscore,m(i_f1,:)  ,'color',[1-i_f1/6 0.5 i_f1/6] ,'linewidth',line_width2);
end
    
plot([-.2 9],[0 0],':k','linewidth',2)
  
[hleg,icons,~,~]  = legend([indLeg],'f1=10 Hz','f1=14 Hz','f1=18 Hz','f1=24 Hz','f1=30 Hz','f1=34 Hz') ;
  
set(gca,'xcolor',[0 0 0],'ycolor',[0 0 0])

set(hleg,'box','off')
set(hleg,'FontSize',font_legend)
set(icons(:),'LineWidth',6); %// Or whatever
axis([2.1 6.6 -1.5 2.5])

ylabel('z-score','FontSize',font_size)
xlabel('Time from f1 (s)','FontSize',font_size)
 
set(gca,'xcolor','k') 
set(gca,'XTick',[3 4 5 6])
set(gca,'XTickLabel',{'0','1','2','3'},'FontSize',font_size) 
set(gca, 'XAxisLocation', 'top')
set(gca,'YTick',[-1.5 -1 0 1 2])
set(gca,'YTickLabel',{'','-1','0','1','2'},'FontSize',font_size) 

%print([results_folder '/Fig6B_left_top_zscore_by_f1_neuron_5'],'-dpdf','-r600');
print([results_folder '/Fig6B_left_top_zscore_by_f1_neuron_5'],'-depsc2');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig6B LEFT TOP, neuron 8 by f1
f1_range = [10 14 18 24 30 34];
n_f1 = size(f1_range,2);
correct = cell(1,n_f1);
m = zeros(n_f1,size(timeAx_zscore,2));
for  i_f1=1:n_f1   
correct{1,i_f1} = select(e_zscore(8),'reward',1,'stimFreq1',f1_range(1,i_f1)); % Select the stimulus classes.
m(i_f1,:)=mean(cell2mat({correct{1,i_f1}.zscore}'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

area(xStim,y2+.5,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim,y1-.5,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y2+.5,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y1-.5,'EdgeColor',mygray,'FaceColor',mygray)

for i_f1=1:n_f1
plot(timeAx_zscore,m(i_f1,:)  ,'color',[1-i_f1/6 0.5 i_f1/6] ,'linewidth',line_width2);
end
    
plot([-.2 9],[0 0],':k','linewidth',2)
axis([2.1 6.6 -1.5 2.5])

ylabel('z-score','FontSize',font_size)
xlabel('Time from f1 (s)','FontSize',font_size)
 
set(gca,'xcolor','k') 
set(gca,'XTick',[3 4 5 6])
set(gca,'XTickLabel',{'0','1','2','3'},'FontSize',font_size) 
set(gca, 'XAxisLocation', 'top')
set(gca,'YTick',[-1.5 -1 0 1 2])
set(gca,'YTickLabel',{'','-1','0','1','2'},'FontSize',font_size) 

%print([results_folder '/Fig6B_left_bottom_zscore_by_f1_neuron_8'],'-dpdf','-r600');
print([results_folder '/Fig6B_left_bottom_zscore_by_f1_neuron_8'],'-depsc2');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig6B RIGHT BOTTOM, neuron 8 by f1
index_neuron = 8;
n_f1 = 6;
range_f1 = [10 14 18 24 30 34];        
responseSO_f1 = cell(1,n_f1);
  for f1=1:n_f1  
      correct=select(e(index_neuron),'reward',1,'StimFreq1',[range_f1(f1) range_f1(f1)]); 
      for i = 1:size(correct,2)
          responseSO_f1{1,f1}(1,i) = correct(i).normalized_response_delay;
      end
          n_hits_class(1,f1) = size(responseSO_f1{1,f1},2);            
      clearvars hits     
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
figure_size = [2.8 2.5];
font_size = 15;
line_width1 = 2;
marker_size = 6;
x_position = range_f1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1.5)
  
for f1 = 1:n_f1
meanF1 = mean(responseSO_f1{1,f1});
stderrF1 = std(responseSO_f1{1,f1})./sqrt(size(responseSO_f1{1,f1},2));
plot(x_position(1,f1),meanF1,'o','Color',[0 0 1],'LineWidth',line_width1);
f1_handle(1,f1)= errorbar(x_position(1,f1),meanF1,stderrF1,'-','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 1]);
plot([0 40],[0 0],'k')
end

for i=1:n_f1
errorbar_tick(f1_handle(1,i),40);
end

ylabel({'Delay activity (z-score)'})
xlabel({'f1 (Hz)'})

set(gca,'XTick',[0 20 40],'XTickLabel',{'0','20','40'})
axis([0 40 -.7 1.4])
%print('-dpdf',[results_folder '/Fig6B_right_bottom_response_delay_byf1_neuron_' num2str(index_neuron)])
print('-depsc2',[results_folder '/Fig6B_right_bottom_response_delay_byf1_neuron_' num2str(index_neuron)])
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig6B RIGHT TOP, neuron 5 by f1
index_neuron = 5;
n_f1 = 6;
range_f1 = [10 14 18 24 30 34];        
responseSO_f1 = cell(1,n_f1);
  for f1=1:n_f1  
      correct=select(e(index_neuron),'reward',1,'StimFreq1',[range_f1(f1) range_f1(f1)]); 
      for i = 1:size(correct,2)
          responseSO_f1{1,f1}(1,i) = correct(i).normalized_response_delay;
      end
          n_hits_class(1,f1) = size(responseSO_f1{1,f1},2);            
      clearvars hits     
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
figure_size = [2.8 2.5];
font_size = 15;
line_width1 = 2;
marker_size = 6;
x_position = range_f1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1.5)
  
for f1 = 1:n_f1
meanF1 = mean(responseSO_f1{1,f1});
stderrF1 = std(responseSO_f1{1,f1})./sqrt(size(responseSO_f1{1,f1},2));
plot(x_position(1,f1),meanF1,'o','Color',[0 0 1],'LineWidth',line_width1);
f1_handle(1,f1)= errorbar(x_position(1,f1),meanF1,stderrF1,'-','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 1]);
plot([0 40],[0 0],'k')
end

for i=1:n_f1
errorbar_tick(f1_handle(1,i),40);
end

ylabel({'Delay activity (z-score)'})
xlabel({'f1 (Hz)'})

set(gca,'XTick',[0 20 40],'XTickLabel',{'0','20','40'})
axis([0 40 -.7 1.4])
%print('-dpdf',[results_folder '/Fig6B_right_top_response_delay_byf1_neuron_' num2str(index_neuron)])
print('-depsc2',[results_folder '/Fig6B_right_top_response_delay_byf1_neuron_' num2str(index_neuron)])
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig6D, non overlapping bins delay
eAl = alignSpikes(e,'KeyDown');
allTypes = select(eAl);
allFR = firingrate([allTypes.spikeTimes],1,'filtertype','boxcar','timeconstant',.5); % come in z-score
baseline = mean(allFR);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure_size = [3.75 2.5];
font_size = 15;
line_width1 = 1.4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot allAlignments Correct trials - POSTER SIZE
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

plot([0 0],[-.25 1.25], 'color',mygray,'linewidth',3)
plot([3 3],[-.25 1.25], 'color',mygray,'linewidth',3)

align    = {'StimOff1'}; 

plot([-.2 3],[0 0],':k','linewidth',1.5)
  
binWidth = .35; % 
filterType = 'boxcar';
timeAxis = (-.1+binWidth/2):0.35:(3-binWidth/2); 
eAl = alignSpikes(e,align); % Align spikes
 
% Select the trial types.
correct = select(eAl,'clase',[1 12] , 'reward',1);%'stimFreq1',10); % Select the stimulus classes.
correctFR = firingrate([correct.spikeTimes],timeAxis,'filtertype',filterType,'timeconstant',binWidth);
correctStderr = std(correctFR)./sqrt(size(correctFR,1));

y_variable = mean(correctFR)-baseline;
  whichstats = {'rsquare','tstat','fstat'};
stats = regstats(y_variable,timeAxis,'interaction',whichstats); 

plot(timeAxis,stats.tstat.beta(1) + stats.tstat.beta(2)*timeAxis,'r','LineWidth',2)
  
plot(timeAxis,y_variable,'b','LineWidth',2);

correct_handle= errorbar(timeAxis,y_variable,correctStderr,'-','LineWidth',line_width1);
errorbar_tick(correct_handle,40);
  
axis([-.20 3.5 -.5 1.5])
ylabel({'Firing rate -';'baseline (Hz)'},'FontSize',font_size)
xlabel('Time from f1 offset (s)')

set(gca,'xcolor','k') 
text(2.45, 1.45, {['R=' num2str(round(sqrt(stats.rsquare)*100)/100)]},'Color',[1 0 0],'FontSize',12,'HorizontalAlignment', 'Center');

%print([results_folder '/Fig6D_activity_f1_delay_non_overlapping'],'-dpdf','-r600');
print('-depsc2',[results_folder '/Fig6D_activity_f1_delay_non_overlapping']);
close
end