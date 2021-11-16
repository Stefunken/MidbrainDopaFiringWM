function [pvals,R,DA_5_Pos] = figure_5_plots(e,results_folder)
%% Pre-Requisits

[e_zscore,timeAx_zscore] = compute_z_score_delay(e); % Z-score during delay
correct = select(e_zscore,'reward',1); % Selcting only correct trials
nNeurons = size(e_zscore,2);
m_all = mean(cell2mat({correct.zscore}')); 
se_all = std(cell2mat({correct.zscore}'))/sqrt(length(correct));

binWidthPos = .25;
positions = [-.5 .25 1.25 2.25 3.25]; % Time position analysed (Aligned to SO1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Zscore delay 2 example neurons

% Figure Pre-requisites
xStim = [3.0 3.0 3.5 3.5];
xStim2 = [6.5 6.5 7.0 7.0];
y2 = [0 1.6 1.6 0];
y1 = [0 -.8 -.8 0];
mygray = [.9 .9 .9];

id_ramp = 5;    % Neuron that shows no ramping behavior
id_N_ramp = 12; % Neuron that shows significant ramping behavior

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig5A -- Ramping Neuron

%%%% LEFT (Z-SCORE TIME COURSE FOR ALL F1 VALUES %%%% 
correct = select(e_zscore(id_ramp),'reward',1);
m = mean(cell2mat({correct.zscore}'));
se = std(cell2mat({correct.zscore}'))/sqrt(length(correct));

% Figure Properties
figure_size = [4.5 2.5];
font_size = 15;
font_legend = 12;
line_width2 = 3;

figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

% For figure explainability
area(xStim,y2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim,y1,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y1,'EdgeColor',mygray,'FaceColor',mygray)
plot([-.2 9],[0 0],':k','linewidth',2)

% Plot results
h = shadedErrorBar(timeAx_zscore,m,se,{'LineWidth',2,'color',[.2,.2,1]});     
[hleg,icons,~,~]  = legend(h.mainLine,'Correct trials') ;

% Axis Properties
set(gca,'xcolor',[0 0 0],'ycolor',[0 0 0])
set(hleg,'Location','North')
set(hleg,'box','off')
set(hleg,'FontSize',font_size)
set(icons(:),'LineWidth',6);
axis([2.1 6.6 -1 1.8])
ylabel('z-score','FontSize',font_size)
xlabel('Time from f1 (s)','FontSize',font_size)
set(gca,'xcolor','k') 
set(gca,'XTick',[3 4 5 6])
set(gca,'XTickLabel',{'0','1','2','3'},'FontSize',font_size) 
set(gca, 'XAxisLocation', 'top')

print([results_folder '/Fig5A_LEFT_zscore__neuron_' num2str(id_ramp)],'-dpdf','-r600');
print([results_folder '/Fig5A_LEFT_zscore__neuron_' num2str(id_ramp)],'-depsc2');
close

%%%% CENTER (Z-SCORE TIME COURSE SORTED BY F1 VALUES) %%%%
f1_range = [10 14 18 24 30 34];
n_f1 = size(f1_range,2);
correct = cell(1,n_f1);
m = zeros(n_f1,size(timeAx_zscore,2));
for  i_f1=1:n_f1  % Obtaining Z-score for each f1 value
    correct{1,i_f1} = select(e_zscore(id_ramp),'reward',1,'stimFreq1',f1_range(1,i_f1)); % Select the stimulus classes.
    m(i_f1,:)=mean(cell2mat({correct{1,i_f1}.zscore}'));
end

figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

% For Figure Explainability
area(xStim,y2+.5,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim,y1-.5,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y2+.5,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y1-.5,'EdgeColor',mygray,'FaceColor',mygray)
plot([-.2 9],[0 0],':k','linewidth',2)

% Plot Results
for i_f1=1:n_f1
    indLeg(i_f1) = plot(timeAx_zscore,m(i_f1,:)  ,'color',[1-i_f1/6 0.5 i_f1/6] ,'linewidth',line_width2);
end
[hleg,icons,~,~]  = legend([indLeg],'f1=10 Hz','f1=14 Hz','f1=18 Hz','f1=24 Hz','f1=30 Hz','f1=34 Hz') ;
  
% Axis Properties
set(gca,'xcolor',[0 0 0],'ycolor',[0 0 0])
set(hleg,'box','off')
set(hleg,'FontSize',font_legend)
set(icons(:),'LineWidth',6); 
axis([2.1 6.6 -1.5 2.5])
ylabel('z-score','FontSize',font_size)
xlabel('Time from f1 (s)','FontSize',font_size)
set(gca,'xcolor','k') 
set(gca,'XTick',[3 4 5 6])
set(gca,'XTickLabel',{'0','1','2','3'},'FontSize',font_size) 
set(gca, 'XAxisLocation', 'top')
set(gca,'YTick',[-1.5 -1 0 1 2])
set(gca,'YTickLabel',{'','-1','0','1','2'},'FontSize',font_size) 

print([results_folder '/Fig5A_CENTER_zscore_by_f1__neuron_' num2str(id_ramp)],'-dpdf','-r600');
print([results_folder '/Fig5A_CENTER_zscore_by_f1__neuron_' num2str(id_ramp)],'-depsc2');
close

%%%% RIGHT (Z-SCORE DELAY BY F1) %%%%
n_f1 = 6;
range_f1 = [10 14 18 24 30 34];        
responseSO_f1 = cell(1,n_f1);
for f1=1:n_f1  % Obtaining Z-score for each f1 value
  correct=select(e(id_ramp),'reward',1,'StimFreq1',[range_f1(f1) range_f1(f1)]); 
  for i = 1:size(correct,2)
      responseSO_f1{1,f1}(1,i) = correct(i).normalized_response_delay;
  end
  n_hits_f1(1,f1) = size(responseSO_f1{1,f1},2);            
  clearvars hits     
end

% One way ANOVA -- F1 response modulation
names = [repmat({'10hz'}, 1, n_hits_f1(1,1)) repmat({'14hz'}, 1, n_hits_f1(1,2))...
         repmat({'18hz'}, 1, n_hits_f1(1,3)) repmat({'24hz'}, 1, n_hits_f1(1,4))...
         repmat({'30hz'}, 1, n_hits_f1(1,5)) repmat({'34hz'}, 1, n_hits_f1(1,6))];
groups = [responseSO_f1{1,1}, responseSO_f1{1,2},responseSO_f1{1,3},...
          responseSO_f1{1,4}, responseSO_f1{1,5},responseSO_f1{1,6}];  
[p_f1_delay,~,~] = anova1(groups, names,'off');
disp(['DA response Delay by F1 Neuron (' num2str(id_ramp) '): p = ' num2str(p_f1_delay)]);

% Figure Properties
figure_size = [2.8 2.5];
font_size = 15;
line_width1 = 2;
marker_size = 6;
x_position = range_f1;

figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1.5)
  
% Plot REsults
for f1 = 1:n_f1
    meanF1 = mean(responseSO_f1{1,f1});
    stderrF1 = std(responseSO_f1{1,f1})./sqrt(size(responseSO_f1{1,f1},2));
    plot(x_position(1,f1),meanF1,'o','Color',[0 0 1],'LineWidth',line_width1);
    f1_handle(1,f1) = errorbar(x_position(1,f1),meanF1,stderrF1,'-','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 1]);
    plot([0 40],[0 0],'k')
end
for i=1:n_f1
    errorbar_tick(f1_handle(1,i),40);
end

% Axis Properties
ylabel({'Delay activity (z-score)'})
xlabel({'f1 (Hz)'})
set(gca,'XTick',[0 20 40],'XTickLabel',{'0','20','40'})
axis([0 40 -.7 1.4])

print('-dpdf',[results_folder '/Fig5A_RIGHT_zscore_delay_by_f1__neuron_' num2str(id_ramp)])
print('-depsc2',[results_folder '/Fig5A_RIGHT_zscore_delay_by_f1__neuron_' num2str(id_ramp)])
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig5B -- No Ramping Neuron 

%%%% LEFT (Z-SCORE TIME COURSE FOR ALL F1 VALUES %%%%
correct = select(e_zscore(id_N_ramp),'reward',1);
m = mean(cell2mat({correct.zscore}'));
se = std(cell2mat({correct.zscore}'))/sqrt(length(correct));

% Figure Properties
figure_size = [4.5 2.5];
font_size = 15;
line_width2 = 3;

figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

% For Figure explainability
area(xStim,y2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim,y1,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y1,'EdgeColor',mygray,'FaceColor',mygray)
plot([-.2 9],[0 0],':k','linewidth',2)

% Plot Results
h=shadedErrorBar(timeAx_zscore,m,se,{'LineWidth',2,'color',[.2,.2,1]});     
[hleg,icons,~,~]  = legend(h.mainLine,'Correct trials') ;
    
% Axis Properties
set(gca,'xcolor',[0 0 0],'ycolor',[0 0 0])
set(hleg,'Location','North')
set(hleg,'box','off')
set(hleg,'FontSize',font_size)
set(icons(:),'LineWidth',6); 
axis([2.1 6.6 -1 1.8])
ylabel('z-score','FontSize',font_size)
xlabel('Time from f1 (s)','FontSize',font_size)
set(gca,'xcolor','k') 
set(gca,'XTick',[3 4 5 6])
set(gca,'XTickLabel',{'0','1','2','3'},'FontSize',font_size) 
set(gca, 'XAxisLocation', 'top')

print([results_folder '/Fig5B_LEFT_zscore__neuron_' num2str(id_N_ramp)],'-dpdf','-r600');
print([results_folder '/Fig5B_LEFT_zscore__neuron_' num2str(id_N_ramp)],'-depsc2');
close

%%%% CENTER (Z-SCORE TIME COURSE SORTED BY F1 VALUES) %%%%
f1_range = [10 14 18 24 30 34];
n_f1 = size(f1_range,2);
correct = cell(1,n_f1);
m = zeros(n_f1,size(timeAx_zscore,2));
for  i_f1=1:n_f1   % Obtaining Z-score for each f1 value
    correct{1,i_f1} = select(e_zscore(id_N_ramp),'reward',1,'stimFreq1',f1_range(1,i_f1)); % Select the stimulus classes.
    m(i_f1,:) = mean(cell2mat({correct{1,i_f1}.zscore}'));
end

figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

% For Figure explainability
area(xStim,y2+.5,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim,y1-.5,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y2+.5,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y1-.5,'EdgeColor',mygray,'FaceColor',mygray)
plot([-.2 9],[0 0],':k','linewidth',2)

% Plot results
for i_f1=1:n_f1
    plot(timeAx_zscore,m(i_f1,:),'color',[1-i_f1/6 0.5 i_f1/6] ,'linewidth',line_width2);
end
    
% Axis Properties
axis([2.1 6.6 -1.5 2.5])
ylabel('z-score','FontSize',font_size)
xlabel('Time from f1 (s)','FontSize',font_size)
set(gca,'xcolor','k') 
set(gca,'XTick',[3 4 5 6])
set(gca,'XTickLabel',{'0','1','2','3'},'FontSize',font_size) 
set(gca, 'XAxisLocation', 'top')
set(gca,'YTick',[-1.5 -1 0 1 2])
set(gca,'YTickLabel',{'','-1','0','1','2'},'FontSize',font_size) 

print([results_folder '/Fig5B_CNETER_zscore_by_f1__neuron_' num2str(id_N_ramp)],'-dpdf','-r600');
print([results_folder '/Fig5B_CNETER_zscore_by_f1__neuron_' num2str(id_N_ramp)],'-depsc2');
close

%%%% RIGHT (Z-SCORE DELAY BY F1) %%%%
n_f1 = 6;
range_f1 = [10 14 18 24 30 34];        
responseSO_f1 = cell(1,n_f1);
for f1=1:n_f1  % Obtaining Z-score for each f1 value
  correct=select(e(id_N_ramp),'reward',1,'StimFreq1',[range_f1(f1) range_f1(f1)]); 
  for i = 1:size(correct,2)
      responseSO_f1{1,f1}(1,i) = correct(i).normalized_response_delay;
  end
  n_hits_f1(1,f1) = size(responseSO_f1{1,f1},2);            
  clearvars hits     
end

% One way ANOVA -- F1 response modulation
names = [repmat({'10hz'}, 1, n_hits_f1(1,1)) repmat({'14hz'}, 1, n_hits_f1(1,2))...
         repmat({'18hz'}, 1, n_hits_f1(1,3)) repmat({'24hz'}, 1, n_hits_f1(1,4))...
         repmat({'30hz'}, 1, n_hits_f1(1,5)) repmat({'34hz'}, 1, n_hits_f1(1,6))];
groups = [responseSO_f1{1,1}, responseSO_f1{1,2},responseSO_f1{1,3},...
          responseSO_f1{1,4}, responseSO_f1{1,5},responseSO_f1{1,6}];  
[p_f1_delay,~,~] = anova1(groups, names,'off');
disp(['DA response Delay by F1 Neuron (' num2str(id_N_ramp) '): p = ' num2str(p_f1_delay)]);

% Figure Properties
figure_size = [2.8 2.5];
font_size = 15;
line_width1 = 2;
marker_size = 6;
x_position = range_f1;

figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1.5)
  
% Plot Results
for f1 = 1:n_f1
    meanF1 = mean(responseSO_f1{1,f1});
    stderrF1 = std(responseSO_f1{1,f1})./sqrt(size(responseSO_f1{1,f1},2));
    plot(x_position(1,f1),meanF1,'o','Color',[0 0 1],'LineWidth',line_width1);
    f1_handle(1,f1) = errorbar(x_position(1,f1),meanF1,stderrF1,'-','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 1]);
    plot([0 40],[0 0],'k')
end
for i=1:n_f1
    errorbar_tick(f1_handle(1,i),40);
end

% Axis Properties
ylabel({'Delay activity (z-score)'})
xlabel({'f1 (Hz)'})
set(gca,'XTick',[0 20 40],'XTickLabel',{'0','20','40'})
axis([0 40 -.7 1.4])
print('-dpdf',[results_folder '/Fig5B_RIGHT_zscore_delay_by_f1__neuron_' num2str(id_N_ramp)])
print('-depsc2',[results_folder '/Fig5B_RIGHT_zscore_delay_by_f1__neuron_' num2str(id_N_ramp)])
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig5C, zscore delay all neurons

% Figure properties
xStim = [3.0 3.0 3.5 3.5];
xStim2 = [6.5 6.5 7.0 7.0];
y2 = [0 .7 .7 0];
y1 = [0 -.5 -.5 0];
mygray = [.9 .9 .9];

figure_size = [8 2.5];
font_size = 15;

figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

area(xStim,y2,'EdgeColor',mygray,'FaceColor',mygray) % Stimuli Regions (Gray Shaded Areas)
area(xStim,y1,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y1,'EdgeColor',mygray,'FaceColor',mygray)

for i = 1:5 % Delay positions Analysed in Fig5E (horizontal bars)
    if i==1
        plot([positions(i)+3-binWidthPos/2 positions(i)+3+binWidthPos/2], [.78 .78], 'color',[1 .5 0], 'LineWidth',5 )        
    else
        plot([positions(i)+3-binWidthPos/2 positions(i)+3+binWidthPos/2], [.78 .78], 'k', 'LineWidth',5 )        
    end
end
h = shadedErrorBar(timeAx_zscore,m_all,se_all,{'LineWidth',2,'color',[.2,.2,1]});
[hleg,icons,~,~]  = legend(h.mainLine,'Correct trials') ;   
plot([-.2 9],[0 0],':k','linewidth',2)
     
set(gca,'xcolor',[0 0 0],'ycolor',[0 0 0])
set(hleg,'Location','South')
set(hleg,'box','off')
set(hleg,'FontSize',font_size)
set(icons(:),'LineWidth',6); 
axis([2.1 6.6 -.3 .85])

ylabel('z-score','FontSize',font_size)
xlabel('Time from f1 (s)','FontSize',font_size)
set(gca,'xcolor','k') 
set(gca,'XTick',positions+3)
set(gca,'XTickLabel',{'-.5', '.25' ,'1.25','2.25','3.25'},'FontSize',font_size) 
set(gca, 'XAxisLocation', 'top')

print([results_folder '/Fig5C_Z_score-all_neurons'],'-dpdf','-r600');
print([results_folder '/Fig5C_Z_score-all_neurons'],'-depsc2');
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig5D, non overlapping bins delay -- Ramping Evidence

%%% OBTAINING BASELINE ZSCORE %%%
eKD = alignSpikes(e,'KeyDown'); allTypes = select(eKD); % Aligning Spikes to KD Events for ALL trials
allFR = firingrate([allTypes.spikeTimes],1,'filtertype','boxcar','timeconstant',.5); % FR -- 1 Second After KD
baseline = mean(allFR);
std_base = std(allFR);

%%% ZSCORE COMPUTING PRE-REQUISITES %%%
binWidth = .35; filterType = 'boxcar';                   % Firing Rate pre-requisites
timeAxis = (-.1+binWidth/2):binWidth:(2.5-binWidth/2);   % Time points to evaluate FR
whichstats = {'rsquare','tstat','fstat'};                % Stats to analyse the linear Regression

%%% OBTAINING ZSCOREs %%%
eAl = alignSpikes(e,'StimOff1');                    % Align spikes to f1 Offset 
correct = select(eAl,'clase',[1 12] , 'reward',1);  % All correct trials
correctFR_ALL = firingrate([correct.spikeTimes],timeAxis,'filtertype',filterType,'timeconstant',binWidth);
Zscore = compute_zscore(correctFR_ALL,baseline,std_base);

% Figure Properties
figure_size = [3.75 2.5];
font_size = 15;
line_width1 = 1.4;

figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

% For figure explainability
plot([0 0],[-.5 1.25], 'color',mygray,'linewidth',3)
plot([3 3],[-.5 1.25], 'color',mygray,'linewidth',3) 
plot([-.2 3],[0 0],':k','linewidth',1.5)

% We will analyse each neuron separately as well
RampingNeurons = zeros(1,nNeurons); pvals = zeros(1,nNeurons); R = pvals;
correctFR_N = zeros(nNeurons,size(timeAxis,2));
for iN = 1:nNeurons
    correct = select(eAl(iN),'clase',[1 12] , 'reward',1);
    base = select(eKD(iN),'clase',[1 12], 'reward',1);
    baseline_FR_N = firingrate([base.spikeTimes],1,'filtertype','boxcar','timeconstant',.5); 
    FR = firingrate([correct.spikeTimes],timeAxis,'filtertype',filterType,'timeconstant',binWidth);
    correctFR_N(iN,:) = mean(FR);
    correctFR_N(iN,:) = (correctFR_N(iN,:)-mean(baseline_FR_N))/std(baseline_FR_N);
    stats_N(iN) = regstats(correctFR_N(iN,:),timeAxis,'interaction',whichstats);
    pvals(1,iN) = stats_N(iN).tstat.pval(2);
    R(1,iN) = sqrt(stats_N(iN).rsquare);
    R(2,iN) = stats_N(iN).tstat.beta(2);
    if pvals(1,iN) < 0.05; RampingNeurons(1,iN) = RampingNeurons(1,iN) + 1; end
end

% Linear Regression for ramping behavior
y_variable = mean(correctFR_ALL);%mean(Zscore);%
correctStderr = std(correctFR_ALL)/sqrt(size(correctFR_ALL,1));%std(Zscore)/sqrt(size(Zscore,1));%
stats = regstats(y_variable,timeAxis,'interaction',whichstats); 

% Plotting results
plot(timeAxis,stats.tstat.beta(1) + stats.tstat.beta(2)*timeAxis,'r','LineWidth',2) % Linear Regression
errorbar(timeAxis,y_variable,correctStderr,'-b','LineWidth',line_width1);           % Zscore
  
% Axis Properties
% axis([-.20 3.5 5.8 6.8])
axis([-.20 3.5 -.1 .3])
ylabel('z-score','FontSize',font_size)
% ylabel('Firing Rate (Hz)','FontSize',font_size)
xlabel('Time from f1 offset (s)')
set(gca,'xcolor','k','YTick',[-.1 0 .1 .2 .3],'YTickLabels',{'-0.1', '0', '0.1', '0.2', '0.3'}) 
text(0.45, .25, {['R = ' num2str(round(sqrt(stats.rsquare)*100)/100)]},'Color',[1 0 0],'FontSize',12,'HorizontalAlignment', 'Center');
% text(0.45, .25, {['p = ' num2str(stats.tstat.pval(2), '%.5f')]},'Color',[1 0 0],'FontSize',12,'HorizontalAlignment', 'Center');
% text(0.45, .25, {['r^2 = ' num2str(stats.rsquare, '%.2f')]},'Color',[1 0 0],'FontSize',12,'HorizontalAlignment', 'Center');

if 0  % If 1 ==> Plots p-value of the regression and an inset with the number of significant ramping neurons
    if stats.tstat.pval(2) < 0.01
        text(1.45, .35, {['p<0.01']},'Color',[1 0 0],'FontSize',12,'HorizontalAlignment', 'Center');
    else
        text(1.45, .35, {['p = ' num2str(stats.tstat.pval(2))]},'Color',[1 0 0],'FontSize',12,'HorizontalAlignment', 'Center');
    end
    axes('Position',[.75 .75 .15 .2])
    box on
    bar([sum(RampingNeurons) nNeurons-sum(RampingNeurons)])
    ylabel('# Neurons','FontSize',8);
    xlim([0.4 2.6]);
    ylim([0 20]);
    set(gca,'XTickLabels',{'p<0.05';'p>0.05'},'FontSize',8)
    xtickangle(45);
end

print([results_folder '/Fig5D_activity_f1_delay_non_overlapping'],'-dpdf','-r600');
print('-depsc2',[results_folder '/Fig5D_activity_f1_delay_non_overlapping']);
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig5E, Linear Regression in 5 delay positions 

n_f1 = 6;
range_f1 = [10 14 18 24 30 34];        
vect = cell(6,1);
for f1 = 1:n_f1
     correct = select(e_zscore,'reward',1,'StimFreq1',[range_f1(f1) range_f1(f1)]); 
     vect{f1,1} = [correct.p1;correct.p2;correct.p3;correct.p4;correct.p5]; % Z-score in 5 positions
end

% Figure properties
figure_size = [8 1.4];
font_size = 10;

figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

disp('----------------------------------------------');
disp('DA in delay; 5 positions compared to DA in .5s before SO1:');

DA_5_Pos = zeros(2,5); % DA Z-score in 5 Temporally Ordered Positions
pos = positions; 

for i = 1:5 % Looping over temporal positions
    DA = [];
    DA_Before = [];
    n_hits_f1 = zeros(1,n_f1);
    mean_hits = zeros(1,n_f1);
    std_hits = zeros(1,n_f1);
    for f1 = 1:n_f1 % Z-score for each f1 value
          responseSO_f1 = vect{f1,1}(i,:);    
          n_hits_f1(1,f1) = size(responseSO_f1,2);
          mean_hits(1,f1) = mean(responseSO_f1);  
          std_hits(1,f1) = std(responseSO_f1);
          DA_Before = cat(2,DA_Before,vect{f1,1}(1,:));
          DA = cat(2,DA,responseSO_f1);
    end
    DA_5_Pos(1,i) = mean(mean_hits(1,:));                  
    DA_5_Pos(2,i) = signrank(DA,DA_Before,'Tail','Right'); % Wilcoxon Signed Ranked Test for increasing DA Activity during the delay period
    disp(['Position ' num2str(pos(1,i)) 's: ' num2str(DA_5_Pos(1,i)) ' > ' num2str(DA_5_Pos(1,1)) ' with p = ' num2str(DA_5_Pos(2,i))]);
    
    subplot(1,5,i)    
        hold on;

        % Linear regression
        whichstats = {'rsquare','tstat','fstat'};
        yFit = mean_hits;
        xFit = range_f1;
        stats = regstats(yFit,xFit,'linear',whichstats);
        slope = stats.tstat.beta(2);
        b     = stats.tstat.beta(1);

        % Plots the results
        for f1 = 1:6
            stderrF1 = std_hits(1,f1)/sqrt(n_hits_f1(1,f1));
            errorbar(xFit(1,f1),yFit(1,f1),stderrF1,'.','MarkerSize',12,'LineWidth',.8,'color',[0 0 1]);
        end
        line(xFit(1:end),xFit(1:end)*slope+b,'linestyle','-','LineWidth',1);

        % Axis properties
        axis([0 40 -.25 .70])
        xlabel({'f1 (Hz)'},'FontSize',font_size)
        if i==1
            ylabel('z-score','FontSize',font_size)
            lr = text(-35,-.35,{'   Linear','Regression'},'FontSize',12,'Color','r');
            set(lr,'Rotation',90);
        end
        set(gca,'xcolor','k') 
%         title(['r^2 = ' num2str(stats.rsquare, '%.2f')],'Color','r');
        title(['p = ' num2str(stats.tstat.pval(2), '%.2f')],'Color','r');
end

print([results_folder '/Fig5E_Linear_Reg_Zscore_5positions'],'-dpdf','-r600');
print([results_folder '/Fig5E_Linear_Reg_Zscore_5positions'],'-depsc2','-r600');
close

%%%%%% One-Way ANOVA in 5 delay positions %%%%%% 
if 0 % Not performed here -- Set to 1 Otherwise
    figure_size = [8 1.4]; % Figure properties
    font_size = 10;
    
    figure('visible','off'),clf, hold on
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',figure_size)
    set(gcf, 'PaperPosition', [0 0 figure_size])
    set(gca,'FontSize',font_size,'LineWidth',1)

    for i = 1:5 % Looping over temporal positions
        n_hits_f1 = zeros(1,n_f1);
        mean_hits = zeros(1,n_f1);
        std_hits = zeros(1,n_f1);
        for f1=1:n_f1 % Z-score for each f1 value
            responseSO_f1 = vect{f1,1}(i,:);
            n_hits_f1(1,f1) = size(responseSO_f1,2);
            mean_hits(1,f1) = mean(responseSO_f1);  
            std_hits(1,f1) = std(responseSO_f1);      
        end
        
        % ANOVA Analysis
        groups = []; 
        names = [repmat({'10hz'}, 1, n_hits_f1(1,1)) repmat({'14hz'}, 1, n_hits_f1(1,2)) repmat({'18hz'}, 1, n_hits_f1(1,3)) ...
        repmat({'24hz'}, 1, n_hits_f1(1,4)) repmat({'30hz'}, 1, n_hits_f1(1,5)) repmat({'34hz'}, 1, n_hits_f1(1,6))];
        for f1 = 1:6 
            groups = [groups vect{f1,1}(i,:)];
        end
        p = anova1(groups, names,'off');
    
        subplot(1,5,i)  
            hold on
            yFit = mean_hits;
            xFit = range_f1;

            % Plots the results
            for f1 = 1:6
                stderrF1 = std_hits(1,f1)/sqrt(n_hits_f1(1,f1));
                errorbar(xFit(1,f1),yFit(1,f1),stderrF1,'.','MarkerSize',12,'LineWidth',.8,'color',[0 0 1]);
            end     

            % Axis Properties
            axis([0 40 -.25 .65])
            xlabel({'f1 (Hz)'},'FontSize',font_size)
            if i==1
                ylabel('z-score','FontSize',font_size)
                lr = text(-35,-.15,{'ANOVA'},'FontSize',12,'Color','r');
                set(lr,'Rotation',90);
            end
            set(gca,'xcolor','k')
            title(['p = ' num2str(p, '%.2f')],'Color','r'); 
    end
    print([results_folder '/ANOVA-z-score-5positions-neurons-ALL '],'-dpdf','-r600');
    close
end
