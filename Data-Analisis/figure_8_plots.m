function figure_8_plots(e,norm_type,num_res_folder,results_folder)

load('results_bayesian_trial_to_trial.mat')
b_f1_correct = rot90(results_trial_to_trial.b_f1_correct,2);
b_classes_correct = results_trial_to_trial.b_classes_correct;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n_classes = size(b_classes_correct,2);
n_trials_class = zeros(1,n_classes);

firing_f2_class = cell(1,n_classes);
response_f2_class = cell(1,n_classes);
rt_norm_class = cell(1,n_classes);
rt_class = cell(1,n_classes);

for class=2:n_classes
    correct=select(e,'reward',1,'Clase',[class class]);
    firing_f2_class{1,class} = [correct.firing_response_f2];
    response_f2_class{1,class} = [correct.normalized_response_f2];
    rt_norm_class{1,class} = [correct.RT_norm];
    rt_class{1,class} = [correct.RT];
    n_trials_class(1,class) = size(correct,2);
end

all_trials = sum(n_trials_class);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the weights as the beliefs
B = zeros(all_trials,12);
for j = 2:12
    aux = [];
    for i = 2:12
        aux = [aux repmat(b_classes_correct(j,i),1,n_trials_class(1,i))];
    end
    B(:,j) = aux';
end

% Define the norñalizatiion for RT and DA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

m_x = zeros(size(norm_type,2),n_classes);
m_y = zeros(size(norm_type,2),n_classes);
cov_xy = zeros(size(norm_type,2),n_classes);
cov_xx = zeros(size(norm_type,2),n_classes);
cov_yy = zeros(size(norm_type,2),n_classes);
corr_xy = zeros(size(norm_type,2),n_classes);


for i_n = 1:size(norm_type,2)
    
    x = [];
    y = [];
    
    if strcmp(norm_type{1,i_n},'00')
        
        for i_c = 2:12
            x = [x;firing_f2_class{1,i_c}'];
            y = [y;rt_class{1,i_c}'];
        end
        
    elseif  strcmp(norm_type{1,i_n},'01')
        
        for i_c = 2:12
            x = [x;firing_f2_class{1,i_c}'];
            y = [y;rt_norm_class{1,i_c}'];
        end
        
    elseif  strcmp(norm_type{1,i_n},'10')
        
        for i_c = 2:12
            x = [x;response_f2_class{1,i_c}'];
            y = [y;rt_class{1,i_c}'];
        end
        
    else
        
        for i_c = 2:12
            x = [x;response_f2_class{1,i_c}'];
            y = [y;rt_norm_class{1,i_c}'];
        end
        
    end
    
    for j = 2:12
        m_x(i_n,j) = (B(:,j)'*x)/sum(B(:,j));
        m_y(i_n,j) = (B(:,j)'*y)/sum(B(:,j));
        cov_xy(i_n,j) = ((B(:,j).*(x-m_x(i_n,j)))'*(B(:,j).*(y-m_y(i_n,j))))/sum(B(:,j));
        cov_xx(i_n,j) = ((B(:,j).*(x-m_x(i_n,j)))'*(B(:,j).*(x-m_x(i_n,j))))/sum(B(:,j));
        cov_yy(i_n,j) = ((B(:,j).*(y-m_y(i_n,j)))'*(B(:,j).*(y-m_y(i_n,j))))/sum(B(:,j));
        corr_xy(i_n,j) = cov_xy(i_n,j)./sqrt(cov_xx(i_n,j).*cov_yy(i_n,j));
    end
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% weigthed linear regression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dlmwrite([num_res_folder '/corr_all_normalizations_f2.txt'],corr_xy)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Norm 01: Error of the CC
x = [];
y = [];
for i_c = 2:12
    x = [x;firing_f2_class{1,i_c}'];
    y = [y;rt_norm_class{1,i_c}'];
end


aux_indices = [0 cumsum(n_trials_class)];
n_resamples = 10000;

for i_r = 1:n_resamples
    RIs = [];
    for i_c = 2:12
        n = n_trials_class(1,i_c);
        RIs = [RIs; randi(n,n,1)+aux_indices(1,i_c)];
    end
    for j = 2:12
        m_x(i_r,j) = (B(RIs,j)'*x(RIs,1))/sum(B(RIs,j));
        m_y(i_r,j) = (B(RIs,j)'*y(RIs,1))/sum(B(RIs,j));
        cov_xy(i_r,j) = ((B(RIs,j).*(x(RIs,1)-m_x(i_r,j)))'*(B(RIs,j).*(y(RIs,1)-m_y(i_r,j))))/sum(B(RIs,j));
        cov_xx(i_r,j) = ((B(RIs,j).*(x(RIs,1)-m_x(i_r,j)))'*(B(RIs,j).*(x(RIs,1)-m_x(i_r,j))))/sum(B(RIs,j));
        cov_yy(i_r,j) = ((B(RIs,j).*(y(RIs,1)-m_y(i_r,j)))'*(B(RIs,j).*(y(RIs,1)-m_y(i_r,j))))/sum(B(RIs,j));
        corr_XY(i_r,j) = cov_xy(i_r,j)./sqrt(cov_xx(i_r,j).*cov_yy(i_r,j));
    end
    
    
end


%err_corr = std(corr_XY,0,1);

alpha = 0.05;
CI = zeros(12,2);
for j = 2:12
    CI(j,:) = prctile(corr_XY(:,j),[100*alpha/2,100*(1-alpha/2)]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dlmwrite([num_res_folder '/corr_err_CI_005_norm01_f2.txt'],CI)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CC VS Class number, for Norm 01 WITHOUT ERRORBAR

iN = 2; % this is norm 01
x_position = 1:12;


figure_size = [6.5 3.5];
font_size = 15;
line_width1 = 2.5;
marker_size = 8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf, hold on
hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1.5)

mean_class = corr_xy(iN,2:end);
plot(x_position(1,2:end),mean_class,'-o','MarkerSize',marker_size,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor',[.6 .6 1],...
    'LineWidth',line_width1,'color',[0 0 1])

ylabel({'Correlation Coefficient'})
xlabel({'Class number'})

set(gca,'XTick',x_position(1:end),'XTickLabel',{'1','2' '3' '4' '5','6','7','8','9','10','11','12'})
set(gca,'YTick',[-.3:.1:.1],'YTickLabel',{'-.3','-.2','-.1','0','.1'})

axis([0 13 -.3 0.1])

%print('-dpdf',[results_folder '/Fig8A_cc_weigthed_belief_by_class_norm_01'])
print('-depsc2',[results_folder '/Fig8A_cc_weigthed_belief_by_class_norm_01'])

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if 0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Fig5A, CC VS Class number, for Norm 01  ERRORBAR
    
    iN = 2; % this is norm 01
    x_position = 1:12;
    
    
    figure_size = [6.5 3.5];
    font_size = 15;
    line_width1 = 2;
    marker_size = 6;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure('visible','off'),clf, hold on
    hold on
    set(gca,'color','w')
    set(gcf,'color','w')
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',figure_size)
    set(gcf, 'PaperPosition', [0 0 figure_size])
    set(gca,'FontSize',font_size,'LineWidth',1.5)
    
    
    
    for class = 2:12
        mean_class = corr_xy(iN,class);
        negE = abs(mean_class-CI(class,1));
        posE = abs(mean_class-CI(class,2));
        class_handle(1,class)= errorbar(x_position(1,class),mean_class,negE,posE,'-o','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 1]);
        
    end
    
    for i=2:12
        errorbar_tick(class_handle(1,i),40);
        
    end
    
    ylabel({'Correlation Coefficient'})
    xlabel({'Class number'})
    
    set(gca,'XTick',[x_position(1:end)],'XTickLabel',{'1','2' '3' '4' '5','6','7','8','9','10','11','12'})
    set(gca,'YTick',[-.4:.2:.2],'YTickLabel',{'-.4','-.2','0','.2'})
    
    axis([0 13 -.45 0.2])
    
    %print('-dpdf',[results_folder '/Fig8A_cc_weigthed_belief_by_class_errorbarY_norm_01'])
    print('-depsc2',[results_folder '/Fig8A_cc_weigthed_belief_by_class_errorbarY_norm_01'])
    
    close
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 8B
f1_range = [10,14,18,24,30,34];
n_f1 = size(f1_range,2);
n_trials_f1 = zeros(1,n_f1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


firing_f1_f1 = cell(1,n_f1);
response_f1_f1 = cell(1,n_f1);
rt_norm_f1 = cell(1,n_f1);
rt_f1 = cell(1,n_f1);

for i=1:n_f1
    correct=select(e,'reward',1,'stimFreq1',[f1_range(1,i), f1_range(1,i)]);
    firing_f1_f1{1,i} = [correct.firing_response_f1];
    response_f1_f1{1,i} = [correct.normalized_response_f1];
    rt_norm_f1{1,i} = [correct.RT_norm];
    rt_f1{1,i} = [correct.RT];
    n_trials_f1(1,i) = size(correct,2);
end

all_trials = sum(n_trials_f1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
B = zeros(all_trials,n_f1);

for j = 1:n_f1
    aux = [];
    for i = 1:n_f1
        aux = [aux repmat(b_f1_correct(j,i),1,n_trials_f1(1,i))];
    end
    B(:,j) = aux';
end

% Define the norñalizatiion for RT and DA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

m_x = zeros(size(norm_type,2),n_f1);
m_y = zeros(size(norm_type,2),n_f1);
cov_xy = zeros(size(norm_type,2),n_f1);
cov_xx = zeros(size(norm_type,2),n_f1);
cov_yy = zeros(size(norm_type,2),n_f1);
corr_xy = zeros(size(norm_type,2),n_f1);



for i_n = 1:size(norm_type,2)
    
    x = [];
    y = [];
    
    if  strcmp(norm_type{1,i_n},'00')
        
        for i_f = 1:n_f1
            x = [x;firing_f1_f1{1,i_f}'];
            y = [y;rt_f1{1,i_f}'];
        end
        
    elseif  strcmp(norm_type{1,i_n},'01')
        
        for i_f = 1:n_f1
            x = [x;firing_f1_f1{1,i_f}'];
            y = [y;rt_norm_f1{1,i_f}'];
        end
        
    elseif  strcmp(norm_type{1,i_n},'10')
        
        for i_f = 1:n_f1
            x = [x;response_f1_f1{1,i_f}'];
            y = [y;rt_f1{1,i_f}'];
        end
        
    else
        
        for i_f = 1:n_f1
            x = [x;response_f1_f1{1,i_f}'];
            y = [y;rt_norm_f1{1,i_f}'];
        end
        
    end
    
    
    for j = 1:n_f1
        m_x(i_n,j) = (B(:,j)'*x)/sum(B(:,j));
        m_y(i_n,j) = (B(:,j)'*y)/sum(B(:,j));
        cov_xy(i_n,j) = ((B(:,j).*(x-m_x(i_n,j)))'*(B(:,j).*(y-m_y(i_n,j))))/sum(B(:,j));
        cov_xx(i_n,j) = ((B(:,j).*(x-m_x(i_n,j)))'*(B(:,j).*(x-m_x(i_n,j))))/sum(B(:,j));
        cov_yy(i_n,j) = ((B(:,j).*(y-m_y(i_n,j)))'*(B(:,j).*(y-m_y(i_n,j))))/sum(B(:,j));
        corr_xy(i_n,j) = cov_xy(i_n,j)./sqrt(cov_xx(i_n,j).*cov_yy(i_n,j));
    end
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% weigthed linear regression

dlmwrite([num_res_folder '/corr_all_normalizations_f1.txt'],corr_xy)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Norm 01: Error of the CC
x = [];
y = [];
for i_f = 1:n_f1
    x = [x;firing_f1_f1{1,i_f}'];
    y = [y;rt_norm_f1{1,i_f}'];
end


aux_indices = [0 cumsum(n_trials_f1)];
n_resamples = 10000;

for i_r = 1:n_resamples
    RIs = [];
    for i_f = 1:n_f1
        n = n_trials_f1(1,i_f);
        RIs = [RIs; randi(n,n,1)+aux_indices(1,i_f)];
    end
    for j = 1:n_f1
        m_x(i_r,j) = (B(RIs,j)'*x(RIs,1))/sum(B(RIs,j));
        m_y(i_r,j) = (B(RIs,j)'*y(RIs,1))/sum(B(RIs,j));
        cov_xy(i_r,j) = ((B(RIs,j).*(x(RIs,1)-m_x(i_r,j)))'*(B(RIs,j).*(y(RIs,1)-m_y(i_r,j))))/sum(B(RIs,j));
        cov_xx(i_r,j) = ((B(RIs,j).*(x(RIs,1)-m_x(i_r,j)))'*(B(RIs,j).*(x(RIs,1)-m_x(i_r,j))))/sum(B(RIs,j));
        cov_yy(i_r,j) = ((B(RIs,j).*(y(RIs,1)-m_y(i_r,j)))'*(B(RIs,j).*(y(RIs,1)-m_y(i_r,j))))/sum(B(RIs,j));
        corr_XY(i_r,j) = cov_xy(i_r,j)./sqrt(cov_xx(i_r,j).*cov_yy(i_r,j));
    end
    
    
end


%err_corr = std(corr_XY,0,1);

alpha = 0.05;
CI = zeros(n_f1,2);
for j = 1:n_f1
    CI(j,:) = prctile(corr_XY(:,j),[100*alpha/2,100*(1-alpha/2)]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dlmwrite([num_res_folder '/corr_err_CI_005_norm01_f1.txt'],CI)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig8B,  of the CC for Norm 01

iN = 2; % this is norm 01
x_position = f1_range;

figure_size = [4.2 3.5];
font_size = 15;
line_width1 = 2.5;
marker_size = 8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf, hold on
hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1.5)

mean_f1 = corr_xy(iN,1:end);

plot(x_position(1,1:end),mean_f1,'-o','MarkerSize',marker_size,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor',[.6 .6 1],...
    'LineWidth',line_width1,'color',[0 0 1])


%ylabel({'Correlation Coefficient'})
xlabel({'f1 (Hz)'})

set(gca,'XTick',[x_position(1:end)],'XTickLabel',{'10','14' '18' '24' '30','34'})
axis([6 40 -.15 0.05])

%print('-dpdf',[results_folder '/Fig8B_cc_weigthed_belief_by_f1_norm_01'])
print('-depsc2',[results_folder '/Fig8B_cc_weigthed_belief_by_f1_norm_01'])

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Fig8B, CC VS f1, for Norm 01  ERRORBAR
    iN = 2; % this is norm 01
    x_position = f1_range;
    
    figure_size = [4.2 3.5];
    font_size = 15;
    line_width1 = 2;
    marker_size = 6;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure('visible','on'),clf, hold on
    hold on
    set(gca,'color','w')
    set(gcf,'color','w')
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',figure_size)
    set(gcf, 'PaperPosition', [0 0 figure_size])
    set(gca,'FontSize',font_size,'LineWidth',1.5)
    
    
    
    for class = 1:n_f1
        mean_class = corr_xy(iN,class);
        negE = abs(mean_class-CI(class,1));
        posE = abs(mean_class-CI(class,2));
        class_handle(1,class)= errorbar(x_position(1,class),mean_class,negE,posE,'-o','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 1]);
        
    end
    
    for i = 1:n_f1
        errorbar_tick(class_handle(1,i),40);
        
    end
    
    ylabel({'Correlation Coefficient'})
    xlabel({'f1 (Hz)'})
    
    set(gca,'XTick',[x_position(1:end)],'XTickLabel',{'10','14' '18' '24' '30','34'})
    axis([6 40 -.2 0.1])
    
    print('-dpdf',[results_folder '/Fig5A_cc_weigthed_belief_by_f1_errorbarY_norm_01'])
    %print('-depsc2',[results_folder '/Fig5A_cc_weigthed_belief_by_f1_errorbarY_norm_01'])
    
    close
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end






end