function figure_1_plots(eRT,results_folder)
%% Figure 1A
%x = [-.5 0.5 .6 2.05 2.25 3.5 4.0 7.0 7.5 8 8.1 8.4 9.2 9.7];
x = [-.5 0.5 .6 1.7 2.0 3.5 4.0 7.0 7.5 8 8.1 8.4 9.2 9.7];
xStim = [3.5 3.5 4.0 4.0];
xStim2 = [7.0 7.0 7.5 7.5];

y1 = .2;
y2 = 0;
yM = .1;
ym = -yM;

yA =.75;
yF = .4;

yA2 = [0 yA-.1 yA-.1 0];
yA1 = [0 -yA+.1 -yA+.1 0];

xS1 = 3.5:.01:4;
yS1 = sin(3*(-pi:2*pi/50:pi));
xS2 = 7.0:.01:7.5;
yS2 = sin(5*(-pi:2*pi/50:pi));

mygray = [.9 .9 .9];
myorange = [255 188 0]/255;
mycyan = [0 188 255]/255;
linewidth_line = 1.5;
linewidth_stim = 3;
linewidth_rt = 5;
figure_size=[18 3];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off')
set(gca,'Color','w')
set(gcf,'Color','w')

set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
hold on


area(xStim,yA2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim,yA1,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,yA2,'EdgeColor',mygray,'FaceColor',mygray)
area(xStim2,yA1,'EdgeColor',mygray,'FaceColor',mygray)
plot([x(13) x(13)],[yA-.1 -yA+.1],'color',mygray,'linewidth',linewidth_rt)

%plot([x(1) x(2)],[y2 y1],'k','linewidth',linewidth_line)
%plot([x(1) x(2)],[y1 y1],'k','linewidth',linewidth_line)
%plot([x(2) x(3)],[y1 y2],'k','linewidth',linewidth_line)
%plot([x(3) x(4)],[y2 y2],'k','linewidth',linewidth_line)

plot([x(1) x(4)],[y2 y2],'k','linewidth',linewidth_line)

plot([x(5) x(6)],[y2 y2],'k','linewidth',linewidth_line)
plot(xS1,.25*yS1,'color',mycyan,'linewidth',linewidth_stim)
plot([x(7) x(8)],[y2 y2],'k','linewidth',linewidth_line)
plot(xS2,.25*yS2,'color',myorange,'linewidth',linewidth_stim)
plot([x(9) x(14)],[y2 y2],'k','linewidth',linewidth_line)

%plot([x(9) x(10)],[y2 y2],'k','linewidth',linewidth_line)
%plot([x(10) x(11)],[y2 y1],'k','linewidth',linewidth_line)
%plot([x(11) x(14)],[y1 y1],'k','linewidth',linewidth_line)

%plot([x(4)-.05 x(4)+.05],[ym yM],'k','linewidth',linewidth_line)
%plot([x(5)-.05 x(5)+.05],[ym yM],'k','linewidth',linewidth_line)

plot([x(3) x(3)]-.7,[y2-.1 y2+.1],'k','linewidth',linewidth_line)
plot([x(3) x(3)]-.45,[y2-.1 y2+.1],'k','linewidth',linewidth_line)
plot([x(11) x(11)],[y2-.1 y2+.1],'k','linewidth',linewidth_line)
plot([x(13) x(13)],[y2-.1 y2+.1],'k','linewidth',linewidth_line)


% plot([x(3) x(3)]-.3,[yF-.1 yF+.1],'r','linewidth',4)
% plot([x(6) x(6)],[yF-.1 yF+.1],'r','linewidth',4)
% plot([x(7) x(7)],[yF-.1 yF+.1],'r','linewidth',4)
% plot([x(8) x(8)],[yF-.1 yF+.1],'r','linewidth',4)
% plot([x(9) x(9)],[yF-.1 yF+.1],'r','linewidth',4)
% plot([x(11) x(11)],[yF-.1 yF+.1],'r','linewidth',4)
% plot([x(13) x(13)],[yF-.1 yF+.1],'r','linewidth',4)


plot([x(6) x(7)], [-.33 -.33], 'k', 'linewidth',3.5)

plot([x(9)+.05 x(11)-.05], [-.33 -.33], 'k', 'linewidth',linewidth_rt)
%plot([x(11) x(13)], [0.05 0.05], 'color', mygray, 'linewidth',5)

text(x(3)-.75,y2+.4,{'Start';'Cue'},'HorizontalAlignment','center','FontSize',15);
text(x(3)-.35,y2+.4,{'Key';'Down'},'HorizontalAlignment','center','FontSize',15);
text(x(4)+.15,y2+.4,{'Pre-stimulus';'(1.5-3 s)'},'HorizontalAlignment','center','FontSize',15);
text(x(6)+.25,yA,'f1','HorizontalAlignment','center','FontSize',15,'fontweight','bold','color',mycyan);
text(x(6)+2,y2+.4,{'Delay';'(3 s)'},'HorizontalAlignment','center','FontSize',15);
text(x(8)+.25,yA,'f2','HorizontalAlignment','center','FontSize',15,'fontweight','bold','color',myorange);
text(x(11),y2+.4,{'Key';'Up'},'HorizontalAlignment','center','FontSize',15);
text(x(13),y2+.4,{'Push';'Button'},'HorizontalAlignment','center','FontSize',15);


%text(x(6),yA,'SO1','HorizontalAlignment','center','FontSize',15);
%text(x(8),yA,'SO2','HorizontalAlignment','center','FontSize',15);
%text(x(11),yA,'KU','HorizontalAlignment','center','FontSize',15);
%text(x(13),yA,'PB','HorizontalAlignment','center','FontSize',15);

%text(x(6)+.25,yA,'f1','HorizontalAlignment','center','FontSize',15);
%text(x(8)+.25,yA,'f2','HorizontalAlignment','center','FontSize',15);
text(x(6)+.25,-.53,'500 ms','HorizontalAlignment','center','FontSize',15);
%text(x(6)+2,-.53,'3 s','HorizontalAlignment','center','FontSize',15);

text(x(9)+.3,-.58,{'Reaction';'Time'},'HorizontalAlignment','center','FontSize',15);
%text(x(11)+.65,-.18,{'MT'},'HorizontalAlignment','center','FontSize',15);


xlim([-.6 9.8])
ylim([-.6 .85])

axis off
%print('-dpdf',[results_folder '/Fig1A_task'])
print('-depsc2',[results_folder '/Fig1A_task'])

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 1B
% This is not generated with matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 1C (classes performance colormap)

freq_classes = [34    30    24    18    14    10  34    30    24    18    14    10;...
              44    38    32    26    22    18   26    22   16    10     8     6 ];

delta_f = abs(freq_classes(1,:)-freq_classes(2,:));          

real_performance = [99 98 99 93 87 85 78 94 98 99 98 98]; % DA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
confusing_matrix = zeros(42,50);
for i = 1:12
        confusing_matrix(freq_classes(1,i)-1:freq_classes(1,i)+1,freq_classes(2,i)-1:freq_classes(2,i)+2) = real_performance(1,i);      
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure_size=[5 3.5];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off')
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',15,'LineWidth',1)
hold on
box off
m= confusing_matrix';
imagesc(m)
colormap_range=64; % default colormap_range is 64, but change it to your needs
[~,xout] =hist(m(:),colormap_range);   % hist intensities according to the colormap range
[~,ind]=sort(abs(xout)); % sort according to values closest to zero
j = jet; %summer
j(ind(1),:) = [1 1 1]; % also see comment below
% you can also use instead something like j(ind(1:whatever),:)=ones(whatever,3); 
colormap(j);

for i=1:12
plot(freq_classes(1,i),freq_classes(2,i),'s','Color',[0.8 0.8 0.8],'Markersize',22,'LineWidth',2)

    if i<=6
        text(freq_classes(1,i)-1.3,freq_classes(2,i)+4, num2str(delta_f(i)),'FontSize',12,'FontWeight','bold','color','k' )
    else
        text(freq_classes(1,i)-.85,freq_classes(2,i)-4, num2str(delta_f(i)),'FontSize',12,'FontWeight','bold','color','k' )
        
    end
    
    
end

xlabel('f_1 (Hz)','color','k')
ylabel('f_2 (Hz)')

set(gca,'Ydir','Normal')
xlim([0 46])
ylim([0 46])

hb = colorbar('location','eastoutside');
caxis([75 100 ])
  
hb_pos=get(hb,'Position');
set(hb,'Units','normalized', 'position', [0.9 1.1*hb_pos(2) 0.03 hb_pos(4)]);

ax = get(gca,'Position');
set(gca,'Position',[ax(1) ax(2)+.07*ax(3) .9*ax(3) .9*ax(4)])

hb_pos=get(hb,'Position');
set(hb,'Units','normalized', 'position', [hb_pos(1) 1.2*hb_pos(2) hb_pos(3:4)]);


plot([0 42],[0 42],'--k','LineWidth',2.5)
h=text(42,42,'  f_1=f_2','FontSize',15);
set(h,'Rotation',36);

box off
  
%print('-dpdf',[results_folder '/Fig1C_accuracy_colormap'])
print('-depsc2',[results_folder '/Fig1C_accuracy_colormap'])

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 1D (contraction bias,red and green squares) 
figure_size=[4.8 3.5];

figure('visible','off')
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',15,'LineWidth',1)

xlabel('f_1 (Hz)')
ylabel('f_2 (Hz)')

set(gca,'Ydir','Normal')
xlim([0 46])
ylim([0 46])

hold on


for i = 1:12

if i<=9
text(freq_classes(1,i)-.8,freq_classes(2,i), num2str(i),'FontSize',12,'FontWeight','bold' )
else
text(freq_classes(1,i)-1.2,freq_classes(2,i), num2str(i),'FontSize',12,'FontWeight','bold' )    
end

if i>=4 && i<=9
    plot(freq_classes(1,i),freq_classes(2,i),'s','Color',[1 0 0],'Markersize',22,'LineWidth',2)
else
    plot(freq_classes(1,i),freq_classes(2,i),'s','Color',[0 0.8 0],'Markersize',22,'LineWidth',2)  
end

end

plot([21.5 21.5],[0 50],'-.k','LineWidth',2)
plot([0 42],[0 42],'--k','LineWidth',2.5)
plot([0 42],[0 42],'--k','LineWidth',2.5)
h=text(42,42,'  f_1=f_2','FontSize',15);
set(h,'Rotation',36);
 
box off
  
%print('-dpdf',[results_folder '/Fig1D_contraction_bias'])
print('-depsc2',[results_folder '/Fig1D_contraction_bias'])

close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 1E (performance with error)

n_resampling = 1000;

real_performance = [0.995022624434389	0.978329571106095	0.992067195520299	0.927231121281465	0.870953032375741	0.847953216374269	0.778262767350502	0.936059156154850	0.970394736842105	0.990909090909091	0.983224603914259	0.977489177489178];
n_trials = round([2210	2215	2143	2185	2193	2394	2291	2299	2128	2200	2146	2310]);

n_correct = round(n_trials.*real_performance);
n_error = n_trials-n_correct;


o =[];
error_perf = zeros(1,12);
for i=1:12
outcome = [ones(1,n_correct(1,i)) zeros(1,n_error(1,i))];
%o(i,:) = outcome;
total = {};
    for j = 1:n_resampling
        ind = randsample(n_trials(1,i),n_trials(1,i),true);   
        total{1,1}(1,j) = sum(outcome(ind))/n_trials(1,i);
    end
    
    error_perf(1,i) = std(total{1,1});
    
end

n_classes =12;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
figure_size = [4.5 3.5];
font_size = 15;
line_width1 = 2;
marker_size = 6;

x_position = 1:12;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf, hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)
  
for class = 1:12

mean_perf = real_performance(1,class)*100;   
std_perf = error_perf(1,class)*100;   


plot(x_position(1,class),mean_perf,'o','MarkerSize',8,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[.75 .75 .75],'LineWidth',line_width1);
f1_handle(1,class)= errorbar(x_position(1,class),mean_perf,std_perf,'-','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 0]);
end


for i=1:n_classes
errorbar_tick(f1_handle(1,i),60);
end


ylabel('% of correct responses')

xlabel({'Class number'})

set(gca,'XTick',[x_position(1:end)],'XTickLabel',{'1' '2' '3' '4' '5','6','7','8','9','10','11','12'})
axis([0 13 70 100])

%print('-dpdf',[results_folder '/Fig1E_performance_by_class'])
print('-depsc2',[results_folder '/Fig1E_performance_by_class'])

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 1F

correctRT = cell(1,12);
errorRT = cell(1,12);

correctRTN = cell(1,12);
errorRTN = cell(1,12);

mean_correctRT = zeros(1,12);
mean_errorRT = zeros(1,12);

stdErr_correctRT = zeros(1,12);
stdErr_errorRT = zeros(1,12);

n_correct_class = zeros(1,12);
n_error_class = zeros(1,12);

for i=1:12
  correct=select(eRT,'reward',1,'clase',[i i]); 
  error=select(eRT,'reward',0,'clase',[i i]);
 
  auxC = cell2mat({correct.RT});
  auxE = cell2mat({error.RT});
  auxC(isnan(auxC))=[];
  auxE(isnan(auxE))=[];
  
  auxCN = cell2mat({correct.RT_norm});
  auxEN = cell2mat({error.RT_norm});
  auxCN(isnan(auxCN))=[];
  auxEN(isnan(auxEN))=[];

  
  correctRT{1,i} = auxC;
  errorRT{1,i} = auxE;
  
   
  correctRTN{1,i} = auxCN;
  errorRTN{1,i} = auxEN;

  mean_correctRT(1,i) = mean(auxC);
  mean_errorRT(1,i) = mean(auxE);

  n_correct_class(1,i) = size(auxC,2);
  n_error_class(1,i) = size(auxE,2);
  
  stdErr_correctRT(1,i) = std(auxC)/sqrt(n_correct_class(1,i));
  stdErr_errorRT(1,i) = std(auxE)/sqrt(n_error_class(1,i)); 


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure_size = [4.5 3.5];
font_size = 15;
line_width1 = 2;
marker_size = 6;
x_position = 1:12;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf
hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for class = 1:12
    
mean_class = mean(correctRTN{1,class});
stderr_class = std(correctRTN{1,class})./sqrt(size(correctRTN{1,class},2));
class_handle(1,class)= errorbar(x_position(1,class),mean_class,stderr_class,'-o','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 1]);	

end

for i=1:12
errorbar_tick(class_handle(1,i),40);
end
 
ylabel({'Reaction time (s.d. units)'})
xlabel({'Class number'})
set(gca,'XTick',[x_position(1:end)],'XTickLabel',{'1' '2' '3' '4' '5','6','7','8','9','10','11','12'})
axis([0 13 -.5 .5])
set(gca,'Ydir','reverse')

%print('-dpdf',[results_folder '/Fig1F_reaction_times'])
print('-depsc2',[results_folder '/Fig1F_reaction_times_correct'])
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf
hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for class = 1:12
mean_classE = mean(errorRTN{1,class});
stderr_classE = std(errorRTN{1,class})./sqrt(size(errorRT{1,class},2));
class_handleE(1,class)= errorbar(x_position(1,class),mean_classE,stderr_classE,'-o','MarkerSize',marker_size,'LineWidth',line_width1,'color',[1 0 0]);	
end

for i=1:12
errorbar_tick(class_handleE(1,i),40);
end

ylabel('Reaction time (s.d. units)')
xlabel({'Class number'})
set(gca,'XTick',[x_position(1:end)],'XTickLabel',{'1' '2' '3' '4' '5','6','7','8','9','10','11','12'})
axis([0 13 -.5 2.5])
set(gca,'Ydir','reverse')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%print('-dpdf',[results_folder '/Fig1F_reaction_times'])
print('-depsc2',[results_folder '/Fig1F_reaction_times_error'])
close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end