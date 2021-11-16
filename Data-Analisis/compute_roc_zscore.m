function [resultsROC] = compute_roc_zscore(g1,g2,TimeAxis,alpha,numOfConsBins,stepSize,align,all_align)
%% Help
% compute_roc_zscore() --> Obtains the Z-score of two groups that want to
% be compared; calls the function rocindex_permTest() that performs a
% ROC permutation test to obtain significant differences in the Z-score
% between the two desired groups.

% Optionally (Line 62) displays a figure with the temporal evolutions of
% the significant differencies.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ROC Permutation

if all_align == 0
    
    timeAx = cell2mat(eval(TimeAxis));    
    if stepSize == 1
        switch align
            case 1
                g1FR = cell2mat({g1.causal_normalized_1ms_f1}');
                g2FR = cell2mat({g2.causal_normalized_1ms_f1}');
            case 2
                g1FR = cell2mat({g1.causal_normalized_1ms_f2}'); % Define this
                g2FR = cell2mat({g2.causal_normalized_1ms_f2}');
        end
        
    else
        switch align
            case 1 
                g1FR = cell2mat({g1.causal_normalized_10ms_f1}');
                g2FR = cell2mat({g2.causal_normalized_10ms_f1}');
            case 2 
                g1FR = cell2mat({g1.causal_normalized_10ms_f2}');
                g2FR = cell2mat({g2.causal_normalized_10ms_f2}');
            case 3 
                g1FR = cell2mat({g2.causal_normalized_10ms_rew}');
                g2FR = cell2mat({g1.causal_normalized_10ms_rew}');
        end
    end   
else   
    timeAx = TimeAxis{align};   
    switch align
        case 1 % Probe-Down
            g1FR = cell2mat({g1.normalized_kd_align_pd_10ms}');
            g2FR = cell2mat({g2.normalized_kd_align_pd_10ms}');
        case 2 % Stimuli  and Delay
            g1FR = cell2mat({g1.causal_normalized_10ms_pd}');
            g2FR = cell2mat({g2.causal_normalized_10ms_pd}');
        case 3 % Reward
            g1FR = cell2mat({g2.normalized_kd_align_rew_10ms}');
            g2FR = cell2mat({g1.normalized_kd_align_rew_10ms}');
    end    
end 

if 0
    correctStderr = std(g1FR)./sqrt(size(g1FR,1));
    erroresStderr = std(g2FR)./sqrt(size(g2FR,1));
end
[ROC, ci, latency] = rocindex_permTest(g1FR,g2FR,'alpha',alpha,'numOfConsBins',numOfConsBins);

% Displaying results
resultsROC.ROC = ROC;
resultsROC.ci = ci;
resultsROC.latency = latency;
resultsROC.timeAx = timeAx;

%% Z-score and signifcant differences between groups plot (Done in another script) %%
if 0
    ROC(logical(ROC==max(ROC)));
    [~,index] = find(ci>0.05);
    index_end = index( find( index > latency, 1 ) );
    index_start = latency;
    timeAx(latency)
    if not(isempty(latency))
      line_width2 = 2;
      hold on
      myerrorbar(timeAx,mean(g2FR),erroresStderr,'color',[0 0.6 1],'interval',1,'alpha',1);
      errorLeg =  plot(timeAx,mean(g2FR),'color',[0 0.6 1],'linewidth',line_width2);
      plot(timeAx,mean(g2FR),'color','k','linewidth',line_width2/4);

      myerrorbar(timeAx,mean(g1FR),correctStderr,'color',[0 0 1],'interval',1,'alpha',1);
      hitLeg =  plot(timeAx,mean(g1FR),'color',[0 0  1],'linewidth',line_width2);
      plot(timeAx,mean(g1FR),'color','k','linewidth',line_width2/4);

      plot([timeAx(latency) timeAx(latency)],[-.32 -.28],'y','LineWidth',4)
      plot([timeAx(index_start) timeAx(index_end)],[-.3 -.3],'color',[.8 .8 .8],'LineWidth',8)
    end
end
end