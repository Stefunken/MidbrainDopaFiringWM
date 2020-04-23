function [p_f1,p_class] = figure_S2_plots(eB,results_folder)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure S2B

n_f1 = 6;
range_f1 = [10 14 18 24 30 34];        
response_f1_by_f1 = cell(1,n_f1);
n_correct_f1 = zeros(1,n_f1);
  for f1=1:n_f1
  
      correct=select(eB,'reward',1,'StimFreq1',[range_f1(f1) range_f1(f1)]); 
      for i = 1:size(correct,2)
            response_f1_by_f1{1,f1}(1,i) = correct(i).normalized_response_f1;
      end  
      n_correct_f1(1,f1) = size(correct,2);
      clearvars correct
      
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
figure_size = [4.2 3.5];
font_size = 15;
line_width1 = 2;
marker_size = 6;

x_position = 1:n_f1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Response to SO1 sorted by f1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf, hold on
%figure(1)
hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1,'xColor','k')

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
%set(gca,'YTick',0:.1:.6,'YTickLabel',{'0','.1','.2','.3','.4','.5','.6'})
%axis([0 7 0 .602]) % groupA
set(gca,'YTick',[-.2:.2:.4],'YTickLabel',{'-.2','0','.2','.4'}) % group B
axis([0 7 -.2 .4]) % groupB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inset
inset_true = 0;
if inset_true
%axes('Position',[.64 .62 .30 .30])
axes('Position',[.72 .70 .27 .27])

set(gca,'LineWidth',.8)

box off
hold on
f1_handle = zeros(1,n_f1);
for f1=1:6 
        
plot(x_position(1,f1),performance_by_freq(1,f1),'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.75 .75 .75],'LineWidth',line_width1);
f1_handle(1,f1)= errorbar(x_position(1,f1),performance_by_freq(1,f1),error_by_freq(1,f1),'-','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 0]);
end
for i=1:n_f1
errorbar_tick(f1_handle(1,i),40);
end
ylabel('% of correct')
xlabel({'f1 (Hz)'})

set(gca,'XTick',x_position(1:end),'XTickLabel',{'10','14','18','24','30','34'},'FontSize',6,'TickDir','out')

axis([0 7 75 100])
end

%print('-dpdf',[results_folder '/FigS2B_response_f1_by_f1_groupB'])
print('-depsc2',[results_folder '/FigS2B_response_f1_by_f1_groupB'])
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1
% One way ANOVA

names = [repmat({'10hz'}, 1, n_correct_f1(1,1)) repmat({'14hz'}, 1, n_correct_f1(1,2))...
         repmat({'18hz'}, 1, n_correct_f1(1,3)) repmat({'24hz'}, 1, n_correct_f1(1,4))...
         repmat({'30hz'}, 1, n_correct_f1(1,5)) repmat({'34hz'}, 1, n_correct_f1(1,6))];
 
groups = [response_f1_by_f1{1,1}, response_f1_by_f1{1,2},response_f1_by_f1{1,3},...
          response_f1_by_f1{1,4}, response_f1_by_f1{1,5},response_f1_by_f1{1,6}];


% results      
[p_f1,~,~] = anova1(groups, names,'off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 2D
n_classes = 12;
response_f2_by_class = cell(1,n_classes);
n_correct_class = zeros(1,n_classes);
for class=1:n_classes    
    correct=select(eB,'reward',1,'Clase',[class class]);
    response_f2_by_class{1,class} = cell2mat({correct.normalized_response_f2});
    n_correct_class(1,class) = size(response_f2_by_class{1,class},2);
    
end  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%figure_size = [4.5 3.5];
figure_size = [7.5 3.5];
font_size = 15;
line_width1 = 2;
marker_size = 6;

x_position = 1:n_classes;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Response to SO2 sorted by class- correct trials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf, hold on
hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

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
%set(gca,'YTick',0.0:.2:1.0,'YTickLabel',{'0','.2','.4','.6','.8','1'})% groupA
%axis([0 13 0 1.0]) % groupA

set(gca,'YTick',[-0.4:.2:.6],'YTickLabel',{'-.4','-.2','.0','.2','.4','.6'})% groupB
axis([0 13 -0.4 .6]) % groupB

%print('-dpdf',[results_folder '/FigS2A_response_f2_by_class_groupB'])
print('-depsc2',[results_folder '/FigS2A_response_f2_by_class_groupB'])
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% One way ANOVA
if 1
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
  
% results anova      
[p_class,~,~] = anova1(groups, names,'off');
%multcompare(stats)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

end