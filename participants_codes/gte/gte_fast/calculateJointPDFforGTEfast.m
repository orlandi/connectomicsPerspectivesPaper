function P = calculateJointPDFforGTEfast(D, G, varargin)
% CALCULATEJOINTPDFFORGTE calculates the joint PDF required for the GTE
% computation. Entires are of the form P(i,j,j_now,j_past,i_past). Same
% order as in the paper.
%
% USAGE:
%    P = calculateJointPDFforGTE(D, varargin)
%
% INPUT arguments:
%    D - A vector containing the binned  signal (rows for
%    samples, columns for neurons)
%    G - A vector containing the binned average signal based on the
%    conditioning level, i.e., 1 if the average signal is below CL and 2 if
%    above.
%
% INPUT optional arguments ('key' followed by its value): 
%    'markovOrder' - Markov Order of the process (default 2).
%
%    'IFT' - true/false. If true includes IFT (Instant Feedback Term)
%    (default true).
%    'Nsamples' - Number of samples to use. If empty, it will use the whole
%    vector (default empty).
%
%    'debug' true/false. Prints out some useful information (default true).
%
%
% OUTPUT arguments:
%    P - The joint PDF (unnormalized, divide sum(P(i,j,:)) to normalize.
%
% EXAMPLE:
%    P = calculateJointPDFforGTE(D);
%
%    (Stetter 2013) Stetter, O., Battaglia, D., Soriano, J. & Geisel, T. 
%    Model-free reconstruction of excitatory neuronal connectivity from 
%    calcium imaging signals. PLoS Comput Biol 8, e1002653 (2012).

%==========================================================================
% Package: ChaLearn Connectomics Challenge Sample Code
% Source: http://connectomics.chalearn.org
% Authors: Javier Orlandi
% Date: Dec 2013
% Last modified: NA
% Contact: causality@chalearn.org
% License: GPL v3 see http://www.gnu.org/licenses/
%==========================================================================
% Modified by Chenyang Tao (cytao@fudan.edu.cn)
% Date: May 2014
%==========================================================================

%%% Assign defuault values
params.markovOrder = 2;
params.IFT = true;
params.debug = true;
params.Nsamples = [];
params = parse_pv_pairs(params,varargin);

% Just in case
if(params.IFT)
    IFT = 1;
else
    IFT = 0;
end
k = params.markovOrder;

% Redefine the vectors based on the number of samples
if(~isempty(params.Nsamples))
    D = D(1:Nsamples, :);
    G = G(1:Nsamples);
end

%bins = length(unique(D(~isnan(D))));
bins = max(D(:));

% Calculate the amount of dimensions
dims = 2*k;
if(IFT)
    dims = dims + 1;
end
% dims = [size(D,2), size(D,2), bins*ones(1, dims), length(unique(G))];
% Pnumel = 1:prod(dims);
dims = [bins*ones(1, dims), length(unique(G)), size(D,2), size(D,2)];
Pnumel = [1:prod(dims(1:end-2))]';

disp(dims)

% Create the multidimensional array to store the probability distribution
% Structure: (I, J, Jnow, Jpast, Ipast, G) Past goes in reverse order: now,
% now-1, now-2, ... Although it doesn't really matter, since all
% sums extend over all the past entries.
P = zeros(dims);
sizeP = double(size(P));
ndimsP = ndims(P);
% To access the matrix with a single index
multipliers = [1 cumprod(sizeP(1:end-1))]';
mul = multipliers(1:end-2);

% Define some internal variables
totalEntries = (size(D,2).^2-size(D,2))/2;
currentEntry = 0;
firstSample = k+1;
if(params.debug)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MSG = 'Generating the joint probability distribution...';
    disp([datestr(now, 'HH:MM:SS'), ' ', MSG]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

n = size(D, 2);
MD_list1 = cell(n, 1);
MD_list2 = cell(n, 1);

for i=1:n
    Di = D(:, i);
    multDi(:, 1) = Di(firstSample:end);
    for l=1:k
            multDi(:, l+1) = Di((firstSample-l):(end-l));
    end
    mDi1 = (multDi-1)*mul(1:k+1);
    mDi2 = (multDi(:,(2-IFT):(end-IFT))-1)*mul(k+2:end-1);
    MD_list1{i} = mDi1;
    MD_list2{i} = mDi2;
end

validSamples = firstSample:size(D,1);
multDi = zeros(length(validSamples), k+1);
multDj = zeros(length(validSamples), k+1);
ONES = ones(1, length(validSamples));
sz = [Pnumel(end) 1];
GV = G(validSamples);
mGV = mul(end)*(GV-1)+1;
% sz
for i = 1:n
%     Di = D(:, i);
%     multDi(:, 1) = Di(firstSample:end);
%     for l=1:k
%             multDi(:, l+1) = Di((firstSample-l):(end-l));
%     end
%     mDi1 = (multDi-1)*mul(1:k+1);
%     mDi2 = (multDi(:,(2-IFT):(end-IFT))-1)*mul(k+2:end-1);
    for j = (i+1):n
%         Dj = D(:,j);
        % multD stores the delayed version of D, with columns (Di, Di-1,
        % Di-2...) to have it ready for the probabilities
%         multDj(:, 1) = Dj(firstSample:end);
%         for l = 1:k
%             multDj(:, l+1) = Dj((firstSample-l):(end-l));
%         end
%         coordsIJ = [i*ones(size(multDi,1),1), j*ones(size(multDi,1),1), multDj(:,1:end), multDi(:,(2-IFT):(end-IFT)), G(validSamples)];
%         indxIJ = (coordsIJ-1)*multipliers+1;
%         P(:) = P(:) + histc(indxIJ, Pnumel);
%         coordsIJ = [multDj(:,1:end)];
%         indxIJ = (coordsIJ-1)*mul(1:k+1)+mDi2+mGV+1;
        indxIJ = MD_list1{j}+MD_list2{i}+mGV;
        displace = (i-1)*multipliers(end-1)+(j-1)*multipliers(end);
%         hc = histc(indxIJ, Pnumel);
        hc = accumarray(indxIJ, ONES, [sz]);
        idx = Pnumel+displace;
%         size(P(idx))
%         size(hc)
        P(idx) = P(idx)+hc;
%         P(:) = P(:) + histc(indxIJ, Pnumel);
%         coordsJI = [j*ones(size(multDj,1),1), i*ones(size(multDi,1),1), multDi(:,1:end), multDj(:,(2-IFT):(end-IFT)), G(validSamples)];
%         indxJI = (coordsJI-1)*multipliers+1;
%         P(:) = P(:) + histc(indxJI, Pnumel);
%         coordsJI = [multDj(:,(2-IFT):(end-IFT))];
%         indxJI = (coordsJI-1)*mul(k+2:end-1)+mDi1+mGV+1;
        indxJI = MD_list2{j}+MD_list1{i}+mGV;
        displace = (j-1)*multipliers(end-1)+(i-1)*multipliers(end);
%         hc = histc(indxJI, Pnumel);
        hc = accumarray(indxJI, ONES, [sz]);
        idx = Pnumel+displace;
        P(idx) = P(idx)+hc;

        currentEntry = currentEntry+1;
        if(params.debug && (mod(currentEntry, floor(totalEntries/100)) == 0));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            MSG = sprintf('%d%%...', round(currentEntry/totalEntries*100));
            disp([datestr(now, 'HH:MM:SS'), ' ', MSG]);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
end
%fprintf('\n');

if(params.debug)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MSG = 'Done!';
    disp([datestr(now, 'HH:MM:SS'), ' ', MSG]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

lendims = length(dims);
P = permute(P, [lendims-1 lendims 1:lendims-2]);