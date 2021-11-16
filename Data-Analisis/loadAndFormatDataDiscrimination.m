function e = loadAndFormatDataDiscrimination(fileList,varargin)


for k=1:length(fileList)
    %canales{k} = filesList(k);
    files{k} = ['DiscrTask' num2str(fileList(k))];
end




%length(filesG2)

e = struct(); % Initialize e

% Loop through each filename.
for k = 1:length(fileList)
    % Read the data file from disk.
    data = load(files{k});
    %data.result(1,:) = []; % Fist row is headings so get rid of it.
    
    if k==1
        for i=1:12
            classesFreq(1,i) = unique(data.data(data.data(:,1)==i,4));
            classesFreq(2,i) = unique(data.data(data.data(:,1)==i,5));

        end
    end
    
    difficulty = abs(log(classesFreq(1,:))-log(classesFreq(2,:)));
      
    % Set the general information.
    %e(k).info.fileName = fileList{k};
    e(k).info.conditions = {'Clase','trialRepetition','Reward','stimFreq1','stimFreq2'};
    e(k).info.events = {'ProbeDown','KeyDown','StimOn1','StimOn2','StimOff1','StimOff2','KeyUp','PushKey'};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    cnt = 1; % Counter for valid trials.
    
    %     % Get the align column number
    %     alignIndx = strmatch(lower(align), lower(e(k).info.events));
    %     if isempty(alignIndx)
    %       error('Align event not found')
    %     end
    
    data.result = data.data; % cell2num(data.data)
    
    %disp(['las clases de la neurona ' num2str(k) ' son ' num2str(unique(data.result(:,1))')])

    % Loop through each trial.
    for m = 1:size(data.result,1) % this is the number of trials in neuron number 1
  

        
        % ProbeDown does not always registers.
        if isempty(data.result(m,6))
            data.result(m,6) = 499; % Use 510 ms which is the most common value.
        end
        
        % Pool the trial conditions
        conditions = [data.result(m,1) data.result(m,2) data.result(m,3) data.result(m,4) data.result(m,5)];
        
        % Pool the trial events. Convert from ms to seconds.
        events = [data.result(m,6)  data.result(m,7) data.result(m,8) data.result(m,9) ...
            data.result(m,10) data.result(m,11) data.result(m,12) data.result(m,13) ] ./ 1000;
        
        
        %       % Exclude trials (%Eliminar clases minoritarias ).
        %       remove = zeros(size(removeTrials{k},2),1);
        %       for r = 1:size(removeTrials{k},1)
        %         remove(r) = all([data.result{m,1} data.result{m,2} ] == removeTrials{k}(r,:));
        %       end
        
        % alignTime = events(alignIndx);% Align time
        
        % Fill the conditions.
        e(k).trial(cnt).conditions = conditions;
        
        % Fill the events.
        e(k).trial(cnt).events = events; % - alignTime;
        
        % Fill the electrode spikeTimes.
        %if ~isempty(data.result{m,6})
        % Loop through each electrode.
        % for v = 1:length(validNeurons{k})
        
        spikeTimes=data.result(cnt,20:end);
        spikeTimes(spikeTimes==0) = [];
        spikeTimes(spikeTimes== Inf) = [];
        
        
        e(k).trial(cnt).spikeTimes = ( spikeTimes / 1000 ); % - alignTime; % Convert from ms to seconds and align.
        
        % Remove double spikes
        
        isi = spikeTimes(2:end) - spikeTimes(1:end-1); % this is diff(spikeTimes);
        indx = isi<=.001; % Remove ISIs smaller than 1 ms.
        %          indx = isi<=0; % Remove ISIs smaller than 1 ms.
        spikeTimes(indx) = [];
        e(k).trial(cnt).spikeTimes = {spikeTimes'/1000};
        
        cnt = cnt + 1; % Increase the valid trial counter.
        clearvars spikeTimes
    end
    
end



end