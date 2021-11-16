function [results_f1_Anova] = pVal_f1_all_sig_points(e_zscore,timeAx_zscore,displace,result_folder,varargin)
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

range_f1 = [10 14 18 24 30 34];
n_f1 = size(range_f1,2);

vectLong = cell(n_f1,1);
vectShort = cell(n_f1,1);
vectAll = cell(n_f1,1);

n_hits_long = zeros(1,n_f1);
n_hits_short = zeros(1,n_f1);
n_hits_all = zeros(1,n_f1);

for f1=1:n_f1
    selCondLong = (allLongMatrix(:,4)==range_f1(f1))';
    selTrialsLong = hits_long(selCondLong==1);
    
    selCondShort  = (allShortMatrix(:,4)==range_f1(f1))';
    selTrialsShort = hits_short(selCondShort==1);
    
    selCondAll=(allAllMatrix(:,4)==range_f1(f1))';
    selTrialsAll = hits(selCondAll==1);
    
    vectLong{f1,1} = cell2mat({selTrialsLong.zscore}');
    n_hits_long(1,f1) = size(vectLong{f1,1},1);
    
    vectShort{f1,1} = cell2mat({selTrialsShort.zscore}');
    n_hits_short(1,f1) = size(vectShort{f1,1},1);
    
    vectAll{f1,1} = cell2mat({selTrialsAll.zscore}');
    n_hits_all(1,f1) = size(vectAll{f1,1},1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ANOVA

names_long = [repmat({'10hz'}, 1, n_hits_long(1,1)) repmat({'14hz'}, 1, n_hits_long(1,2)) repmat({'18hz'}, 1, n_hits_long(1,3)) ...
    repmat({'24hz'}, 1, n_hits_long(1,4)) repmat({'30hz'}, 1, n_hits_long(1,5)) repmat({'34hz'}, 1, n_hits_long(1,6))];

names_short = [repmat({'10hz'}, 1, n_hits_short(1,1)) repmat({'14hz'}, 1, n_hits_short(1,2)) repmat({'18hz'}, 1, n_hits_short(1,3)) ...
    repmat({'24hz'}, 1, n_hits_short(1,4)) repmat({'30hz'}, 1, n_hits_short(1,5)) repmat({'34hz'}, 1, n_hits_short(1,6))];

names_all = [repmat({'10hz'}, 1, n_hits_all(1,1)) repmat({'14hz'}, 1, n_hits_all(1,2)) repmat({'18hz'}, 1, n_hits_all(1,3)) ...
    repmat({'24hz'}, 1, n_hits_all(1,4)) repmat({'30hz'}, 1, n_hits_all(1,5)) repmat({'34hz'}, 1, n_hits_all(1,6))];

n_time = size(vectShort{1,1},2);
p_val_long = zeros(1,n_time);
p_val_short = zeros(1,n_time);
p_val_all = zeros(1,n_time);
Zscore = zeros(n_f1,n_time);
Zscore_S = zeros(n_f1,n_time);
Zscore_L = zeros(n_f1,n_time);
std_Zscore = zeros(n_f1,n_time);
std_Zscore_S = zeros(n_f1,n_time);
std_Zscore_L = zeros(n_f1,n_time);

for i_t=1:n_time % they all have the same length in time 
    groups_long = [];
    groups_short = [];
    groups_all = [];
    
    for f1=1:n_f1
        groups_long = [groups_long vectLong{f1,1}(:,i_t)'];
        groups_short = [groups_short vectShort{f1,1}(:,i_t)'];
        groups_all = [groups_all vectAll{f1,1}(:,i_t)'];
        
        Zscore(f1,i_t) = mean(vectAll{f1,1}(:,i_t));
        std_Zscore(f1,i_t) = std(vectAll{f1,1}(:,i_t))/sqrt(size(vectAll{f1,1}(:,i_t),1));
        Zscore_S(f1,i_t) = mean(vectShort{f1,1}(:,i_t));
        std_Zscore_S(f1,i_t) = std(vectShort{f1,1}(:,i_t))/sqrt(size(vectShort{f1,1}(:,i_t),1));
        Zscore_L(f1,i_t) = mean(vectLong{f1,1}(:,i_t));
        std_Zscore_L(f1,i_t) = std(vectLong{f1,1}(:,i_t))/sqrt(size(vectLong{f1,1}(:,i_t),1));        
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

[~,index_max] = find(realTime<0.51);
start_index = index_max(end)-50;
[~,index_t] = min(p_val_all(start_index:index_max(end)));
[~,index_tS] = min(p_val_short(start_index:index_max(end)));
[~,index_tL] = min(p_val_long(start_index:index_max(end)));

results_f1_Anova.pVal = p_val_all(index_t+start_index-1);
results_f1_Anova.time = realTime(index_t+start_index-1);
results_f1_Anova.pVal_L = p_val_long(index_tL+start_index-1);
results_f1_Anova.time_L = realTime(index_tL+start_index-1);
results_f1_Anova.pVal_S = p_val_short(index_tS+start_index-1);
results_f1_Anova.time_S = realTime(index_tS+start_index-1);

results_f1_Anova.binWidth = .25;
results_f1_Anova.realTime = realTime;
results_f1_Anova.Response_Evolution = struct;
results_f1_Anova.Response_Evolution.pval_Evol = p_val_all;
results_f1_Anova.Response_Evolution.pval_S_Evol = p_val_short;
results_f1_Anova.Response_Evolution.pval_L_Evol = p_val_long;
results_f1_Anova.Response_Evolution.Zscore = Zscore;
results_f1_Anova.Response_Evolution.Zscore_S = Zscore_S;
results_f1_Anova.Response_Evolution.Zscore_L = Zscore_L;
results_f1_Anova.Response_Evolution.std_Zscore = std_Zscore;
results_f1_Anova.Response_Evolution.std_Zscore_S = std_Zscore_S;
results_f1_Anova.Response_Evolution.std_Zscore_L = std_Zscore_L;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOT: z-score vs f1 in pVals significant: ALL TRIALS

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
        mean_ = zeros(1,n_f1);
        std_ = zeros(1,n_f1);

        for f1=1:n_f1
            response_f1_all = vectAll{f1,1}(:,sel_index)';
            n_hits_all(1,f1) = size(response_f1_all,2);
            mean_(1,f1) = mean(response_f1_all);
            std_(1,f1) = std(response_f1_all);
        end

        % anova results
        p = p_val_all(sel_index);
        t = realTime(sel_index);

        yFit = mean_;
        xFit = range_f1;

        % plots the results
        for f1=1:n_f1
            stderrF1 = std_(1,f1)/sqrt(n_hits_all(1,f1));
            errorbar(xFit(1,f1),yFit(1,f1),stderrF1,'.','MarkerSize',18,'LineWidth',1.8,'color',[0 0 0]/255);
        end

        axis([0 40 -.6 1.5])
        text(15,1.2,{['p = ' num2str(p, '%.3f')];['t = ' num2str(t, '%.3f') 's']},'FontSize',font_size,'Color','r');

        xlabel({'f1 (Hz)'},'FontSize',font_size)
        if i == 0 || mod(i,n_cols)==1
            ylabel('z-score','FontSize',font_size)
        end
    end
    print([result_folder '/z-score-p-val-sig-f1-all-trials'],'-dpdf','-r600');
    close

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PLOT: z-score vs f1 in pVals significant: short RT
    
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

        for f1=1:n_f1
            response_f1_short = vectShort{f1,1}(:,sel_index)';
            n_hits_short(1,f1) = size(response_f1_short,2);
            mean_(1,f1) = mean(response_f1_short);
            std_(1,f1) = std(response_f1_short);
        end

        % anova
        p = p_val_short(sel_index);
        t = realTime(sel_index);

        yFit = mean_;
        xFit = range_f1;

        % plots the results
        for f1=1:6
            stderrF1 = std_(1,f1)/sqrt(n_hits_short(1,f1));
            errorbar(xFit(1,f1),yFit(1,f1),stderrF1,'.','MarkerSize',18,'LineWidth',1.8,'color',[0 0 255]/255);
        end


        axis([0 40 -.6 1.5])
        text(15,1.2,{['p = ' num2str(p, '%.3f')];['t = ' num2str(t, '%.3f') 's']},'FontSize',font_size,'Color','r');

        xlabel({'f1 (Hz)'},'FontSize',font_size)
        if i == 0 || mod(i,n_cols)==1
            ylabel('z-score','FontSize',font_size)
        end
    end
    print([result_folder '/z-score-p-val-sig-f1-short-RT'],'-dpdf','-r600');
    close

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PLOT: z-score vs f1 in pVals significant: long RT

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

        for f1=1:n_f1
            response_f1_all = vectLong{f1,1}(:,sel_index)';

            n_hits_all(1,f1) = size(response_f1_all,2);
            mean_(1,f1) = mean(response_f1_all);
            std_(1,f1) = std(response_f1_all);
        end

        % anova results
        p = p_val_long(sel_index);
        t = realTime(sel_index);

        yFit = mean_;
        xFit = range_f1;

        % plots the results
        for f1=1:n_f1
            stderrF1 = std_(1,f1)/sqrt(n_hits_long(1,f1));
            errorbar(xFit(1,f1),yFit(1,f1),stderrF1,'.','MarkerSize',18,'LineWidth',1.8,'color',[0 188 255]/255);
        end

        axis([0 40 -.6 1.5])
        text(15,1.2,{['p = ' num2str(p, '%.3f')];['t = ' num2str(t, '%.3f') 's']},'FontSize',font_size,'Color','r');

        xlabel({'f1 (Hz)'},'FontSize',font_size)
        if i == 0 || mod(i,n_cols)==1
            ylabel('z-score','FontSize',font_size)
        end
    end
    print([result_folder '/z-score-p-val-sig-f1-long-RT'],'-dpdf','-r600');
    close
end
end
