close all
clear all
clc
%%%%%%%%%%%%%%%%%%%%%%

addpath('data_folder')
results_folder = 'preprocessed_data';

n_files = 299;
fileList =  1:n_files; % 13 n, select the neurons compatible with RL
files = cell(1,n_files);

for k=1:length(fileList)
    files{k} = ['DiscrTask' num2str(fileList(k))];
end

freq_sample = [34    30    24    18    14    10    34    30    24    18    14    10 ; ...
               44    38    32    26    22    18    26    22    16    10     8     6 ];
%performance_real = [99 98 99 93 87 85 78 94 98 99 98 98; ...
%                    98 94 97 95 91 86 81 85 92 97 97 97; ...
%                    95 94 89 85 89 82 93 91 94 90 89 93];         

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% LOAD, SELECT AND FORMAT DATA
 
[e,index_cl,index_freq] = loadAndFormatDataDiscrimination_FreqSetB(fileList); 

% index_cl: same (f1,f2) as in the experiment and same class number

% index_freq: same (f1,f2) as in the experiment, the class number is
% different, and the prior probability is not uniform in these sessions,
% therefore they are discarded from the analysis of reaction times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% AUXILIARY TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
index_equal = zeros(size(index_cl));
for i=1:length(index_cl)
index_equal(i) = find(index_freq==index_cl(i));
end

index_different = index_freq;
index_different(index_equal) = [];

%%
eDifferent=loadAndFormatDataDiscrimination_FreqSetB(index_different); % seleciona los trials con (f1,f2) como los del setB

count = zeros(size(eDifferent,2),12);

for i = 1:size(eDifferent,2)
  conditions = cell2mat({eDifferent(i).trial.conditions}'); 
  for j = 1:size(eDifferent(i).trial,2)
  aux_ind=find(all(repmat(conditions(j,4:5)',1,12)==freq_sample));
  count(i,aux_ind) = count(i,aux_ind) + 1;
  end
end

% si uno mira la variable count sale una distribucion diferente de la
% uniforme para la 12 clases

%%
countAll = zeros(size(e,2),12);

for i = 1:size(e,2)
  conditions = cell2mat({e(i).trial.conditions}'); 
  for j = 1:size(e(i).trial,2)
  aux_ind=find(all(repmat(conditions(j,4:5)',1,12)==freq_sample));
  countAll(i,aux_ind) = countAll(i,aux_ind) + 1;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Performance according to class number and to f1
n_classes = 12;
n_f1 = 6;
trials_DA = [e(index_equal).trial];
conditions_DA = cell2mat({trials_DA.conditions}');
classes_DA = cell(1,n_classes);
f1_DA = cell(1,n_f1);
performance_class_DA = zeros(1,n_classes);
n_trials_per_class = zeros(1,n_classes);
performance_f1_DA = zeros(1,n_f1);
n_trials_per_f1 = zeros(1,n_f1);

for i = 1:n_classes
index = conditions_DA(:,4) == freq_sample(1,i) & conditions_DA(:,5) == freq_sample(2,i);     
classes_DA{i} = conditions_DA(index,:);
performance_class_DA(1,i) = sum(classes_DA{i}(:,3))/size(classes_DA{i},1);
n_trials_per_class(1,i) = size(classes_DA{i},1);
    if i <=n_f1
        index = conditions_DA(:,4) == freq_sample(1,i);     
        f1_DA{i} = conditions_DA(index,:);
        performance_f1_DA(1,i) = sum(f1_DA{i}(:,3))/size(f1_DA{i},1);
        n_trials_per_f1(1,i) = size(f1_DA{i},1);
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Performance with error, with resampling
n_resampling = 1000; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% by class
n_correct_class = round(n_trials_per_class.*performance_class_DA);
n_error_class = n_trials_per_class-n_correct_class;
error_perf_class = zeros(1,n_classes);

for i=1:n_classes
outcome = [ones(1,n_correct_class(1,i)) zeros(1,n_error_class(1,i))];
%o(i,:) = outcome;
total = zeros(1,n_resampling);
    for j = 1:n_resampling
        ind = randsample(n_trials_per_class(1,i),n_trials_per_class(1,i),true);   
        total(1,j) = sum(outcome(ind))/n_trials_per_class(1,i);
    end    
    error_perf_class(i) = std(total(1,:));    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% by f1
n_correct_f1 = round(n_trials_per_f1.*performance_f1_DA);
n_error_f1 = n_trials_per_f1-n_correct_f1;
error_perf_f1 = zeros(1,n_f1);

for i=1:n_f1
outcome = [ones(1,n_correct_f1(1,i)) zeros(1,n_error_f1(1,i))];
%o(i,:) = outcome;
total = zeros(1,n_resampling);
    for j = 1:n_resampling
        ind = randsample(n_trials_per_f1(1,i),n_trials_per_f1(1,i),true);   
        total(1,j) = sum(outcome(ind))/n_trials_per_f1(1,i);
    end    
    error_perf_f1(i) = std(total(1,:));    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAVE THE RELEVANT SESSIONS
eDASetB = e(index_equal);
save([results_folder '/filesFormattedSetB'],'eDASetB')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
results_performance.mean_accuracy_class = performance_class_DA;
results_performance.error_accuracy_class = error_perf_class;
results_performance.n_trials_class = n_trials_per_class;
results_performance.n_correct_class = n_correct_class;
results_performance.mean_accuracy_f1 = performance_f1_DA;
results_performance.error_accuracy_f1 = error_perf_f1;
results_performance.n_trials_f1 = n_trials_per_f1;
results_performance.n_correct_f1 = n_correct_f1;
save([results_folder '/performanceSetB'],'results_performance')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

