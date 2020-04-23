function eNorm = get_normalized_FR(e1)

align    = {'ProbeDown','StimOn1', 'PushKey','StimOn2'};
filterType = 'boxcar';
normCenterWidth = [1 .5];% [-.25 .5]; 

binWidthSO = .45; % .20 .45
binWidthSO2 = .45; % .20 .45
binWidthRew = .2;
binWidthDelay = 2.5; %3

timeAxisSO = .28; % .28 --27 , .225
timeAxisSO2 = .32; % .32 ---.17 , .225

timeAxisRew = .7;
timeAxisDelay = 2.25; %2

binWidth = {.25, .25, .25}; % tama�o de la ventana para cada alineacion
TimeAxis = ['{ (-0.5+binWidth{i_align}/2):0.05:(1.5-binWidth{i_align}/2),' ...
    '  (-1.5+binWidth{i_align}/2):0.05:(4.5-binWidth{i_align}/2),' ...
    '  (-0.1+binWidth{i_align}/2):0.05:(1.0-binWidth{i_align}/2) }'];

binWidth_ROC = 0.01;
TimeAxis_ROC_10ms_all = ['{ (-0.5+binWidth_ROC/2):binWidth_ROC:(1.5-binWidth_ROC/2),' ...
    '  (-1.5+binWidth_ROC/2):binWidth_ROC:(4.5-binWidth_ROC/2),' ...
    '  (-0.1+binWidth_ROC/2):binWidth_ROC:(1.5-binWidth_ROC/2) }'];



TimeAxis_ROC_1ms = ['{ (-0.3):0.001:(.6)}'];
TimeAxis_ROC_10ms = ['{ (-0.3):0.01:(.6)}'];

TimeAxis_ROC_10ms_Rew = ['{ (0.2):0.01:(.9)}'];

binROC = .25;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


e_KD = alignSpikes(e1,'KeyDown'); % Align spikes


for i_align=1:4; % in alignment
    

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
    
    eAl = alignSpikes(e1,align{i_align});
    
    
    % Normalize firing rates
    
    for i_neuron = 1:length(e_KD) % Loop through each (e)xperimentd, neuron!!
        
        selTrials = select(e_KD(i_neuron),'clase',[1 12]);
        
        basal_fr_kd_align = firingrate([selTrials.spikeTimes],normCenterWidth(1,1),'filtertype',filterType,'timeconstant',normCenterWidth(1,2));
        mean_basal = mean(basal_fr_kd_align);
        std_basal = std(basal_fr_kd_align);
        
        
        
        for i_trial = 1:length(eAl(i_neuron).trial)
            
            
            spikeTimes = eAl(i_neuron).trial(i_trial).spikeTimes;
            
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
    
    eNorm = e1;
end