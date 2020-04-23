close all
clear all
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is to select the files to load
fileListA =  [21 25 28 35 42 65 70 75 87 123 134 140]; % 12 neurons, group A
fileListB =  [34 41 48 53 56 61 64 83 105 166 252]; % 11 neurons, group B, deleted 14,265
fileList = [fileListA fileListB];
nA = length(fileListA);
nB = length(fileListB);
nAB = length(fileList);

files = cell(1,nAB);
for k=1:nAB
    files{k} = ['DiscrTask' num2str(fileList(k))];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOAD AND FORMAT DATA, AND SOME PREPROCESSING
% Group A
eA = loadAndFormatDataDiscrimination(fileList(1:nA)); % each e(i) is a structure and corresponds with one neuron
eA=get_normalized_FR(eA); % to get the z-scores
eA=get_times_setB(eA); % to get the standardized reaction and movement times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get the z-score and the response to different events
eA=get_normalized_FR(eA);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ROC z-score
% the z-score has been calcultare with the function get_normalizedFR
% binWidth = .25; this parameter is defined in get_normalized_FR ; 250ms
correct=select(eA,'reward',1);
error= select(eA,'reward',0);
correct_rt_norm = [correct.RT_norm];

long_index = correct_rt_norm >= prctile(correct_rt_norm,60);
short_index = correct_rt_norm <= prctile(correct_rt_norm,40);

correct_long = correct(logical(long_index==1)); % long response time
correct_short = correct(logical(short_index==1)); % short response time

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% select the two groups you want to compare
gr1 = correct_short;
gr2 = correct_long;

alpha = 0.05;
stepSize = 10; % the same of TimeAxis
numOfConsBins = round(50/stepSize);
 
binWidth_ROC = 0.01;
TimeAxisROC = eval(['{ (-0.5+binWidth_ROC/2):binWidth_ROC:(1.5-binWidth_ROC/2),' ...
    '  (-1.5+binWidth_ROC/2):binWidth_ROC:(4.5-binWidth_ROC/2),' ...
    '  (-0.1+binWidth_ROC/2):binWidth_ROC:(1.5-binWidth_ROC/2) }']);

all_align = 1;
 
for i_align = 1:3 % 1=SO1, 2=SO2; 3=Rew
    
  
    [results_roc_rt(i_align)]= compute_roc_zscore(gr1,gr2,TimeAxisROC,alpha,numOfConsBins,stepSize,i_align,all_align);
    
end 


save('preprocessed_data/results_roc_rt','results_roc_rt')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This should be done also for correct VS errors

