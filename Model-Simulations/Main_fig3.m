close all
clear all
clc
model_results_folder = 'model_results';
addpath(model_results_folder)
results_folder = ['Results-' date]; % results + the date of today
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 3
folder_name = [results_folder '/Fig3'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 3A
% This is not generate in matlab, codes for this figure are in the folder
% Fig3A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 3B
load('performanceSetB')
real_performance = results_performance.mean_accuracy_class*100;
load('results_bayesian_model')

Param1 = results_best_fit.param1;
Param2 = results_best_fit.param2;
Param3 = results_best_fit.param3;
Param4 = results_best_fit.param4;

classesFreq = [34    30    24    18    14    10  34    30    24    18    14    10;...
              44    38    32    26    22    18   26    22   16    10     8     6 ]; 

[psycho] = giveMePsychoThesisClasses(Param1*Param2,Param2,Param3,Param4);
psycho = psycho*100;

%%%%%%%%%%%%%%%%%%%%%%%%
figure_size=[4.5 3.5];
font_size = 15;
font_legend = 12;
figure('visible','off')
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

hold on
data=plot(classesFreq(1,1:6),real_performance(1:6),'-ok','markerfacecolor','k','markersize',8,'LineWidth',1.5);
model=plot(classesFreq(1,1:6),psycho(1:6),'--<','color',[0 .85 0],'markerfacecolor',[0 .85 0],'markersize',8,'LineWidth',1.5);
plot(classesFreq(1,1:6),100-real_performance(7:12),'-ok','markerfacecolor','k','markersize',8,'LineWidth',1.5)
plot(classesFreq(1,1:6),100-psycho(7:12),'--<','color',[0 .85 0],'markerfacecolor',[0 .85 0],'markersize',8,'LineWidth',1.5)

[hleg,icons,plots,str]  = legend([data model],'Data','Model') ;

set(hleg,'Position',[0.7, 0.7, .01, .01,]);
set(hleg,'box','off')
set(hleg,'FontSize',font_legend)

ylabel('% of f_1 called lower')
ylim([0 100])
xlabel('f_1 (Hz)')
xlim([8 36])

%print([folder_name '/Fig3B_model_fit'],'-dpdf','-r600');
print([folder_name '/Fig3B_model_fit'],'-depsc2','-r600');

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 3C
load('results_bayesian_trial_to_trial')
b_classes_correct = results_trial_to_trial.belief_f1_lower_f2_correct;
b_classes_correct(7:12) = 1-b_classes_correct(7:12); 
b_classes_error = results_trial_to_trial.belief_f1_lower_f2_error;
b_classes_error(1:6) = 1-b_classes_error(1:6);
n_classes = 12;

figure_size=[4.5 3.5];
figure('visible','off')
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)
box off
hold on
correct = plot(1:n_classes,b_classes_correct,'-bo','MarkerEdgeColor','b','MarkerFaceColor', 'b','Markersize',8,'LineWidth',1.5);
error = plot(1:n_classes,b_classes_error,'-ro','MarkerFaceColor', 'r','Markersize',8,'LineWidth',1.5);

set(gca,'XTick',1:n_classes)
set(gca,'xticklabel',{'1','2','3','4','5','6','7','8','9','10','11','12'})

l=legend([correct error],'correct','error');
set(l,'Location','best');
set(l,'box','off')
set(l,'fontsize',font_legend)

xlim([0 13])
ylim([.65 1.002])

% for i = 1:12
% text(i,b_classes(1,i),['c' num2str(i)])
% end
box off
ylabel('Confidence (as belief)')
xlabel('Class number')
%print([folder_name '/Fig3C_confidece_class_number'],'-dpdf','-r600');
print([folder_name '/Fig3C_confidece_class_number'],'-depsc2','-r600');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


