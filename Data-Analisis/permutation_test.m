function [pval, H1] = permutation_test(X,Y,folder_name,Event,varargin)
%%

% Receives two lists X and Y anc computes the correlations between them.
% The p-value is obtained by shuffling the data. H1 is a binary variable
% that tests for the alternative hypothesis.

% Input: 
% N_Permutations --> Number of permutations.
% Significance --> Significance level.

% It uses a left-sided hypothesis since we are testing for negative
% correlations.
 
%%

% getArgumentValue('ARGUMENT',DEFAULTVALUE, VARARGIN);
N_Perms = getArgumentValue('N_Permutations', 1000, varargin{:});
Sig_Lev = getArgumentValue('Significance', 0.05, varargin{:});
Fig = getArgumentValue('Figure', 'Off', varargin{:});

Real_CC_mat = corrcoef(X,Y);
Real_CC = Real_CC_mat(1,2);
clear Real_CC_mat

% Random Shuffling Data
CC = zeros(1,N_Perms);
PV = CC;
for p = 1:N_Perms
    X_hat = X(randperm(length(X)));
    Y_hat = Y(randperm(length(Y)));
    [CC_mat, PV_mat] = corrcoef(X_hat,Y_hat);
    CC(1,p) = CC_mat(1,2); 
    PV(1,p) = PV_mat(1,2); 
end
pval = sum(CC <= Real_CC)/N_Perms;
H1 = pval <= Sig_Lev;

if strcmp(Fig,'On')
    figure_size = [6 4]; % [18.5 3.5]
    font_size = 15;
    figure('visible','off'),clf, hold on
    set(gca,'color','w')
    set(gcf,'color','w')
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',figure_size)
    set(gcf, 'PaperPosition', [0 0 figure_size])

    h = histogram(CC,'HandleVisibility','Off');
    title([Event ' Correlations Permutation Test'],'FontSize',8,'FontWeight','Bold');
    maxcount = max(h.Values);
    hold on;
        xline(Real_CC,'--b','DisplayName',['Real CC = ' num2str(Real_CC)]);
        xline(prctile(CC,Sig_Lev*100),'-r','LineWidth',2,'DisplayName',[num2str(Sig_Lev*100) '% Significance']);
        area([-0.2 Real_CC],[maxcount+200 maxcount+200],'DisplayName',['p_{val} = ' num2str(pval)],'LineStyle','none',...
            'FaceColor',[0.1 0.6 0.2],'FaceAlpha',0.2);
    hold off;
    xlabel('CC','FontSize',12);
    ylim([0 maxcount+20]);
    legend('Box','Off','Location','NorthEast','FontSize',8);
    print([folder_name '/Perm_Test_CC_' Event],'-dpdf','-r600');
end