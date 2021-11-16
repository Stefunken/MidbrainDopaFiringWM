function single_neurons_FR_Diff_plots(e,FileList,fileListA,results_folder,HC_K,LC_K,fileListExtra)
%% Pre-Requisites

binWidth = {.3, .3, .25}; 
filterType = 'boxcar'; 
align    = {'ProbeDown','StimOn1' , 'PushKey'};
TimeAxis = ['{ (-0.5+binWidth{j}/2):0.05:(1.5-binWidth{j}/2),' ...
    '  (-1.5+binWidth{j}/2):0.05:(4.5-binWidth{j}/2),' ... 
    '  (-0.1+binWidth{j}/2):0.05:(1.0-binWidth{j}/2) }'];

% Firing Rates
single_neurons_FR_High = cell(1,3);
single_neurons_FR_Low = cell(1,3);
% Standard Deviations
single_neurons_Stderr_High = cell(1,3);
single_neurons_Stderr_Low = cell(1,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Obtaining Single Neuron FRs

n_neurons = length(e);
for i=1:n_neurons
    for j=1:3
        eAl = alignSpikes(e(i),align{j}); % Align spikes to each event (See Line 7)    
        High = [select(eAl,'reward',1,'clase', HC_K(1,:)),select(eAl,'reward',1,'clase', HC_K(2,:))]; % Low Difficulty (High Confidence)
        Low = select(eAl,'reward',1,'clase', LC_K); % High Difficulty (Low Confidence)

        % Calculate the time axis and displacement.
        gap = 0;
        timeAxis = eval(TimeAxis);
        displace(2) = timeAxis{1}(end)+abs(timeAxis{2}(1))+ gap + binWidth{j}; 
        displace(3) = displace(2) + timeAxis{2}(end) + abs(timeAxis{3}(1)) + gap + binWidth{j};
        timeAx      = timeAxis{j} + displace(j);

        % Obtain the mean firing rates.
        High_FR = firingrate([High.spikeTimes], timeAxis{j},'filtertype',filterType,'timeconstant',binWidth{j});
        Low_FR = firingrate([Low.spikeTimes], timeAxis{j},'filtertype',filterType,'timeconstant',binWidth{j});

        min_trials = 3; % Minimum number of trials to have statistics 
        if size(High_FR,1)< min_trials
            High_mean = nan*ones(size(timeAx));
            High_stderr = High_mean;
        else
            High_mean = mean(High_FR);
            High_stderr = std(High_FR)/sqrt(size(High_FR,1));
        end
        if size(Low_FR,1)< min_trials
            Low_mean = nan*ones(size(timeAx));
            Low_stderr = Low_mean;
        else
            Low_mean = mean(Low_FR);
            Low_stderr = std(Low_FR)/sqrt(size(Low_FR,1));
        end

        single_neurons_FR_High{1,j} = [single_neurons_FR_High{1,j} ; High_mean];
        single_neurons_FR_Low{1,j} = [single_neurons_FR_Low{1,j} ; Low_mean];

        single_neurons_Stderr_High{1,j} = [single_neurons_Stderr_High{1,j} ; High_stderr];
        single_neurons_Stderr_Low{1,j} = [single_neurons_Stderr_Low{1,j} ; Low_stderr];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figures Single Neurons

% Temporal gap between the events in the figure
gap  = .1; 
gap_rew = 2;

% For Figure Explainability
y = [2 12];
xPD = [0 0];
xRew = [8.0 8.0] + gap_rew;
xStim = [3.0 3.0 3.5 3.5];
xStim2 = [6.5 6.5 7.0 7.0];
y1 = [2 12 12 2];
mygray = [.9 .9 .9];

% Figure properties
figure_size = [18.5 3.5];
font_size = 15;

%%% Loop over all neurons %%%
for i=1:n_neurons
    figure('visible','off'),clf, hold on
    set(gca,'color','w')
    set(gcf,'color','w')
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',figure_size)
    set(gcf, 'PaperPosition', [0 0 figure_size])
    set(gca,'FontSize',font_size,'LineWidth',1,'XColor','w')
    
    % For Figure Explainability
    plot(xPD,y, 'color',mygray,'linewidth',5)
    area(xStim,y1,'EdgeColor',mygray,'FaceColor',mygray)
    area(xStim2,y1,'EdgeColor',mygray,'FaceColor',mygray)
    plot(xRew,y, 'color',mygray,'linewidth',5)

    for j=1:3
        % Calculate the time axis and displacement.
        timeAxis = eval(TimeAxis);
        displace(2) = timeAxis{1}(end)+abs(timeAxis{2}(1))+ gap + binWidth{j};
        displace(3) = displace(2) + timeAxis{2}(end) + abs(timeAxis{3}(1)) + gap_rew + binWidth{j};
        timeAx      = timeAxis{j} + displace(j);
        
        % Obtain Data to plot
        High_mean = single_neurons_FR_High{1,j}(i,:);
        High_stderr = single_neurons_Stderr_High{1,j}(i,:);
        Low_mean = single_neurons_FR_Low{1,j}(i,:);
        Low_stderr = single_neurons_Stderr_Low{1,j}(i,:);
        
        % Plot Results
        h1 = shadedErrorBar(timeAx,High_mean,High_stderr,{'LineWidth',2,'color',[.2,.2,1]});
        h2 = shadedErrorBar(timeAx,Low_mean,Low_stderr,{'LineWidth',2,'color',[.2,.6,1]});
        
        if j==2
            [hleg,icons,~,~]  = legend([h1.mainLine h2.mainLine],'Low Diff','High Diff') ;
        end
    end

    % Axis, Legend and Title Properties
    set(hleg,'Position',[0.48 0.18 0.1 0.1])
    set(hleg,'box','off')
    set(hleg,'FontSize',font_size)
    set(icons(:),'LineWidth',6);   
    ylabel('z-score','FontSize',font_size)
    set(gca,'XTick',[])
    set(gca,'XTickLabel',{''},'FontSize',font_size)
    if any(fileListA == FileList(i))         % 12 Original Neurons 
        title(['Neuron # '  num2str(FileList(i))], 'color', [0 .7 0],'FontSize',20)
    elseif any(fileListExtra == FileList(i)) % Extra Neurons (May 2021)
        title(['Neuron # '  num2str(FileList(i))], 'color', [0 0 .7], 'FontSize',20)
    end
    print([results_folder '/FigDiff-Neuron-' num2str(FileList(i))],'-dpdf','-r600');
%     print([results_folder '/FigDiff-Neuron-' num2str(FileList(i))],'-depsc2');  
    close 
end 