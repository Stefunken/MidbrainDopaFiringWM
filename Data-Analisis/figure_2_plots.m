function [p_f1,p_class] = figure_2_plots(e,eA,fileList,fileListA,results_folder)
%% Figure 2A

filterType = 'boxcar';
align    = {'PushKey'}; 
binWidth =  .1; % response [.7 .25 .2]
timeAxis = .25:0.1:1.05; 

binWidth2 = .2; %for the selection of neurons
binWidth3 = .5; %for the selection of neurons


eAl = alignSpikes(e,align); % Align spikes

nNeurons = size(eAl,2);
valueMax = zeros(1,nNeurons);
timeMax = zeros(1,nNeurons);


for i_neuron = 1:nNeurons
    correct = select(eAl(i_neuron),'reward',1); %'trialType',[1 18],
    meanCorrectFR = mean(firingrate([correct.spikeTimes],timeAxis,'filtertype',filterType,'timeConstant',binWidth));

    incorrect = select(eAl(i_neuron),'reward',0); %'trialType',[1 18],
    
    [value,ind]=max(meanCorrectFR);
    
    valueMax(1,i_neuron) = value;  
    timeMax(1,i_neuron) = timeAxis(1,ind);
    
    %%
    centerWindow = timeMax(1,i_neuron);
    centerWindow2 = timeMax(1,i_neuron)-.1;

    correctFR = firingrate([correct.spikeTimes],centerWindow,'filtertype',filterType,'timeConstant',binWidth2);
    incorrectFR = firingrate([incorrect.spikeTimes],centerWindow2,'filtertype',filterType,'timeConstant',binWidth3);
    
    [h,p,~,~] = ttest2(correctFR,incorrectFR,'Tail','right','Alpha',0.05,'Vartype','unequal');

    
    r(i_neuron).mean_correct = mean(correctFR);
    r(i_neuron).mean_incorrect = mean(incorrectFR);
    r(i_neuron).std_correct = std(correctFR);
    r(i_neuron).std_incorrect = std(incorrectFR);
    r(i_neuron).p = p;
    r(i_neuron).h = h;
    
end  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% colors for fig
colorA = [255 123 31]/255;
colorB = [133 255 102]/255;
%%% figure properties
figure_size = [4.5 3.5];
font_size = 15;
line_width = 3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)
hold on
xA = valueMax(logical([r(1:length(fileListA)).h]));
xB = valueMax(length(fileListA)+find([r(length(fileListA)+1:length(fileList)).h]));

xbins = 0:1.5:30;
[nA,~] = hist(xA,xbins);
xbins = 0:1.5:30;
[nB,xbins] = hist(xB,xbins);


bar(xbins,nA,'FaceColor',colorA,'EdgeColor','k','LineWidth',1.2)

bar(xbins,nB,'FaceColor',colorB,'EdgeColor','k','LineWidth',1.2)


plot([15.75 15.75],[0 5],'--k','LineWidth',line_width)

xlim([0 30])

xlabel('Peak response to reward (Hz)','FontSize',font_size)
ylabel('# of neurons','FontSize',font_size)

print('-depsc2',[results_folder '/Fig2A_hist_response'])
%print('-dpdf',[results_folder '/Fig2A_hist_response'])
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 2B
load('results_wilcoxon_single_A.mat');
groupA = results_wilcoxon_single_A;

load('results_wilcoxon_single_B.mat');
groupB = results_wilcoxon_single_B;

significanceA=[groupA.h_SO1]'+[groupA.h_SO2]';
significanceB=[groupB.h_SO1]'+[groupB.h_SO2]';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% colors for the fig
colorA = [255 123 31]/255;
colorB = [133 255 102]/255;
% figure properties 
figure_size = [4.5 3.5];
font_size = 15;
font_legend = 12;
marker_size = 6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Response to SO1
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

for i_a = 1:size(groupA,2)

   switch significanceA(i_a,1)
       case 2
            both = plot(groupA(i_a).meanDiffSO1,groupA(i_a).meanDiffSO2,'h','Markersize',marker_size+2,'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[0 0 0],'LineWidth',1);  
            plot(groupA(i_a).meanDiffSO1,groupA(i_a).meanDiffSO2,'h','Markersize',marker_size+2,'MarkerFaceColor',colorA,'MarkerEdgeColor',[0 0 0],'LineWidth',1)
       case 0
            no_sig = plot(groupA(i_a).meanDiffSO1,groupA(i_a).meanDiffSO2,'o','Markersize',marker_size,'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[0 0 0],'LineWidth',1);
            plot(groupA(i_a).meanDiffSO1,groupA(i_a).meanDiffSO2,'o','Markersize',marker_size,'MarkerFaceColor',colorA,'MarkerEdgeColor',[0 0 0],'LineWidth',1)

       case 1
           if groupA(i_a).h_SO1==1
           %SO1 = plot(groupA(i_a).meanDiffSO1,groupA(i_a).meanDiffSO2,'s','Markersize',marker_size,'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[0 0 0],'LineWidth',1);
           plot(groupA(i_a).meanDiffSO1,groupA(i_a).meanDiffSO2,'s','Markersize',marker_size,'MarkerFaceColor',colorA,'MarkerEdgeColor',[0 0 0],'LineWidth',1)
   
           else
           SO2 = plot(groupA(i_a).meanDiffSO1,groupA(i_a).meanDiffSO2,'^','Markersize',marker_size,'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[0 0 0],'LineWidth',1);               
           plot(groupA(i_a).meanDiffSO1,groupA(i_a).meanDiffSO2,'^','Markersize',marker_size,'MarkerFaceColor',colorA,'MarkerEdgeColor',[0 0 0],'LineWidth',1)
           end         
   end
end

for i_b = 1:size(groupB,2)
    %if i_b ~=7
        switch significanceB(i_b,1)
            case 2
            plot(groupB(i_b).meanDiffSO1,groupB(i_b).meanDiffSO2,'h','Markersize',marker_size+2,'MarkerFaceColor',colorB,'MarkerEdgeColor',[0 0 0],'LineWidth',1)
            case 0
            plot(groupB(i_b).meanDiffSO1,groupB(i_b).meanDiffSO2,'o','Markersize',marker_size,'MarkerFaceColor',colorB,'MarkerEdgeColor',[0 0 0],'LineWidth',1)

            case 1
                if groupB(i_b).h_SO1==1
                    SO1 = plot(groupB(i_b).meanDiffSO1,groupB(i_b).meanDiffSO2,'s','Markersize',marker_size,'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[0 0 0],'LineWidth',1);
                    plot(groupB(i_b).meanDiffSO1,groupB(i_b).meanDiffSO2,'s','Markersize',marker_size,'MarkerFaceColor',colorB,'MarkerEdgeColor',[0 0 0],'LineWidth',1)
   
                else
                    plot(groupB(i_b).meanDiffSO1,groupB(i_b).meanDiffSO2,'^','Markersize',marker_size,'MarkerFaceColor',colorB,'MarkerEdgeColor',[0 0 0],'LineWidth',1)               
                end         
        end
    %end
end

plot([0 0], [-0.5 1],'--k','LineWidth',1.5)
plot([-0.5 1],[0 0],'--k','LineWidth',1.5)


%[hleg,icons,plots,str]  = legend([no_sig SO1 SO2 both],'not significant', 'SO1', 'SO2','both stimuli') ;
[hleg,~,~,~]  = legend([no_sig SO2 both],'not significant', 'f2','both stimuli') ;

set(hleg,'FontSize',font_legend)
set(hleg,'Location','SouthEast')
set(hleg,'box','off')

axis([-.5 1 -.5 1])

ylabel('Response to f2 (z-score)','FontSize',font_size)
xlabel('Response to f1 (z-score)','FontSize',font_size)

%print('-dpdf',[results_folder '/Fig2B_responses_to_stimuli'])
print('-depsc2',[results_folder '/Fig2B_responses_to_stimuli'])
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 2C
load('performanceSetB')
performance_by_freq = fliplr(results_performance.mean_accuracy_f1*100); % origially accuracy is from f1=34 
error_by_freq = fliplr(results_performance.error_accuracy_f1*100);
%%
n_f1 = 6;
range_f1 = [10 14 18 24 30 34];        
response_f1_by_f1 = cell(1,n_f1);
n_correct_f1 = zeros(1,n_f1);
  for f1=1:n_f1
   
      correct=select(eA,'reward',1,'StimFreq1',[range_f1(f1) range_f1(f1)]); 
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
set(gca,'YTick',0:.1:.6,'YTickLabel',{'0','.1','.2','.3','.4','.5','.6'})
axis([0 7 0 .602])

%set(gca,'YTick',[0:.4:1.2],'YTickLabel',{'0','.4','.8','1.2'}) % group B
%axis([0 7 0 .802])
%axis([0 7 -.1 1.2]) % groupB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inset
inset_true = 1;
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

%print('-dpdf',[results_folder '/Fig2C_response_f1_by_f1'])
print('-depsc2',[results_folder '/Fig2Dresponse_f1_by_f1'])
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure_size = [2.5 2.5];
font_size = 15;
line_width1 = 2;
marker_size = 6;

figure('visible','off'),clf, hold on
%figure(1)
hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1,'xColor','k')


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

set(gca,'XTick',x_position(1:end),'XTickLabel',{'10','14','18','24','30','34'},'FontSize',font_size,'TickDir','out')

axis([0 7 75 100])
  
print('-dpdf',[results_folder '/Fig2D_inset'])
print('-depsc2',[results_folder '/Fig2D_inset'])
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    correct=select(eA,'reward',1,'Clase',[class class]);
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
set(gca,'YTick',0.0:.2:1.0,'YTickLabel',{'0','.2','.4','.6','.8','1'})% groupA
axis([0 13 0 1.0]) % groupA

%set(gca,'YTick',[-0.2:.4:1.8],'YTickLabel',{'-.2','.2','.6','1','1.4','1.8'})% groupB
%axis([0 13 -0.2 1.8]) % groupB

%print('-dpdf',[results_folder '/Fig2D_response_f2_by_class'])
print('-depsc2',[results_folder '/Fig2C_response_f2_by_class'])
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