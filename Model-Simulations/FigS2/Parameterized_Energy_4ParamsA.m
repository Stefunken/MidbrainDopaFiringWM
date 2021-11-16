function E = Parameterized_Energy_4ParamsA(x,a,real_performance)
%Energy - Summary of this function goes here
%   Detailed explanation goes here

alpha      = x(1); 
noiseFreq2 = x(2); 
epsilon    = x(3); 
pend       = x(4);

%Parametros

% real_performance = [98 94 97 95 91 86 81 85 92 97 97 97]/100; % from romo et el 2002
% % % %real_performance = [99 98 99 93 87 85 78 94 98 99 98 98]/100;
% % % %real_performance = (real_performance + real_performance1)/2;

% real_performance = [95.38  92.12  84.24  83.15  90.76  81.70 ...  
%                     82.06  90.22  90.22  90.71  89.13  91.44 ]/100; % from PFC sessions, R14

real_performance1 = real_performance(1,[1:6]);
real_performance2 = real_performance(1,[7:12]);

%[psycho] = giveMe_Bayesian_Psycho(Param1*Param2,Param2);
[psycho] = giveMe_Bayesian_Psycho_Classes_MATLAB(alpha*noiseFreq2,noiseFreq2,epsilon,pend);

psycho1 = a*psycho(1,[1:6]);
psycho2 = psycho(1,[7:12]);

E=sum((psycho1-real_performance1).^2) + sum((psycho2-real_performance2).^2);   
% E=sum(abs(psycho1-true_performance1)) + sum(abs(psycho2-true_performance2));

% E=1/[sum((psycho-real_performance).^2)];  %% esto supone que a=1

% % % E=1/[sum((a*psycho1-real_performance1).^2) + sum((psycho2-real_performance2).^2)];
% E=1/[sum(abs(a*psycho1-true_performance1)) + sum(abs(psycho2-true_performance2))];

% E
% [real_performance; psycho]



end

