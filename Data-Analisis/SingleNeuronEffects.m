function SN_Table = SingleNeuronEffects(eA,pvals_ramping,R2_Ramping,fileListA,HC_K,LC_K)

nNeurons = size(eA,2);              % Neurons

SN_Table = struct;                  
for iN = 1:nNeurons
    correct = select(eA(iN),'reward',1);
    
    %%%%% Neuron ID %%%%%
    SN_Table(iN).NeuronID = fileListA(iN);
        
    %%%%% Response PD %%%%% ==> Wilcoxon Signed Rank Test
    response_PD = cell2mat({correct.norm_response_PD_Win}');
    SN_Table(iN).response_PD = mean(response_PD);
    SN_Table(iN).pval_PD = signrank(response_PD,0,'tail','right');
    
    %%%%% Response by f1 at SO1 %%%%% ==> Wilcoxon Signed Rank Test
    response_f1 = cell2mat({correct.normalized_response_f1}');
    SN_Table(iN).response_f1 = mean(response_f1);
    SN_Table(iN).pval_SO1 = signrank(response_f1,0,'tail','right');
    
    %%%%% Response by class number at SO2 %%%%% ==> Wilcoxon Signed Rank Test
    response_f2 = cell2mat({correct.normalized_response_f2}');
    SN_Table(iN).response_f2 = mean(response_f2);
    SN_Table(iN).pval_SO2 = signrank(response_f2,0,'tail','right');
    
    %%%%% Difficulty Modulation %%%%% ==> T-test
    response_f1_by_diff = cell(1,2);
    response_f2_by_diff = cell(1,2);
    HC = [select(eA(iN),'reward',1,'clase',HC_K(1,:)),select(eA(iN),'reward',1,'clase',HC_K(2,:))];
    LC = select(eA(iN),'reward',1,'clase',LC_K);
    
            % Modulation at SO1
    response_f1_by_diff{1,1} = cell2mat({HC.normalized_response_f1}'); % High Confidence - Low Difficulty
    response_f1_by_diff{1,2} = cell2mat({LC.normalized_response_f1}'); % Low Confidence - High Difficulty
    SN_Table(iN).response_SO1_Difficulty = [mean(response_f1_by_diff{1,1}) mean(response_f1_by_diff{1,2})];
    [~,SN_Table(iN).pval_SO1_Difficulty] = ttest2(response_f1_by_diff{1,1},response_f1_by_diff{1,2});
            % Modulation at SO2
    response_f2_by_diff{1,1} = cell2mat({HC.normalized_response_f2}'); % High Confidence - Low Difficulty
    response_f2_by_diff{1,2} = cell2mat({LC.normalized_response_f2}'); % Low Confidence - High Difficulty
    SN_Table(iN).response_SO2_Difficulty = [mean(response_f2_by_diff{1,1}) mean(response_f2_by_diff{1,2})];
%     [~,SN_Table(iN).pval_SO2_Difficulty] = ttest2(response_f2_by_diff{1,1},response_f2_by_diff{1,2},'Tail','Right');
    [SN_Table(iN).pval_SO2_Difficulty,~] = ranksum(response_f2_by_diff{1,1},response_f2_by_diff{1,2},'Tail','Right');
    
    %%%%% Ramping %%%%% ==> T-test for R2>0
    SN_Table(iN).pRamping = pvals_ramping(iN);    
    if R2_Ramping(2,iN) < 0
        SN_Table(iN).Ramp = 'Negative';
        SN_Table(iN).R2_Ramping = -R2_Ramping(1,iN);
    else
        SN_Table(iN).Ramp = 'Positive';
        SN_Table(iN).R2_Ramping = R2_Ramping(1,iN);
    end
    
end

% [CC_Ramping_vs_ClassModulation,pVal_Ramping_vs_ClassModulation] = corrcoef([SN_Table.pRamping],[SN_Table.pval_SO2_Difficulty])