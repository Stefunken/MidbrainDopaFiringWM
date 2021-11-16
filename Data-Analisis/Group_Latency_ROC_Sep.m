function latency = Group_Latency_ROC_Sep(varargin)

SO1 = getArgumentValue('SO1', 1, varargin{:});          % Analyse SO1
SO2 = getArgumentValue('SO2', 1, varargin{:});          % Analyse SO2
Rew = getArgumentValue('Rew', 1, varargin{:});          % Analyse SO2
cons_bins = getArgumentValue('n_bins', 5, varargin{:}); % Consecutive Bins

load('results_roc_outcome.mat');        % 2 Groups sorted by outcome
load('results_roc_diff_6Class.mat');    % 2 Groups sorted by difficulty

timeAx = results_roc_outcome(2).timeAx;
t1_on = 0; t2_on = 3.5;
x_Out = double(results_roc_outcome(2).ci<0.05); % ROC Outcome Groups
x_Dif = double(results_roc_diff(2).ci<0.05);    % ROC Difficulty Groups

latency = struct;
latency.Outcome = [];
latency.Difficulty = [];

if SO1 % Latency in First Stimulus
    time_SO1 = timeAx(timeAx>= -.1+t1_on & timeAx<=.6+t1_on);
    x_Out_1 = x_Out(timeAx>= -.1+t1_on & timeAx<=.6+t1_on); % Logical Array when two groups are separated
    x_Dif_1 = x_Dif(timeAx>= -.1+t1_on & timeAx<=.6+t1_on);
    
    control_Out = 1; control_Dif = 1;
    for t = 1:(size(time_SO1,2)-cons_bins)
        if control_Out % Outcome
            n_Out = sum(x_Out_1(t:t+cons_bins-1),2); 
            control_Out = n_Out ~= cons_bins;
            if not(control_Out)
                latency.Outcome.SO1 = round(1000*(time_SO1(1,t)-t1_on)); % Time of separation
                for t_aux = (t+cons_bins-1):size(time_SO1,2)
                    if x_Out_1(1,t_aux) ~= 1
                        break
                    end
                end
                latency.Outcome.SO1_Interval = round(1000*(time_SO1(1,t_aux-1) - time_SO1(1,t))); % Interval duration
            end
        end
        if control_Dif % Difficulty
            n_Dif = sum(x_Dif_1(t:t+cons_bins-1),2);
            control_Dif = n_Dif ~= cons_bins;
            if not(control_Dif)
                latency.Difficulty.SO1 = round(1000*(time_SO1(1,t)-t1_on)); % Time of separation
                for t_aux = (t+cons_bins-1):size(time_SO1,2)
                    if x_Dif_1(1,t_aux) ~= 1
                        break
                    end
                end
                latency.Difficulty.SO1_Interval = round(1000*(time_SO1(1,t_aux-1) - time_SO1(1,t))); % Interval duration
            end
        end
    end
    
end

if SO2 % Latency in Second Stimulus
    time_SO2 = timeAx(timeAx>= -.1+t2_on & timeAx<=.6+t2_on);
    x_Out_2 = x_Out(timeAx>= -.1+t2_on & timeAx<=.6+t2_on);
    x_Dif_2 = x_Dif(timeAx>= -.1+t2_on & timeAx<=.6+t2_on);
    
    control_Out = 1; control_Dif = 1;
    for t = 1:(size(time_SO2,2)-cons_bins)
        if control_Out % Outcome
            n_Out = sum(x_Out_2(t:t+cons_bins-1),2);
            control_Out = n_Out ~= cons_bins;
            if not(control_Out)
                latency.Outcome.SO2 = round(1000*(time_SO2(1,t)-t2_on)); % Time of separation
                for t_aux = (t+cons_bins-1):size(time_SO2,2)
                    if x_Out_2(1,t_aux) ~= 1
                        break
                    end
                end
                latency.Outcome.SO2_Interval = round(1000*(time_SO2(1,t_aux-1) - time_SO2(1,t))); % Interval duration
            end
        end
        if control_Dif % Difficulty
            n_Dif = sum(x_Dif_2(t:t+cons_bins-1),2);
            control_Dif = n_Dif ~= cons_bins;
            if not(control_Dif)
                latency.Difficulty.SO2 = round(1000*(time_SO2(1,t)-t2_on)); % Time of separation
                for t_aux = (t+cons_bins-1):size(time_SO2,2)
                    if x_Dif_2(1,t_aux) ~= 1
                        break
                    end
                end
                latency.Difficulty.SO2_Interval = round(1000*(time_SO2(1,t_aux-1) - time_SO2(1,t))); % Interval duration
            end
        end
    end
end

if Rew % Latency in Reward Delivery for Outcome Groups
    timeAx_Rew = results_roc_outcome(3).timeAx;
    x_Rew_Out = double(results_roc_outcome(3).ci<0.05);
    control = 1; 
    for t = 1:(size(timeAx_Rew,2)-cons_bins)
        if control
            n_Out = sum(x_Rew_Out(t:t+cons_bins-1),2);
            control = n_Out ~= cons_bins;
            if not(control)
                latency.Outcome.Reward = round(1000*(time_Rew(1,t))); % Time of separation 
            end
        end
    end
end