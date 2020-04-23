function [results_wilcoxon, parameters_wilcoxon] = wilcoxon_test_f1_f2(e,id_e)

eAl = alignSpikes(e,'StimOn1');
correct = select(eAl,'clase',[1 12] , 'reward',1);

centerBeforeSO1 = -.65;
centerBeforeSO2 = 3.3; %3.15 
centerDuringSO1 = .25;
centerAfterSO1 = 1.25; % 500 ms to 1000 ms after SO1 offset

centerDuringSO2 = 3.75; % in the 500 ms of presentation of SO2


binWidth = .5;
binWidth2 = .35;


beforeSO1_FR = firingrate([correct.spikeTimes],centerBeforeSO1,'filtertype','boxcar','timeconstant',binWidth); 
beforeSO2_FR = firingrate([correct.spikeTimes],centerBeforeSO2,'filtertype','boxcar','timeconstant',binWidth); 
duringSO1_FR = firingrate([correct.spikeTimes],centerDuringSO1,'filtertype','boxcar','timeconstant',binWidth); 
afterSO1_FR = firingrate([correct.spikeTimes],centerAfterSO1,'filtertype','boxcar','timeconstant',binWidth); 
duringSO2_FR = firingrate([correct.spikeTimes],centerDuringSO2,'filtertype','boxcar','timeconstant',binWidth2); 


[p_SO1,h_SO1] = signrank(duringSO1_FR,beforeSO1_FR,'tail','right'); % tests that median of
%the first input is greater (tail right) than the median of the second

%[p_SO1,h_SO1] = signrank(duringSO1_FR,beforeSO1_FR);

[p_delay,h_delay] = signrank(beforeSO2_FR,beforeSO1_FR,'tail','right');

[p_within_delay,h_within_delay] = signrank(beforeSO2_FR,afterSO1_FR,'tail','right');

[p_decreas_delay,h_decreas_delay] = signrank(beforeSO2_FR,afterSO1_FR,'tail','left');

[p_SO2,h_SO2] = signrank(duringSO2_FR,beforeSO1_FR,'tail','right'); 
%[p_SO2,h_SO2] = signrank(duringSO2_FR,beforeSO1_FR); 



meanBeforeSO1 = mean(beforeSO1_FR);
meanDuringSO1 = mean(duringSO1_FR);
meanBeforeSO2 = mean(beforeSO2_FR);
meanAfterSO1 = mean(afterSO1_FR);
meanDuringSO2 = mean(duringSO2_FR);


semBeforeSO1 = std(beforeSO1_FR)/sqrt(size(duringSO1_FR,1));
semDuringSO1 = std(duringSO1_FR)/sqrt(size(duringSO1_FR,1));
semBeforeSO2 = std(beforeSO2_FR)/sqrt(size(duringSO1_FR,1));
semAfterSO1 = std(beforeSO2_FR)/sqrt(size(afterSO1_FR,1));
semDuringSO2 = std(duringSO2_FR)/sqrt(size(duringSO2_FR,1));



parameters_wilcoxon.center_preSO1 = centerBeforeSO1;
parameters_wilcoxon.center_inSO1 = centerDuringSO1;
parameters_wilcoxon.center_preSO2 = centerBeforeSO2;
parameters_wilcoxon.center_afterSO1 = centerAfterSO1;
parameters_wilcoxon.center_inSO2 = centerDuringSO2;
parameters_wilcoxon.binWidth = binWidth;
parameters_wilcoxon.binWidthSO2 = binWidth2;



results_wilcoxon.p_SO1 = p_SO1;
results_wilcoxon.h_SO1 = h_SO1;
results_wilcoxon.p_delay = p_delay;
results_wilcoxon.h_delay = h_delay;
results_wilcoxon.p_ramp = p_within_delay;
results_wilcoxon.h_ramp  = h_within_delay;
results_wilcoxon.p_neg = p_decreas_delay;
results_wilcoxon.h_neg  = h_decreas_delay;
results_wilcoxon.p_SO2 = p_SO2;
results_wilcoxon.h_SO2 = h_SO2;

% results_wilcoxon.meanBeforeSO1 = meanBeforeSO1;
% results_wilcoxon.meanDuringSO1 = meanDuringSO1;
% results_wilcoxon.meanBeforeSO2 = meanBeforeSO2;
% results_wilcoxon.meanAfterSO1 = meanAfterSO1;
% results_wilcoxon.meanDuringSO2 = meanDuringSO2;

results_wilcoxon.meanDiffSO1 = (meanDuringSO1-meanBeforeSO1)/std(beforeSO1_FR); % these are z-scores
results_wilcoxon.meanDiffSO2 = (meanDuringSO2-meanBeforeSO1)/std(beforeSO1_FR);

results_wilcoxon.id_neuron = id_e;

%results_wilcoxon.sem = [semBeforeSO1;semDuringSO1;semBeforeSO2;semAfterSO1];
%save the results
   

end

