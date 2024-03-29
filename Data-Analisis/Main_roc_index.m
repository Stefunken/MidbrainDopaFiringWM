close all
clear all
clc

addpath('data_folder') % add to path the data folder
addpath('preprocessed_data')

results_folder = ['Results-' date]; % results + the date of today
if ~exist(results_folder, 'dir')
    mkdir(results_folder)
end

num_res_folder = [results_folder '/numerical_results'];
if ~exist(num_res_folder, 'dir')
    mkdir(num_res_folder)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of files with interesting neurons

Num_Neurons = 22; % To check if the list is correct
fileListA = [1 2 3 4 5 6 7 8 9 10 11 12]; % 12 neurons, group A
fileListGood = [13 14 15 16 17 18 19 20 21 22];  % 10 neurons, added on May 2021
fileListA = unique([fileListGood fileListA]);

if size(fileListA,2) ~= Num_Neurons
    msg = 'Incorrect Selection of Neurons';
    error(msg)
end

fileListB =  [34 41 48 53 56 61 64 83 105 166 252];   % 11 neurons, group B
fileList = [fileListA fileListB];
nA = length(fileListA);
nB = length(fileListB);
nAB = length(fileList);

files = cell(1,nAB);
for k=1:nAB
    files{k} = ['DiscrTask' num2str(fileList(k))];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOAD AND FORMAT DATA, AND SOME PREPROCESSING

timeAxisSO = .28; binWidthSO = .45;
timeAxisSO2 = .32; binWidthSO2 = .45;
% Group A
eA = loadAndFormatDataDiscrimination(fileList(1:nA)); % Each e(i) is a structure and corresponds with one neuron
eA = get_normalized_FR(eA,binWidthSO,timeAxisSO,binWidthSO2,timeAxisSO2); % Get the Z-scores
eA = get_times_setB(eA); % Standardized reaction and movement times

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ROC Permutations

for ROC_VAR = 1:3 % 1-> RT // 2-> Difficulty // 3-> Outcome
    if ROC_VAR == 1
        %% ROC z-score for RT Groups
        disp('RT ROC')
        
        correct = select(eA,'reward',1);
        error = select(eA,'reward',0);
        correct_rt_norm = [correct.RTKD];

        long_index = correct_rt_norm >= prctile(correct_rt_norm,50);
        short_index = correct_rt_norm <= prctile(correct_rt_norm,50);

        correct_long = correct(logical(long_index==1));   % long response time
        correct_short = correct(logical(short_index==1)); % short response time

        % Select the two groups you want to compare
        gr1 = correct_short;
        gr2 = correct_long;

        alpha = 0.05;
        stepSize = 10; % the same of TimeAxis
        numOfConsBins = round(50/stepSize);
        binWidth_ROC = 0.01;
        TimeAxisROC = eval(['{ (-0.1+binWidth_ROC/2):binWidth_ROC:(0.6-binWidth_ROC/2),' ...
            '  (-1.5+binWidth_ROC/2):binWidth_ROC:(4.5-binWidth_ROC/2),' ...
            '  (-0.1+binWidth_ROC/2):binWidth_ROC:(1.5-binWidth_ROC/2) }']);
        all_align = 1;
        for i_align = 1:3 % 1=PD, 2=SO1; 3=Rew
            [results_roc_rt(i_align)]= compute_roc_zscore(gr1,gr2,TimeAxisROC,alpha,numOfConsBins,stepSize,i_align,all_align);
        end 
        save('preprocessed_data/results_roc_rt','results_roc_rt')
    elseif ROC_VAR == 2
        %% ROC z-score for Difficulty Groups
        disp('Difficulty ROC')
        
        HC_K = [[1 3];[10 12]]; % High Conf Classes
        LC_K = [4 9];           % Low Conf
        highConf = [select(eA,'reward',1,'clase', HC_K(1,:)),select(eA,'reward',1,'clase', HC_K(2,:))];%'stimFreq1',10); % Select the stimulus classes.
        lowConf = select(eA,'reward',1,'clase', LC_K);
        % Select the two groups you want to compare
        gr1 = highConf;
        gr2 = lowConf;
        
        alpha = 0.05;
        stepSize = 10; % the same of TimeAxis
        numOfConsBins = round(50/stepSize);
        binWidth_ROC = 0.01;
        TimeAxisROC = eval(['{ (-0.1+binWidth_ROC/2):binWidth_ROC:(0.6-binWidth_ROC/2),' ...
            '  (-1.5+binWidth_ROC/2):binWidth_ROC:(4.5-binWidth_ROC/2),' ...
            '  (-0.1+binWidth_ROC/2):binWidth_ROC:(1.5-binWidth_ROC/2) }']);
        all_align = 1;
        for i_align = 1:3 % 1=PD, 2=SO1; 3=Rew
            [results_roc_diff(i_align)]= compute_roc_zscore(gr1,gr2,TimeAxisROC,alpha,numOfConsBins,stepSize,i_align,all_align);
        end 
        save('preprocessed_data/results_roc_diff','results_roc_diff')    
    else
        %% ROC z-score for Outcome Groups
        disp('Outcome ROC')
        
        % Select the two groups you want to compare
        gr1 = select(eA,'reward',1);
        gr2 = select(eA,'reward',0);

        alpha = 0.05;
        stepSize = 10; % the same of TimeAxis
        numOfConsBins = round(50/stepSize);
        binWidth_ROC = 0.01;
        TimeAxisROC = eval(['{ (-0.1+binWidth_ROC/2):binWidth_ROC:(0.6-binWidth_ROC/2),' ...
            '  (-1.5+binWidth_ROC/2):binWidth_ROC:(4.5-binWidth_ROC/2),' ...
            '  (-0.1+binWidth_ROC/2):binWidth_ROC:(1.5-binWidth_ROC/2) }']);
        all_align = 1;
        for i_align = 1:3 % 1=PD, 2=SO1; 3=Rew
            [results_roc_outcome(i_align)]= compute_roc_zscore(gr1,gr2,TimeAxisROC,alpha,numOfConsBins,stepSize,i_align,all_align);
        end 
        save('preprocessed_data/results_roc_outcome','results_roc_outcome')    
    end
end