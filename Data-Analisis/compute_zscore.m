function zscore = compute_zscore(firing_rate,mean_basal,std_basal)
% Computes de standardized firing rate with respect to a baseline
zscore = (firing_rate - mean_basal)/std_basal;
end