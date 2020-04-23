function figure_3_plots()

% This is to generate Figure 3A, panel right
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = 0:.001:1;
y = heaviside(x-0.5);
z = [1 - x(x<.5) x(x>=.5)];



figure_size=[3.2 3.5];
figure('visible','off')
set(gca,'color','w')
set(gcf,'color','w')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',figure_size)
set(gcf, 'PaperPosition', [0 0 figure_size])
set(gca,'FontSize',18,'LineWidth',.5)
hold on
box off

choice=plot(x,y,'r','LineWidth',3);
conf=plot(x,z,'--k','LineWidth',3);

l=legend([choice conf],'P_{decision}=  "f_1>f_2"  ','confidence');
set(l,'Location','NorthOutside','box','off')

xlabel('b(f_1>f_2)')

ylim([-0.01 1.01])
  
%print('-dpdf',['ChoiceConfBM'])
print('-depsc2',['ChoiceConfBM'])

close

end