function [p_f1,p_class] = figure_2_plots(e,eA,fileList,fileListA,results_folder)
%% Loading Performance by f1 values 

load('performanceSetB') % Mat file in "preprocessed_data" folder
performance_by_freq = fliplr(results_performance.mean_accuracy_f1*100); 
error_by_freq = fliplr(results_performance.error_accuracy_f1*100);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Response to SO1 by f1 

n_f1 = 6;
range_f1 = [10 14 18 24 30 34]; % f1 set values
response_f1_by_f1 = cell(1,n_f1);       
n_correct_f1 = zeros(1,n_f1);
for f1=1:n_f1
    correct=select(eA,'reward',1,'StimFreq1',[range_f1(f1) range_f1(f1)]);
    response_f1_by_f1{1,f1} = cell2mat({correct.normalized_response_f1});  % Z-scores
    n_correct_f1(1,f1) = size(correct,2);
end

if 1
    % Significance test - One way ANOVA
    names = [repmat({'10hz'}, 1, n_correct_f1(1,1)) repmat({'14hz'}, 1, n_correct_f1(1,2))...
             repmat({'18hz'}, 1, n_correct_f1(1,3)) repmat({'24hz'}, 1, n_correct_f1(1,4))...
             repmat({'30hz'}, 1, n_correct_f1(1,5)) repmat({'34hz'}, 1, n_correct_f1(1,6))];

    groups = [response_f1_by_f1{1,1}, response_f1_by_f1{1,2},response_f1_by_f1{1,3},...
              response_f1_by_f1{1,4}, response_f1_by_f1{1,5},response_f1_by_f1{1,6}];
  
    [p_f1,~,~] = anova1(groups, names,'off');
    disp(['DA response at F1 by F1: p = ' num2str(p_f1)]);
end

% Response to f1 by Extreme Vs Central values
g_extreme = [response_f1_by_f1{1,1} response_f1_by_f1{1,6}]; % Low performance f1 values
g_central = [response_f1_by_f1{1,3} response_f1_by_f1{1,4}]; % High Performance f1 values
[~,p_ext_cen] = ttest2(g_central,g_extreme,'Tail','Right'); 
disp(['DA response at F1 by Extrem or Central F1s: ' num2str(mean(g_central)) ' > ' num2str(mean(g_extreme)) ' p = ' num2str(p_ext_cen)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Responses to SO1 by class number & to SO2 by f2 and class number 

n_classes = 12; % Class number
response_f2_by_class = cell(1,n_classes);
response_f1_by_class = cell(1,2*n_f1);
n_correct_class = zeros(1,n_classes);
for class=1:n_classes    
    correct = select(eA,'reward',1,'Clase',[class class]);
    response_f1_by_class{1,class} = cell2mat({correct.normalized_response_f1}); % Z-score at f1
    response_f2_by_class{1,class} = cell2mat({correct.normalized_response_f2}); % Z-score at f2
    n_correct_class(1,class) = size(response_f2_by_class{1,class},2);
end

if 1
    % Significance test at f2 by class - One way ANOVA
    names = [repmat({'1'}, 1, n_correct_class(1,1)) repmat({'2'}, 1, n_correct_class(1,2))...
             repmat({'3'}, 1, n_correct_class(1,3)) repmat({'4'}, 1, n_correct_class(1,4)) ...
             repmat({'5'}, 1, n_correct_class(1,5)) repmat({'6'}, 1, n_correct_class(1,6))...
             repmat({'7'}, 1, n_correct_class(1,7)) repmat({'8'}, 1, n_correct_class(1,8))...
             repmat({'9'}, 1, n_correct_class(1,9)) repmat({'10'}, 1, n_correct_class(1,10))...
             repmat({'11'}, 1, n_correct_class(1,11))  repmat({'12'}, 1, n_correct_class(1,12)) ];

    groups = [response_f2_by_class{1,1}, response_f2_by_class{1,2},response_f2_by_class{1,3},...
              response_f2_by_class{1,4},response_f2_by_class{1,5},response_f2_by_class{1,6},...
              response_f2_by_class{1,7},response_f2_by_class{1,8},response_f2_by_class{1,9},...
              response_f2_by_class{1,10},response_f2_by_class{1,11},response_f2_by_class{1,12}];

    [p_class,~,~] = anova1(groups, names,'off');
    disp(['DA response at F2 by Class: p = ' num2str(p_class)]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 2A -- Response to SO2 sorted by class. Only correct trials

figure_size = [7.5 3.5];
font_size = 15;
line_width1 = 2;
marker_size = 6;

figure('visible','off'),clf, hold on
hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

x_position = 1:n_classes;
class_handle = zeros(1,n_classes);  
for class = 1:n_classes
    mean_class = mean(response_f2_by_class{1,class});
    stderr_class = std(response_f2_by_class{1,class})./sqrt(n_correct_class(1,class));
    bar(x_position(1,class),mean_class,'EdgeColor',[0 0 1],'FaceColor',[204 204 255]/255,'LineWidth',line_width1);
    class_handle(1,class)= errorbar(x_position(1,class),mean_class,stderr_class,'-','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 1]);
end

for i=1:n_classes
    errorbar_tick(class_handle(1,i),40);
end

ylabel('Response to f2 (z-score)')
xlabel({'Class number'})

set(gca,'XTick',x_position(1:end),'XTickLabel',{'1' '2' '3' '4' '5','6','7','8','9','10','11','12'},'TickDir','out')
set(gca,'YTick',0.0:.2:.8,'YTickLabel',{'0','.2','.4','.6','.8'})
axis([0 13 0 .8])

print('-dpdf',[results_folder '/Fig2A_response_f2_by_class'])
print('-depsc2',[results_folder '/Fig2A_response_f2_by_class'])
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 2B -- Response to SO1 by f1
figure_size = [4.2 3.5];
font_size = 15;
line_width1 = 2;
marker_size = 6;

figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1,'xColor','k')

x_position = 1:n_f1;
f1_handle = zeros(1,n_f1);
for f1 = 1:n_f1
    meanF1 = mean(response_f1_by_f1{1,f1});
    stderrF1 = std(response_f1_by_f1{1,f1})./sqrt(n_correct_f1(1,f1));
    bar(x_position(1,f1),meanF1,'EdgeColor',[0 0 1],'FaceColor',[204 204 255]/255,'LineWidth',line_width1);
    f1_handle(1,f1)= errorbar(x_position(1,f1),meanF1,stderrF1,'-','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 1]);
end
for i=1:n_f1
    errorbar_tick(f1_handle(1,i),40);
end

ylabel('Response to f1 (z-score)')
xlabel({'f1 (Hz)'})
set(gca,'XTick',x_position(1:end),'XTickLabel',{'10','14','18','24','30','34'},'TickDir','out')
set(gca,'YTick',0:.1:.6,'YTickLabel',{'0','.1','.2','.3','.4','.5','.6'})
axis([0 7 0 .602])

% Inset -- Performance by f1
inset_true = 1;
if inset_true
    axes('Position',[.72 .70 .27 .27])
    set(gca,'LineWidth',.8)
    box off;
    hold on;
        f1_handle = zeros(1,n_f1);
        for f1=1:6         
            plot(x_position(1,f1),performance_by_freq(1,f1),'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.75 .75 .75],'LineWidth',line_width1);
            f1_handle(1,f1)= errorbar(x_position(1,f1),performance_by_freq(1,f1),error_by_freq(1,f1),'-','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 0]);
        end
        for i=1:n_f1
            errorbar_tick(f1_handle(1,i),40);
        end
    hold off;
    ylabel('% of correct')
    xlabel({'f1 (Hz)'})
    set(gca,'XTick',x_position(1:end),'XTickLabel',{'10','14','18','24','30','34'},'FontSize',6,'TickDir','out')
    axis([0 7 75 100])
end
print('-dpdf',[results_folder '/Fig2B_response_f1_by_f1'])
print('-depsc2',[results_folder '/Fig2B_response_f1_by_f1'])
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Additional Figures

figure_size = [4.5 3.5];
font_size = 15;
line_width1 = 2;
marker_size = 6;

% Response to SO1 sorted by class. Only correct trials.
figure('visible','off'),clf, hold on
hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

x_position = [n_f1:-1:1 n_f1:-1:1];
class_handle = zeros(1,n_classes);  
for class = 1:n_classes
    if (class >=1 && class<=3) || (class >=10 && class<=12)       % Defining the colors
        EdCo = [255 192 203]/255; 
    else
        EdCo = [121 61 244]/255;
    end
    mean_class = mean(response_f1_by_class{1,class});
    stderr_class = std(response_f1_by_class{1,class})./sqrt(n_correct_class(1,class));
    plot(x_position(1,class),mean_class,'o','Color',EdCo,'LineWidth',line_width1);
    class_handle(1,class)= errorbar(x_position(1,class),mean_class,stderr_class,'-','MarkerSize',marker_size,'LineWidth',line_width1,'color',EdCo);
end

ylabel('Response to f1 (z-score)')
xlabel({'f1 (Hz)'})
set(gca,'XTick',1:n_f1,'XTickLabel',{'10','14','18','24','30','34'},'TickDir','out')
set(gca,'YTick',0:.1:.6,'YTickLabel',{'0','.1','.2','.3','.4','.5','.6'})
axis([0 n_f1+1 0 .602])

plot(0.57,0.57,'o','Color',[255 192 203]/255,'LineWidth',line_width1,'MarkerSize',9)
plot(0.57,0.53,'o','Color',[121 61 244]/255,'LineWidth',line_width1,'MarkerSize',9)
text(.88,.57,'Low Difficulty','FontSize',12);
text(.88,.53,'High Difficulty','FontSize',12);

print('-dpdf',[results_folder '/Fig_response_f1_by_class'])
print('-depsc2',[results_folder '/Fig_response_f1_by_class'])
close

% Response to SO2 sorted by f2. Only correct trials.
figure_size = [7.5 3.5];
font_size = 15;
line_width1 = 2;
marker_size = 6;

figure('visible','off'),clf, hold on
hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

x_position = [12 11 10 9 6 5 8 4 7 3 2 1]; % Class numbers sorted by increasing value of f2
class_handle = zeros(1,n_classes);  
for i = 1:n_classes
    class = x_position(1,i);
    mean_class = mean(response_f2_by_class{1,class});
    stderr_class = std(response_f2_by_class{1,class})./sqrt(n_correct_class(1,class));
    bar(i,mean_class,'EdgeColor',[0 0 1],'FaceColor',[204 204 255]/255,'LineWidth',line_width1);
    class_handle(1,class)= errorbar(i,mean_class,stderr_class,'-','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 1]);
end
for i=1:n_classes
    errorbar_tick(class_handle(1,i),40);
end

ylabel('Response to f2 (z-score)')
xlabel({'f2 (Hz)'})
set(gca,'XTick',1:n_classes,'XTickLabel',sort([44 38 32 26 22 18 26 22 16 10 8 6]),'TickDir','out')
set(gca,'YTick',0.0:.2:1.0,'YTickLabel',{'0','.2','.4','.6','.8','1'})

print('-dpdf',[results_folder '/Fig_response_f2_by_f2'])
print('-depsc2',[results_folder '/Fig_response_f2_by_f2'])
close