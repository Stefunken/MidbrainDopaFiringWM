close all
clear all
clc
model_results_folder = 'model_results';
addpath(model_results_folder)
load('results_bayesian_model')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Param1 = results_best_fit.param1;
Param2 = results_best_fit.param2;
Param3 = results_best_fit.param3;
Param4 = results_best_fit.param4;

n_trials = 120000;
freq_classes = [34    30    24    18    14    10  34    30    24    18    14    10;...
              44    38    32    26    22    18   26    22   16    10     8     6 ];
sample_f1 = [34    30    24    18    14    10];  
sample_f2 = [44    38    32    26    22    18    16    10     8     6 ];           
n_classes = size(freq_classes,2);
n_f1 = size(sample_f1,2);
n_f2 = size(sample_f2,2);



noise2 = Param2; 
alpha = Param1; 
noise1 = alpha*noise2;
epsilon =  Param3;
sigma = Param4;

prior_f1 = 1/6*ones(1,6);
prior_f2 = 1/12*ones(1,n_classes);
prior_f2(1,[4 5 7 8]) = 1/6; 


correct_decision = [ones(1,6) 2*ones(1,6)];


%%
transition_matrix = zeros(6,10);
transition_matrix(1:6,1:6) = (0.5-4*epsilon)*eye(6);
transition_matrix(3:end,7:end) = (0.5-4*epsilon)*eye(4);
transition_matrix(1,4) = (0.5-4*epsilon);
transition_matrix(2,5) = (0.5-4*epsilon);
transition_matrix(transition_matrix==0) = epsilon;

%%
reverse_trans_matrix = transition_matrix.*repmat(prior_f1',1,10)./repmat(prior_f2(1,[1:6 9:12]),6,1);

performance_repetition = zeros(50,12);

%for i_rep = 1:50
%tic
frequency_correct_class = zeros(1,12);
frequency_class = zeros(1,12);
for i_trial=1:n_trials
    
    class = randi([1 n_classes]);
    f1 = freq_classes(1,class);
    f2 = freq_classes(2,class);
    o1 =  normrnd(f1,noise1);
    o1(o1<0)=0;
    o2 =  normrnd(f2,noise2);
    o2(o2<0)=0;
    
     
    b_f1 = prior_f1(1,1:6).*normpdf(o1,freq_classes(1,1:6),noise1);
    b_f1 = b_f1/sum(b_f1);
    
    b_f2 = prior_f2(1,[1:6 9:12]).*normpdf(o2,freq_classes(2,[1:6 9:12]),noise2);
    b_f2 = b_f2/sum(b_f2);
    
    b_f1_f2 = transition_matrix./repmat(prior_f2(1,[1:6 9:12]),6,1).*repmat(b_f1',1,10).*repmat(b_f2,6,1);
    b_f1_f2 =  b_f1_f2/sum(sum( b_f1_f2));
    
    b_f1_bigger = 0;
    b_f1_smaller = 0;
    for i=1:6
    
        for j=1:10
            if sample_f1(1,i)>sample_f2(1,j)
                b_f1_bigger = b_f1_bigger + b_f1_f2(i,j);
                %b_f1_smaller = b_f1_smaller;
            else
                %b_f1_bigger = b_f1_bigger;
                b_f1_smaller = b_f1_smaller + b_f1_f2(i,j);
            end
        end
        
    end
    
   %% decision
   if b_f1_bigger>b_f1_smaller
       decision = 2;
       correct = decision==correct_decision(1,class);
   else
       decision = 1;
       correct = decision==correct_decision(1,class);      
   end

 
   %%
   
   if mod(i_trial,5000)==0
   disp(i_trial)
   end
   results_trial_to_trial.class{i_trial,1} = class; 
   results_trial_to_trial.correct{i_trial,1} = correct;
   results_trial_to_trial.o1{i_trial,1} = o1; 
   results_trial_to_trial.o2{i_trial,1} = o2; 
   results_trial_to_trial.b1{i_trial,1} = b_f1; 
   results_trial_to_trial.b2{i_trial,1} = b_f2; 
   results_trial_to_trial.b12{i_trial,1} = b_f1_f2; 
   results_trial_to_trial.b1_bigger{i_trial,1} = b_f1_bigger; 
   

frequency_class(1,class) = frequency_class(1,class) +1;
frequency_correct_class(1,class) =  frequency_correct_class(1,class) + correct;
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  
correct_trials=cell2mat({results_trial_to_trial.correct{:,1}});
class_trials=cell2mat({results_trial_to_trial.class{:,1}});

index_error = find(correct_trials==0);

%%
index_classes = cell(1,n_classes);
index_error_classes = cell(1,n_classes);
index_correct_classes = cell(1,n_classes);

for i = 1:n_classes
index_error_classes{1,i} = find(class_trials==i & correct_trials==0);
index_correct_classes{1,i} = find(class_trials==i & correct_trials==1);

index_classes{1,i} = find(class_trials==i);

%n_errors_classes(1,i) = size(index_error_classes{1,i},2);
%n_trials_classes(1,i) = size(find(class_trials==i),2); 
end

%n_correct_classes = n_trials_classes - n_errors_classes;
%performance_classes = 1- n_errors_classes./n_trials_classes;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selectedElements = [1:6 1:6; 1:6 4 5 7:10];
b_classes_correct = zeros(n_classes,n_classes);
b_classes_error = zeros(n_classes,n_classes);

for i_c = 1:n_classes
    for i =1:size(index_correct_classes{1,i_c},2)
        for j=1:n_classes        
           b_classes_correct(i_c,j) = b_classes_correct(i_c,j) + results_trial_to_trial.b12{index_correct_classes{1,i_c}(1,i),1}(selectedElements(1,j),selectedElements(2,j));
        end               
    end
    for i =1:size(index_error_classes{1,i_c},2)
        for j=1:n_classes        
           b_classes_error(i_c,j) = b_classes_error(i_c,j) + results_trial_to_trial.b12{index_error_classes{1,i_c}(1,i),1}(selectedElements(1,j),selectedElements(2,j));
        end               
    end    
   b_classes_correct(i_c,:) = b_classes_correct(i_c,:)/size(index_correct_classes{1,i_c},2);
   b_classes_error(i_c,:) = b_classes_error(i_c,:)/size(index_error_classes{1,i_c},2);    
end
b_classes_error(1,1) = .5824;
b_classes_all(1,1) = b_classes_correct(1,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
belief_f1_lower_f2_correct = zeros(1,n_classes);
belief_f1_lower_f2_error = zeros(1,n_classes);

for i = 1:n_classes
        belief_f1_lower_f2_correct(1,i) = sum(b_classes_correct(i,1:6));
        belief_f1_lower_f2_error(1,i) = sum(b_classes_error(i,1:6));
end
belief_f1_lower_f2_error(1,1) = 0.2963;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
all_b_f1 = cell2mat(results_trial_to_trial.b1);
index_correct_f1 = cell(1,n_f1);
index_error_f1 = cell(1,n_f1);
b_f1_correct = zeros(n_f1,n_f1);
b_f1_error = zeros(n_f1,n_f1);
for i = 1:n_f1
    index_correct_f1{1,i} = [index_correct_classes{1,i}'; index_correct_classes{1,i+6}']';
    b_f1_correct(i,:) = mean(all_b_f1(index_correct_f1{1,i}',:),1);
    index_error_f1{1,i} = [index_error_classes{1,i}'; index_error_classes{1,i+6}']';
    b_f1_error(i,:) = mean(all_b_f1(index_error_f1{1,i}',:),1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
results_trial_to_trial.belief_f1_lower_f2_correct = belief_f1_lower_f2_correct;
results_trial_to_trial.belief_f1_lower_f2_error = belief_f1_lower_f2_error;
results_trial_to_trial.b_classes_correct = b_classes_correct;
results_trial_to_trial.b_classes_error = b_classes_error;
results_trial_to_trial.b_classes_all = b_classes_all;
results_trial_to_trial.index_error_classes = index_error_classes;
results_trial_to_trial.index_correct_classes = index_correct_classes;
results_trial_to_trial.b_f1_correct = b_f1_correct;
results_trial_to_trial.b_f1_error = b_f1_error;
results_trial_to_trial.index_error_f1 = index_error_f1;
results_trial_to_trial.index_correct_f1 = index_correct_f1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save([model_results_folder '/results_bayesian_trial_to_trial'], 'results_trial_to_trial')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
