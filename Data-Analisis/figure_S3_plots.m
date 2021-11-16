function [e_zscore_10ms,results_f1_Anova,results_class_Anova] = figure_S3_plots(eA,folder_name)
%% Obtaining p-values and Z-scores

f1 = [10 14 18 24 30 34]; 
classes = (1:12); 

[e_zscore_10ms,timeAx_zscore_10ms,displace] = compute_z_score_delay_shift10_window250(eA);
[results_f1_Anova] = pVal_f1_all_sig_points(e_zscore_10ms,timeAx_zscore_10ms,displace(2),folder_name,'Optional_Figs',0);
[results_class_Anova] = pVal_class_all_sig_points(e_zscore_10ms,timeAx_zscore_10ms,displace(2),folder_name,'Optional_Figs',0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data Analysis and preparation

kappa = 1; % In case we want to smooth the time evolution of the p-values --> kappa<1

timeAx = results_f1_Anova.realTime;
pAll_f1 = 0*timeAx;
pAll_f1_e = 0;
pAll_class = 0*timeAx; 
pAll_class_e = 0; 

% Exponentially running average
for t = 1:size(timeAx,2)
    pAll_f1_e = (1-kappa)*pAll_f1_e + kappa*results_f1_Anova.Response_Evolution.pval_Evol(1,t);
    pAll_f1(1,t) = pAll_f1_e;
    
    pAll_class_e = (1-kappa)*pAll_class_e + kappa*results_class_Anova.Response_Evolution.pval_Evol(1,t);
    pAll_class(1,t) = pAll_class_e;
end

% Gray Shaded Areas in figures
stim1 = [0.01 0.01 0.49 0.49];
stim2 = [3.51 3.51 3.99 3.99];
y = [-20 -20 -20 -20];
mygray = [.9 .9 .9];

% Color code 
col_All = [.2,.2,1]; %[0 0 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% P-val ANOVA Evolution and zscore by F1

figure_size = [10 2];
font_size = 15;

figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

% Significant temporal positions ANOVA modulation
t1 = -.3350; timeAx(1,103) = t1; % This is just because of decimal precision
t2 = 0.2250; timeAx(1,161) = t2; % t2 = 0.1550; timeAx(1,154) = t2;
t3 = 2.3650; timeAx(1,375) = t3;
t4 = 3.7150; timeAx(1,510) = t4;
t5 = 4.2550; timeAx(1,564) = t5;

area(stim1,y,'EdgeColor',mygray,'FaceColor',mygray,'HandleVisibility','Off');
hold on;
    area(stim2,y,'EdgeColor',mygray,'FaceColor',mygray,'HandleVisibility','Off');
    plot(timeAx,log(pAll_f1),'LineWidth',2,'Color',col_All,'DisplayName','All Trials');
    yline(log(0.05),'--r','LineWidth',2,'HandleVisibility','Off');
hold off;
axis([-1 4.5 -10 0]);
xlabel('Time from SO1 (s)','FontSize',10);
ylabel('log(p)','FontSize',12);
set(gca, 'XAxisLocation', 'top','box','off');

print([folder_name '/pval_f1_Evolution_A'],'-dpdf','-r600');
print([folder_name '/pval_f1_Evolution_A'],'-deps');

% BOTTOM Panel; zscores
figure_size = [12 2];
font_size = 15;

figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

subplot(1,5,1)
    Zs_f1 = results_f1_Anova.Response_Evolution.Zscore(:,timeAx==t1)';
    std_Zs_f1 = results_f1_Anova.Response_Evolution.std_Zscore(:,timeAx==t1)';
    errorbar(f1,Zs_f1,std_Zs_f1,'.','MarkerSize',15,'LineWidth',1.8,'color',col_All);
    text(18,1.4,['t = ' num2str(t1) 's'],'FontSize',10,'Color','r');
    text(18,1.2,['p = ' num2str(round(pAll_f1(timeAx==t1),3))],'FontSize',10,'Color','r');
    xlabel('f_1 (Hz)','FontSize',10);
    ylabel('zscore');
    ylim([-0.5 1.5]);
    xlim([9 35]);
    set(gca,'box','off','XTick',f1);
subplot(1,5,2)
    Zs_f1 = results_f1_Anova.Response_Evolution.Zscore(:,timeAx==t2)';
    std_Zs_f1 = results_f1_Anova.Response_Evolution.std_Zscore(:,timeAx==t2)';
    errorbar(f1,Zs_f1,std_Zs_f1,'.','MarkerSize',15,'LineWidth',1.8,'color',col_All);
    text(18,1.4,['t = ' num2str(t2) 's'],'FontSize',10,'Color','r');
    text(18,1.2,['p = ' num2str(round(pAll_f1(timeAx==t2),3))],'FontSize',10,'Color','r');
    xlabel('f_1 (Hz)','FontSize',10);
    xlim([9 35]);
    ylim([-0.5 1.5]);
    set(gca,'box','off','XTick',f1);
subplot(1,5,3)
    Zs_f1 = results_f1_Anova.Response_Evolution.Zscore(:,timeAx==t3)';
    std_Zs_f1 = results_f1_Anova.Response_Evolution.std_Zscore(:,timeAx==t3)';
    errorbar(f1,Zs_f1,std_Zs_f1,'.','MarkerSize',15,'LineWidth',1.8,'color',col_All);
    text(18,1.4,['t = ' num2str(t3) 's'],'FontSize',10,'Color','r');
    text(18,1.2,['p = ' num2str(round(pAll_f1(timeAx==t3),3))],'FontSize',10,'Color','r');
    xlabel('f_1 (Hz)','FontSize',10);
    xlim([9 35]);
    ylim([-0.5 1.5]);
    set(gca,'box','off','XTick',f1);
subplot(1,5,4)
    Zs_f1 = results_f1_Anova.Response_Evolution.Zscore(:,timeAx==t4)';
    std_Zs_f1 = results_f1_Anova.Response_Evolution.std_Zscore(:,timeAx==t4)';
    errorbar(f1,Zs_f1,std_Zs_f1,'.','MarkerSize',15,'LineWidth',1.8,'color',col_All);
    text(18,1.4,['t = ' num2str(t4) 's'],'FontSize',10,'Color','r');
    text(18,1.2,['p = ' num2str(round(pAll_f1(timeAx==t4),3))],'FontSize',10,'Color','r');
    xlabel('f_1 (Hz)','FontSize',10);
    xlim([9 35]);
    ylim([-0.5 1.5]);
    set(gca,'box','off','XTick',f1);
subplot(1,5,5)
    Zs_f1 = results_f1_Anova.Response_Evolution.Zscore(:,timeAx==t5)';
    std_Zs_f1 = results_f1_Anova.Response_Evolution.std_Zscore(:,timeAx==t5)';
    errorbar(f1,Zs_f1,std_Zs_f1,'.','MarkerSize',15,'LineWidth',1.8,'color',col_All);
    text(18,1.4,['t = ' num2str(t5) 's'],'FontSize',10,'Color','r');
    text(18,1.2,['p = ' num2str(round(pAll_f1(timeAx==t5),3))],'FontSize',10,'Color','r');
    xlabel('f_1 (Hz)','FontSize',10);
    xlim([9 35]);
    ylim([-0.5 1.5]);
    set(gca,'box','off','XTick',f1);  
    
print([folder_name '/pval_f1_Evolution_B'],'-dpdf','-r600');
print([folder_name '/pval_f1_Evolution_B'],'-deps');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% P-val Evolution ANOVA by Classes

figure_size = [10 2];
font_size = 15;

figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

% Significant temporal positions ANOVA modulation
t1 = -.3350; timeAx(1,103) = t1; % This is just because of decimal precision
t2 = 0.2950; timeAx(1,168) = t2;
t3 = 1.9250; timeAx(1,331) = t3;
t4 = 3.6850; timeAx(1,507) = t4;
t5 = 4.2550; timeAx(1,564) = t5;

area(stim1,y,'EdgeColor',mygray,'FaceColor',mygray,'HandleVisibility','Off');
hold on;
    area(stim2,y,'EdgeColor',mygray,'FaceColor',mygray,'HandleVisibility','Off');
    plot(timeAx,log(pAll_class),'LineWidth',2,'Color',col_All,'DisplayName','All Trials');
    yline(log(0.05),'--r','LineWidth',2,'HandleVisibility','Off');
hold off;
axis([-1 4.5 -20 0]);
xlabel('Time from SO1 (s)','FontSize',10);
ylabel('log(p)','FontSize',12);
set(gca, 'XAxisLocation', 'top','box','off');

print([folder_name '/pval_class_Evolution_A'],'-dpdf','-r600');
print([folder_name '/pval_class_Evolution_A'],'-deps');

% BOTTOM Panel; zscores
figure_size = [12 2];
font_size = 15;

figure('visible','off'),clf, hold on
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

subplot(1,5,1)
    Zs_class = results_class_Anova.Response_Evolution.Zscore(:,timeAx==t1)';
    std_Zs_class = results_class_Anova.Response_Evolution.std_Zscore(:,timeAx==t1)';
    errorbar(classes,Zs_class,std_Zs_class,'.','MarkerSize',15,'LineWidth',1.8,'color',col_All);
    text(5,1.4,['t = ' num2str(t1) 's'],'FontSize',10,'Color','r');
    text(5,1.2,['p = ' num2str(round(pAll_class(timeAx==t1),3))],'FontSize',10,'Color','r');
    xlabel('Class Number','FontSize',10);
    ylabel('zscore');
    ylim([-0.5 1.5]);
    xlim([0 13]);
    set(gca,'box','off','XTick',classes);
subplot(1,5,2)
    Zs_class = results_class_Anova.Response_Evolution.Zscore(:,timeAx==t2)';
    std_Zs_class = results_class_Anova.Response_Evolution.std_Zscore(:,timeAx==t2)';
    errorbar(classes,Zs_class,std_Zs_class,'.','MarkerSize',15,'LineWidth',1.8,'color',col_All);
    text(5,1.4,['t = ' num2str(t2) 's'],'FontSize',10,'Color','r');
    text(5,1.2,['p = ' num2str(round(pAll_class(timeAx==t2),3))],'FontSize',10,'Color','r');
    xlabel('Class Number','FontSize',10);
    xlim([0 13]);
    ylim([-0.5 1.5]);
    set(gca,'box','off','XTick',classes);
subplot(1,5,3)
    Zs_class = results_class_Anova.Response_Evolution.Zscore(:,timeAx==t3)';
    std_Zs_class = results_class_Anova.Response_Evolution.std_Zscore(:,timeAx==t3)';
    errorbar(classes,Zs_class,std_Zs_class,'.','MarkerSize',15,'LineWidth',1.8,'color',col_All);
    text(5,1.4,['t = ' num2str(t3) 's'],'FontSize',10,'Color','r');
    text(5,1.2,['p = ' num2str(round(pAll_class(timeAx==t3),3))],'FontSize',10,'Color','r');
    xlabel('Class Number','FontSize',10);
    xlim([0 13]);
    ylim([-0.5 1.5]);
    set(gca,'box','off','XTick',classes);
subplot(1,5,4)
    Zs_class = results_class_Anova.Response_Evolution.Zscore(:,timeAx==t4)';
    std_Zs_class = results_class_Anova.Response_Evolution.std_Zscore(:,timeAx==t4)';
    errorbar(classes,Zs_class,std_Zs_class,'.','MarkerSize',15,'LineWidth',1.8,'color',col_All);
    text(5,1.4,['t = ' num2str(t4) 's'],'FontSize',10,'Color','r');
    text(5,1.2,['p < 0.001'],'FontSize',10,'Color','r');
    xlabel('Class Number','FontSize',10);
    xlim([0 13]);
    ylim([-0.5 1.5]);
    set(gca,'box','off','XTick',classes);
subplot(1,5,5)
    Zs_class = results_class_Anova.Response_Evolution.Zscore(:,timeAx==t5)';
    std_Zs_class = results_class_Anova.Response_Evolution.std_Zscore(:,timeAx==t5)';
    errorbar(classes,Zs_class,std_Zs_class,'.','MarkerSize',15,'LineWidth',1.8,'color',col_All);
    text(5,1.4,['t = ' num2str(t5) 's'],'FontSize',10,'Color','r');
    text(5,1.2,['p = ' num2str(round(pAll_class(timeAx==t5),3))],'FontSize',10,'Color','r');
    xlabel('Class Number','FontSize',10);
    xlim([0 13]);
    ylim([-0.5 1.5]);
    set(gca,'box','off','XTick',classes);
    
print([folder_name '/pval_class_Evolution_B'],'-dpdf','-r600');
print([folder_name '/pval_class_Evolution_B'],'-deps');
