close all
clear all
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 5
model_results_folder = 'model_results';
addpath(model_results_folder)
results_folder = ['Results-' date]; % results + the date of today

load('results_bayesian_trial_to_trial')

folder_name = [results_folder '/Fig5'];
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
freq_classes = [34    30    24    18    14    10  34    30    24    18    14    10;...
              44    38    32    26    22    18   26    22   16    10     8     6 ];

n_classes = size(freq_classes,2);          
b_classes_correct = results_trial_to_trial.b_classes_correct;
b_classes_error = results_trial_to_trial.b_classes_error;
belief_f1_lower_f2_correct = results_trial_to_trial.belief_f1_lower_f2_correct;
belief_f1_lower_f2_error = results_trial_to_trial.belief_f1_lower_f2_error;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Confufing matrix

confusing_matrix_all_classes_C = cell(1,12);
confusing_matrix_all_classes_E = cell(1,12);

for j = 1:12
confusing_matrix_E = zeros(44,54);
confusing_matrix_C = zeros(44,54);
  
for i = 1:12
        confusing_matrix_C(freq_classes(1,i)-1:freq_classes(1,i)+1,freq_classes(2,i)-1:freq_classes(2,i)+1) = b_classes_correct(j,i);      
        confusing_matrix_E(freq_classes(1,i)-1:freq_classes(1,i)+1,freq_classes(2,i)-1:freq_classes(2,i)+1) = b_classes_error(j,i);
end

confusing_matrix_all_classes_C{1,j} = confusing_matrix_C;
confusing_matrix_all_classes_E{1,j} = confusing_matrix_E;

end
sampleClasses = freq_classes;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Error trials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
colormap_range=30; % default colormap_range is 64, but change it to your needs

figure_size=[15 3];
font_size = 14;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off');clf;
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])


box off
k=0;
% correct, classes 1-6
for i = [1 2 5 6]
k=k+1;
s(k)=subplot(1,4,k);
set(gca,'FontSize',font_size,'LineWidth',1) 
sPos(k,:) = get(s(k),'position');

class = i;
m= confusing_matrix_all_classes_E{1,i}';

imagesc(m)
%colormap_range=20; % default colormap_range is 64, but change it to your needs
 [n,xout] =hist(m(:),colormap_range);   % hist intensities according to the colormap range
 [val ind]=sort(abs(xout)); % sort according to values closest to zero
 j = summer(colormap_range);
 j(ind(1),:) = [1 1 1]; % also see comment below
 % you can also use instead something like j(ind(1:whatever),:)=ones(whatever,3); 
 colormap(j);
 hold on
 
plot([0 38],[0 38],'k','LineWidth',2)

xlabel('f_1 (Hz)')
if i ==1 
ylabel('f_2 (Hz)')
end
set(gca,'Ydir','Normal')
xlim([6 38])
ylim([2 46])

hold on
plot(sampleClasses(1,:),sampleClasses(2,:),'o','Color',[.8 .8 .8],'Markersize',16,'LineWidth',2)
plot(sampleClasses(1,class),sampleClasses(2,class),'or','Markersize',16,'LineWidth',2)

if i==1
h=text(38,36,'  f_1=f_2','FontSize',font_size);
set(h,'Rotation',36);

c=text(-12,2, 'Error  Trials','FontSize',24,'Color','r','FontWeight','Bold');
set(c,'Rotation',90);
end


colorbar off
caxis([0 1])


box off

end

% error classes 1-6

sPos(2:end,3:4) = repmat([sPos(1,3:4)],3,1);
for k=1:4    
set(s(k),'position',sPos(k,:));
end

aux_vect = [1 2 5 6];
for k=1:4
pos1 = 0.12 + (k-1)*.215;
set(s(k),'Units','normalized', 'position', [pos1 0.18 0.15 0.65]);

axes('Position',[pos1+.11 0.24 .041 .13])
box off
bar_data=[belief_f1_lower_f2_error(aux_vect(k)) 1-belief_f1_lower_f2_error(aux_vect(k))];
hold on

bar(0.8,bar_data(1),'FaceColor','w','Edgecolor',[0 0 102]/255);
bar(1.8,bar_data(2),'FaceColor','w','Edgecolor','r');

set(gca,'XTick',[.7 1.7])
set(gca,'xticklabel',{'b(L) ','b(H)'})
set(gca,'FontSize',8)
xlim([0 2.6])

end



% hb = colorbar('location','eastoutside');
% caxis([0 1])
% 
% set(hb,'Units','normalized', 'position', [0.96 0.18 0.008 0.55]);
% set(hb,'fontsize',14)
% 
% t=title(hb,{'B(k|k_0)' ,'value'});
% set(t,'fontsize',16)
%%set(t,'fontsize',18,'FontWeight','Bold')

%print('-dpdf',[folder_name '/Fig5_error_beliefs']) 
print('-depsc2',[folder_name '/Fig5_error_beliefs']) 

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Correct trials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


f1=figure('visible','off');clf;
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])


box off
k=0;
% correct, classes 1-6
for i = [1 2 5 6]
k=k+1;
s(k)=subplot(1,4,k);
set(gca,'FontSize',font_size,'LineWidth',1) 
sPos(k,:) = get(s(k),'position');

class = i;
m= confusing_matrix_all_classes_C{1,i}';

imagesc(m)
%colormap_range=20; % default colormap_range is 64, but change it to your needs
[n,xout] =hist(m(:),colormap_range);   % hist intensities according to the colormap range
[val ind]=sort(abs(xout)); % sort according to values closest to zero
j = summer(colormap_range);
j(ind(1),:) = [1 1 1]; % also see comment below

%mymap=j(1:2:end,:);
% you can also use instead something like j(ind(1:whatever),:)=ones(whatever,3); 
colormap(j);
hold on
%caxis([.2 1]) 
plot([0 38],[0 38],'k','LineWidth',2)

% xlabel('f_1 (Hz)','FontSize',18)
if i ==1 
ylabel('f_2 (Hz)','FontSize',font_size)
end
set(gca,'Ydir','Normal')
xlim([6 38])
ylim([2 46])

hold on
plot(sampleClasses(1,:),sampleClasses(2,:),'o','Color',[.8 .8 .8],'Markersize',16,'LineWidth',2)
plot(sampleClasses(1,class),sampleClasses(2,class),'or','Markersize',16,'LineWidth',2)

if i==1
h=text(38,36,'  f_1=f_2','FontSize',font_size);
set(h,'Rotation',36);

c=text(-12,-1, 'Correct  Trials','FontSize',24,'Color',[0 0 182]/255,'FontWeight','Bold');
set(c,'Rotation',90);
end


colorbar off
caxis([0 1])

title(['k_0 = ' num2str(class)],'FontSize',16,'FontWeight','Bold')


box off

end

% error classes 1-6

sPos(2:end,3:4) = repmat([sPos(1,3:4)],3,1);
for k=1:4    
set(s(k),'position',sPos(k,:));
end

aux_vect = [1 2 5 6];
for k=1:4
pos1 = 0.12 + (k-1)*.215;
set(s(k),'Units','normalized', 'position', [pos1 0.18 0.15 0.65]);

axes('Position',[pos1+.11 0.24 .041 .13])
box off
bar_data=[belief_f1_lower_f2_correct(aux_vect(k)) 1-belief_f1_lower_f2_correct(aux_vect(k))];
hold on

bar(0.8,bar_data(1),'FaceColor','w','Edgecolor',[0 0 102]/255);
bar(1.8,bar_data(2),'FaceColor','w','Edgecolor','r');

set(gca,'XTick',[.7 1.7])
set(gca,'xticklabel',{'b(L) ','b(H)'})
set(gca,'FontSize',8)
xlim([0 2.6])

end


% for i=7:12
% pos1 = 0.065 + (5-(i-7))*.15;
% set(s(i),'Units','normalized', 'position', [pos1 0.18 0.1 0.3]);
% 
% axes('Position',[pos1+.084 0.21 .028 .07])
% 
% box off
% bar_data=[belief_f1_lower_f2_error(i) 1-belief_f1_lower_f2_error(i)];
% hold on
% 
% bar(0.8,bar_data(1),'FaceColor','w','Edgecolor','r');
% bar(1.8,bar_data(2),'FaceColor','w','Edgecolor',[0 0 102]/255);
% 
% 
% set(gca,'XTick',[.7 1.7])
% set(gca,'xticklabel',{'b(L) ','b(H)'})
% set(gca,'FontSize',8)
% xlim([0 2.6])
% 
% end

hb = colorbar('location','eastoutside');
caxis([0 1])

set(hb,'Units','normalized', 'position', [0.96 0.2 0.008 0.55]);
set(hb,'fontsize',font_size)

t=title(hb,{'B(k|k_0)' ,'value'});
set(t,'fontsize',font_size)

%set(t,'fontsize',18,'FontWeight','Bold')
%print('-dpdf',[folder_name '/Fig5_correct_beliefs']) 
print('-depsc2',[folder_name '/Fig5_correct_beliefs']) 

close