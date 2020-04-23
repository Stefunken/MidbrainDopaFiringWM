function selectedTrials = select(e,varargin)
%
%  Examples:
%  selected = selectTrials(trials(1:100),'corr_tarangle',[0 180]) 
%  selected = selectTrials(trials(1:100),'align','dots_on','corr_tarangle',[270 90])       % Note that [LowerLim > UpperLim].
%
%  Note: [Lower Upper] limits define closed intervals, i.e. they include the limit values.
%        if     [Lower > Upper], the selected values are [Lower:+Inf & -Inf:Upper],
%        elseif [Lower < Upper], the selected values are [Lower : Upper]
%  'prefDir',[dir] Uses the neuron's preferred direction (0 or 180) to set the trial.direction field to 0 (nonPref) or 1 (prefDir).


% Get condition names.
conditionNames = [e(1).info.conditions e(1).info.events]; % It supposes all files have the same conditions. IMPROVE code to handle files with different conditions.
 
% Pool all the trials.
trials = [e.trial];

% Matrix of conditions
conditions = cell2mat({trials.conditions}');

% Matrix of events
events = cell2mat({trials.events}');

% Concatenate conditions and events
conditions = [conditions events];

indxs = zeros(1,length(varargin)/2); % For saving the condition column number

% Loop through each ..,'argument',[value],... pair on the varargin input.
for arg = 1:2:length(varargin)
  indx = strmatch(lower(varargin{arg}),lower(conditionNames));
  if isempty(indx)
    warning([mfilename '.m: Trial condition not found.'])
    disp(['Conditions are: ' conditionNames])
    continue
  end

  indxs((arg+1)/2) = indx; % Save the column number.

  % Get the desired value or range. 
  desiredRange = varargin{arg+1};

  % If it's a scalar, make it a vector.
  if length(desiredRange) == 1  
    desiredRange(2) =  desiredRange(1);
  end

  % Select the trials
  if desiredRange(1) <= desiredRange(2)
     % Test each trial agains the desired value or range. 
     conditions(:,indx) = (conditions(:,indx)>=desiredRange(1) & conditions(:,indx)<=desiredRange(2));

  elseif desiredRange(1)> desiredRange(2)
     % Test each trial agains the desired value or range.
     conditions(:,indx) = (conditions(:,indx)>=desiredRange(1) | conditions(:,indx)<=desiredRange(2));

  elseif length(desiredRange)>2 % Error checking: desired range must a two element vector [lowerlimit upperlimit].
     error(['Desired range must a two element vector ...''' varargin{field_num} ''',[lowerlimit upperlimit],...'])
  end
 
end

indx = all(conditions(:,indxs(indxs>0) ),2);

selectedTrials = trials(indx);
