function figure_1_RTKD_plots(eRT,results_folder)
%% Separating trials per RT conditions (Short or Long)

mean_high = zeros(1,12); 
mean_low = mean_high;
trials_per_class_high = zeros(1,12);
trials_per_class_low = zeros(1,12);

all = select(eRT);
XA = [all.RTKD];
YA = prctile(XA,50);
Y1A = prctile(XA,50);

high_index = XA>Y1A;
low_index = XA<YA;

all_high = all([logical(high_index==1)]); % long response time
all_low = all([logical(low_index==1)]);   % short response time

cond_high = cell2mat({all_high.conditions}');
cond_low = cell2mat({all_low.conditions}');

% Obtaining accuracies for each condition
for iC = 1:12
    mean_high(1,iC) = sum(cond_high(:,1)==iC & cond_high(:,3)==1);
    mean_low(1,iC) = sum(cond_low(:,1)==iC & cond_low(:,3)==1);
    trials_per_class_high(1,iC) = sum(cond_high(:,1)==iC);
    trials_per_class_low(1,iC) = sum(cond_low(:,1)==iC);
end    
mean_high = 100*mean_high./trials_per_class_high;
mean_low = 100*mean_low./trials_per_class_low;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 1E

% To obtain percentatges
counts_all_high = sum(trials_per_class_high,1);
counts_all_low = sum(trials_per_class_low,1);
trial_per_class = counts_all_high + counts_all_low;
centers = (1:12);

% Figure properties
figure_size = [4.5 3.5];
font_size = 15;
line_width1 = 2;


figure('visible','off'),clf, hold on
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)
hold on;

% Plot results
plot(centers,1/12*ones(1,12)*100,'--','Color',[1 .6 0],'LineWidth',line_width1);
lowLeg = plot(centers,counts_all_low./sum(counts_all_low)*100,'-o','Color',[0 0 0],'LineWidth',line_width1);
highLeg = plot(centers,counts_all_high./sum(counts_all_high)*100,'-o','Color',[.8 .8 .8],'LineWidth',line_width1);
allLeg = plot(centers,trial_per_class./sum(trial_per_class)*100,'-yx','LineWidth',line_width1);

% Legend and Axis properties
l = legend([lowLeg highLeg allLeg],'Short RT', 'Long RT', 'All trials');
set(l,'box','off');
set(l,'Position',[.62 .82 .1 .1]);
set(l,'FontSize',12);
set(gca,'XTick', (1:12));
set(gca,'XTickLabel',{'1','2','3','4','5','6','7','8','9','10','11','12'});
xlim([0 13]);
ylim([6 10]);
xlabel('Class number');
ylabel('% of trials');

print('-depsc2',[results_folder '/Fig1E_short-long_distributions_VS_class']);
print('-dpdf',[results_folder '/Fig1E_short-long_distributions_VS_class'],'-r600');
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 1F left

% Figure properties
figure_size = [4.5 3.5];
font_size = 15;
line_width1 = 1.2;
marker_size = 6;

figure('visible','off'),clf, hold on
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)
hold on

% Plot results
handleH = plot((1:12),mean_high,'-o','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 .6 1],'MarkerFaceColor',[0 .6 1]);
handleL = plot((1:12),mean_low,'-o','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 1],'MarkerFaceColor',[0 0 1]);

% Legend and axis properties
l = legend([handleL handleH],'Short RT', 'Long RT');
set(l,'box','off');
set(l,'Position',[.72 .22 .1 .1]);
set(l,'FontSize',12);
set(gca,'XTick', (1:12));
set(gca,'XTickLabel',{'1','2','3','4','5','6','7','8','9','10','11','12'});
xlim([0 13]);
xlabel('Class number');
ylabel('% of trials');

print('-depsc2',[results_folder '/Fig1F-left_perc_correct_short-long_VS_class'])
print('-dpdf',[results_folder '/Fig1F-left_perc_correct_short-long_VS_class'],'-r600')
% print('-dpng',[results_folder '/Fig1F-left_perc_correct_short-long_VS_class'],'-r600')
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 1F right

% Figure properties
figure_size = [4.5 3.5];
figure('visible','off'),clf, hold on
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)
hold on

% Plot results
mean_diff = mean_high - mean_low;
plot((1:12),mean_diff,'-o','MarkerSize',marker_size,'LineWidth',line_width1,'color','k','MarkerFaceColor','k');

% Axis properties
set(gca,'XTick', (1:12));
set(gca,'XTickLabel',{'1','2','3','4','5','6','7','8','9','10','11','12'});
xlim([0 13]);
xlabel('Class number');
ylabel('\Delta % correct (long-short)');

print('-depsc2',[results_folder '/Fig1F-right_perc_correct_diff_short-long_VS_class']);
print('-dpdf',[results_folder '/Fig1F-right_perc_correct_diff_short-long_VS_class'],'-r600');
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 1G

% Correct and Error trials
correct = select(eRT,'reward',1);
error = select(eRT,'reward',0);

% Hypothesis testing
[h,p] = ttest2(cell2mat({error.RTKD}),cell2mat({correct.RTKD}),'tail','right');

mean_correct = 1000*nanmean(cell2mat({correct.RTKD}));
stderr_correct = 1000*nanstd(cell2mat({correct.RTKD}))./sqrt(size(correct,2));
mean_error = 1000*mean(cell2mat({error.RTKD}));
stderr_error = 1000*std(cell2mat({error.RTKD}))./sqrt(size(error,2));

% Figure properties
figure_size = [2.2 2.5];
font_size = 15;
line_width1 = 2;
marker_size = 6;
x_position = [1 3];

figure('visible','off'),clf
hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

% Plot results and error bars
handleC = errorbar(x_position(1),mean_correct,stderr_correct,'-o','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 1]);
handleE = errorbar(x_position(2),mean_error,stderr_error,'-o','MarkerSize',marker_size,'LineWidth',line_width1,'color',[1 0 0]);
errorbar_tick(handleC,40);
errorbar_tick(handleE,40);

% Axis properties
ylabel('Reaction time (ms)');
set(gca,'XTick',x_position(1:end),'XTickLabel',{'Correct' 'Error'});
% title({['p = ' num2str(p, '%.3f')]},'FontSize',font_size,'Color','k');
axis([0 4 730 750]);
set(gca,'Ydir','reverse');

print('-depsc2',[results_folder '/Fig1G_mean_reaction_times_KD_correct_vs_error'])
print('-dpdf',[results_folder '/Fig1G_mean_reaction_times_KD_correct_vs_error'],'-r600')
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end