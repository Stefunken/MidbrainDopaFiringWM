function [Long_RT,Short_RT] = figure_6_plots(e,results_folder)
%% Fig7A - ZSCORE - Correct Trials Sorted by RT + ROC Significancy

load('results_roc_rt.mat') % Load ROC results from the preprocessed_data folder
align    = {'ProbeDown','StimOn1' , 'PushKey'}; % Three Events
binWidth = {.25, .25, .25};                     % Window Size for each event alignment
filterType = 'boxcar';
TimeAxis = ['{ (-0.5+binWidth{j}/2):0.05:(1.5-binWidth{j}/2),' ...
    '  (-1.5+binWidth{j}/2):0.05:(4.5-binWidth{j}/2),' ...
    '  (-0.1+binWidth{j}/2):0.05:(1.0-binWidth{j}/2) }']; % Time Axis for each Event Alignment
binWidth_ROC = 0.01;
TimeAxisROC = ['{ (-0.5+binWidth_ROC/2):binWidth_ROC:(1.5-binWidth_ROC/2),' ...
    '  (-1.5+binWidth_ROC/2):binWidth_ROC:(4.5-binWidth_ROC/2),' ...
    '  (-0.1+binWidth_ROC/2):binWidth_ROC:(1.5-binWidth_ROC/2) }']; % Time Axis for ROC Significancy test

%%% Variables for Figure Representation %%%
gap  = .1; % Temporal gap between different plot alignments
gap_rew = 2;
y = [-.5 1.22];
xOn1 = [3 3];
xOff1 = [3.5 3.5];
xOn2 = [6.5 6.5];
xOff2 = [7 7]; 
xPD = [0 0];
xRew = [8.0 8.0] + gap_rew;
xStim = [3.0 3.0 3.5 3.5];
xStim2 = [6.5 6.5 7.0 7.0];
y2 = [0 1.22 1.22 0];
y1 = [0 -.5 -.5 0];
mygray = [.9 .9 .9];
x = [-1.2+xOn1(1) xOn1(1) xOff1(1) xOn2(1) xOff2(1) xRew(1)];
yT1 = 1.10;
xS1 = 3:.01:3.5;
yS1 = yT1+.4*sin(3*(-pi:2*pi/50:pi));
xS2 = 6.5:.01:7.0;
yS2 = yT1+.4*sin(5*(-pi:2*pi/50:pi));
shift_yT = 3/4*yT1;

% Figure Properties
figure_size = [15 3.5]; % [18.5 3.5]
font_size = 15;

figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1,'XColor','w')

% For Figure Explainability (Stimulus time regions, task scheme, ...)
plot(xPD,y, 'color',mygray,'linewidth',5)
area(xStim,y2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim,y1,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y1,'EdgeColor',mygray,'FaceColor',mygray)
plot(xRew,y, 'color',mygray,'linewidth',5)
yVert = .06;
plot([xPD(1) xPD(1)+0.5],[yT1 yT1],'k','linewidth',1)
plot([xPD(1) xPD(1)],[yT1-yVert yT1+yVert],'k','linewidth',1)
plot([xPD(1)+0.5-.03 xPD(1)+0.5+.03],[yT1-yVert yT1+yVert],'k','linewidth',1)
plot([x(1)-.03 x(1)+.03],[yT1-yVert yT1+yVert],'k','linewidth',1)
plot([x(1) x(2)],[yT1 yT1],'k','linewidth',1)
plot(xS1,.25*yS1+shift_yT,'k','linewidth',1)
plot([x(3) x(4)],[yT1 yT1],'k','linewidth',1)
plot(xS2,.25*yS2+shift_yT,'k','linewidth',1)
plot([x(5) x(5)+.9],[yT1 yT1],'k','linewidth',1)
plot([x(6)-.8 x(6)+1],[yT1 yT1],'k','linewidth',1)
plot([x(6) x(6)],[yT1-yVert yT1+yVert],'k','linewidth',1)
plot([x(5)+.9-.03 x(5)+.9+.03],[yT1-yVert yT1+yVert],'k','linewidth',1)
plot([x(6)-.8-.03 x(6)-.8+.03],[yT1-yVert yT1+yVert],'k','linewidth',1)
plot([3 3.5],[-.48 -.48],'k','LineWidth',6)

for j=1:3 % Plotting Z_Score and Significance for the three Events (See Line 8)
    % Calculate the time axis and displacement.
    timeAxis = eval(TimeAxis);
    timeAxisROC = eval(TimeAxisROC);    
    displace(2) = timeAxis{1}(end)+abs(timeAxis{2}(1))+ gap + binWidth{j};
    displace(3) = displace(2) + timeAxis{2}(end) + abs(timeAxis{3}(1)) + gap_rew + binWidth{j};
    timeAx      = timeAxis{j} + displace(j);
    timeAxROC = timeAxisROC{j} + displace(j)-.125;
    
    %%% Obtaining Z-score %%% 
    eAl = alignSpikes(e,align{j});    % Align spikes to current event       
    correct = select(eAl,'reward',1); % Only Correct Trials
    correct_rt_norm = [correct.RTKD]; % Reaction Times
    Long_RT = prctile(correct_rt_norm,50); % Percentile 50
    Short_RT = prctile(correct_rt_norm,50);
    long_index = correct_rt_norm >= prctile(correct_rt_norm,50);
    short_index = correct_rt_norm <= prctile(correct_rt_norm,50);

    correct_long = correct(logical(long_index==1));   % long response time
    correct_short = correct(logical(short_index==1)); % short response time

    %%% ROC significance test %%%
    x = double(results_roc_rt(j).ci<0.05)*-.35;
    x(x==0) = NaN; % Changing the value of x. If you need it preserved, save to a new variable.
    y = double(results_roc_rt(j).ci>=0.05)*-.35;
    y(y==0) = NaN; % Changing the value of y. If you need it preserved, save to a new variable.
    if j == 1
        sR=60;
        sE=90;
    else
        sR=25;
        sE=0;    
    end
    % Plot ROC Significance
    h = plot(timeAxROC(sR:end-sE),x(sR:end-sE),'y-');
    set(h,'LineWidth',3.5)
    h = plot(timeAxROC(sR:end-sE),y(sR:end-sE),'-','color',[80 80 80]/255);
    set(h,'LineWidth',3.5)
    
    if j==1     % PD Alignment      
        long_zscore = cell2mat({correct_long.normalized_kd_align_pd}');
        long_mean = mean(long_zscore);
        long_stderr = std(long_zscore)./sqrt(size(long_zscore,1));        
        short_zscore = cell2mat({correct_short.normalized_kd_align_pd}');      
        short_mean = mean(short_zscore);
        short_stderr = std(short_zscore)./sqrt(size(short_zscore,1));
        % Plot
        interval=[7:20];
        h2=shadedErrorBar(timeAx(interval),long_mean(interval),long_stderr(interval), ...
                            {'LineWidth',2,'color',[.2,.6,1]});
        h1=shadedErrorBar(timeAx(interval),short_mean(interval),short_stderr(interval), ...
                            {'LineWidth',2,'color',[.2,.2,1]});                  
    elseif j==2 % F1 Onset Alignment (Includes both stimuli and delay)
        long_zscore = cell2mat({correct_long.normalized_response_pd}');
        long_mean = mean(long_zscore);
        long_stderr = std(long_zscore)./sqrt(size(long_zscore,1));        
        short_zscore = cell2mat({correct_short.normalized_response_pd}');      
        short_mean = mean(short_zscore);
        short_stderr = std(short_zscore)./sqrt(size(short_zscore,1));
        % Plot
        h2 = shadedErrorBar(timeAx,long_mean,long_stderr,{'LineWidth',2,'color',[.2,.6,1]});
        h1 = shadedErrorBar(timeAx,short_mean,short_stderr,{'LineWidth',2,'color',[.2,.2,1]});        
    else       % Push Button alignment (Includes reward delivery)
        long_zscore = cell2mat({correct_long.normalized_kd_align_rew}');
        long_mean = mean(long_zscore);
        long_stderr = std(long_zscore)./sqrt(size(long_zscore,1));        
        short_zscore = cell2mat({correct_short.normalized_kd_align_rew}');      
        short_mean = mean(short_zscore);
        short_stderr = std(short_zscore)./sqrt(size(short_zscore,1));       
        % Plot
        h2 = shadedErrorBar(timeAx,long_mean,long_stderr,{'LineWidth',2,'color',[.2,.6,1]});
        h1 = shadedErrorBar(timeAx,short_mean,short_stderr,{'LineWidth',2,'color',[.2,.2,1]});   
    end    
    baseline = 0;
    plot([2.5 7.8],[baseline baseline],':k','linewidth',2)
    plot([9.2 10.7],[baseline baseline],':k','linewidth',2)
    if j==2
        [hleg,icons,~,~]  = legend([h1.mainLine h2.mainLine],'Short RT (<P50)','Long RT (>P50)') ;
    end    
end

% For Figure Explainability
text(0,1.4,'PD','FontSize',font_size)
text(3.2,1.4,'f1','FontSize',font_size)
text(9.7,1.4,'reward','FontSize',font_size)
text(6.7,1.4,'f2','FontSize',font_size)
text(3.1,-.6,'0.5 s','FontSize',font_size)

% Axis Properties
set(hleg,'Position',[0.48 0.58 0.1 0.1])
set(hleg,'box','off')
set(hleg,'FontSize',font_size)
set(icons(:),'LineWidth',6); 
axis([-1.5 10.7 -.5 1.5])
ylabel('z-score','FontSize',font_size)
set(gca,'XTick',[])
set(gca,'XTickLabel',{''},'FontSize',font_size)
set(gca,'YTick',[-.5 0 .5 1 1.5])
set(gca,'YTickLabel',{'-0.5', '0', '0.5', '1','1.5'},'FontSize',font_size)

print([results_folder '/Fig6A_Zscore_RTKD'],'-dpdf','-r600');
print([results_folder '/Fig6A_Zscore_RTKD'],'-dpng','-r600');
print([results_folder '/Fig6A_Zscore_RTKD'],'-depsc2');
% print([results_folder '/Fig6A_Zscore_RTKD'],'-dpng','-r600');
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Correlations to PD, F1, F2 and Delay

One_Tailed = 1; % Set to 0 if wanted a Two-Sided test

%%% Z-SCORE and REACTION TIMES for correct trials %%%
correct = select(e,'reward',1);                 
correct_RT = [correct.RTKD];  
correct_PD = [correct.norm_response_PD_Win];   
correct_F1 = [correct.normalized_response_f1];
correct_F2 = [correct.normalized_response_f2];
correct_De = [correct.normalized_response_delay];
correct_De_CT = cell2mat({correct.normalized_response_delay_CT}'); 

[CC_RT_PD,pval_RT_PD] = corrcoef(correct_RT,correct_PD);
[CC_RT_F1,pval_RT_F1] = corrcoef(correct_RT,correct_F1); % Window: (.24s -- .48s) for significant correlations
[CC_RT_F2,pval_RT_F2] = corrcoef(correct_RT,correct_F2);
[CC_RT_De,pval_RT_De] = corrcoef(correct_RT,correct_De);

CC_De_CT = zeros(1,size(correct_De_CT,2));  % Correlations during delay; Non-Overlapping bins
PV_De_CT = CC_De_CT;
for ij = 1:size(correct_De_CT,2)
    [CC_RT_De_CT,pval_RT_De_CT] = corrcoef(correct_RT,correct_De_CT(:,ij));
    CC_De_CT(1,ij) = CC_RT_De_CT(1,2);
    PV_De_CT(1,ij) = pval_RT_De_CT(1,2)/(1+One_Tailed); % Left Tailed Hypothesis --> Simmetry --> Divide p-value by 2
end

CC_PD = CC_RT_PD(1,2); PV_PD = pval_RT_PD(1,2)/(1+One_Tailed);
CC_F1 = CC_RT_F1(1,2); PV_F1 = pval_RT_F1(1,2)/(1+One_Tailed);
CC_F2 = CC_RT_F2(1,2); PV_F2 = pval_RT_F2(1,2)/(1+One_Tailed);
CC_De = CC_RT_De(1,2); PV_De = pval_RT_De(1,2)/(1+One_Tailed);
disp('-----------------------------');
disp('Correlations With "Corrcoef":');
disp(['PD: CC = ' num2str(CC_PD) ' -- p = ' num2str(PV_PD)]);
disp(['F1: CC = ' num2str(CC_F1) ' -- p = ' num2str(PV_F1)]);
disp(['F2: CC = ' num2str(CC_F2) ' -- p = ' num2str(PV_F2)]);
disp(['Delay: CC = ' num2str(CC_De) ' -- p = ' num2str(PV_De)]);

% Linear Fits to data points
zs = linspace(-5,15,200);
p_PD = polyfit(correct_PD,correct_RT,1);
L_PD = polyval(p_PD,zs);
p_F1 = polyfit(correct_F1,correct_RT,1);
L_F1 = polyval(p_F1,zs);
p_De = polyfit(correct_De,correct_RT,1);
L_De = polyval(p_De,zs);
timeAxisDelayCT = (0.5:0.15:3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig6B Left - Correlations PD

figure_size = [4.2 3.5]; % [18.5 3.5]
font_size = 15;
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])

scatter(correct_PD,correct_RT,10,'filled','MarkerEdgeColor',[0 .5 .5],'MarkerFaceColor',[0 .7 .7],'LineWidth',1.5)

xlabel('zscore','FontSize',12);
ylabel('RT (s)');
xlim([-3 9]);
ylim([0.3 1.5]);
set(gca,'XTick',[-3 0 3 6 9],'XTickLabels',{'-3', '0', '3', '6','9'},'YTick',[0.3 0.9 1.5],'YTickLabels',{'0.3', '0.9', '1.5'});
hold on;
    plot(zs,L_PD,'r-','LineWidth',1);
hold off;
print([results_folder '/Fig6B_LEFT_CC_PD'],'-dpdf','-r600');
print([results_folder '/Fig6B_LEFT_CC_PD'],'-dpng','-r600');
print([results_folder '/Fig6B_LEFT_CC_PD'],'-depsc2');
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig6B Right - Correlations F1

figure_size = [4.2 3.5]; % [18.5 3.5]
font_size = 15;
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])

scatter(correct_F1,correct_RT,10,'filled','MarkerEdgeColor',[0.5 .5 0],'MarkerFaceColor',[.7 .7 0],'LineWidth',1.5)

xlabel('zscore','FontSize',12');
ylabel('RT (s)');
xlim([-3 6]);
ylim([0.3 1.5]);
set(gca,'XTick',[-3 0 3 6],'XTickLabels',{'-3', '0', '3', '6'});
hold on;
    plot(zs,L_F1,'r-','LineWidth',1);
hold off;
print([results_folder '/Fig6B_RIGHT_CC_F1'],'-dpdf','-r600');
print([results_folder '/Fig6B_RIGHT_CC_F1'],'-dpng','-r600');
print([results_folder '/Fig6B_RIGHT_CC_F1'],'-depsc2');
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig6C Left - Correlations Delay 

figure_size = [4.2 3.5]; % [18.5 3.5]
font_size = 15;
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])

scatter(correct_De,correct_RT,10,'filled','MarkerEdgeColor',[0 .5 .5],'MarkerFaceColor',[0 .7 .7],'LineWidth',1.5)

xlabel('zscore','FontSize',12);
ylabel('RT (s)');
xlim([-3 4]);
ylim([0.3 1.5]);
set(gca,'YTick',[0.3 0.9 1.5],'YTickLabels',{'0.3', '0.9', '1.5'});
hold on;
    plot(zs,L_De,'r-','LineWidth',1);
hold off;
print([results_folder '/Fig6C_LEFT_CC_Delay'],'-dpdf','-r600');
print([results_folder '/Fig6C_LEFT_CC_Delay'],'-dpng','-r600');
print([results_folder '/Fig6C_LEFT_CC_Delay'],'-depsc2');
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig6C Right - Temporal Evolution of correlations delay

figure_size = [4.2 3.5]; % [18.5 3.5]
font_size = 15;
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])

X_data_S = timeAxisDelayCT(PV_De_CT<=.05); 
Y_data_S = X_data_S*0 - .095; 

plot(timeAxisDelayCT,CC_De_CT,'o-b','LineWidth',2,'MarkerSize',6,'MarkerEdgeColor','b','MarkerFaceColor',[0.1,0.4,0.8]);
hold on;
    plot(X_data_S,Y_data_S,'*','MarkerSize',5,'MarkerEdgeColor','r','MarkerFaceColor',[1,0,0]);
hold off;

xlabel('Time from f1 Offset (s)');
ylabel('Correlation Coefficient','Color','k');
xlim([0.3 3.2]);

print([results_folder '/Fig6C_RIGHT_CC_Temporal_Delay'],'-dpdf','-r600');
print([results_folder '/Fig6C_RIGHT_CC_Temporal_Delay'],'-dpng','-r600');
print([results_folder '/Fig6C_RIGHT_CC_Temporal_Delay'],'-depsc2');
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Permutation Test for Correlations

disp('----------------------------------');
disp('Permutation Test for Correlations:');
[p_permutation,~] = permutation_test(correct_RT,correct_PD,results_folder,'PD','N_Permutations',10000,'Significance',0.05,'Figure','Off');
disp(['PD: p = ' num2str(p_permutation)]);
[p_permutation,~] = permutation_test(correct_RT,correct_F1,results_folder,'F1','N_Permutations',10000,'Significance',0.05,'Figure','Off');
disp(['F1: p = ' num2str(p_permutation)]);
[p_permutation,~] = permutation_test(correct_RT,correct_F2,results_folder,'F2','N_Permutations',10000,'Significance',0.05,'Figure','Off');
disp(['F2: p = ' num2str(p_permutation)]);
[p_permutation,~] = permutation_test(correct_RT,correct_De,results_folder,'Delay','N_Permutations',10000,'Significance',0.05,'Figure','Off');
disp(['Delay: p = ' num2str(p_permutation)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Delay DA Response
    
Long_RT = prctile(correct_RT,50);
Short_RT = prctile(correct_RT,50);
long_index = correct_RT >= prctile(correct_RT,50);
short_index = correct_RT <= prctile(correct_RT,50);

correct_long_De = correct(logical(long_index==1));   % long response time
correct_short_De = correct(logical(short_index==1)); % short response time
Short_DA = cell2mat({correct_short_De.normalized_response_delay}');
Long_DA = cell2mat({correct_long_De.normalized_response_delay}');
disp('---------------');
disp('Delay Activity:');
disp(['Short RT: = ' num2str(mean(Short_DA)) ' pm ' num2str(std(Short_DA)./sqrt(size(Short_DA,1))) ' SEM']);
disp(['Long RT: = ' num2str(mean(Long_DA)) ' pm ' num2str(std(Long_DA)./sqrt(size(Long_DA,1))) ' SEM']); 
[~,p_De] = ttest2(Short_DA,Long_DA,'Tail','Right');
disp(['Short_DA > Long_DA with p = ' num2str(p_De)]);