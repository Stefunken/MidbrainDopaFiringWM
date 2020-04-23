function [psycho] = give_me_psycho_classes(noiseFreq1,noiseFreq2,epsilon,pend)

% weber_factor_f2 puede variar entre 0.01 y 0.2
% weber_factor_f1 tiene que ser 2 o 3 veces mas grande del weber_factor_1, yo diria que varia entre .02 y .6
% pero puedes dejar que los dos parametros varien entre .01 y .6
%real_performance = [99 98 99 93 87 85 78 94 98 99 98 98]/100;
%squared_error=sum((psycho - real_performance).^2);
%%
% close all
% clear all
% clc
% 
% noiseFreq1 = 2;
% noiseFreq2 = 4;

sampleFreq1 = [34    30    24    18    14    10];  
sampleFreq2 = [44    38    32    26    22    18    16    10     8     6 ];  
           

binFreq = 1;           
freqObs = 1:binFreq:100;

priorFreq1 = 1/size(sampleFreq1,2)*ones(size(sampleFreq1));
priorFreq2 = 1/size(sampleFreq2,2)*ones(size(sampleFreq2));
priorFreq2(1,[4 5]) = 2*priorFreq2(1,[4 5]);
priorFreq2 = priorFreq2/sum(priorFreq2);


probObsMatrix1 = zeros(size(sampleFreq1,2),size(freqObs,2)); 
probObsMatrix2 = zeros(size(sampleFreq2,2),size(freqObs,2)); 



for i=1:size(sampleFreq1,2)
     
    mean1 = sampleFreq1(1,i);
    sigma1 = noiseFreq1;

    probObsMatrix1(i,:) = normpdf(freqObs,mean1,sigma1); 
end

for i = 1:size(sampleFreq2,2)
    
    mean2 = sampleFreq2(1,i);
    sigma2 = noiseFreq2;
    
    probObsMatrix2(i,:) = normpdf(freqObs,mean2,sigma2); 

end
 
probObsMatrix1 = probObsMatrix1./repmat(sum(probObsMatrix1,2),1,size(freqObs,2));
probObsMatrix2 = probObsMatrix2./repmat(sum(probObsMatrix2,2),1,size(freqObs,2));

 
%posteriorMatrix1 = probObsMatrix1.*repmat(priorFreq1',1,size(freqObs,2));
posteriorMatrix1 = probObsMatrix1.*repmat(priorFreq1',1,size(freqObs,2));
posteriorMatrix1 = posteriorMatrix1./repmat(sum(posteriorMatrix1,1),size(sampleFreq1,2),1);

%posteriorMatrix2 = probObsMatrix2.*repmat(priorFreq2',1,size(freqObs,2));
posteriorMatrix2 = probObsMatrix2.*repmat(priorFreq2',1,size(freqObs,2));
posteriorMatrix2 = posteriorMatrix2./repmat(sum(posteriorMatrix2,1),size(sampleFreq2,2),1);



%epsilon = 0.01;
transitionMatrix = zeros(size(sampleFreq1,2),size(sampleFreq2,2));
transitionMatrix(1:size(sampleFreq1,2),1:size(sampleFreq1,2)) = (0.5-4*epsilon)*eye(size(sampleFreq1,2));
transitionMatrix(3:end,size(sampleFreq1,2)+1:end) = (0.5-4*epsilon)*eye(size(sampleFreq2,2)-size(sampleFreq1,2));
transitionMatrix(1,4) = (0.5-4*epsilon);
transitionMatrix(2,5) = (0.5-4*epsilon);
transitionMatrix(transitionMatrix==0) = epsilon;

prob1Great2GivenObs = zeros(size(freqObs,2));
prob1Small2GivenObs = zeros(size(freqObs,2));

for i=1:size(sampleFreq1,2)
    
    for j=1:size(sampleFreq2,2)
        if sampleFreq1(1,i)>sampleFreq2(1,j)
            prob1Great2GivenObs = prob1Great2GivenObs + posteriorMatrix1(i,:)'*transitionMatrix(i,j)/priorFreq2(1,j)*posteriorMatrix2(j,:);
            prob1Small2GivenObs = prob1Small2GivenObs;
        else
            prob1Great2GivenObs = prob1Great2GivenObs;
            prob1Small2GivenObs = prob1Small2GivenObs + posteriorMatrix1(i,:)'*transitionMatrix(i,j)/priorFreq2(1,j)*posteriorMatrix2(j,:);
        end
    end
    
end

normAux = prob1Great2GivenObs + prob1Small2GivenObs;
prob1Great2GivenObs = prob1Great2GivenObs./normAux;
prob1Small2GivenObs = prob1Small2GivenObs./normAux;

% a=0;
% for i=1:size(sampleFreq1,2)
%     a = a + posteriorMatrix1(i,1)'*sum(posteriorMatrix2(sampleFreq2'<sampleFreq1(1,i),1),1);   
% end

%prob1Great2GivenFreq = probObsMatrix1*(prob1Great2GivenObs>0.5)*probObsMatrix2';
%prob1Small2GivenFreq = probObsMatrix1*(prob1Small2GivenObs>0.5)*probObsMatrix2';
prob1Great2GivenFreq = probObsMatrix1*sigmf(prob1Great2GivenObs,[pend 0.5])*probObsMatrix2';
prob1Small2GivenFreq = probObsMatrix1*sigmf(prob1Small2GivenObs,[pend 0.5])*probObsMatrix2';


normAux = prob1Great2GivenFreq + prob1Small2GivenFreq;
prob1Great2GivenFreq = prob1Great2GivenFreq./normAux;
prob1Small2GivenFreq = prob1Small2GivenFreq./normAux;
 
selectedElements = [1:6 1:6; 1:6 4 5 7:10];

performance = zeros(1,12);
for i=1:6
performance(1,i) =  1-prob1Great2GivenFreq(selectedElements(1,i),selectedElements(2,i));
end
for i=7:12
    performance(1,i) =  prob1Great2GivenFreq(selectedElements(1,i),selectedElements(2,i));
end

psycho=performance;


%%

end