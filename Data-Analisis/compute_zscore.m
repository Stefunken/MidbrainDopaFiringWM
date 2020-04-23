function zscore = compute_zscore(firing_rate,mean_basal,std_basal)
    zscore = (firing_rate - mean_basal)/std_basal;
end