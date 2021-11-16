function single_neurons_FR_plots(e,FileList,fileListA,results_folder,fileListExtra)
%% Pre-Requisites

binWidth = {.3, .3, .25}; 
filterType = 'boxcar'; 
align    = {'ProbeDown','StimOn1' , 'PushKey'};
TimeAxis = ['{ (-0.5+binWidth{j}/2):0.05:(1.5-binWidth{j}/2),' ...
    '  (-1.5+binWidth{j}/2):0.05:(4.5-binWidth{j}/2),' ... 
    '  (-0.1+binWidth{j}/2):0.05:(1.0-binWidth{j}/2) }'];

% Firing Rates
single_neurons_FR_correct = cell(1,3);
single_neurons_FR_error = cell(1,3);
% Standard Deviations
single_neurons_Stderr_correct = cell(1,3);
single_neurons_Stderr_error = cell(1,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Obtaining Single Neuron FRs

n_neurons = length(e);
for i=1:n_neurons
    for j=1:3
        eAl = alignSpikes(e(i),align{j}); % Align spikes       
        correct = select(eAl,'reward',1);
        error = select(eAl,'reward', 0);

        % Calculate the time axis and displacement.
        gap = 0;
        timeAxis = eval(TimeAxis);
        displace(2) = timeAxis{1}(end)+abs(timeAxis{2}(1))+ gap + binWidth{j}; 
        displace(3) = displace(2) + timeAxis{2}(end) + abs(timeAxis{3}(1)) + gap + binWidth{j};
        timeAx      = timeAxis{j} + displace(j);

        % Obtain the mean firing rates.
        correct_FR = firingrate([correct.spikeTimes], timeAxis{j},'filtertype',filterType,'timeconstant',binWidth{j});
        error_FR = firingrate([error.spikeTimes], timeAxis{j},'filtertype',filterType,'timeconstant',binWidth{j});

        min_trials = 3; % Minimum number of trials to have statistics 
        if size(correct_FR,1)< min_trials
            correct_mean = nan*ones(size(timeAx));
            correct_stderr = correct_mean;
        else
            correct_mean = mean(correct_FR);
            correct_stderr = std(correct_FR)/sqrt(size(correct_FR,1));
        end
        if size(error_FR,1)< min_trials
            error_mean = nan*ones(size(timeAx));
            error_stderr = error_mean;
        else
            error_mean = mean(error_FR);
            error_stderr = std(error_FR)/sqrt(size(error_FR,1));
        end

        single_neurons_FR_correct{1,j} = [single_neurons_FR_correct{1,j} ; correct_mean];
        single_neurons_FR_error{1,j} = [single_neurons_FR_error{1,j} ; error_mean];

        single_neurons_Stderr_correct{1,j} = [single_neurons_Stderr_correct{1,j} ; correct_stderr];
        single_neurons_Stderr_error{1,j} = [single_neurons_Stderr_error{1,j} ; error_stderr];
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
        correct_mean = single_neurons_FR_correct{1,j}(i,:);
        correct_stderr = single_neurons_Stderr_correct{1,j}(i,:);
        error_mean = single_neurons_FR_error{1,j}(i,:);
        error_stderr = single_neurons_Stderr_error{1,j}(i,:);
        
        % Plot Results
        h1 = shadedErrorBar(timeAx,correct_mean,correct_stderr,{'LineWidth',2,'color',[.2,.2,1]});
        h2 = shadedErrorBar(timeAx,error_mean,error_stderr,{'LineWidth',2,'color',[1,.2,.2]});
        
        if j==2
            [hleg,icons,~,~]  = legend([h1.mainLine h2.mainLine],'Correct','Error') ;
        end
    end

    % Axis, Legend and Title Properties
    set(hleg,'Position',[0.48 0.18 0.1 0.1])
    set(hleg,'box','off')
    set(hleg,'FontSize',font_size)
    set(icons(:),'LineWidth',6); %// Or whatever    
    ylabel('z-score','FontSize',font_size)
    set(gca,'XTick',[])
    set(gca,'XTickLabel',{''},'FontSize',font_size)
    if any(fileListA == FileList(i))         % 12 Original Neurons 
        title(['Neuron # '  num2str(FileList(i))], 'color', [0 .7 0],'FontSize',20)
    elseif any(fileListExtra == FileList(i)) % Extra Neurons (May 2021)
        title(['Neuron # '  num2str(FileList(i))], 'color', [0 0 .7], 'FontSize',20)
    end
    print([results_folder '/FigCorrectError-Neuron-' num2str(FileList(i))],'-dpdf','-r600');
%     print([results_folder '/FigCorrectError-Neuron-' num2str(FileList(i))],'-depsc2'); 
    close 
end 