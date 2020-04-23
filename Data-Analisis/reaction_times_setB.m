function reaction_times_setB(e,result_folder) %REACTION TIMES (KU-PB)

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
  correct=select(e,'reward',1,'clase',[i i]); 
  error=select(e,'reward',0,'clase',[i i]);
 
  auxC = cell2mat({correct.responseTime});
  auxE = cell2mat({error.responseTime});
  auxC(isnan(auxC))=[];
  auxE(isnan(auxE))=[];
  
  auxCN = cell2mat({correct.responseTimeNorm});
  auxEN = cell2mat({error.responseTimeNorm});
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



% names = [repmat({'c1'}, 1, n_correct_class(1,1)) repmat({'c2'}, 1, n_correct_class(1,2)) repmat({'c3'}, 1, n_correct_class(1,3)) ...
%     repmat({'c4'}, 1, n_correct_class(1,4)) repmat({'c5'}, 1, n_correct_class(1,5)) repmat({'c6'}, 1, n_correct_class(1,6)) ...
%     repmat({'c7'}, 1, n_correct_class(1,7)) repmat({'c8'}, 1, n_correct_class(1,8)) repmat({'c9'}, 1, n_correct_class(1,9)) ...
%     repmat({'c10'}, 1, n_correct_class(1,10)) repmat({'c11'}, 1, n_correct_class(1,11)) repmat({'c12'}, 1, n_correct_class(1,12))];
%  
% groups = [correctRT{1,1}, correctRT{1,2},correctRT{1,3},...
%           correctRT{1,4}, correctRT{1,5},correctRT{1,6},...
%           correctRT{1,7}, correctRT{1,8},correctRT{1,9},...
%           correctRT{1,10}, correctRT{1,11},correctRT{1,12}];
%       
% [p,anovatab,stats] = anova1(groups, names);
% 
%  multcompare(stats)

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
figure_size = [10.5 3.5];
font_legend = 12;
font_size = 22;
line_width1 = 2;
marker_size = 6;

x_position = 1:12;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Response Time- correct trials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf, hold on
hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1.5)
  
for class = 1:12
    
mean_class = mean(correctRTN{1,class});
stderr_class = std(correctRTN{1,class})./sqrt(size(correctRTN{1,class},2));


class_handle(1,class)= errorbar(x_position(1,class),mean_class,stderr_class,'-o','MarkerSize',marker_size,'LineWidth',line_width1,'color',[1-class/12 0.5 class/12]);	


% 
% 
% clearvars class_handle
end

for i=1:12
errorbar_tick(class_handle(1,i),40);
end

%[hleg,icons,plots,str]  = legend([f2Leg(1:end)],' 98 %',' 98 %',' 99 %',' 98 %', ' 85 %' ,' 90.5 %',' 85.5 %', ' 99 %', ' 98 %', ' 99 %') ;
[hleg,icons,plots,str]  = legend([class_handle(1:end)],' 98 %',' 94 %',' 97 %',' 95 %', ' 91 %' ,' 86 %',' 81 %', ' 85 %', ' 92 %', ' 97 %',' 97 %',' 97 %') ;

set(hleg,'box','off')
set(hleg,'Location','NorthEastOutside','FontSize',font_legend);
%set(icons(:),'LineWidth',2); %// Or whatever


%text(1, -.25, {'Outside','the PSW'},'FontSize',font_legend,'HorizontalAlignment', 'Center'); 
 

%set(gca,'xcolor','w') 
%set(gca,'XTick',[])

 
ylabel({'Reaction time','(s.d. units)'})
xlabel({'class number'})

set(gca,'XTick',[x_position(1:end)],'XTickLabel',{'1' '2' '3' '4' '5','6','7','8','9','10','11','12'})
axis([0 13 -.5 .5])
set(gca,'Ydir','reverse')

print('-dpdf',[result_folder '/ReactionTimes-byclass-Correct-zScore-setB'])
print('-depsc2',[result_folder '/ReactionTimes-byclass-Correct-zScore-setB'])

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Response Time- error trials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('visible','off'),clf, hold on
hold on
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',font_size,'LineWidth',1.5)
  
for class = 1:12
    
mean_class = mean(errorRTN{1,class});
stderr_class = std(errorRTN{1,class})./sqrt(size(errorRT{1,class},2));


class_handle(1,class)= errorbar(x_position(1,class),mean_class,stderr_class,'-o','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0.5 class/12 1-class/12]);	


% 
% 
% clearvars class_handle
end

for i=1:12
errorbar_tick(class_handle(1,i),40);
end

%[hleg,icons,plots,str]  = legend([f2Leg(1:end)],' 98 %',' 98 %',' 99 %',' 98 %', ' 85 %' ,' 90.5 %',' 85.5 %', ' 99 %', ' 98 %', ' 99 %') ;
[hleg,icons,plots,str]  = legend([class_handle(1:end)],' 98 %',' 94 %',' 97 %',' 95 %', ' 91 %' ,' 86 %',' 81 %', ' 85 %', ' 92 %', ' 97 %',' 97 %',' 97 %') ;

set(hleg,'box','off')
set(hleg,'Location','NorthEastOutside','FontSize',font_legend);
%set(icons(:),'LineWidth',2); %// Or whatever


%text(1, -.25, {'Outside','the PSW'},'FontSize',font_legend,'HorizontalAlignment', 'Center'); 
 

%set(gca,'xcolor','w') 
%set(gca,'XTick',[])

  
ylabel({'Reaction time','(s.d. units)'})
xlabel({'class number'})

set(gca,'XTick',[x_position(1:end)],'XTickLabel',{'1' '2' '3' '4' '5','6','7','8','9','10','11','12'})
%axis([0 13 -.5 1.2])
set(gca,'Ydir','reverse')

print('-dpdf',[result_folder '/ReactionTimes-byclass-Error-zScore-setB'])
print('-depsc2',[result_folder '/ReactionTimes-byclass-Error-zScore-setB'])

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Response Time Normalized - correct trials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


figure_size = [4.5 3.5];
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
  
for class = 1:12
    
mean_class = mean(correctRTN{1,class});
stderr_class = std(correctRTN{1,class})./sqrt(size(correctRTN{1,class},2));


mean_classE = mean(errorRTN{1,class});
stderr_classE = std(errorRTN{1,class})./sqrt(size(errorRT{1,class},2));

%class_handle(1,class)= errorbar(x_position(1,class),mean_class,stderr_class,'-o','MarkerSize',marker_size,'LineWidth',line_width1,'color',[1-class/12 0.5 class/12]);	
%class_handleE(1,class)= errorbar(x_position(1,class),mean_classE,stderr_classE,'-o','MarkerSize',marker_size,'LineWidth',line_width1,'color',[1-class/12 0.5 class/12]);	

class_handle(1,class)= errorbar(x_position(1,class),mean_class,stderr_class,'-o','MarkerSize',marker_size,'LineWidth',line_width1,'color',[0 0 1]);	
class_handleE(1,class)= errorbar(x_position(1,class),mean_classE,stderr_classE,'-o','MarkerSize',marker_size,'LineWidth',line_width1,'color',[1 0 0]);	
% 
% 
% clearvars class_handle
end

for i=1:12
errorbar_tick(class_handle(1,i),40);
errorbar_tick(class_handleE(1,i),40);

end

[hleg,icons,plots,str]  = legend([class_handle(class) class_handleE(class)],'Correct','Error') ;
%[hleg,icons,plots,str]  = legend([class_handle(1:end)],' 98 %',' 94 %',' 97 %',' 95 %', ' 91 %' ,' 86 %',' 81 %', ' 85 %', ' 92 %', ' 97 %',' 97 %',' 97 %') ;

set(hleg,'box','off')
set(hleg,'Location','SouthWest','FontSize',12);

 
ylabel({'Response time (s.d. units)'})
xlabel({'Class number'})

set(gca,'XTick',[x_position(1:end)],'XTickLabel',{'1' '2' '3' '4' '5','6','7','8','9','10','11','12'})
axis([0 13 -.5 2.5])
set(gca,'Ydir','reverse')

print('-dpdf',[result_folder '/ReactionTimes-byclass-Correct-vs-Error-Norm-zScore-setB'])
print('-depsc2',[result_folder '/ReactionTimes-byclass-Correct-vs-Error-zScore-setB'])

close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 
end
  
