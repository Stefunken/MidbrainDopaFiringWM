function [e,index_cl,index_freq] = loadAndFormatDataDiscrimination_FreqSetB(fileList,varargin)

freq_sample = unique([34    30    24    18    14    10    34    30    24    18    14    10 ; ...
               44    38    32    26    22    18    26    22    16    10     8     6 ]','rows');
%%           
freq_sample_ordered = [34    30    24    18    14    10    34    30    24    18    14    10 ; ...
               44    38    32    26    22    18    26    22    16    10     8     6 ];
%% SET B           
% class_freq_sample = unique([1   2   3   4   5   6   7   8   9   10   11   12
%                34    30    24    18    14    10    34    30    24    18    14    10 ; ...
%                44    38    32    26    22    18    26    22    16    10     8     6 ]','rows');           
%%
for k=1:length(fileList)
    %canales{k} = filesList(k);
    files{k} = ['DiscrTask' num2str(fileList(k))];
end

e = struct(); % Initialize e
index_cl=[];
index_freq=[];

% Loop through each filename.
i=0;
for k = 1:length(fileList)
    
    
    % Read the data file from disk.
    data = load(files{k});
        if max(data.data(:,1))==12
        index_cl = [index_cl k];
        end
    
    frequecies = unique([data.data(:,4) data.data(:,5)],'rows');    
    if (size(frequecies,1) == 12)
    if all(all(freq_sample==frequecies))

        
        index_freq = [index_freq k];
    
        i = i+1;
        

        
        % Set the general information.
        %e(k).info.fileName = fileList{k};
        e(i).info.conditions = {'Clase','trialRepetition','Reward','stimFreq1','stimFreq2'};
        e(i).info.events = {'ProbeDown','KeyDown','StimOn1','StimOn2','StimOff1','StimOff2','KeyUp','PushKey'};
        
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
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aux_ind=find(all(repmat(conditions(1,4:5)',1,12)==freq_sample_ordered));
            conditions(1,1) = aux_ind; % assign the class as the ones of set B
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            e(i).trial(cnt).conditions = conditions;
            
            % Fill the events.
            e(i).trial(cnt).events = events; % - alignTime;
            
            % Fill the electrode spikeTimes.
            %if ~isempty(data.result{m,6})
            % Loop through each electrode.
            % for v = 1:length(validNeurons{k})
            
            spikeTimes=data.result(cnt,20:end);
            spikeTimes(spikeTimes==0) = [];
            spikeTimes(spikeTimes== Inf) = [];
            
            
            e(i).trial(cnt).spikeTimes = ( spikeTimes / 1000 ); % - alignTime; % Convert from ms to seconds and align.
            
            % Remove double spikes
            
            isi = spikeTimes(2:end) - spikeTimes(1:end-1); % this is diff(spikeTimes);
            indx = isi<=.001; % Remove ISIs smaller than 1 ms.
            %          indx = isi<=0; % Remove ISIs smaller than 1 ms.
            spikeTimes(indx) = [];
            e(i).trial(cnt).spikeTimes = {spikeTimes'/1000};
            
            cnt = cnt + 1; % Increase the valid trial counter.
            clearvars spikeTimes
        end
        
    end
    end
end


end