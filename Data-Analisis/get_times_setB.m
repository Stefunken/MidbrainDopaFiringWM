function [eNorm] = get_times_setB(e1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

e_KD = alignSpikes(e1,'KeyDown'); % Align spikes

% Normalize firing rates

for i_neuron = 1:length(e_KD) % Loop through each (e)xperimentd, neuron!!
    
    
    aux1 = select(e1(i_neuron),'reward',1,'clase',[1 6]);
    aux2 = select(e1(i_neuron),'reward',1,'clase',[7 12]);
    
    auxE1 = select(e1(i_neuron),'reward',0,'clase',[1 6]);
    auxE2 = select(e1(i_neuron),'reward',0,'clase',[7 12]);
    
    B1 = [aux1 auxE2];
    B2 = [aux2 auxE1];

    for i_trial_1 =1:length(aux1)
        RT1(i_trial_1) =   B1(i_trial_1).events(7) - B1(i_trial_1).events(6);
        MT1(i_trial_1) =   B1(i_trial_1).events(8) - B1(i_trial_1).events(7);
    end
    
    for i_trial_2 =1:length(aux2)
        RT2(i_trial_2) =   B2(i_trial_2).events(7) - B2(i_trial_2).events(6);
        MT2(i_trial_2) =   B2(i_trial_2).events(8) - B2(i_trial_2).events(7);
    end
    
    for i_trial = 1:length(e_KD(i_neuron).trial)
        RTKD(i_trial) = e_KD(i_neuron).trial(i_trial).events(2) - e_KD(i_neuron).trial(i_trial).events(1);
    end
     
    
%     for i_trial_1 =1:length(auxE1)
%         RT_E1(i_trial_1) =   auxE1(i_trial_1).events(7) - auxE1(i_trial_1).events(6);
%         MT_E1(i_trial_1) =   auxE1(i_trial_1).events(8) - auxE1(i_trial_1).events(7);
%     end
%     
%     for i_trial_2 =1:length(auxE2)
%         RT_E2(i_trial_2) =   auxE2(i_trial_2).events(7) - auxE2(i_trial_2).events(6);
%         MT_E2(i_trial_2) =   auxE2(i_trial_2).events(8) - auxE2(i_trial_2).events(7);
%     end
    
    
    meanRT1(i_neuron) = mean(RT1);
    meanRT2(i_neuron) = mean(RT2);
    stdRT1(i_neuron) = std(RT1);
    stdRT2(i_neuron) = std(RT2);
    
    meanMT1(i_neuron) = mean(MT1);
    meanMT2(i_neuron) = mean(MT2);
    stdMT1(i_neuron) = std(MT1);
    stdMT2(i_neuron) = std(MT2);

    meanRTKD(i_neuron) = mean(RTKD);
    stdRTKD(i_neuron) = std(RTKD);
    
    clearvars RT1 RT2 MT1 MT2 RTKD

%     meanRT_E1(i_neuron) = mean(RT_E1);
%     meanRT_E2(i_neuron) = mean(RT_E2);
%     stdRT_E1(i_neuron) = std(RT_E1);
%     stdRT_E2(i_neuron) = std(RT_E2);
%     
%     meanMT_E1(i_neuron) = mean(MT_E1);
%     meanMT_E2(i_neuron) = mean(MT_E2);
%     stdMT_E1(i_neuron) = std(MT_E1);
%     stdMT_E2(i_neuron) = std(MT_E2);
    
     
    for i_trial = 1:length(e_KD(i_neuron).trial)
        
        e1(i_neuron).trial(i_trial).RT = e_KD(i_neuron).trial(i_trial).events(7)-...
            e_KD(i_neuron).trial(i_trial).events(6) ;
        e1(i_neuron).trial(i_trial).MT = e_KD(i_neuron).trial(i_trial).events(8)-...
            e_KD(i_neuron).trial(i_trial).events(7) ;
        
        e1(i_neuron).trial(i_trial).RTKD = e_KD(i_neuron).trial(i_trial).events(2)-...
                                                e_KD(i_neuron).trial(i_trial).events(1) ;
        e1(i_neuron).trial(i_trial).RTKD_norm = (e1(i_neuron).trial(i_trial).RTKD - ...
                                                meanRTKD(i_neuron))/stdRTKD(i_neuron);
                                            
        if (e1(i_neuron).trial(i_trial).conditions(1)<=6)
            e1(i_neuron).trial(i_trial).RT_norm = (e1(i_neuron).trial(i_trial).RT-meanRT1(i_neuron))/stdRT1(i_neuron);
            e1(i_neuron).trial(i_trial).MT_norm = (e1(i_neuron).trial(i_trial).MT-meanMT1(i_neuron))/stdMT1(i_neuron);

        elseif (e1(i_neuron).trial(i_trial).conditions(1)>6 && e1(i_neuron).trial(i_trial).conditions(1)<=12)
            e1(i_neuron).trial(i_trial).RT_norm = (e1(i_neuron).trial(i_trial).RT-meanRT2(i_neuron))/stdRT2(i_neuron);
            e1(i_neuron).trial(i_trial).MT_norm = (e1(i_neuron).trial(i_trial).MT-meanMT2(i_neuron))/stdMT2(i_neuron);
        end
        
        
        if e1(i_neuron).trial(i_trial).conditions(3)==0
            if (e1(i_neuron).trial(i_trial).conditions(1)>6 && e1(i_neuron).trial(i_trial).conditions(1)<=12)

                e1(i_neuron).trial(i_trial).RT_norm = (e1(i_neuron).trial(i_trial).RT-meanRT1(i_neuron))/stdRT1(i_neuron);
                e1(i_neuron).trial(i_trial).MT_norm = (e1(i_neuron).trial(i_trial).MT-meanMT1(i_neuron))/stdMT1(i_neuron);
                
            elseif e1(i_neuron).trial(i_trial).conditions(1)<=6
                e1(i_neuron).trial(i_trial).RT_norm = (e1(i_neuron).trial(i_trial).RT-meanRT2(i_neuron))/stdRT2(i_neuron);
                e1(i_neuron).trial(i_trial).MT_norm = (e1(i_neuron).trial(i_trial).MT-meanMT2(i_neuron))/stdMT2(i_neuron);
                
            end
        end
        
    end
    
end

eNorm = e1;

end
     
