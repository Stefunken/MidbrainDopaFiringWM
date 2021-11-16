function [e_zscore,timeAx_zscore,displace] = compute_z_score_delay_shift10_window250(e)
%% Pre-Requisites (Window characteristics, Alignments, ...)
% Note that this script is almost identical to compute_z_score_delay().
% They only differ in the delay temporal sliding window (line 22); in this
% case, it's every 10 miliseconds.

% Spike alignment
e_KD = alignSpikes(e,'KeyDown');
eAl = alignSpikes(e,'StimOn1');

filterType = 'boxcar';

normCenterWidth = [1 .5]; % Baseline Window +1s after KD with Window width of .5s

% Window and 5 time positions (Delay period)
binWidthPos = .25; 
positions = [-.5 .25 1.25 2.25 3.25];

% Each alignment window width
binWidth = {.25, .25, .25}; 
TimeAxis = ['{ (-0.5+binWidth{j}/2):0.05:(1.5-binWidth{j}/2),' ...
            '  (-1.5+binWidth{j}/2):0.01:(5.5-binWidth{j}/2),' ... % 10 ms sliding window 
            '  (-0.1+binWidth{j}/2):0.05:(1.0-binWidth{j}/2) }']; 
        
% Temporal gap between events
gap  = .1; 
gap_rew = .3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Obtaining Z-sccores

j = 2; % StimOn1 alignment
for i_neuron = 1:length(e_KD) % Loop through each (e)xperimentd, neuron!!

    % Baseline Firing Rate (+1s after KD)
    selTrials = select(e_KD(i_neuron),'clase',[1 12]);
    basalFR_KD = firingrate([selTrials.spikeTimes],normCenterWidth(1,1),'filtertype',filterType,'timeconstant',normCenterWidth(1,2));
    meanBasalFR = mean(basalFR_KD);
    stdBasalFR = std(basalFR_KD);

    % Calculate the time axis and displacement.
    timeAxis = eval(TimeAxis);
    displace(2) = timeAxis{1}(end)+abs(timeAxis{2}(1))+ gap + binWidth{j}; 
    displace(3) = displace(2) + timeAxis{2}(end) + abs(timeAxis{3}(1)) + gap_rew + binWidth{j};
    timeAx_zscore      = timeAxis{j} + displace(j);

    % Select trials from all presented classes
    correct = select(eAl(i_neuron),'clase',[1 12]);
    for i_trial = 1:length(correct)
        %%% Obtain the mean firing rates and Z-scores %%%
        correctFR = firingrate([correct(i_trial).spikeTimes],timeAxis{j},'filtertype',filterType,'timeconstant',binWidth{j});        
        % correctFR = firingrate_causal([correct(i_trial).spikeTimes],timeAxis{j},'filtertype',filterType,'timeconstant',binWidth{j});
        e(i_neuron).trial(i_trial).zscore = (correctFR-meanBasalFR)/stdBasalFR; 

        % Position 1 --> -0.5 s
        p1 = firingrate([correct(i_trial).spikeTimes],positions(1),'filtertype',filterType,'timeconstant',binWidthPos);
        e(i_neuron).trial(i_trial).p1 =  (p1-meanBasalFR)/stdBasalFR;
        e(i_neuron).trial(i_trial).FR1 = p1;
        % Position 2 --> 0.25 s
        p2 = firingrate([correct(i_trial).spikeTimes],positions(2),'filtertype',filterType,'timeconstant',binWidthPos);
        e(i_neuron).trial(i_trial).p2 =  (p2-meanBasalFR)/stdBasalFR;
        e(i_neuron).trial(i_trial).FR2 = p2;
        % Position 3 --> 1.25 s
        p3 = firingrate([correct(i_trial).spikeTimes],positions(3),'filtertype',filterType,'timeconstant',binWidthPos);
        e(i_neuron).trial(i_trial).p3 =  (p3-meanBasalFR)/stdBasalFR;   
        e(i_neuron).trial(i_trial).FR3 = p3;
        % Position 4 --> 2.25 s
        p4 = firingrate([correct(i_trial).spikeTimes],positions(4),'filtertype',filterType,'timeconstant',binWidthPos);
        e(i_neuron).trial(i_trial).p4 =  (p4-meanBasalFR)/stdBasalFR;
        e(i_neuron).trial(i_trial).FR4 = p4;
        % Position 5 --> 3.25 s
        p5 = firingrate([correct(i_trial).spikeTimes],positions(5),'filtertype',filterType,'timeconstant',binWidthPos);
        e(i_neuron).trial(i_trial).p5 =  (p5-meanBasalFR)/stdBasalFR;
        e(i_neuron).trial(i_trial).FR5 = p5;

%         p6 = firingrate([correct(i_trial).spikeTimes],positions(6),'filtertype',filterType,'timeconstant',binWidthPos);
%         e(i_neuron).trial(i_trial).p6 =  (p6-meanBasalFR)/stdBasalFR;
%         e(i_neuron).trial(i_trial).FR6 = p6;
    end        
end
e_zscore = e; % Final Output