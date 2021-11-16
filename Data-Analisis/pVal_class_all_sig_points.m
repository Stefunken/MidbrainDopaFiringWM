function [results_class_Anova] = pVal_class_all_sig_points(e_zscore,timeAx_zscore,displace,result_folder,varargin)
%% Obtaining RT Percentiles and Z-scores

hits=select(e_zscore,'reward',1); % here we use hits instead of correct trials

all_RTN = [hits.RTKD]; % Response Times
long_index = all_RTN > prctile(all_RTN,50);
short_index = all_RTN < prctile(all_RTN,50);

hits_long = hits(long_index==1);
hits_short = hits(short_index==1);

allLongMatrix=cell2mat({hits_long.conditions}');
allShortMatrix=cell2mat({hits_short.conditions}');
allAllMatrix=cell2mat({hits.conditions}');

n_classes = 12;      

vectLong = cell(n_classes,1);
vectShort = cell(n_classes,1);
vectAll = cell(n_classes,1);

n_hits_long = zeros(1,n_classes);
n_hits_short = zeros(1,n_classes);
n_hits_all = zeros(1,n_classes);

for class=1:n_classes
    selCondHigh = (allLongMatrix(:,1) == class)';
    selTrialsHigh = hits_long(selCondHigh==1);
    
    selCondLow = (allShortMatrix(:,1) == class)';
    selTrialsLow = hits_short(selCondLow==1);
    
    selCondAll = (allAllMatrix(:,1) == class)';
    selTrialsAll = hits(selCondAll == 1);
    
    vectLong{class,1} = cell2mat({selTrialsHigh.zscore}');
    n_hits_long(1,class) = size(vectLong{class,1},1);
    
    vectShort{class,1} = cell2mat({selTrialsLow.zscore}');
    n_hits_short(1,class) = size(vectShort{class,1},1);
    
    vectAll{class,1} = cell2mat({selTrialsAll.zscore}');
    n_hits_all(1,class) = size(vectAll{class,1},1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ANOVA 

names_long = [repmat({'1'}, 1, n_hits_long(1,1)) repmat({'2'}, 1, n_hits_long(1,2)) repmat({'3'}, 1, n_hits_long(1,3)) ...
repmat({'4'}, 1, n_hits_long(1,4)) repmat({'5'}, 1, n_hits_long(1,5)) repmat({'6'}, 1, n_hits_long(1,6)) ...
repmat({'7'}, 1, n_hits_long(1,7)) repmat({'8'}, 1, n_hits_long(1,8)) repmat({'9'}, 1, n_hits_long(1,9)) ...
repmat({'10'}, 1, n_hits_long(1,10)) repmat({'11'}, 1, n_hits_long(1,11)) repmat({'12'}, 1, n_hits_long(1,12))];

names_short = [repmat({'1'}, 1, n_hits_short(1,1)) repmat({'2'}, 1, n_hits_short(1,2)) repmat({'3'}, 1, n_hits_short(1,3)) ...
repmat({'4'}, 1, n_hits_short(1,4)) repmat({'5'}, 1, n_hits_short(1,5)) repmat({'6'}, 1, n_hits_short(1,6)) ...
repmat({'7'}, 1, n_hits_short(1,7)) repmat({'8'}, 1, n_hits_short(1,8)) repmat({'9'}, 1, n_hits_short(1,9)) ...
repmat({'10'}, 1, n_hits_short(1,10)) repmat({'11'}, 1, n_hits_short(1,11)) repmat({'12'}, 1, n_hits_short(1,12))];  

names_all = [repmat({'1'}, 1, n_hits_all(1,1)) repmat({'2'}, 1, n_hits_all(1,2)) repmat({'3'}, 1, n_hits_all(1,3)) ...
repmat({'4'}, 1, n_hits_all(1,4)) repmat({'5'}, 1, n_hits_all(1,5)) repmat({'6'}, 1, n_hits_all(1,6)) ...
repmat({'7'}, 1, n_hits_all(1,7)) repmat({'8'}, 1, n_hits_all(1,8)) repmat({'9'}, 1, n_hits_all(1,9)) ...
repmat({'10'}, 1, n_hits_all(1,10)) repmat({'11'}, 1, n_hits_all(1,11)) repmat({'12'}, 1, n_hits_all(1,12))];  

n_time = size(vectShort{1,1},2);
p_val_long = zeros(1,n_time);
p_val_short = zeros(1,n_time);
p_val_all = zeros(1,n_time);
Zscore = zeros(n_classes,n_time);
Zscore_S = zeros(n_classes,n_time);
Zscore_L = zeros(n_classes,n_time);
std_Zscore = zeros(n_classes,n_time);
std_Zscore_S = zeros(n_classes,n_time);
std_Zscore_L = zeros(n_classes,n_time);

for i_t=1:n_time 
    groups_long = [];
    groups_short = [];
    groups_all = [];
    
    for class=1:n_classes
        groups_long = [groups_long vectLong{class,1}(:,i_t)'];
        groups_short = [groups_short vectShort{class,1}(:,i_t)'];
        groups_all = [groups_all vectAll{class,1}(:,i_t)'];
        
        Zscore(class,i_t) = mean(vectAll{class,1}(:,i_t));
        std_Zscore(class,i_t) = std(vectAll{class,1}(:,i_t))/sqrt(size(vectAll{class,1}(:,i_t),1));
        Zscore_S(class,i_t) = mean(vectShort{class,1}(:,i_t));
        std_Zscore_S(class,i_t) = std(vectShort{class,1}(:,i_t))/sqrt(size(vectShort{class,1}(:,i_t),1));
        Zscore_L(class,i_t) = mean(vectLong{class,1}(:,i_t));
        std_Zscore_L(class,i_t) = std(vectLong{class,1}(:,i_t))/sqrt(size(vectLong{class,1}(:,i_t),1));
    end
    
    pL = anova1(groups_long, names_long,'off');
    pS = anova1(groups_short, names_short,'off');
    pA = anova1(groups_all, names_all,'off');
    
    p_val_long(1,i_t) = pL;
    p_val_short(1,i_t) = pS;
    p_val_all(1,i_t) = pA;    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Returning results into a matlab structure

realTime = timeAx_zscore-displace;

[~,index_max] = find(realTime<4.1 );
start_index = index_max(end)-100;
[~,index_t] = min(p_val_all(start_index:index_max(end)));
[~,index_tS] = min(p_val_short(start_index:index_max(end)));
[~,index_tL] = min(p_val_long(start_index:index_max(end)));

results_class_Anova.pVal = p_val_all(index_t+start_index-1);
results_class_Anova.time = realTime(index_t+start_index-1);
results_class_Anova.pVal_L = p_val_long(index_tL+start_index-1);
results_class_Anova.time_L = realTime(index_tL+start_index-1);
results_class_Anova.pVal_S = p_val_short(index_tS+start_index-1);
results_class_Anova.time_S = realTime(index_tS+start_index-1);

results_class_Anova.binWidth = .25;
results_class_Anova.realTime = realTime;
results_class_Anova.Response_Evolution = struct;
results_class_Anova.Response_Evolution.pval_Evol = p_val_all;
results_class_Anova.Response_Evolution.pval_S_Evol = p_val_short;
results_class_Anova.Response_Evolution.pval_L_Evol = p_val_long;
results_class_Anova.Response_Evolution.Zscore = Zscore;
results_class_Anova.Response_Evolution.Zscore_S = Zscore_S;
results_class_Anova.Response_Evolution.Zscore_L = Zscore_L;
results_class_Anova.Response_Evolution.std_Zscore = std_Zscore;
results_class_Anova.Response_Evolution.std_Zscore_S = std_Zscore_S;
results_class_Anova.Response_Evolution.std_Zscore_L = std_Zscore_L;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOT: z-score vs class number in pVals significant: ALL TRIALS

Opt_Figs = getArgumentValue('Optional_Figs', 0, varargin{:});
% if 1 --> Displays pdfs with all temporal points where ANOVA yielded significant results
if Opt_Figs
    realTime = timeAx_zscore-displace;

    [~,ind_sign_all] = find(p_val_all <=.05);
    n_sign = length(ind_sign_all);
    n_cols = 7;

    if mod(n_sign,n_cols)==0
        n_rows = round(n_sign/n_cols);
    else
        n_rows = round(n_sign/n_cols) + 1;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Figure properties
    figure_size = [2.8*n_cols 3*n_rows];
    font_size = 15;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    figure('visible','off'),clf
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',figure_size)
    set(gcf, 'PaperPosition', [0 0 figure_size])

    for i = 1:n_sign
        subplot(n_rows,n_cols,i)
        set(gca,'FontSize',font_size)
        hold on

        sel_index = ind_sign_all(i);
        mean_ = zeros(1,n_classes);
        std_ = zeros(1,n_classes);

        for class=1:n_classes
            response_class_all = vectAll{class,1}(:,sel_index)';
            n_hits_all(1,class) = size(response_class_all,2);
            mean_(1,class) = mean(response_class_all);
            std_(1,class) = std(response_class_all);
        end

        % anova results
        p = p_val_all(sel_index);
        t = realTime(sel_index);

        yFit = mean_;
        xFit = 1:n_classes;

        % plots the results
        for class = 1:n_classes
            stderrC = std_(1,class)/sqrt(n_hits_all(1,class));
            errorbar(xFit(1,class),yFit(1,class),stderrC,'.','MarkerSize',18,'LineWidth',1.8,'color',[0 0 0]/255);
        end

        axis([0 13 -.8 2.2])
        text(5,1.8,{['p = ' num2str(p, '%.4f')];['t = ' num2str(t, '%.3f') 's']},'FontSize',font_size,'Color','r')    

        xlabel({'Class number'},'FontSize',font_size)
        if i == 0 || mod(i,n_cols)==1
            ylabel('z-score','FontSize',font_size)
        end
    end
    print([result_folder '/z-score-p-val-sig-class-all-trials'],'-dpdf','-r600');
    close
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PLOT: z-score vs class in pVals significant: short RT
    
    [~,ind_sign_low] = find(p_val_short <=.05);
    n_sign = length(ind_sign_low);
    n_cols = 7;

    if mod(n_sign,n_cols)==0
        n_rows = round(n_sign/n_cols);
    else
        n_rows = round(n_sign/n_cols) + 1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %n Figure properties
    figure_size = [2.8*n_cols 3*n_rows];
    font_size = 15;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    figure('visible','off'),clf

    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',figure_size)
    set(gcf, 'PaperPosition', [0 0 figure_size])

    for i = 1:n_sign
        subplot(n_rows,n_cols,i)
        set(gca,'FontSize',font_size)

        sel_index = ind_sign_low(i);

        hold on

        for class = 1:n_classes
            response_class_short = vectShort{class,1}(:,sel_index)';
            n_hits_short(1,class) = size(response_class_short,2);
            mean_(1,class) = mean(response_class_short);
            std_(1,class) = std(response_class_short);
        end

        % anova
        p = p_val_short(sel_index);
        t = realTime(sel_index);

        yFit = mean_;
        xFit = 1:n_classes;

        % plots the results
        for class = 1:n_classes
            stderrC = std_(1,class)/sqrt(n_hits_short(1,class));
            errorbar(xFit(1,class),yFit(1,class),stderrC,'.','MarkerSize',18,'LineWidth',1.8,'color',[0 0 255]/255);
        end

        axis([0 13 -.8 2.2])
        text(5,1.8,{['p = ' num2str(p, '%.4f')];['t = ' num2str(t, '%.3f') 's']},'FontSize',font_size,'Color','r')    

        xlabel({'Class number'},'FontSize',font_size)
        if i == 0 || mod(i,n_cols)==1
            ylabel('z-score','FontSize',font_size)
        end
    end
    print([result_folder '/z-score-p-val-sig-class-short-RT'],'-dpdf','-r600');
    close

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PLOT: z-score vs class in pVals significant: long RT

    [~,ind_sign_high] = find(p_val_long <=.05);
    n_sign = length(ind_sign_high);
    n_cols = 7;

    if mod(n_sign,n_cols)==0
        n_rows = round(n_sign/n_cols);
    else
        n_rows = round(n_sign/n_cols) + 1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Figure properties
    figure_size = [2.8*n_cols 3*n_rows];
    font_size = 15;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure('visible','off'),clf
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',figure_size)
    set(gcf, 'PaperPosition', [0 0 figure_size])

    for i = 1:n_sign
        subplot(n_rows,n_cols,i)
        set(gca,'FontSize',font_size)
        hold on

        sel_index = ind_sign_high(i);

        for class = 1:n_classes
            response_class_all = vectLong{class,1}(:,sel_index)';

            n_hits_all(1,class) = size(response_class_all,2);
            mean_(1,class) = mean(response_class_all);
            std_(1,class) = std(response_class_all);
        end

        % anova results
        p = p_val_long(sel_index);
        t = realTime(sel_index);

        yFit = mean_;
        xFit = 1:n_classes;

        % plots the results
        for class = 1:n_classes
            stderrC = std_(1,class)/sqrt(n_hits_long(1,class));
            errorbar(xFit(1,class),yFit(1,class),stderrC,'.','MarkerSize',18,'LineWidth',1.8,'color',[0 188 255]/255);
        end

        axis([0 13 -.8 2.2])
        text(5,1.8,{['p = ' num2str(p, '%.4f')];['t = ' num2str(t, '%.3f') 's']},'FontSize',font_size,'Color','r')    

        xlabel({'Class number'},'FontSize',font_size)
        if i == 0 || mod(i,n_cols)==1
            ylabel('z-score','FontSize',font_size)
        end
    end
    print([result_folder '/z-score-p-val-sig-class-long-RT'],'-dpdf','-r600');
    close
end
end
