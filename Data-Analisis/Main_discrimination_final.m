close all
clear all
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
addpath('data_folder/selected_data_folder') % add to path the data folder
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%freq_sample = [34    30    24    18    14    10    34    30    24    18    14    10 ; ...
%               44    38    32    26    22    18    26    22    16    10     8     6 ];
%performance_real = [99 98 99 93 87 85 78 94 98 99 98 98;...
%                    98 94 97 95 91 86 81 85 92 97 97 97; ...
%                    95 94 89 85 89 82 93 91 94 90 89 93];         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOAD AND FORMAT DATA, AND SOME PREPROCESSING
% Group A
eA = loadAndFormatDataDiscrimination(fileList(1:nA)); % each e(i) is a structure and corresponds with one neuron
eA=get_normalized_FR(eA); % to get the z-scores
eA=get_times_setB(eA); % to get the standardized reaction and movement times
% Group B
eB = loadAndFormatDataDiscrimination(fileList(nA+1:nA+nB));
eB=get_normalized_FR(eB); % to get the z-scores
% All neurons
e = loadAndFormatDataDiscrimination(fileList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('filesFormattedSetB'); % This contains all sessions, used for performance and response times
eRT=eDASetB;
%eRT=get_times_setB(eRT);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get the z-score and the response to different events
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 1 
folder_name = [results_folder '/Fig1'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end
figure_1_plots(eRT,folder_name) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 2  
% This runs the wilcoxon test for Fig2B
for i_neuron = 1:nA
[results_wilcoxon_single_A(i_neuron), ~] = wilcoxon_test_f1_f2(eA(i_neuron),fileListA(i_neuron)); % esto hace los tests de la figura 4.4 de la tesis
end
save('preprocessed_data/results_wilcoxon_single_A', 'results_wilcoxon_single_A')

for i_neuron = 1:nB
[results_wilcoxon_single_B(i_neuron), ~] = wilcoxon_test_f1_f2(eB(i_neuron),fileListB(i_neuron)); % esto hace los tests de la figura 4.4 de la tesis
end
save('preprocessed_data/results_wilcoxon_single_B', 'results_wilcoxon_single_B')

%% This makes the figure
folder_name = [results_folder '/Fig2'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end

figure_2_plots(e,eA,fileList,fileListA,folder_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 3 
% This is generated in the modelling folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 4 
folder_name = [results_folder '/Fig4'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end

figure_4_plots(eA,folder_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 5
% This is generated in the modelling folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 6
folder_name = [results_folder '/Fig6'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end
 
figure_6_plots(eA,folder_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 7
folder_name = [results_folder '/Fig7'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end

figure_7_plots(eA,folder_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 8
folder_name = [results_folder '/Fig8'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end
norm_type = {'00','01','10','11'};
figure_8_plots(eA,norm_type,num_res_folder,folder_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE S2
folder_name = [results_folder '/FigS2'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end

[p_f1_anova_B,p_class_anova_B] = figure_S2_plots(eB,folder_name);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%