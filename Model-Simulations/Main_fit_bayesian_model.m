clear all
close all
clc
model_results_folder = 'model_results';
if ~exist(model_results_folder, 'dir')
    mkdir(model_results_folder)
end
addpath(model_results_folder)
load('performanceSetB')
%Parametros

real_performance = results_performance.mean_accuracy_class;

tic

T=3;
n=20000;
range2=[1 4];
range1 = [.3 3]; % this is alpha
range3 = [0 0]; %.1
range4=[20000,20000];

%Starting Point

Param1=1; % antes 1
Param2=3;% this means alpha = 1, antes 3
Param3 = 0.0;
Param4 = 20000;


[psycho] = give_me_psycho_classes(Param1*Param2,Param2,Param3,Param4);
E=1/sum((psycho-real_performance).^2);

%Loop
for i=1:n
    
    if mod(i,5)==0
    T=T*0.999;   
    end
    
    Param12=Param1+(rand()<0.5)*(range1(1)-Param1)*((rand())^2)*0.5+(rand()<0.5)*(range1(2)-Param1)*((rand())^2)*0.5;   
    Param22=Param2+(rand()<0.5)*(range2(1)-Param2)*((rand())^2)*0.5+(rand()<0.5)*(range2(2)-Param2)*((rand())^2)*0.5;
    Param32=Param3+(rand()<0.5)*(range3(1)-Param3)*((rand())^2)*0.5+(rand()<0.5)*(range3(2)-Param3)*((rand())^2)*0.5;
    Param42=Param4+(rand()<0.5)*(range4(1)-Param4)*((rand())^2)*0.5+(rand()<0.5)*(range4(2)-Param4)*((rand())^2)*0.5;
    
    %Param12=Param1*(1+1.05*randn()); without constraint
    %Param22=Param2*(1+1.05*randn());
    
    [psycho] = give_me_psycho_classes(Param12*Param22,Param22,Param32,Param42);
    
    E2=1/sum((psycho-real_performance).^2);
 

    
    P=exp((E2-E)/T);
     
    if rand()<P
        Param1=Param12;
        Param2=Param22;
        Param3=Param32;
        Param4=Param42;
       
        E=E2;
    end
    
    if mod(i,10)==0
        disp(['Iteration no ' num2str(i) ', time is == , ' num2str(toc) ', T == ' num2str(T) ' E == ' num2str(E)])
    end
    
end  

results_best_fit.param1 = Param1;
results_best_fit.param2 = Param2;
results_best_fit.param3 = Param3;
results_best_fit.param4 = Param4;

save([model_results_folder '/results_bayesian_model'],'results_best_fit')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


