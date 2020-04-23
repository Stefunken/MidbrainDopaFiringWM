function e = alignSpikes(e,alignEvent,varargin)
% Aligns the spikes and events to alignEvent.


for j = 1:length(e) % Loop through each experiment
  % Get the align column number
  alignIndx = strmatch(lower(alignEvent), lower(e(1).info.events));

  % Make sure event exists.
  if isempty(alignIndx)
    error('Align event not found')
  end

  for k = 1:length(e(j).trial)                               % Loop through each trial
    alignTime = e(j).trial(k).events(alignIndx);
    e(j).trial(k).events = e(j).trial(k).events - alignTime; % Align events 
    
    for m = 1:length(e(j).trial(k).spikeTimes)               % Loop through each neuron.
      spikeTimes = e(j).trial(k).spikeTimes{m};
      e(j).trial(k).spikeTimes{m} = spikeTimes - alignTime;  % Align spikes
    end
  end

end




