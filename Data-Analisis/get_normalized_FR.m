function eNorm = get_normalized_FR(e1,binWidthSO,timeAxisSO,binWidthSO2,timeAxisSO2)
%% Help

% Receives as inputs a MATLAB structure (e1) with the Spike Times of each
% neuron in each trial. Also the characteristics of the windows to compute
% the Firing Rates (FRs) and Zscores at both the first and second stimuli.
% The ouptut is the same MATLAB structure with the added fields containing
% the neuron responses (FRs and Zscores) at the different events. Check the
% next section for window and events characterization.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Window characterization

% Declaring the different alignment events
align    = {'ProbeDown','StimOn1', 'PushKey','StimOn2'};
% Filter type for computing FRs
filterType = 'boxcar';
% Baseline 
normCenterWidth = [1 .5]; % [1s after KD and .5s width] 

% Window Widths 
binWidthPD = .3;             % Probe Down (PD)
binWidthDelay = 3; %1; %2.5; % Delay
binWidthDelayCT = .3;        % Delay Consecutive Times
binWidthRew = .2;            % Reward
% Window temporal positions
timeAxisPD = 0.25;                 % PD
timeAxisDelay = 1.5; %2.25; %2.25; % Delay
timeAxisDelayCT = (0.5:0.15:3);    % Delay Consecutive Times
timeAxisRew = .7;                  % Reward

% Windows for FRs temporal profiles (Widths and temporal position)
binWidth = {.25, .25, .25}; % 3 Alignments: {'PD';'StimOn1';'PushKey'}
TimeAxis = ['{ (-0.5+binWidth{i_align}/2):0.05:(1.5-binWidth{i_align}/2),' ...
    '  (-1.5+binWidth{i_align}/2):0.05:(4.5-binWidth{i_align}/2),' ...
    '  (-0.1+binWidth{i_align}/2):0.05:(1.0-binWidth{i_align}/2) }'];

% Windows for ROC Analysis purposes
binWidth_ROC = 0.01;
TimeAxis_ROC_10ms_all = ['{ (-0.5+binWidth_ROC/2):binWidth_ROC:(1.5-binWidth_ROC/2),' ...
    '  (-1.5+binWidth_ROC/2):binWidth_ROC:(4.5-binWidth_ROC/2),' ...
    '  (-0.1+binWidth_ROC/2):binWidth_ROC:(1.5-binWidth_ROC/2) }'];
TimeAxis_ROC_1ms = ['{ (-0.3):0.001:(.6)}'];
TimeAxis_ROC_10ms = ['{ (-0.3):0.01:(.6)}'];
TimeAxis_ROC_10ms_Rew = ['{ (0.2):0.01:(.9)}'];
binROC = .25;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Obtaining Firing Rates and Zscores

e_KD = alignSpikes(e1,'KeyDown'); % Align spikes to compute Baseline
for i_align=1:4 % Alignments 

    if not(i_align == 4)
        timeAxis = eval(TimeAxis);
        timeAxis_ROC_10ms_all = eval(TimeAxis_ROC_10ms_all);
        
    end
    
    if (i_align == 4) || (i_align == 2)
        timeAxis_1ms = eval(TimeAxis_ROC_1ms);
        timeAxis_10ms = eval(TimeAxis_ROC_10ms);
    end
    
    if i_align == 3
        timeAxis_10ms = eval(TimeAxis_ROC_10ms_Rew);
    end  
    
    % Normalize firing rates --> FRs and Zscores 
    eAl = alignSpikes(e1,align{i_align}); 
    for i_neuron = 1:length(e_KD) % Loop through each (e)xperimentd, neuron!!
        
        % Baseline for each Neuron
        selTrials = select(e_KD(i_neuron),'clase',[1 12]);
        basal_fr_kd_align = firingrate([selTrials.spikeTimes],normCenterWidth(1,1),'filtertype',filterType,'timeconstant',normCenterWidth(1,2));
        mean_basal = mean(basal_fr_kd_align);
        std_basal = std(basal_fr_kd_align);

        for i_trial = 1:length(eAl(i_neuron).trial)
            spikeTimes = eAl(i_neuron).trial(i_trial).spikeTimes; % Spikes
            
            if not(i_align == 4)
                trial_fr = firingrate(spikeTimes,timeAxis{i_align},'filtertype',filterType,'timeconstant',binWidth{i_align});
                trial_fr_causal_10ms_all = firingrate_causal(spikeTimes,timeAxis_ROC_10ms_all{i_align},'filtertype',filterType,'timeconstant',binROC);  
            end
            if (i_align == 4) || (i_align == 2)
                trial_fr_causal_1ms = firingrate_causal(spikeTimes,timeAxis_1ms{1},'filtertype',filterType,'timeconstant',binROC);
                trial_fr_causal_10ms = firingrate_causal(spikeTimes,timeAxis_10ms{1},'filtertype',filterType,'timeconstant',binROC);
            end            
            if i_align == 3
                trial_fr_causal_10ms = firingrate_causal(spikeTimes,timeAxis_10ms{1},'filtertype',filterType,'timeconstant',binROC);                
            end           
            if not(i_align == 4)
            end

            switch i_align
                case 1
                    e1(i_neuron).trial(i_trial).normalized_kd_align_pd = compute_zscore(trial_fr,mean_basal,std_basal);
                    e1(i_neuron).trial(i_trial).normalized_kd_align_pd_10ms = compute_zscore(trial_fr_causal_10ms_all,mean_basal,std_basal);
                    % Normalized Response to PD in a single window
                    response_PD = firingrate(spikeTimes,timeAxisPD,'filtertype',filterType,'timeconstant',binWidthPD);
                    e1(i_neuron).trial(i_trial).firing_PD_Win = response_PD;
                    e1(i_neuron).trial(i_trial).norm_response_PD_Win = compute_zscore(response_PD,mean_basal,std_basal);
                    
                case 2
                    response_f1 = firingrate(spikeTimes,timeAxisSO,'filtertype',filterType,'timeconstant',binWidthSO);
                    e1(i_neuron).trial(i_trial).normalized_response_f1 = compute_zscore(response_f1,mean_basal,std_basal); 
                    e1(i_neuron).trial(i_trial).firing_response_f1 = response_f1;
                    e1(i_neuron).trial(i_trial).normalized_response_pd = compute_zscore(trial_fr,mean_basal,std_basal);             
                    e1(i_neuron).trial(i_trial).causal_normalized_10ms_pd = compute_zscore(trial_fr_causal_10ms_all,mean_basal,std_basal); 

                    response_delay = firingrate(spikeTimes,timeAxisDelay,'filtertype',filterType,'timeconstant',binWidthDelay);
                    e1(i_neuron).trial(i_trial).firing_response_delay = response_delay;                   
                    e1(i_neuron).trial(i_trial).normalized_response_delay = compute_zscore(response_delay,mean_basal,std_basal);
                    
                    e1(i_neuron).trial(i_trial).causal_normalized_1ms_f1 = compute_zscore(trial_fr_causal_1ms,mean_basal,std_basal);
                    e1(i_neuron).trial(i_trial).causal_normalized_10ms_f1 = compute_zscore(trial_fr_causal_10ms,mean_basal,std_basal);
                    
                    response_delay_CT = firingrate(spikeTimes,timeAxisDelayCT,'filtertype',filterType,'timeconstant',binWidthDelayCT);
                    e1(i_neuron).trial(i_trial).normalized_response_delay_CT = compute_zscore(response_delay_CT,mean_basal,std_basal);                   
                case 3
                    response_rew = firingrate(spikeTimes,timeAxisRew,'filtertype',filterType,'timeconstant',binWidthRew);
                    e1(i_neuron).trial(i_trial).normalized_response_rew = compute_zscore(response_rew,mean_basal,std_basal);
                    e1(i_neuron).trial(i_trial).normalized_kd_align_rew = compute_zscore(trial_fr,mean_basal,std_basal);
                    e1(i_neuron).trial(i_trial).normalized_kd_align_rew_10ms = compute_zscore(trial_fr_causal_10ms_all,mean_basal,std_basal);       
                    e1(i_neuron).trial(i_trial).causal_normalized_10ms_rew = compute_zscore(trial_fr_causal_10ms,mean_basal,std_basal);
                case 4
                    response_f2 = firingrate(spikeTimes,timeAxisSO2,'filtertype',filterType,'timeconstant',binWidthSO2);
                    e1(i_neuron).trial(i_trial).firing_response_f2 = response_f2;                   
                    e1(i_neuron).trial(i_trial).normalized_response_f2 = compute_zscore(response_f2,mean_basal,std_basal);
                    e1(i_neuron).trial(i_trial).causal_normalized_1ms_f2 = compute_zscore(trial_fr_causal_1ms,mean_basal,std_basal);
                    e1(i_neuron).trial(i_trial).causal_normalized_10ms_f2 = compute_zscore(trial_fr_causal_10ms,mean_basal,std_basal);   
            end
        end
    end
    eNorm = e1; % New MATLAB structure with the computed Zscores and FRs
end