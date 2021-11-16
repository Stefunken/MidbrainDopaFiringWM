close all; clear; clc;

tic
% Line 105: choose the significance test

for j = 1:2
    if j == 1; Perf_RT = load('Data_RT_Performance_Perc_50.mat'); Pc = '50'; end
    if j == 2; Perf_RT = load('Data_RT_Performance_Perc_40_60.mat'); Pc = '40-60'; end
    
    folder_name = ['Results_Pc' num2str(Pc)];
    if ~exist(folder_name, 'dir')
        mkdir(folder_name)
    end

    %% Parametros
    N_runs = 200;
    alp = zeros(2,N_runs); % Long and Short RT
    si2 = alp;
    eps = alp;
    si1 = alp;
    Err = alp;
    Pen = alp; 

    for RT = 1:2
        if RT == 1
            real_performance = Perf_RT.Long_RT/100;
        else
            real_performance = Perf_RT.Short_RT/100;
        end
        
        for run = 1:N_runs

            % Bounds
            range1 = [0.1 4]; % this is alpha
            range2=[1 8];
            range3 = [0 1/8];
            range4=[10000,40000];

            lb = [range1(1) range2(1) range3(1) range4(1)];
            ub = [range1(2) range2(2) range3(2) range4(2)];

            a = 1.0; %0.80; %1.10;

            % Random Starting Conditions
            Param1 = (range1(2)-range1(1))*rand + range1(1);%1.7191;   % alpha
            Param2 = (range2(2)-range2(1))*rand + range2(1);%3.2112;   % sigma
            Param3 = (range3(2)-range3(1))*rand + range3(1);%0.0016;   % epsilon
            Param4 = (range4(2)-range4(1))*rand + range4(1);%20000;    % slope sigmoid decision

            x0 = [Param1*Param2 Param2 Param3 Param4];
            ObjectiveFunction = @(x)Parameterized_Energy_4ParamsA(x,a,real_performance);

            % rng default %%% For reproducibility
            [x,E,exitFlag,output] = simulannealbnd(ObjectiveFunction,x0,lb,ub);

            alp(RT,run) = x(1);      % alpha;
            si2(RT,run) = x(2);      % sigma2;
            si1(RT,run) = x(1)*x(2); % sigma1;
            eps(RT,run) = x(3);      % epsilon;
            Pen(RT,run) = x(4);      % Pendiente Sigmoide
            Err(RT,run) = E;         % Error
        end
    end
    save([folder_name '/Results_Fit_Pc_' Pc '.mat'],'alp','si2','si1','eps','Err','Pen');

    %% Cleaning Data

    % Deleting NaN (non-convergent fits)
    alp_L = alp(1,~isnan(Err(1,:))); alp_S = alp(2,~isnan(Err(2,:))); 
    si1_L = si1(1,~isnan(Err(1,:))); si1_S = si1(2,~isnan(Err(2,:))); 
    si2_L = si2(1,~isnan(Err(1,:))); si2_S = si2(2,~isnan(Err(2,:))); 
    eps_L = eps(1,~isnan(Err(1,:))); eps_S = eps(2,~isnan(Err(2,:))); 
    Pen_L = Pen(1,~isnan(Err(1,:))); Pen_S = Pen(2,~isnan(Err(2,:))); 
    Err_L = Err(1,~isnan(Err(1,:))); Err_S = Err(2,~isnan(Err(2,:))); 

    clear alp si1 si2 eps Err ;

    [z_alp_L,m_alp_L,sd_alp_L] = zscore(alp_L);
    [z_si1_L,m_si1_L,sd_si1_L] = zscore(si1_L);
    [z_si2_L,m_si2_L,sd_si2_L] = zscore(si2_L);
    [z_eps_L,m_eps_L,sd_eps_L] = zscore(eps_L);
    [z_Pen_L,m_Pen_L,sd_Pen_L] = zscore(Pen_L);
    [z_Err_L,m_Err_L,sd_Err_L] = zscore(Err_L);

    [z_alp_S,m_alp_S,sd_alp_S] = zscore(alp_S);
    [z_si1_S,m_si1_S,sd_si1_S] = zscore(si1_S);
    [z_si2_S,m_si2_S,sd_si2_S] = zscore(si2_S);
    [z_eps_S,m_eps_S,sd_eps_S] = zscore(eps_S);
    [z_Pen_S,m_Pen_S,sd_Pen_S] = zscore(Pen_S);
    [z_Err_S,m_Err_S,sd_Err_S] = zscore(Err_S);

    N = 2; % 2 sigmas 
    alp_L = alp_L(abs(z_Err_L)<N); % Discard data where the Error is bigger than N sigmas
    alp_S = alp_S(abs(z_Err_S)<N);
    si1_L = si1_L(abs(z_Err_L)<N);
    si1_S = si1_S(abs(z_Err_S)<N);
    si2_L = si2_L(abs(z_Err_L)<N);
    si2_S = si2_S(abs(z_Err_S)<N);
    eps_L = eps_L(abs(z_Err_L)<N);
    eps_S = eps_S(abs(z_Err_S)<N);
    Pen_L = Pen_L(abs(z_Err_L)<N);
    Pen_S = Pen_S(abs(z_Err_S)<N);
    Err_L = Err_L(abs(z_Err_L)<N);
    Err_S = Err_S(abs(z_Err_S)<N);

    %% Stats

    % Two tailed t-test
    [h_alp,p_alp] = ttest2(alp_L,alp_S,'Alpha',0.05,'Vartype','unequal'); 
    [h_si1,p_si1] = ttest2(si1_L,si1_S,'Alpha',0.05,'Vartype','unequal'); 
    [h_si2,p_si2] = ttest2(si2_L,si2_S,'Alpha',0.05,'Vartype','unequal');
    [h_eps,p_eps] = ttest2(eps_L,eps_S,'Alpha',0.05,'Vartype','unequal');
    [h_Pen,p_Pen] = ttest2(Pen_L,Pen_S,'Alpha',0.05,'Vartype','unequal'); 
    [h_Err,p_Err] = ttest2(Err_L,Err_S,'Alpha',0.05,'Vartype','unequal'); 

    % Mann-Wilcoxon test
%     [p_alp,h_alp] = ranksum(alp_L,alp_S); 
%     [p_si1,h_si1] = ranksum(si1_L,si1_S); 
%     [p_si2,h_si2] = ranksum(si2_L,si2_S);
%     [p_eps,h_eps] = ranksum(eps_L,eps_S);
%     [p_Pen,h_Pen] = ranksum(Pen_L,Pen_S); 
%     [p_Err,h_Err] = ranksum(Err_L,Err_S); 

    %% Figures and Results
    figure(1)
    figure_size = [15 10];
    set(gca,'color','w')
    set(gcf,'color','w')
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',figure_size)
    set(gcf, 'PaperPosition', [0 0 figure_size])
    set(gca,'FontSize',18,'LineWidth',1)
    bins = 20;

    subplot(2,3,1)
        Long = histogram(alp_L,bins,'BinWidth',0.05);
        hold on;
            Short = histogram(alp_S,bins,'BinWidth',0.05);
        hold off;
        title(['H = ' num2str(h_alp) ' ; p = ' num2str(p_alp)]);
        xlabel('\alpha','FontSize',12);
    %     set(gca,'YTick',[]);
    subplot(2,3,2)
        Long = histogram(si1_L,bins,'BinWidth',0.05);
        hold on;
            Short = histogram(si1_S,bins,'BinWidth',0.05);
        hold off;
        title(['H = ' num2str(h_si1) ' ; p = ' num2str(p_si1)]);
        xlabel('\sigma_1','FontSize',12);
    %     set(gca,'YTick',[]);
    subplot(2,3,3)
        Long = histogram(si2_L,bins,'BinWidth',0.05);
        hold on;
            Short = histogram(si2_S,bins,'BinWidth',0.05);
        hold off;
        title(['H = ' num2str(h_si2) ' ; p = ' num2str(p_si2)]);
        xlabel('\sigma_2','FontSize',12);
    %     set(gca,'YTick',[]);
    subplot(2,3,4)
        Long = histogram(eps_L,bins,'BinWidth',0.001);
        hold on;
            Short = histogram(eps_S,bins,'BinWidth',0.001);
        hold off;
        title(['H = ' num2str(h_eps) ' ; p = ' num2str(p_eps)]);
        xlabel('\epsilon','FontSize',12);
    %     set(gca,'YTick',[]);
    subplot(2,3,5)
        Long = histogram(Pen_L,bins,'BinWidth',1000);
        hold on;
            Short = histogram(Pen_S,bins,'BinWidth',1000);
        hold off;
        title(['H = ' num2str(h_Pen) ' ; p = ' num2str(p_Pen)]);
        xlabel('Pendiente','FontSize',12);
    %     set(gca,'YTick',[]);
    subplot(2,3,6)
        Long = histogram(Err_L,bins,'BinWidth',0.0001);
        hold on;
            Short = histogram(Err_S,bins,'BinWidth',0.0001);
        hold off;
        title(['H = ' num2str(h_Err) ' ; p = ' num2str(p_Err)]);
        xlabel('E','FontSize',12);
    %     set(gca,'YTick',[]);
        legend('Long RT','Short RT');
    print([folder_name '/Stats_Fit Short_Long Pc_' Pc],'-dpdf','-r600');

    % Obtaining Performance With Fitted Values
%     alpha_L = (m_alp_L+(1-h_alp)*m_alp_S)/(2-h_alp); % If h = 0 ==> No significant difference ==> alpha_Long = mean between Long and short
%     alpha_S = (m_alp_S+(1-h_alp)*m_alp_L)/(2-h_alp); % If h = 1 ==> Significant difference ==> Different Values for Long and Short
%     sigma1_L = (m_si1_L+(1-h_si1)*m_si1_S)/(2-h_si1); 
%     sigma1_S = (m_si1_S+(1-h_si1)*m_si1_L)/(2-h_si1);
%     sigma2_L = (m_si2_L+(1-h_si2)*m_si2_S)/(2-h_si2); 
%     sigma2_S = (m_si2_S+(1-h_si2)*m_si2_L)/(2-h_si2);
%     epsilon_L = (m_eps_L+(1-h_eps)*m_eps_S)/(2-h_eps); 
%     epsilon_S = (m_eps_S+(1-h_eps)*m_eps_L)/(2-h_eps);
%     Pend_L = (m_Pen_L+(1-h_Pen)*m_Pen_S)/(2-h_Pen); 
%     Pend_S = (m_Pen_S+(1-h_Pen)*m_Pen_L)/(2-h_Pen);
    alpha_L = alp_L(Err_L==min(Err_L)); % The fit with minimum error
    alpha_S = alp_S(Err_S==min(Err_S));
    sigma1_L = si1_L(Err_L==min(Err_L));
    sigma1_S = si1_S(Err_S==min(Err_S));
    sigma2_L = si2_L(Err_L==min(Err_L));
    sigma2_S = si2_S(Err_S==min(Err_S));
    epsilon_L = eps_L(Err_L==min(Err_L));
    epsilon_S = eps_S(Err_S==min(Err_S));
    Pend_L = Pen_L(Err_L==min(Err_L));
    Pend_S = Pen_S(Err_S==min(Err_S));
    Error_L = min(Err_L);
    Error_S = min(Err_S);
    
    [psycho_L] = giveMe_Bayesian_Psycho_Classes_MATLAB(alpha_L*sigma2_L,sigma2_L,epsilon_L,Pend_L);
    [psycho_S] = giveMe_Bayesian_Psycho_Classes_MATLAB(alpha_S*sigma2_S,sigma2_S,epsilon_S,Pend_S);

    classesFreq = [34    30    24    18    14    10  34    30    24    18    14    10; ...
                   44    38    32    26    22    18   26    22   16    10     8     6 ];  

    dfile = [folder_name '/Stat_Results_Pc_' Pc '.txt'];
    if exist(dfile, 'file') ; delete(dfile); end
    diary(dfile)

    diary on;
    disp('MEAN VALUES:');
    disp(['-- For alpha: ']);
    if h_alp 
        disp(['Long = ' num2str(m_alp_L) ' and Short = ' num2str(m_alp_S) ' with p-value ' num2str(p_alp)]);
    else
        disp(['No significant difference with p-value ' num2str(p_alp)]);
    end
    disp(['-- For sigma1: ']);
    if h_si1 
        disp(['Long = ' num2str(m_si1_L) ' and Short = ' num2str(m_si1_S) ' with p-value ' num2str(p_si1)]);
    else
        disp(['No significant difference with p-value ' num2str(p_si1)]);
    end
    disp(['-- For sigma2: ']);
    if h_si2 
        disp(['Long = ' num2str(m_si2_L) ' and Short = ' num2str(m_si2_S) ' with p-value ' num2str(p_si2)]);
    else
        disp(['No significant difference with p-value ' num2str(p_si2)]);
    end
    disp(['-- For epsilon: ']);
    if h_eps 
        disp(['Long = ' num2str(m_eps_L) ' and Short = ' num2str(m_eps_S) ' with p-value ' num2str(p_eps)]);
    else
        disp(['No significant difference with p-value ' num2str(p_eps)]);
    end
    disp(['-- For the Pendiente: ']);
    if h_Pen 
        disp(['Long = ' num2str(m_Pen_L) ' and Short = ' num2str(m_Pen_S) ' with p-value ' num2str(p_Pen)]);
    else
        disp(['No significant difference with p-value ' num2str(p_Pen)]);
    end
    disp(['-- For the Error: ']);
    if h_Err 
        disp(['Long = ' num2str(m_Err_L) ' and Short = ' num2str(m_Err_S) ' with p-value ' num2str(p_Err)]);
    else
        disp(['No significant difference with p-value ' num2str(p_Err)]);
    end       
    disp('-------------------------------------------');
    disp('VALUES FOR THE PLOTTED FITS:');
    disp('Correspond to the minimum error fit: Long -- Short');
    disp(['alpha = ' num2str(alpha_L) ' -- ' num2str(alpha_S)]);
    disp(['sigma1 = ' num2str(sigma1_L) ' -- ' num2str(sigma1_S)]);
    disp(['sigma2 = ' num2str(sigma2_L) ' -- ' num2str(sigma2_S)]);
    disp(['epsilon = ' num2str(epsilon_L) ' -- ' num2str(epsilon_S)]);
    disp(['pend = ' num2str(Pend_L) ' -- ' num2str(Pend_S)]);
    disp(['Error = ' num2str(Error_L) ' -- ' num2str(Error_S)]);
    disp('-------------------------------------------');
    disp('REAL PERFORMANCE SHORT: ');
    disp(Perf_RT.Short_RT/100)
    disp('PSYCHO SHORT: ');
    disp(psycho_S)
    disp('REAL PERFORMANCE LONG: ');
    disp(Perf_RT.Long_RT/100)
    disp('PSYCHO LONG: ');
    disp(psycho_L)
    diary off;

    figure(2)
    figure_size = [8 4];
    set(gca,'color','w')
    set(gcf,'color','w')
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',figure_size)
    set(gcf, 'PaperPosition', [0 0 figure_size])
    set(gca,'FontSize',18,'LineWidth',1)

    subplot(1,2,1)
        plot(classesFreq(1,1:6),Perf_RT.Long_RT(1:6),'-ob','markersize',8,'LineWidth',1.5);
        title('Long RT');
        hold on;
            plot(classesFreq(1,1:6),100*psycho_L(1:6),'--<r','markersize',8,'LineWidth',1.5);
            plot(classesFreq(1,1:6),100-100*psycho_L(7:12),'--<r','markersize',8,'LineWidth',1.5);
            plot(classesFreq(1,1:6),100-Perf_RT.Long_RT(7:12),'-ob','markersize',8,'LineWidth',1.5);
        hold off;
        axis([8 36 0 100])
        xlabel('f_1 (Hz)');
        ylabel('% f_1 Called Lower');
        box off
    subplot(1,2,2)
        plot(classesFreq(1,1:6),Perf_RT.Short_RT(1:6),'-ob','markersize',8,'LineWidth',1.5,'DisplayName','Data');
        title('Short RT');
        hold on;
            plot(classesFreq(1,1:6),100*psycho_S(1:6),'--<r','markersize',8,'LineWidth',1.5,'DisplayName','Model');
            plot(classesFreq(1,1:6),100-100*psycho_S(7:12),'--<r','markersize',8,'LineWidth',1.5,'HandleVisibility','Off');
            plot(classesFreq(1,1:6),100-Perf_RT.Short_RT(7:12),'-ob','markersize',8,'LineWidth',1.5,'HandleVisibility','Off');
        hold off;
        legend('Location','East','Box','Off');
        axis([8 36 0 100])
        xlabel('f_1 (Hz)');
        box off
    print('-dpdf',[folder_name '/psychometric_Short_Long_Pc_' Pc]);

    figure(3)
    figure_size = [6 4];
    set(gca,'color','w')
    set(gcf,'color','w')
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',figure_size)
    set(gcf, 'PaperPosition', [0 0 figure_size])
    set(gca,'FontSize',18,'LineWidth',1)

    subplot(1,2,1)
        plot((1:12),Perf_RT.Long_RT,'-o','LineWidth',2,'DisplayName','Long RT');
        hold on;
            plot((1:12),Perf_RT.Short_RT,'-o','LineWidth',2,'DisplayName','Short RT');
        hold off;
        axis([0 13 70 100])
        xlabel('Class Number');
        ylabel('% Correct - Data');
        box off
    subplot(1,2,2)
        plot((1:12),100*psycho_L,'-o','LineWidth',2,'DisplayName','Long RT');
        hold on;
            plot((1:12),100*psycho_S,'-o','LineWidth',2,'DisplayName','Short RT');
        hold off;
        axis([0 13 70 100])
        xlabel('Class Number');
        ylabel('% Correct - Model Performance');
        legend('Box','Off','Location','SouthEast');
        box off
    print('-dpdf',[folder_name '/Model Performance RT P_' Pc]);
end
toc