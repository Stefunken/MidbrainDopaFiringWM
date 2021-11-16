%% Main Code Script
% "Dopamine firing plays a dual role in coding reward prediction errors and signaling motivation in a working memory task."
% Journal: PNAS 
% Year: 2021
% Authors: Stefania Sarno, Manuel Beirán, Joan Falcó-Roget, Gabriel Diaz-de Leon, Román Rossi-Pool, Ranulfo Romo, and Néstor Parga.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

close all; clear; clc;

addpath('data_folder')              % add to path the data folder
addpath('preprocessed_data')

results_folder = ['Results-' date]; % results + the date of today
if ~exist(results_folder, 'dir')
    mkdir(results_folder)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of files with interesting neurons

fileListA = [1 2 3 4 5 6 7 8 9 10 11 12]; % 12 neurons, group A
fileListOriginal = fileListA;
fileListGood = [13 14 15 16 17 18 19 20 21 22];  % 10 neurons, added on May 2021
fileListA = unique([fileListA fileListGood]);

fileListB =  [34 41 48 53 56 61 64 83 105 166 252]; % 11 neurons, group B. Not analysed.

fileList = [fileListA fileListB];
nA = length(fileListA);
nB = length(fileListB);

HC_K = [[1 3];[10 12]]; % Low Difficulty (High Conf) Classes
LC_K = [4 9];           % High Difficulty (Low Conf)

timeAxisSO = .28; binWidthSO = .45;   % F1 Window (.28s -- .45s) (For significant correlations in F1 see figure_6_plots.m -- Line 193)
timeAxisSO2 = .32; binWidthSO2 = .45; % F2 Window (.32s -- .45s) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Print information to txt file

file_N = fopen([results_folder '/Selected Neurons.txt'],'w');
fprintf(file_N,'%s\n','NEURON ID');
fprintf(file_N,'%i\n',fileListA);

fprintf(file_N,'\n%s\n','TOTAL NEURONS');
fprintf(file_N,'%i\n',size(fileListA,2));

fprintf(file_N,'\n%s\n','High Confidence Classes');
fprintf(file_N,'%i ',[(HC_K(1,1):HC_K(1,2)) (HC_K(2,1):HC_K(2,2))]);
fprintf(file_N,'\n\n%s\n','Low Confidence Classes');
fprintf(file_N,'%i ',(LC_K(1,1):LC_K(1,2)));

fprintf(file_N,'\n\n%s\n','SO1 Window Center -- Window Width');
fprintf(file_N,'%.2f %.2f',timeAxisSO,binWidthSO);
fprintf(file_N,'\n\n%s\n','SO2 Window Center -- Window Width');
fprintf(file_N,'%.2f %.2f',timeAxisSO2,binWidthSO2);
fclose(file_N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOAD DATA, FORMAT DATA AND SOME PREPROCESSING

% Group A -- Analysed Neurons 
eA = loadAndFormatDataDiscrimination(fileListA); % Each eA(i) is a structure and corresponds with one neuron
eA = get_normalized_FR(eA,binWidthSO,timeAxisSO,binWidthSO2,timeAxisSO2); % Get the Z-scores
eA = get_times_setB(eA); % Get the standardized Reaction and Movement times
for iA=1:size(eA,2) % Adding neuron index to eA(iA)
    aux = fileListA(iA) * ones(1,size(eA(iA).trial,2));
    C = num2cell(aux);
    [eA(iA).trial.ind_neuron] = C{:};
end

% Group B -- Not Analysed Neurons
eB = loadAndFormatDataDiscrimination(fileList(nA+1:nA+nB));
eB = get_normalized_FR(eB,binWidthSO,timeAxisSO,binWidthSO2,timeAxisSO2); % Get the Z-scores
eB = get_times_setB(eB); % Get the standardized Reaction and Movement times

% All neurons (Group A and B)
e = loadAndFormatDataDiscrimination(fileList);
 
% All sessions. Used for Performance and Reaction Times
load('filesFormattedSetB'); 
eRT = eDASetB;
eRT = get_times_setB(eRT);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Opening Diary File -- Write Results

dfile = [results_folder '/Numerical Results.txt'];
if exist(dfile,'file'); delete(dfile); end
diary(dfile)
diary on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Single neuron Firing Rate (FR) 

% if 1 ==> Displays Single neuron Firing Rates
if 0 
    % Correct and Error FR
    folder_name = [results_folder '/FirigRateSingleNeurons'];
    if ~exist(folder_name, 'dir')
        mkdir(folder_name)
    end  
    single_neurons_FR_plots(eA,fileListA,fileListOriginal,folder_name,fileListGood)

    % High and Low Difficulty FR
    folder_name = [results_folder '/FirigRateSingleNeuronsDifficulty'];
    if ~exist(folder_name, 'dir')
        mkdir(folder_name)
    end  
    single_neurons_FR_Diff_plots(eA,fileListA,fileListOriginal,folder_name,HC_K,LC_K,fileListGood)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 1 

folder_name = [results_folder '/Fig1'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end  
figure_1_plots(eRT,folder_name);  
figure_1_RTKD_plots(eRT,folder_name);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 2

folder_name = [results_folder '/Fig2'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end
figure_2_plots(e,eA,fileList,fileListA,folder_name);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 3 
% This is generated in the modelling folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 4 

folder_name = [results_folder '/Fig4'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end
figure_4_plots(eA,folder_name,HC_K,LC_K);  
Latency = Group_Latency_ROC_Sep(folder_name,'SO1',1,'SO2',1,'Rew',1,'n_bins',5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 5

folder_name = [results_folder '/Fig5'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end

[pvals_Ramping,R_Ramping,DA_5_Pos_Delay] = figure_5_plots(eA,folder_name);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 6

folder_name = [results_folder '/Fig6'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end
[Long_RT,Short_RT] = figure_6_plots(eA,folder_name);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ANOVA test -- p-vals Zscore -- FigS3

folder_name = [results_folder '/pVals-Zscore'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end
[e_Zscore_10ms,F1_Anova,Class_ANOVA] = figure_S3_plots(eA,folder_name);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Single Neuron Effects

SN_Effects = SingleNeuronEffects(eA,pvals_Ramping,R_Ramping,fileListA,HC_K,LC_K);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diary off;