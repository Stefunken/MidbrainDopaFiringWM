function [ROC, p, latency] = rocindex_permTest(A,B,varargin)
% rocindex_permTest()  Calculates the probability of succesfully distinguishing values coming from distribution A from
%            values coming from distribution B.
%
%   [ROC ci latency] = rocindex(A,B)
%   [ROC ci latency] = rocindex(A,B,'optionName',optionValue,...)
%   [ROC ci latency] = rocindex(A,B,'ALPHA',.05,'NUMOFCONSBINS',3)
%
%   Inputs:
%   A,B            Must be matrices with the same number of columns. NaN elements will be removed.
%
%   Options:
%   ALPHA          Used to calculate the confidence intervals. For example,and ALPHA=0.05 (default) will
%                  produce 95% confidence intervals.
%   NUMOFCONSBINS  Number of consecutive bins (3 by default) that must be significantly away from 0.5 to
%                  consider it at the onset of response.
%
%   Output:
%   ROC            Receiver Operating Characteristic.
%   CI             Confidence interval (95% by default)
%   LATENCY        Index of the firs of n consecutive bins with a ROC index significantly away from 0.5
%
%   If A and B are matices, a ROC index will be calculated for each pair of columns columns ROC(A(:,1),B(:,1)),
%   ROC(A(:,2),B(:,2)), etc.
%
%   vhdlf 2008


% Make sure that if A and B are vectors, they are column vectors.
if isvector(A)
    A = A(:);
    B = B(:);
else
    % If matrices, make sure that the number of columns are the same.
    if size(A,2) ~= size(B,2)
        error('rocindex(A,B,...): Number of columns of A and B must be the same.')
    end
end

% Initialize the output matrix
ROC = zeros(1,size(A,2));        %% size(A,2): the # of columns of A. size(A,1): the # of rows of A.
p  = zeros(1,size(A,2));


% Loop through each colum (likely a time slice).
for t = 1:size(A,2)
    % Compare each element of matrix A to each element of matrix B to construct the comparison matrix.
    columnOfb = B(:,t);               % Select a colum of B.
    columnOfb(isnan(columnOfb)) = []; % Remove nans.
    columnOfa = A(:,t);               % Select a colum of A.
    columnOfa(isnan(columnOfa)) = []; % Remove nans.
    
    % Initialize the comparison matrices and the ROC output vector.
    la = length(columnOfa);
    lb = length(columnOfb);
    LarOrEq   = zeros(lb,la);
    Equal     = zeros(lb,la);
    Different = zeros(lb,la);
    
    % Loop through each element of columnOfa and compare it to each element of columnOfb
    for e = 1:la
        LarOrEq(:,e)   = columnOfa(e)>=columnOfb;
        Equal(:,e)     = columnOfa(e)==columnOfb;
        Different(:,e) = columnOfa(e)~=columnOfb;
    end
    mtrx = Different + Equal/2;
    ComparisonMtrx = mtrx.*LarOrEq;
    ROC(t) = mean(mean(ComparisonMtrx));
    
    % If confidence interval are required.
    if nargout>1
        % Set the default parameters or get its values from the VARARGIN input.
        n_perm = 1000;
        aux = 0;
        for i_perm=1:n_perm
            C = [B(:,t);A(:,t)]';
            C_rand = C(randperm(length(C)));
            columnOfb = C_rand(1:size(B,1))';
            C_rand(1:size(B,1)) = [];
            columnOfa = C_rand';
            
            % Initialize the comparison matrices and the ROC output vector.
            la = length(columnOfa);
            lb = length(columnOfb);
            LarOrEq   = zeros(lb,la);
            Equal     = zeros(lb,la);
            Different = zeros(lb,la);
            
            % Loop through each element of columnOfa and compare it to each element of columnOfb
            for e = 1:la
                LarOrEq(:,e)   = columnOfa(e)>=columnOfb;
                Equal(:,e)     = columnOfa(e)==columnOfb;
                Different(:,e) = columnOfa(e)~=columnOfb;
            end
            mtrx = Different + Equal/2;
            ComparisonMtrx = mtrx.*LarOrEq;
            ROC_perm = mean(mean(ComparisonMtrx));
            
            aux = aux+(ROC_perm>=ROC(t));
        end
        p(1,t) = aux/n_perm;
        disp(['t-' num2str(t) '-of-' num2str(size(p,2))]) 
    end
end

% If the "latency" output is requested, calculate it.
if nargout ==3
    numOfConsecutiveBins = getArgumentValue('numOfConsBins',5,varargin{:});
    significance_p = getArgumentValue('alpha',0.05,varargin{:});
    significantlyAwayFromPointFive = p<significance_p; % (ci(1,:)<0.5 | ci(2,:)>0.5);
    significantlyAwayFromPointFive = num2str(significantlyAwayFromPointFive(:))';
    % s='111', for example, will look for 3 consequitive bins in which the confidence intervals do not include 0.5
    s = num2str(ones(numOfConsecutiveBins,1));
    latency = min(strfind(significantlyAwayFromPointFive,s'));
end


% Note: The following code looks uses no "for" loop, but it gives out of memory errors if vectors are too long (>~4000 elements).
%
% a = repmat(a(:)',length(b),1);  % Creates a matrix by horizontally tiling the vector a,
%                                 % e.g. turns [1 2 3] into [1 2 3; 1 2 3;1 2 3;...]
% b = repmat(b(:) ,1,length(a));  % Creates a matrix by vertically tiling the vector b,
%                                 % e.g. turns [1 2 3] into [[1 2 3]' [1 2 3]' [1 2 3]'...]
%
% LargerOrEqual = a>=b;
% EqualValues   = a==b;
% Different     = a~=b;
%
% ComparisonMatrix = (Different +  EqualValues/2) .* LargerOrEqual;
% ROC = mean(mean(ComparisonMatrix ))
end