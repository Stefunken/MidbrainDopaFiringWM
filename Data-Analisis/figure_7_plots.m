function figure_7_plots(e,results_folder)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig7A, all alignments sorted by RT + ROC
load('results_roc_rt.mat')

binWidth = {.25, .25, .25}; % tama�o de la ventana para cada alineacion

filterType = 'boxcar';

align    = {'ProbeDown','StimOn1' , 'PushKey'};

TimeAxis = ['{ (-0.5+binWidth{j}/2):0.05:(1.5-binWidth{j}/2),' ...
    '  (-1.5+binWidth{j}/2):0.05:(4.5-binWidth{j}/2),' ...
    '  (-0.1+binWidth{j}/2):0.05:(1.0-binWidth{j}/2) }'];


binWidth_ROC = 0.01;

TimeAxisROC = ['{ (-0.5+binWidth_ROC/2):binWidth_ROC:(1.5-binWidth_ROC/2),' ...
    '  (-1.5+binWidth_ROC/2):binWidth_ROC:(4.5-binWidth_ROC/2),' ...
    '  (-0.1+binWidth_ROC/2):binWidth_ROC:(1.5-binWidth_ROC/2) }'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables for the figure
gap  = .1; % Temporal gap between plot
gap_rew = 2;

y = [-.5 1.18];
xOn1 = [3 3];
xOff1 = [3.5 3.5];
xOn2 = [6.5 6.5];
xOff2 = [7 7]; % 6.68 6.68]; % 6.65
xRew = [8.0 8.0] + gap_rew;
xStim = [3.0 3.0 3.5 3.5];
xStim2 = [6.5 6.5 7.0 7.0];
y2 = [0 1.18 1.18 0];
y1 = [0 -.5 -.5 0];

mygray = [.9 .9 .9];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = [-1.2+xOn1(1) xOn1(1) xOff1(1) xOn2(1) xOff2(1) xRew(1)];
yT1 = 1.06;
xS1 = 3:.01:3.5;
yS1 = yT1+.4*sin(3*(-pi:2*pi/50:pi));
xS2 = 6.5:.01:7.0;
yS2 = yT1+.4*sin(5*(-pi:2*pi/50:pi));
shift_yT = 3/4*yT1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% figure properties
figure_size = [16.5 3.5];
font_size = 15;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot allAlignments Correct trials - POSTER SIZE
%% Response to SO1
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1,'XColor','w')

area(xStim,y2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim,y1,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,y1,'EdgeColor',mygray,'FaceColor',mygray)
plot(xRew,y, 'color',mygray,'linewidth',5)

yVert = .06;
plot([x(1)-.03 x(1)+.03],[yT1-yVert yT1+yVert],'k','linewidth',1)

plot([x(1) x(2)],[yT1 yT1],'k','linewidth',1)
plot(xS1,.25*yS1+shift_yT,'k','linewidth',1)
plot([x(3) x(4)],[yT1 yT1],'k','linewidth',1)
plot(xS2,.25*yS2+shift_yT,'k','linewidth',1)
plot([x(5) x(5)+.9],[yT1 yT1],'k','linewidth',1)
plot([x(6)-.8 x(6)+1],[yT1 yT1],'k','linewidth',1)
plot([x(6) x(6)],[yT1-yVert yT1+yVert],'k','linewidth',1)
plot([x(5)+.9-.03 x(5)+.9+.03],[yT1-yVert yT1+yVert],'k','linewidth',1)
plot([x(6)-.8-.03 x(6)-.8+.03],[yT1-yVert yT1+yVert],'k','linewidth',1)

plot([3 3.5],[-.48 -.48],'k','LineWidth',6)

for j=2:3
    % Calculate the time axis and displacement.
    timeAxis = eval(TimeAxis);
    timeAxisROC = eval(TimeAxisROC);    
    displace(2) = timeAxis{1}(end)+abs(timeAxis{2}(1))+ gap + binWidth{j};
    displace(3) = displace(2) + timeAxis{2}(end) + abs(timeAxis{3}(1)) + gap_rew + binWidth{j};
    timeAx      = timeAxis{j} + displace(j);
    timeAxROC = timeAxisROC{j} + displace(j)-.125;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Select the trial types.
        
    eAl = alignSpikes(e,align{j}); % Align spikes       
    correct=select(eAl,'reward',1);
    correct_rt_norm = [correct.RT_norm];

    long_index = correct_rt_norm >= prctile(correct_rt_norm,60);
    short_index = correct_rt_norm <= prctile(correct_rt_norm,40);

    correct_long = correct(logical(long_index==1)); % long response time
    correct_short = correct(logical(short_index==1)); % short response time
       
    % ROC significance
    x = double(results_roc_rt(j).ci<0.05)*-.35;
    x(x==0) = NaN; % Changing the value of x. If you need it preserved, save to a new variable.
    y = double(results_roc_rt(j).ci>=0.05)*-.35;
    y(y==0) = NaN; % Changing the value of x. If you need it preserved, save to a new variable.
    %%%%
    sR = 25; 
    h = plot(timeAxROC(sR:end),x(sR:end),'y-');
    set(h,'LineWidth',3.5)
    h = plot(timeAxROC(sR:end),y(sR:end),'-','color',[80 80 80]/255);
    set(h,'LineWidth',3.5)
    
    
    if j==2
        
        long_zscore = cell2mat({correct_long.normalized_response_pd}');
        long_mean = mean(long_zscore);
        long_stderr = std(long_zscore)./sqrt(size(long_zscore,1));        
        short_zscore = cell2mat({correct_short.normalized_response_pd}');      
        short_mean = mean(short_zscore);
        short_stderr = std(short_zscore)./sqrt(size(short_zscore,1));
        
        h2=shadedErrorBar(timeAx,long_mean,long_stderr,{'LineWidth',2,'color',[.2,.6,1]});
        h1=shadedErrorBar(timeAx,short_mean,short_stderr,{'LineWidth',2,'color',[.2,.2,1]});
        
    else
              
        long_zscore = cell2mat({correct_long.normalized_kd_align_rew}');
        long_mean = mean(long_zscore);
        long_stderr = std(long_zscore)./sqrt(size(long_zscore,1));        
        short_zscore = cell2mat({correct_short.normalized_kd_align_rew}');      
        short_mean = mean(short_zscore);
        short_stderr = std(short_zscore)./sqrt(size(short_zscore,1));
        
        h2=shadedErrorBar(timeAx,long_mean,long_stderr,{'LineWidth',2,'color',[.2,.6,1]});
        h1=shadedErrorBar(timeAx,short_mean,short_stderr,{'LineWidth',2,'color',[.2,.2,1]});
   
    end
    
    baseline = 0;
    plot([2.5 7.8],[baseline baseline],':k','linewidth',2)
    plot([9.2 10.7],[baseline baseline],':k','linewidth',2)
        
    if j==2
        [hleg,icons,~,~]  = legend([h1.mainLine h2.mainLine],'Short RT (<P40)','Long RT (>P60)') ;
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text(3.2,1.4,'f1','FontSize',font_size)
text(9.7,1.4,'reward','FontSize',font_size)
text(6.7,1.4,'f2','FontSize',font_size)
text(3.1,-.6,'0.5 s','FontSize',font_size)

set(hleg,'Position',[0.38 0.82 0.1 0.1])
set(hleg,'box','off')
set(hleg,'FontSize',font_size)
set(icons(:),'LineWidth',6); %// Or whatever

axis([1.5 10.7 -.5 1.5])

ylabel('z-score','FontSize',font_size)
set(gca,'XTick',[])
set(gca,'XTickLabel',{''},'FontSize',font_size)
set(gca,'YTick',[-.5 0 .5 1 1.5])
set(gca,'YTickLabel',{'-0.5', '0', '0.5', '1','1.5'},'FontSize',font_size)

%print([results_folder '/Fig7A_zscore_sorted_rt_all_alignments_roc'],'-dpdf','-r600');
print([results_folder '/Fig7A_zscore_sorted_rt_all_alignments_roc'],'-depsc2');

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Computation for Fig7B to 7D
[e_zscore,timeAx_zscore,displace] = compute_z_score_delay_shift10_window250(e);

correct=select(e_zscore,'reward',1); 
correct_rtn = [correct.RT_norm];

% select long and short RT 
long_index = correct_rtn > prctile(correct_rtn,60); % above the P60
short_index = correct_rtn < prctile(correct_rtn,40); % below the P40

correct_long = correct(logical(long_index==1));
correct_short = correct(logical(short_index==1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% p-vals by f1
n_f1 = 6;
range_f1 = [10 14 18 24 30 34];        

vectLong = cell(n_f1,1);
vectShort = cell(n_f1,1);
vectAll = cell(n_f1,1);


allLongMatrix=cell2mat({correct_long.conditions}');
allShortMatrix=cell2mat({correct_short.conditions}');
allAllMatrix=cell2mat({correct.conditions}');


n_correct_long = zeros(1,n_f1);
n_correct_short = zeros(1,n_f1);
n_correct_all = zeros(1,n_f1);

for f1=1:n_f1 
     selCondLong=(allLongMatrix(:,4)==range_f1(f1))';
     selTrialsLong = correct_long(logical(selCondLong==1));
     
     selCondShort=(allShortMatrix(:,4)==range_f1(f1))';
     selTrialsShort = correct_short(logical(selCondShort==1));   
     
     selCondAll=(allAllMatrix(:,4)==range_f1(f1))';
     selTrialsAll = correct(logical(selCondAll==1));
     
     vectLong{f1,1} = cell2mat({selTrialsLong.zscore}');
     n_correct_long(1,f1) = size(vectLong{f1,1},1);
     
     vectShort{f1,1} = cell2mat({selTrialsShort.zscore}');
     n_correct_short(1,f1) = size(vectShort{f1,1},1);
     
     vectAll{f1,1} = cell2mat({selTrialsAll.zscore}');
     n_correct_all(1,f1) = size(vectAll{f1,1},1);     
end


%% ANOVA
names_long = [repmat({'10hz'}, 1, n_correct_long(1,1)) repmat({'14hz'}, 1, n_correct_long(1,2)) ...
              repmat({'18hz'}, 1, n_correct_long(1,3)) repmat({'24hz'}, 1, n_correct_long(1,4)) ... 
              repmat({'30hz'}, 1, n_correct_long(1,5)) repmat({'34hz'}, 1, n_correct_long(1,6))];

names_short = [repmat({'10hz'}, 1, n_correct_short(1,1)) repmat({'14hz'}, 1, n_correct_short(1,2)) ...
               repmat({'18hz'}, 1, n_correct_short(1,3)) repmat({'24hz'}, 1, n_correct_short(1,4)) ... 
               repmat({'30hz'}, 1, n_correct_short(1,5)) repmat({'34hz'}, 1, n_correct_short(1,6))];   

names_all = [repmat({'10hz'}, 1, n_correct_all(1,1)) repmat({'14hz'}, 1, n_correct_all(1,2)) ...
             repmat({'18hz'}, 1, n_correct_all(1,3)) repmat({'24hz'}, 1, n_correct_all(1,4)) ... 
             repmat({'30hz'}, 1, n_correct_all(1,5)) repmat({'34hz'}, 1, n_correct_all(1,6))];   


for i_t=1:size(vectShort{1,1},2)
    
    groups_long = [];
    groups_short = [];
    groups_all = [];

    for f1=1:n_f1 
        groups_long = [groups_long vectLong{f1,1}(:,i_t)'];
        groups_short = [groups_short vectShort{f1,1}(:,i_t)'];
        groups_all = [groups_all vectAll{f1,1}(:,i_t)'];

    end
    %[p,anovatab,stats] = anova1(groups, names);
     pL = anova1(groups_long, names_long,'off');  
     pS = anova1(groups_short, names_short,'off');  
     pA = anova1(groups_all, names_all,'off');  

     p_val_long(i_t) = pL;
     p_val_short(i_t) = pS;
     p_val_all(i_t) = pA;
     
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% p-vals classes 
n_classes = 12;
range_classes = [1:n_classes];        

vectLong_class = cell(n_classes,1);
vectShort_class = cell(n_classes,1);
vectAll_class = cell(n_classes,1);


n_correct_long_class = zeros(1,n_classes);
n_correct_short_class = zeros(1,n_classes);
n_correct_all_class = zeros(1,n_classes);

for class = 1:n_classes 
     selCondLong=(allLongMatrix(:,1)==range_classes(class))';
     selTrialsLong = correct_long(logical(selCondLong==1));
     
     selCondShort=(allShortMatrix(:,1)==range_classes(class))';
     selTrialsShort = correct_short(logical(selCondShort==1));   
     
     selCondAll=(allAllMatrix(:,1)==range_classes(class))';
     selTrialsAll = correct(logical(selCondAll==1));
     
     vectLong_class{class,1} = cell2mat({selTrialsLong.zscore}');
     n_correct_long_class(1,class) = size(vectLong_class{class,1},1);
     
     vectShort_class{class,1} = cell2mat({selTrialsShort.zscore}');
     n_correct_short_class(1,class) = size(vectShort_class{class,1},1);
     
     vectAll_class{class,1} = cell2mat({selTrialsAll.zscore}');
     n_correct_all_class(1,class) = size(vectAll_class{class,1},1);     
end


%% ANOVA
names_long_c = [repmat({'1'}, 1, n_correct_long_class(1,1)) repmat({'2'}, 1, n_correct_long_class(1,2)) ...
                repmat({'3'}, 1, n_correct_long_class(1,3)) repmat({'4'}, 1, n_correct_long_class(1,4)) ... 
                repmat({'5'}, 1, n_correct_long_class(1,5)) repmat({'6'}, 1, n_correct_long_class(1,6)) ...
                repmat({'7'}, 1, n_correct_long_class(1,7)) repmat({'8'}, 1, n_correct_long_class(1,8)) ...
                repmat({'9'}, 1, n_correct_long_class(1,9)) repmat({'10'}, 1, n_correct_long_class(1,10)) ... 
                repmat({'11'}, 1, n_correct_long_class(1,11)) repmat({'12'}, 1, n_correct_long_class(1,12))];

                
                
names_short_c = [repmat({'1'}, 1, n_correct_short_class(1,1)) repmat({'2'}, 1, n_correct_short_class(1,2)) ...
                 repmat({'3'}, 1, n_correct_short_class(1,3)) repmat({'4'}, 1, n_correct_short_class(1,4)) ... 
                 repmat({'5'}, 1, n_correct_short_class(1,5)) repmat({'6'}, 1, n_correct_short_class(1,6)) ...
                 repmat({'7'}, 1, n_correct_short_class(1,7)) repmat({'8'}, 1, n_correct_short_class(1,8)) ...
                 repmat({'9'}, 1, n_correct_short_class(1,9)) repmat({'10'}, 1, n_correct_short_class(1,10)) ... 
                 repmat({'11'}, 1, n_correct_short_class(1,11)) repmat({'12'}, 1, n_correct_short_class(1,12))];  

names_all_c = [repmat({'1'}, 1, n_correct_all_class(1,1)) repmat({'2'}, 1, n_correct_all_class(1,2)) ...
               repmat({'3'}, 1, n_correct_all_class(1,3)) repmat({'4'}, 1, n_correct_all_class(1,4)) ... 
               repmat({'5'}, 1, n_correct_all_class(1,5)) repmat({'6'}, 1, n_correct_all_class(1,6)) ...
               repmat({'7'}, 1, n_correct_all_class(1,7)) repmat({'8'}, 1, n_correct_all_class(1,8)) ...
               repmat({'9'}, 1, n_correct_all_class(1,9)) repmat({'10'}, 1, n_correct_all_class(1,10)) ... 
               repmat({'11'}, 1, n_correct_all_class(1,11)) repmat({'12'}, 1, n_correct_all_class(1,12))]; 



for i_t=1:size(vectShort_class{1,1},2)
    
    groups_long_c = [];
    groups_short_c = [];
    groups_all_c = [];

    for class=1:n_classes 
        groups_long_c = [groups_long_c vectLong_class{class,1}(:,i_t)'];
        groups_short_c = [groups_short_c vectShort_class{class,1}(:,i_t)'];
        groups_all_c = [groups_all_c vectAll_class{class,1}(:,i_t)'];

    end
    %[p,anovatab,stats] = anova1(groups, names);
     pL_c = anova1(groups_long_c, names_long_c,'off');  
     pS_c = anova1(groups_short_c, names_short_c,'off');  
     pA_c = anova1(groups_all_c, names_all_c,'off');  

     p_val_long_class(i_t) = pL_c;
     p_val_short_class(i_t) = pS_c;
     p_val_all_class(i_t) = pA_c;
     
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
realTime = timeAx_zscore-displace(2);
% significance by f1
[~,ind_sign_short] = find(p_val_short <=.05);
[~,ind_sign_long] = find(p_val_long <=.05);
% significance by class
[~,ind_sign_short_class] = find(p_val_short_class <=.05);
[~,ind_sign_long_class] = find(p_val_long_class <=.05);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig7B
figure_size = [6.0 2.5]; 
font_size = 15;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NEW Figure 7B, short RT during/after f1 by f1 
ind_short_f1 = [4 19]; % first line
n_short_f1 = size(ind_short_f1,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('visible','off'),clf

set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])

for j = 1:n_short_f1
    
i = ind_short_f1(j) ;    
subplot(1,2,j)
set(gca,'FontSize',font_size)

sel_index = ind_sign_short(i);

hold on

    for f1=1:n_f1
  
      
          responseSO_f1 = vectShort{f1,1}(:,sel_index)';
      
          n_trials(1,f1) = size(responseSO_f1,2);
          mean_response(1,f1) = mean(responseSO_f1);  
          std_response(1,f1) = std(responseSO_f1);
         
      
    end
    
    % anova
    
     p = p_val_short(sel_index);
     t = realTime(sel_index);
    
    hold on

 
    
     yFit = mean_response;
     xFit = range_f1;
    
    
    % plots the results
        for f1=1:6
            stderrF1 = std_response(1,f1)/sqrt(n_trials(1,f1));
            errorbar(xFit(1,f1),yFit(1,f1),stderrF1,'.','MarkerSize',18,'LineWidth',1.8,'color',[0 0 255]/255);
        end
        
        
    axis([0 40 -.6 1.5])
    text(22,1.2,{['t = ' num2str(t, '%.3f') 's'];['p = ' num2str(p, '%.3f')]},'FontSize',font_size,'Color','r');
        

    
    xlabel({'f1 (Hz)'},'FontSize',font_size)
    if j == 1 
        ylabel('z-score','FontSize',font_size)
    end
end
%print([results_folder '/Fig7B_zscore_during_after_f1_by_f1_short_RT'],'-dpdf','-r600');
print([results_folder '/Fig7B_zscore_during_after_f1_by_f1_short_RT'],'-depsc2','-r600');

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NEW Figure 7C, short/long RT during f2 by class 
ind_short_class = 53; 
ind_long_class = 17;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('visible','off'),clf

set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,2,1)
set(gca,'FontSize',font_size)

sel_index = ind_sign_short_class(ind_short_class);

hold on

for class = 1:n_classes
    
    responseSO_f2 = vectShort_class{class,1}(:,sel_index)';
    
    n_trials(1,class) = size(responseSO_f2,2);
    mean_response(1,class) = mean(responseSO_f2);
    std_response(1,class) = std(responseSO_f2);
    
    
end

% anova

p = p_val_short_class(sel_index);
t = realTime(sel_index);

hold on



yFit = mean_response;
xFit = range_classes;

% plots the results
for class=1:n_classes
    stderrF1 = std_response(1,class)/sqrt(n_trials(1,class));
    errorbar(xFit(1,class),yFit(1,class),stderrF1,'.','MarkerSize',18,'LineWidth',1.8,'color',[0 0 255]/255);
end


axis([0 13 -.7 2.1])
text(7,1.8,{['t = ' num2str(t, '%.3f') 's'];['p = ' num2str(p, '%.3f')]},'FontSize',font_size,'Color','r');

xlabel({'Class number'},'FontSize',font_size)
ylabel('z-score','FontSize',font_size)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,2,2)
set(gca,'FontSize',font_size)

sel_index = ind_sign_long_class(ind_long_class);

hold on

for class = 1:n_classes
    
    responseSO_f2 = vectLong_class{class,1}(:,sel_index)';
    
    n_trials(1,class) = size(responseSO_f2,2);
    mean_response(1,class) = mean(responseSO_f2);
    std_response(1,class) = std(responseSO_f2);
    
    
end

% anova

p = p_val_long_class(sel_index);
t = realTime(sel_index);

hold on



yFit = mean_response;
xFit = range_classes;

% plots the results
for class=1:n_classes
    stderrF1 = std_response(1,class)/sqrt(n_trials(1,class));
    errorbar(xFit(1,class),yFit(1,class),stderrF1,'.','MarkerSize',18,'LineWidth',1.8,'color',[0 188 255]/255);
end


axis([0 13 -.7 2.1])
text(7,1.8,{['t = ' num2str(t, '%.3f') 's'];['p = ' num2str(p, '%.3f')]},'FontSize',font_size,'Color','r');

xlabel({'Class number'},'FontSize',font_size)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%print([results_folder '/Fig7C_zscore_during_f2_by_class_short_long_RT'],'-dpdf','-r600');
print([results_folder '/Fig7C_zscore_during_f2_by_class_short_long_RT'],'-depsc2','-r600');
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fig7D, short/long RT during f2 by class 
ind_long = 35; 
ind_long_class = 36;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('visible','off'),clf
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,2,2)

set(gca,'FontSize',font_size)
sel_index = ind_sign_long(ind_long);

hold on

for f1=1:n_f1
    
    responseSO_f1 = vectLong{f1,1}(:,sel_index)';   
    n_trials(1,f1) = size(responseSO_f1,2);
    mean_response(1,f1) = mean(responseSO_f1);
    std_response(1,f1) = std(responseSO_f1);
    
end

% anova

p = p_val_long(sel_index);
t = realTime(sel_index);

hold on



yFit = mean_response;
xFit = range_f1;


% plots the results
for f1=1:6
    stderrF1 = std_response(1,f1)/sqrt(n_trials(1,f1));
    errorbar(xFit(1,f1),yFit(1,f1),stderrF1,'.','MarkerSize',18,'LineWidth',1.8,'color',[0 188 255]/255);
end


axis([0 40 -.7 1.5])
text(22,1.3,{['t = ' num2str(t, '%.3f') 's'];['p = ' num2str(p, '%.3f')]},'FontSize',font_size,'Color','r');


ylabel({'z-score'},'FontSize',font_size)
xlabel({'f1 (Hz)'},'FontSize',font_size)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,2,1)
set(gca,'FontSize',font_size)

sel_index = ind_sign_long_class(ind_long_class);

hold on

for class = 1:n_classes
    
    responseSO_f2 = vectLong_class{class,1}(:,sel_index)';
    
    n_trials(1,class) = size(responseSO_f2,2);
    mean_response(1,class) = mean(responseSO_f2);
    std_response(1,class) = std(responseSO_f2);
    
    
end

% anova

p = p_val_long_class(sel_index);
t = realTime(sel_index);

hold on

yFit = mean_response;
xFit = range_classes;

% plots the results
for class=1:n_classes
    stderrF1 = std_response(1,class)/sqrt(n_trials(1,class));
    errorbar(xFit(1,class),yFit(1,class),stderrF1,'.','MarkerSize',18,'LineWidth',1.8,'color',[0 188 255]/255);
end

axis([0 13 -.7 1.5])
text(7,1.3,{['t = ' num2str(t, '%.3f') 's'];['p = ' num2str(p, '%.3f')]},'FontSize',font_size,'Color','r');

xlabel({'Class number'},'FontSize',font_size)

%print([results_folder '/Fig7D_zscore_after_f2_by_f1_class_long_RT'],'-dpdf','-r600');
print([results_folder '/Fig7D_zscore_after_f2_by_f1_class_long_RT'],'-depsc2','-r600');

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end




