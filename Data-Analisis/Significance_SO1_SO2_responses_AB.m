close all
clear all
clc

%%
load('wilcoxon_POS_3a.mat');
groupA = results_wilcoxon_single;
%%
load('wilcoxon_POS_3b.mat');
groupB = results_wilcoxon_single;
groupB = groupB(2:12); % eliminate first and last neurons, do correspond to set B 
%%

significanceA=[groupA.h_SO1]'+[groupA.h_SO2]';
significanceB=[groupB.h_SO1]'+[groupB.h_SO2]';
%%

colorA = [255 123 31]/255;
colorB = [133 255 102]/255;

%%% figure properties
figure_size = [4.5 3.5];
font_size = 15;
font_legend = 12;
line_width1 = 1.4;
line_width2 = 3;
marker_size = 6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Response to SO1
figure('visible','on'),clf, hold on
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
[hleg,icons,plots,str]  = legend([no_sig SO2 both],'not significant', 'SO2','both stimuli') ;

set(hleg,'FontSize',font_legend)
set(hleg,'Location','SouthEast')
set(hleg,'box','off')

axis([-.5 1 -.5 1])

ylabel('Response to SO2 (z-score)','FontSize',font_size)
xlabel('Response to SO1 (z-score)','FontSize',font_size)

print('GroupAB_POSITIVE_responses','-dpdf','-r600');
print('-depsc2','GroupAB_POSITIVE_responses')
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%