function [e_zscore,timeAx_zscore] = compute_z_score_delay(e)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
binWidthPos = .25; % before .25
positions = [-.5 .3 1.25 2.25 3.25];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
e_KD = alignSpikes(e,'KeyDown');
align    = {'ProbeDown','StimOn1'}; 

filterType = 'boxcar';

normCenterWidth = [1 .5];% [-.25 .5]; %el primer dato se corresponde con la normalizaccion despues de kd, o sea se normaliza

binWidth = {.25, .25, .25}; % tama�o de la ventana para cada alineacion

%binWidth = {.3, .3, .25}; % tama�o de la ventana para cada alineacion


TimeAxis = ['{ (-0.5+binWidth{j}/2):0.05:(1.5-binWidth{j}/2),' ...
            '  (-1.5+binWidth{j}/2):0.05:(5.5-binWidth{j}/2),' ... % 20 ms, 
            '  (-0.1+binWidth{j}/2):0.05:(1.0-binWidth{j}/2) }']; 

gap  = .1; % Temporal gap between plot
gap_rew = .3;

j=2;        
eAl = alignSpikes(e,align{j});

%z_score = cell(1,length(e_KD));
% Normalize firing rates

    for i_neuron = 1:length(e_KD) % Loop through each (e)xperimentd, neuron!!

        selTrials = select(e_KD(i_neuron),'clase',[1 12]);

        basalFR_KD = firingrate([selTrials.spikeTimes],normCenterWidth(1,1),'filtertype',filterType,'timeconstant',normCenterWidth(1,2));
        meanBasalFR = mean(basalFR_KD);
        stdBasalFR = std(basalFR_KD);

        % Calculate the time axis and displacement.
        timeAxis = eval(TimeAxis);
        displace(2) = timeAxis{1}(end)+abs(timeAxis{2}(1))+ gap + binWidth{j}; 
        displace(3) = displace(2) + timeAxis{2}(end) + abs(timeAxis{3}(1)) + gap_rew + binWidth{j};
        timeAx_zscore      = timeAxis{j} + displace(j);
 
        
        % Select the trial types.
        correct = select(eAl(i_neuron),'clase',[1 12]);%'stimFreq1',10); % Select the stimulus classes.
        for i_trial = 1:length(correct)

        % Obtain the mean firing rates.
  
            %correctFR = firingrate_causal([correct(i_trial).spikeTimes],timeAxis{j},'filtertype',filterType,'timeconstant',binWidth{j});        
            correctFR = firingrate([correct(i_trial).spikeTimes],timeAxis{j},'filtertype',filterType,'timeconstant',binWidth{j});        
            e(i_neuron).trial(i_trial).zscore =  (correctFR-meanBasalFR)/stdBasalFR; 
            
            p1 = firingrate([correct(i_trial).spikeTimes],positions(1),'filtertype',filterType,'timeconstant',binWidthPos);
            e(i_neuron).trial(i_trial).p1 =  (p1-meanBasalFR)/stdBasalFR;
            e(i_neuron).trial(i_trial).FR1 = p1;
            
            p2 = firingrate([correct(i_trial).spikeTimes],positions(2),'filtertype',filterType,'timeconstant',binWidthPos);
            e(i_neuron).trial(i_trial).p2 =  (p2-meanBasalFR)/stdBasalFR;
            e(i_neuron).trial(i_trial).FR2 = p2;
                        
            p3 = firingrate([correct(i_trial).spikeTimes],positions(3),'filtertype',filterType,'timeconstant',binWidthPos);
            e(i_neuron).trial(i_trial).p3 =  (p3-meanBasalFR)/stdBasalFR;   
            e(i_neuron).trial(i_trial).FR3 = p3;
            
            p4 = firingrate([correct(i_trial).spikeTimes],positions(4),'filtertype',filterType,'timeconstant',binWidthPos);
            e(i_neuron).trial(i_trial).p4 =  (p4-meanBasalFR)/stdBasalFR;
            e(i_neuron).trial(i_trial).FR4 = p4;
            
            p5 = firingrate([correct(i_trial).spikeTimes],positions(5),'filtertype',filterType,'timeconstant',binWidthPos);
            e(i_neuron).trial(i_trial).p5 =  (p5-meanBasalFR)/stdBasalFR;
            e(i_neuron).trial(i_trial).FR5 = p5;
            
%             p6 = firingrate([correct(i_trial).spikeTimes],positions(6),'filtertype',filterType,'timeconstant',binWidthPos);
%             e(i_neuron).trial(i_trial).p6 =  (p6-meanBasalFR)/stdBasalFR;
%             e(i_neuron).trial(i_trial).FR6 = p6;
            
            
        end        
        
    end
e_zscore = e;    
end