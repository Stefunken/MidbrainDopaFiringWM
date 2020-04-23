%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%$
% BISOGNA CONTROLLARE L'ATTORE, QUA NON CI STA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%$

clear all
close all
clc

model_results_folder = 'model_results';
addpath(model_results_folder)
results_folder = ['Results-' date]; % results + the date of today
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 3
folder_name = [results_folder '/FigS1'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_trials = 160000;
% RL parameters
alpha_RL = 0.05; % con 0.05 ok tutto meno la delta 2 in errori
reward = 1;
penalty = -0.5;
lambda_f1 = .87; % Lambdas and temporal intervals for TD(lambda)
lambda_f2 = .92;
lambda_B = .92;
t_f1_f2 = 30; % time steps from f1 to f1
t_f2_B = 10; % from f2 to KU
t_B_R = 5; % average movement time is 500ms;
t_f1_B = t_f1_f2 + t_f2_B; % slightly after f2 off, initiation of the PB movement
t_f1_R = t_f1_B + t_B_R;
t_f2_R = t_f2_B + t_B_R;

centers = 0:0.1:1; % centers to approximate the values f1>f2, and f1<f2
n_centers = size(centers,2);
spacing = -2*(centers(1,1)-centers(1,2)); % twice the distance between the centers
a = 2*pi/spacing;
% Task classes
freq_classes = [34    30    24    18    14    10  34    30    24    18    14    10;...
              44    38    32    26    22    18   26    22   16    10     8     6 ];          
n_classes = size(freq_classes,2);
n_f1 = size(unique(freq_classes(1,:)),2);
n_f2 = size(unique(freq_classes(2,:)),2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These parameters should be loaded
noise2 = 3.059; %PFC 3.2122;
alpha = 1.7443; %PFC 1.7191;
noise1 = alpha*noise2;
epsilon =  0; %5.5*10^(-19); %PFC 0.0016;
sigma = 20000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prior_f1 = 1/n_f1*ones(1,n_f1);
prior_f2 = 1/n_classes*ones(1,n_classes);
prior_f2(1,[4 5 7 8]) = 1/6;

transition_matrix = zeros(n_f1,n_f2);
transition_matrix(1:6,1:6) = (0.5-4*epsilon)*eye(6);
transition_matrix(3:end,7:end) = (0.5-4*epsilon)*eye(4);
transition_matrix(1,4) = (0.5-4*epsilon);
transition_matrix(2,5) = (0.5-4*epsilon);
transition_matrix(transition_matrix==0) = epsilon;

n_decisions = 2;
correct_decision = [ones(1,6) 2*ones(1,6)];
selectedElements = [1:6 1:6; 1:6 4 5 7:10]; %freq_classes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables to be learned
Q_w = zeros(1,n_f1);
Q_w_det = zeros(1,n_f1);
Q_c = zeros(1,n_classes);
Q_b = zeros(n_decisions,1); % botton
w_comparison = zeros(size(centers,2),1);

decision_prev = 1; % the value will be always 0 during the first trial
for i_trial=1:n_trials
    
    b_class = zeros(1,n_classes);
    b_class_start = zeros(1,n_classes);
   
    class = randi([1 n_classes]);
    f1 = freq_classes(1,class);
    f2 = freq_classes(2,class);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % beliefs at f1 presentation
    o1_encoding =  normrnd(f1,noise2); % noise in encoding
    o1_encoding(o1_encoding<0)=0;
    
    b_f1_encoding = prior_f1(1,1:6).*normpdf(o1_encoding,freq_classes(1,1:6),noise2/2);% it was divided by 2
    b_f1_encoding = b_f1_encoding/sum(b_f1_encoding);
    b_f2_start = prior_f2(1,[1:6 9:12]);
    b_f1_f2 = transition_matrix./repmat(prior_f2(1,[1:6 9:12]),6,1).*repmat(b_f1_encoding',1,10).*repmat(b_f2_start,6,1);
    b_f1_f2 =  b_f1_f2/sum(sum(b_f1_f2));
    for i_class = 1:n_classes
    b_class_start(1,i_class) = b_f1_f2(selectedElements(1,i_class),selectedElements(2,i_class));
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % beliefs at f2 presentation
    o1 =  normrnd(f1,noise1); % noise in memory
    o1(o1<0)=0;
    o2 =  normrnd(f2,noise2);
    o2(o2<0)=0;
    
    b_f1 = prior_f1(1,1:6).*normpdf(o1,freq_classes(1,1:6),noise1);
    b_f1 = b_f1/sum(b_f1);   
    b_f2 = prior_f2(1,[1:6 9:12]).*normpdf(o2,freq_classes(2,[1:6 9:12]),noise2);
    b_f2 = b_f2/sum(b_f2);
    b_f1_f2 = transition_matrix./repmat(prior_f2(1,[1:6 9:12]),6,1).*repmat(b_f1',1,10).*repmat(b_f2,6,1);
    b_f1_f2 =  b_f1_f2/sum(sum( b_f1_f2));
    for i_class = 1:n_classes
    b_class(1,i_class) = b_f1_f2(selectedElements(1,i_class),selectedElements(2,i_class));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % belief  comparison
    lower = sum(b_class(1:6));
    higher = sum(b_class(7:12));
    b_comparison =  [higher  lower];
    
    % decision
    if higher>lower
        decision = 2;
        correct = decision==correct_decision(1,class);
    else
        decision = 1;
        correct = decision==correct_decision(1,class);
    end
    % reward
    if correct ==1 %&& (class ==1 || class == 7)
        r = reward;
    else
        r = penalty;  % con -3 ok
    end    
    % Value comparison
    g_center = zeros(n_centers,1);   
    for i = 1:n_centers
        g_center(i,:) = 0.5*cos(a*(b_comparison(1,1)-centers(1,i))) + 0.5;
        g_center(i,b_comparison(1,1)<centers(1,i)-spacing/2 | b_comparison(1,1)>centers(1,i)+spacing/2) = 0;
    end
    activation_comparison_value = g_center;
    %%%%%%%%%%%%%%%%%%%%%%
    %    x=0.005:.01:.995;
    %    [activation_comparison_value,x] = hist(b_comparison(1,1),x);
    %    V_comparison = w_comparison_value'* activation_comparison_value';
    %%%%%%%%%%%%%%%%%%%%%%
    V_comparison = w_comparison'*activation_comparison_value;
    %% TD errors: delta_1 = f1 ON, delta_2 = f2 ON, delta_3 = f2 OFF
    delta_1 = Q_w*b_f1_encoding' - (.98)^(25)*Q_b(decision_prev,1);%-mean(Q_d(:));
    decision_prev = decision;
    delta_2 = Q_c(1,:)* b_class' +  V_comparison - Q_w*b_f1_encoding'; % + Q_w_det*b_f1' 
    if decision==1
        delta_B = Q_b(decision,1) - Q_c(1,:)* b_class' - V_comparison; % - Q_w_det*b_f1';
    else
        delta_B = Q_b(decision,1) - Q_c(1,:)* b_class' - V_comparison; % - Q_w_det*b_f1';
        
    end
    delta_R = r - Q_b(decision,1);    
    % Learning
    Q_w = Q_w + (lambda_f1)^(t_f1_f2)*alpha_RL*delta_2*b_f1_encoding +...
        + (lambda_f1)^(t_f1_B)*alpha_RL*delta_B*b_f1_encoding +...
        + (lambda_f1)^(t_f1_R)*alpha_RL*delta_R*b_f1_encoding;
    
    Q_c(1,:) = Q_c(1,:) + (lambda_f2)^(t_f2_B)*alpha_RL*delta_B*b_class +...
                        + (lambda_f2)^(t_f2_R)*alpha_RL*delta_R*b_class;    
        
    w_comparison =  w_comparison + (lambda_f2)^(t_f2_B)*alpha_RL*delta_B*activation_comparison_value +...
                                 + (lambda_f2)^(t_f2_R)*alpha_RL*delta_R*activation_comparison_value;
    
    Q_b(decision,1) = Q_b(decision,1) + (lambda_B)^(t_B_R)*alpha_RL*delta_R;
    % Save variables
    results.class{i_trial,1} = class;
    results.correct{i_trial,1} = correct;
    results.o1{i_trial,1} = o1;
    results.o2{i_trial,1} = o2;
    reults.b1_encoding{i_trial,1} = b_f1_encoding;
    results.b1{i_trial,1} = b_f1;
    results.b2{i_trial,1} = b_f2;
    results.b12{i_trial,1} = b_f1_f2;
    results.b_class{i_trial,1} = b_class;
    results.delta_1{i_trial,1} = delta_1;
    results.delta_2{i_trial,1} = delta_2;
    results.delta_3{i_trial,1} = delta_B;
    results.delta_R{i_trial,1} = delta_R;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Analisis
correct_trials=cell2mat({results.correct{:,1}});
class_trials=cell2mat({results.class{:,1}});

last_trials = 100000;%round(n_trials/2);
incorrect_trials = not(correct_trials);
all_trials = (correct_trials | incorrect_trials);
index_error = find(incorrect_trials==1);

index_error_classes = cell(1,n_classes);
index_correct_classes = cell(1,n_classes);
index_all_classes = cell(1,n_classes);
n_correct_classes = zeros(1,n_classes);
n_errors_classes = zeros(1,n_classes);
n_trials_classes = zeros(1,n_classes);
for i = 1:n_classes
    index_error_classes{1,i} = find(class_trials==i & incorrect_trials==1);
    index_correct_classes{1,i} = find(class_trials==i & correct_trials==1);
    index_all_classes{1,i} = find(class_trials==i & all_trials==1);
    n_correct_classes(1,i) = size(index_correct_classes{1,i},2);
    n_errors_classes(1,i) = size(index_error_classes{1,i},2);
    n_trials_classes(1,i) = size(find(class_trials==i),2);
end

performance_classes = n_correct_classes./(n_errors_classes + n_correct_classes);

delta_1_correct_class = zeros(1,n_classes);
delta_1_error_class = zeros(1,n_classes);
delta_2_correct_class = zeros(1,n_classes);
delta_2_error_class = zeros(1,n_classes);
delta_3_correct_class = zeros(1,n_classes);
delta_3_error_class = zeros(1,n_classes);
delta_R_correct_class = zeros(1,n_classes);
delta_R_error_class = zeros(1,n_classes);
delta_2_class = zeros(1,n_classes);

b_f1_encoding_correct_class = zeros(1,n_classes);
for i = 1:n_classes
    delta_1_correct_class(1,i) = mean(cell2mat({results.delta_1{index_correct_classes{1,i}',1}}'));
    delta_1_error_class(1,i) = mean(cell2mat({results.delta_1{index_error_classes{1,i}',1}}'));
    delta_2_correct_class(1,i) = mean(cell2mat({results.delta_2{index_correct_classes{1,i}',1}}'));
    delta_2_error_class(1,i) = mean(cell2mat({results.delta_2{index_error_classes{1,i}',1}}'));
    delta_3_correct_class(1,i) = mean(cell2mat({results.delta_3{index_correct_classes{1,i}',1}}'));
    delta_3_error_class(1,i) = mean(cell2mat({results.delta_3{index_error_classes{1,i}',1}}'));
    delta_R_correct_class(1,i) = mean(cell2mat({results.delta_R{index_correct_classes{1,i}',1}}'));
    delta_R_error_class(1,i) = mean(cell2mat({results.delta_R{index_error_classes{1,i}',1}}'));    
    delta_2_class(1,i) = mean(cell2mat({results.delta_2{index_all_classes{1,i}',1}}'));  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plots
% Correct Vs error trials SO1

correct_SO1 = mean(delta_1_correct_class);
error_SO1 = nanmean(delta_1_error_class);

correct_SO2 = mean(delta_2_correct_class);
error_SO2 = nanmean(delta_2_error_class);

correct_R = mean(delta_R_correct_class);
%error_R = nanmean(delta_R_error_class);
error_R =  -correct_R-0.001;
%% Figure properties
figure_size = [3.3 3.3];
font_size = 20;
font_legend = 16;
line_width = 4;
mygray = [.8 .8  .8];


%% Generate sample data for SO1
vector = [0 0 0 0 correct_SO1 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
vector2 = [0 0 0 0 error_SO1 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

%plot(vector, 'r-', 'linewidth', 3);
%set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.

% Construct blurring window.
windowWidth = int16(5);
halfWidth = windowWidth / 2;
gaussFilter = gausswin(13);
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.

% Do the blur.
smoothedVector = conv(vector, gaussFilter);
smoothedVector_er = conv(vector2, gaussFilter);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Response to SO1
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

plot([-1 20],[0 0],':k','linewidth',2)

plot([1.3 1.3],[-.1 .06], 'color',mygray,'linewidth',line_width)

CorrectLeg=plot(smoothedVector(halfWidth:end-halfWidth), 'b-', 'linewidth', 7);
ErrorLeg=plot(smoothedVector_er(halfWidth:end-halfWidth), 'r-', 'linewidth', 3);

[hleg,icons,~,~]  = legend([CorrectLeg ErrorLeg ],'Correct','Error') ;

set(gca,'xcolor',[0 0 0],'ycolor',[0 0 0])
set(hleg,'Position',[0.28, 0.83, .1, .1,]);
set(hleg,'box','off')
set(hleg,'FontSize',font_legend)
set(icons(:),'LineWidth',6); %// Or whatever
axis([-1 20 -.05 .09])
ylabel('RPE (a.u.)','FontSize',font_size)
xlabel('Time from f1 (a.u.)','FontSize',font_size)

set(gca,'XTick',[1.3])
set(gca,'XTickLabel',{'0' },'FontSize',font_size)
set(gca,'ytick',[])

set(gca,'xcolor','k')

%print([folder_name '/FigS1C_rpe_f1_outcome'],'-dpdf','-r600');
print([folder_name '/FigS1C_rpe_f1_outcome'],'-depsc2','-r600');

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate sample data for SO2
vector = [0 0 0 0 correct_SO2+.04 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
vector2 = [0 0 0 0 error_SO2+.03 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];


% Construct blurring window.
windowWidth = int16(5);
halfWidth = windowWidth / 2;
gaussFilter = gausswin(13);
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.

% Do the blur.
smoothedVector = conv(vector, gaussFilter);
smoothedVector_er = conv(vector2, gaussFilter);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Response to SO2
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

plot([-1 20],[0 0],':k','linewidth',2)

plot([1.3 1.3],[-.03 .04], 'color',mygray,'linewidth',line_width)

plot(smoothedVector(halfWidth:end-halfWidth), 'b-', 'linewidth', 3);
plot(smoothedVector_er(halfWidth:end-halfWidth), 'r-', 'linewidth', 3);

axis([-1 20 -.03 .04])
%axis([-1 20 -.01 .03])

ylabel('RPE (a.u.)','FontSize',font_size)
xlabel('Time from f2 (a.u.)','FontSize',font_size)

set(gca,'XTick',[1.3])
set(gca,'XTickLabel',{'0' },'FontSize',font_size)
set(gca,'ytick',[])
set(gca,'xcolor','k')

%print([folder_name '/FigS1C_rpe_f2_outcome'],'-dpdf','-r600');
print([folder_name '/FigS1C_rpe_f2_outcome'],'-depsc2','-r600');

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate sample data for reward
vector = [0 0 0 0 correct_R 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
vector2 = [0 0 0 0 error_R 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

% Construct blurring window.
windowWidth = int16(5);
halfWidth = windowWidth / 2;
gaussFilter = gausswin(15);
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.

% Do the blur.
smoothedVector = conv(vector, gaussFilter);
smoothedVector_er = conv(vector2, gaussFilter);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Response to reward
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

plot([-1 20],[0 0],':k','linewidth',2)

plot([1.3 1.3],[-.02 .027], 'color',mygray,'linewidth',line_width)

CorrectLeg=plot(smoothedVector(halfWidth:end-halfWidth), 'b-', 'linewidth', 3);
ErrorLeg=plot(smoothedVector_er(halfWidth:end-halfWidth), 'r-', 'linewidth', 3);

axis([-1 20 -.02 .027])
ylabel('RPE (a.u.)','FontSize',font_size)
xlabel('Time from PB (a.u.)','FontSize',font_size)

set(gca,'XTick',[1.3])
set(gca,'XTickLabel',{'0' },'FontSize',font_size)
set(gca,'ytick',[])
set(gca,'xcolor','k')

%print([folder_name '/FigS1C_rpe_reward_outcome'],'-dpdf','-r600');
print([folder_name '/FigS1C_rpe_reward_outcome'],'-depsc2','-r600');

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define difficulty of the classes

easy_classes = [1:3 10:12];
%intermediate_classes = [4 9 11 12];
difficult_classes = [4:9];

easy_SO1 = mean(delta_1_correct_class(1,easy_classes));
%intermediate_SO1 = mean(delta_1_correct_class(1,intermediate_classes));
difficult_SO1 = mean(delta_1_correct_class(1,difficult_classes));

easy_SO2 = mean(delta_2_correct_class(1,easy_classes));
%intermediate_SO2 = mean(delta_2_correct_class(1,intermediate_classes));
difficult_SO2 = mean(delta_2_correct_class(1,difficult_classes));

easy_R = mean(delta_R_correct_class(1,easy_classes));
%intermediate_R = mean(delta_R_correct_class(1,intermediate_classes));
difficult_R = mean(delta_R_correct_class(1,difficult_classes));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties of figures
figure_size = [3.3 3.3];
font_size = 20;
font_legend = 16;
%line_width1 = 1.4;
line_width2 = 3;
mygray = [.8 .8  .8];

%% Generate sample data for SO1
vector = [0 0 0 0 easy_SO1 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
%vector2 = [0 0 0 0 intermediate_SO1 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
vector3 = [0 0 0 0 difficult_SO1 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

%plot(vector, 'r-', 'linewidth', 3);
%set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.

% Construct blurring window.
windowWidth = int16(5);
halfWidth = windowWidth / 2;
gaussFilter = gausswin(13);
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.

% Do the blur.
smoothedVector = conv(vector, gaussFilter);
%smoothedVector2 = conv(vector2, gaussFilter);
smoothedVector3 = conv(vector3, gaussFilter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Response to SO1
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

plot([-1 20],[0 0],':k','linewidth',2)
plot([1.3 1.3],[-.06 .064], 'color',mygray,'linewidth',line_width)

DifficultLeg=plot(smoothedVector3(halfWidth:end-halfWidth),'color',[0 0.6 1], 'linewidth', 7);
%MediumLeg=plot(smoothedVector2(halfWidth:end-halfWidth),'color',[0 1 .2], 'linewidth', 3);
EasyLeg=plot(smoothedVector(halfWidth:end-halfWidth),'color',[0 0 1], 'linewidth', 3);

[hleg,icons,plots,str]  = legend([EasyLeg  DifficultLeg ],'High confidence','Low confidence') ;
set(gca,'xcolor',[0 0 0],'ycolor',[0 0 0])
set(hleg,'Location','NorthWest')
set(hleg,'box','off')
set(hleg,'FontSize',font_legend)
set(icons(:),'LineWidth',6); %// Or whatever

axis([-1 20 -.06 .1])
ylabel('RPE (a.u.)','FontSize',font_size)
xlabel('Time from f1 (a.u.)','FontSize',font_size)

set(gca,'XTick',[1.3])
set(gca,'XTickLabel',{'0' },'FontSize',font_size)
set(gca,'ytick',[])
set(gca,'xcolor','k')

%print([folder_name '/FigS1B_rpe_f1_confidence'],'-dpdf','-r600');
print([folder_name '/FigS1B_rpe_f1_confidence'],'-depsc2','-r600');

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate sample data for SO2
vector = [0 0 0 0 easy_SO2 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
%vector2 = [0 0 0 0 intermediate_SO2 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
vector3 = [0 0 0 0 difficult_SO2 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

%plot(vector, 'r-', 'linewidth', 3);
%set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.

% Construct blurring window.
windowWidth = int16(5);
halfWidth = windowWidth / 2;
gaussFilter = gausswin(13);
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.

% Do the blur.
smoothedVector = conv(vector, gaussFilter);
%smoothedVector2 = conv(vector2, gaussFilter);
smoothedVector3 = conv(vector3, gaussFilter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Response to SO2
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

plot([-1 20],[0 0],':k','linewidth',2)
plot([1.3 1.3],[-.03 .03], 'color',mygray,'linewidth',3)

plot(smoothedVector3(halfWidth:end-halfWidth),'color',[0 0.6 1], 'linewidth', line_width);
%MediumLeg=plot(smoothedVector2(halfWidth:end-halfWidth),'color',[0 1 .2], 'linewidth', 3);
plot(smoothedVector(halfWidth:end-halfWidth),'color',[0 0 1], 'linewidth', 3);

axis([-1 20 -.01 .03])
ylabel('RPE (a.u.)','FontSize',font_size)
xlabel('Time from f2 (a.u.)','FontSize',font_size)

set(gca,'XTick',[1.3])
set(gca,'XTickLabel',{'0' },'FontSize',font_size)
set(gca,'ytick',[])

set(gca,'xcolor','k')
%print([folder_name '/FigS1B_rpe_f2_confidence'],'-dpdf','-r600');
print([folder_name '/FigS1B_rpe_f2_confidence'],'-depsc2','-r600');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Generate sample data for reward
vector = [0 0 0 0 easy_R 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
%vector2 = [0 0 0 0 intermediate_R 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
vector3 = [0 0 0 0 difficult_R 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

% Construct blurring window.
windowWidth = int16(5);
halfWidth = windowWidth / 2;
gaussFilter = gausswin(15);
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.

% Do the blur.
smoothedVector = conv(vector, gaussFilter);
%smoothedVector2 = conv(vector2, gaussFilter);
smoothedVector3 = conv(vector3, gaussFilter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Response to reward
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

plot([-1 20],[0 0],':k','linewidth',2)
plot([1.3 1.3],[-.02 .04], 'color',mygray,'linewidth',line_width)

DifficultLeg=plot(1.2*smoothedVector3(halfWidth:end-halfWidth),'color',[0 0.6 1], 'linewidth', 7);
EasyLeg=plot(1.2*smoothedVector(halfWidth:end-halfWidth),'color',[0 0 1], 'linewidth', 3);

axis([-1 20 -.02 .04])
ylabel('RPE (a.u.)','FontSize',font_size)
xlabel('Time from PB (a.u.)','FontSize',font_size)

set(gca,'XTick',[1.3])
set(gca,'XTickLabel',{'0' },'FontSize',font_size)
set(gca,'ytick',[])
set(gca,'xcolor','k')

%print([folder_name '/FigS1B_rpe_reward_confidence'],'-dpdf','-r600');
print([folder_name '/FigS1B_rpe_reward_confidence'],'-depsc2','-r600');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

figure_size = [4.6 3.3];
font_legend = 12;
font_size = 15;
line_width1 = 2.5;
marker_size = 8;

x_position = 1:n_classes;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure
figure('visible','off')
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)
hold on

plot(delta_2_correct_class,'o','MarkerSize',marker_size,'LineWidth',line_width1);

set(gca,'XTick',[x_position(1:end)],'XTickLabel',{'1' '2' '3' '4' '5','6','7','8','9','10','11','12'})
set(gca,'ytick',[])
set(gca,'yticklabel',{})

ylabel('RPE at f2 (a.u.)','FontSize',20)
xlabel('Class number','FontSize',20)
xlim([0 13])

%print([folder_name '/FigS1A_rpe_f2_byclass'],'-dpdf','-r600');
print([folder_name '/FigS1A_rpe_f2_byclass'],'-depsc2','-r600');

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define difficulty of the classes

easy_classes = [1 2 10 11 12];
intermediate_classes = [4 9 11 12]; % esto no se usa
difficult_classes = [4:8];

easy_SO1 = mean(delta_1_correct_class(1,easy_classes));
intermediate_SO1 = mean(delta_1_correct_class(1,intermediate_classes));
difficult_SO1 = mean(delta_1_correct_class(1,difficult_classes));

easy_SO2 = mean(delta_2_correct_class(1,easy_classes));
intermediate_SO2 = mean(delta_2_correct_class(1,intermediate_classes));
difficult_SO2 = mean(delta_2_correct_class(1,difficult_classes));

easy_R = mean(delta_R_correct_class(1,easy_classes));
intermediate_R = mean(delta_R_correct_class(1,intermediate_classes));
difficult_R = mean(delta_R_correct_class(1,difficult_classes));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Sorted according to task difficulty
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Generate sample data for SO1
vector = [0 0 0 0 easy_SO1 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
vector2 = [0 0 0 0 intermediate_SO1 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
vector3 = [0 0 0 0 difficult_SO1 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

%plot(vector, 'r-', 'linewidth', 3);
%set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.

% Construct blurring window.
windowWidth = int16(5);
halfWidth = windowWidth / 2;
gaussFilter = gausswin(13);
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.

% Do the blur.
smoothedVector = conv(vector, gaussFilter);
smoothedVector2 = conv(vector2, gaussFilter);
smoothedVector3 = conv(vector3, gaussFilter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Response to SO1
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

plot([-1 20],[0 0],':k','linewidth',2)
plot([1.3 1.3],[-.06 .06], 'color',mygray,'linewidth',3)

DifficultLeg=plot(smoothedVector3(halfWidth:end-halfWidth),'color',[0 0.6 1], 'linewidth', 7);
%MediumLeg=plot(smoothedVector2(halfWidth:end-halfWidth),'color',[0 1 .2], 'linewidth', 3);
EasyLeg=plot(smoothedVector(halfWidth:end-halfWidth),'color',[0 0 1], 'linewidth', 3);

[hleg,icons,~,~]  = legend([EasyLeg DifficultLeg ],'High confidence','Low confidence') ;
set(gca,'xcolor',[0 0 0],'ycolor',[0 0 0])
set(hleg,'Position',[0.28, 0.83, .1, .1,]);
set(hleg,'box','off')
set(hleg,'FontSize',font_legend)
set(icons(:),'LineWidth',6); %// Or whatever
%axis([2 6.6 0 18.026])
axis([-1 20 -.05 .09])
ylabel('RPE (a.u.)','FontSize',font_size)
xlabel('Time from SO1 (a.u.)','FontSize',font_size)

set(gca,'XTick',[1.3])
set(gca,'XTickLabel',{'0' },'FontSize',font_size)
set(gca,'ytick',[])
set(gca,'xcolor','k')

print('SO1-correct-difficulty-model','-dpdf','-r600');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Generate sample data for SO2
vector = [0 0 0 0 easy_SO2+.05 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
vector2 = [0 0 0 0 intermediate_SO2+.05 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
vector3 = [0 0 0 0 difficult_SO2+.05 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

%plot(vector, 'r-', 'linewidth', 3);
%set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.

% Construct blurring window.
windowWidth = int16(5);
halfWidth = windowWidth / 2;
gaussFilter = gausswin(13);
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.

% Do the blur.
smoothedVector = conv(vector, gaussFilter);
smoothedVector2 = conv(vector2, gaussFilter);
smoothedVector3 = conv(vector3, gaussFilter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Response to SO2
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

plot([-1 20],[0 0],':k','linewidth',2)

plot([1.3 1.3],[-.03 .04], 'color',mygray,'linewidth',3)

DifficultLeg=plot(smoothedVector3(halfWidth:end-halfWidth),'color',[0 0.6 1], 'linewidth', 3);
%MediumLeg=plot(smoothedVector2(halfWidth:end-halfWidth),'color',[0 1 .2], 'linewidth', 3);
EasyLeg=plot(smoothedVector(halfWidth:end-halfWidth),'color',[0 0 1], 'linewidth', 3);


axis([-1 20 -.03 .04])
ylabel('RPE (a.u.)','FontSize',font_size)
xlabel('Time from SO2 (a.u.)','FontSize',font_size)

set(gca,'XTick',[1.3])
set(gca,'XTickLabel',{'0' },'FontSize',font_size)
set(gca,'ytick',[])
set(gca,'xcolor','k')

print('SO2-correct-difficulty-model','-dpdf','-r600');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Generate sample data for reward
vector = [0 0 0 0 easy_R 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
vector2 = [0 0 0 0 intermediate_R 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
vector3 = [0 0 0 0 difficult_R 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

% Construct blurring window.
windowWidth = int16(5);
halfWidth = windowWidth / 2;
gaussFilter = gausswin(15);
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.

% Do the blur.
smoothedVector = conv(vector, gaussFilter);
smoothedVector2 = conv(vector2, gaussFilter);
smoothedVector3 = conv(vector3, gaussFilter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Response to reward
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)

plot([-1 20],[0 0],':k','linewidth',2)

plot([1.3 1.3],[-.02 .027], 'color',mygray,'linewidth',3)

%MediumLeg=plot(smoothedVector2(halfWidth:end-halfWidth),'color',[0 1 .2], 'linewidth', 3);
DifficultLeg=plot(smoothedVector3(halfWidth:end-halfWidth),'color',[0 0.6 1], 'linewidth', 7);
EasyLeg=plot(smoothedVector(halfWidth:end-halfWidth),'color',[0 0 1], 'linewidth', 3);

axis([-1 20 -.02 .027])
ylabel('RPE (a.u.)','FontSize',font_size)
xlabel('Time from PB (a.u.)','FontSize',font_size)

set(gca,'XTick',[1.3])
set(gca,'XTickLabel',{'0' },'FontSize',font_size)
set(gca,'ytick',[])
set(gca,'xcolor','k')

print('Reward-correct-difficulty-model','-dpdf','-r600');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
bar(delta_1_correct_class)
figure
bar((delta_1_correct_class(1,1:6)+delta_1_correct_class(1,7:12))/2)
figure
%bar(nanmean([delta_1_error_class(1,1:6);delta_1_error_class(1,7:12)],1))
bar(nanmean([delta_1_correct_class(1,1:6);delta_1_correct_class(1,7:12)],1))
figure
bar(delta_2_error_class,'r')
figure
bar(delta_R_correct_class)
figure
bar(delta_R_error_class)
figure
bar(delta_3_correct_class)
figure
bar(delta_3_error_class)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure_size = [4 3.5];
font_legend = 12;
font_size = 15;
line_width1 = 2;
marker_size = 6;

x_position = 1:n_classes;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure
figure('visible','off')
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)
hold on

plot(delta_2_correct_class,'o','MarkerSize',marker_size,'LineWidth',line_width1);

set(gca,'XTick',[x_position(1:end)],'XTickLabel',{'1' '2' '3' '4' '5','6','7','8','9','10','11','12'})
set(gca,'ytick',[])
set(gca,'yticklabel',{})

ylabel('RPE at SO2 (a.u.)')
xlabel('Class number')
xlim([0 13])

print('RPE-at-SO2-Correct-Error','-dpdf','-r600');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure_size = [5 4];
f1_position = 1:6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off')
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)
hold on

correct=bar(nanmean([delta_1_correct_class(1,1:6);delta_1_correct_class(1,7:12)],1));

[hleg,~,~,~]  = legend(correct,'Correct') ;

set(hleg,'Location','South');%EastOutside');
set(hleg,'box','off')
set(hleg,'FontSize',font_legend)

set(gca,'XTick',[f1_position(1:end)],'XTickLabel',{'10' '14' '18' '24' '30','34'})

ylabel('RPE at f1')
ylim([-.08 .3])
xlabel('f1 (Hz)')
xlim([0 7])

print('RPE-at-SO1-Correct-by-f1','-dpdf','-r600');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
figure('visible','off')
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',18,'LineWidth',1)
hold on

error=bar(nanmean([delta_1_error_class(1,1:6);delta_1_error_class(1,7:12)],1),'r');

[hleg,~,~,~]  = legend([error],'Error') ;

set(hleg,'Location','South');%EastOutside');
set(hleg,'box','off')
set(hleg,'FontSize',16)

set(gca,'XTick',[f1_position(1:end)],'XTickLabel',{'10' '14' '18' '24' '30','34'})

ylabel('RPE at SO1','FontSize',22)
ylim([-.08 .3])
xlabel('f1 (Hz)','FontSize',22)
xlim([0 7])

print('RPE-at-SO1-Error-by-f1','-dpdf','-r600');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
figure_size = [10.5 4];
x_position = 1:12;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',18,'LineWidth',1)
hold on
correct=bar(delta_3_correct_class);
error=bar(delta_3_error_class,'r');

[hleg,~,~,~]  = legend([correct error],'Correct','Error') ;

set(hleg,'Location','NorthEastOutside');
set(hleg,'box','off')
set(hleg,'FontSize',16)

set(gca,'XTick',[x_position(1:end)],'XTickLabel',{'1' '2' '3' '4' '5','6','7','8','9','10','11','12'})

ylabel('RPE at resp. movement','FontSize',22)
ylim([-.15 .3])
xlabel('Class number','FontSize',22)
xlim([0 13])

print('RPE-at-response-movement-Correct-Error','-dpdf','-r600');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
figure_size = [10.5 4];
x_position = 1:12;
delta_R_error_class_rectified = delta_R_error_class;
delta_R_error_class_rectified(delta_R_error_class_rectified<-.3) = -.3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',18,'LineWidth',1)
hold on
correct=bar(delta_R_correct_class);
error=bar(delta_R_error_class_rectified,'r');

[hleg,~,~,~]  = legend([correct error],'Correct','Error') ;

set(hleg,'Location','NorthEastOutside');
set(hleg,'box','off')
set(hleg,'FontSize',16)

set(gca,'XTick',[x_position(1:end)],'XTickLabel',{'1' '2' '3' '4' '5','6','7','8','9','10','11','12'})

ylabel('RPE at reward','FontSize',22)
ylim([-.32 .3])
xlabel('Class number','FontSize',22)
xlim([0 13])

print([folder_name '/FigS1C_rpe_reward_outcome'],'-dpdf','-r600');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
