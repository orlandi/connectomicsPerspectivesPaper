function GTE = computeGTEfast(D, G, debug_)
%GTE = computeGE(F)
%GTE = computeGE(F, debug_)
% Baseline method to compute scores based on 
%    (Stetter 2013) Stetter, O., Battaglia, D., Soriano, J. & Geisel, T. 
%    Model-free reconstruction of excitatory neuronal connectivity from 
%    calcium imaging signals. PLoS Comput Biol 8, e1002653 (2012).
% Set flag debug_ to true to visualize histograms.

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

if nargin<3,
    debug_ = false; 
end

%% Discretize the fluorescence signal
% [hits, pos] = hist(avgF, 100);
% [~, idx] = max(hits);
% CL = pos(idx)+0.05;
% G = (avgF >= CL)+1;
% D = double(F>params.thres);
% [D, G] = discretizeFluorescenceSignal(F, 'debug', debug_, 'conditioningLevel', 0.25, 'bins', [-10,0.12,10]);
% D = F;
% avgF = mean(F,2);
% [hits, pos] = hist(avgF, 100);
% [~, idx] = max(hits);
% CL = pos(idx)+0.05;
% G = (avgF >= CL)+1;
% D = zeros(size(F));
% for i=1:size(F, 2)
%     qt = quantile(F(:, i), [0.25 0.5, 0.75, 1]);
%     D(:, i) = D(:, i)+(F(:, i)>=qt(1));
%     D(:, i) = D(:, i)+(F(:, i)>=qt(2));
%     D(:, i) = D(:, i)+(F(:, i)>=qt(3));
% end
%% Calculate the joint PDF
P = calculateJointPDFforGTEfast(D, G);

%% Calculate the GTE from the joint PDF
GTE = calculateGTEfromJointPDF(P, 'returnFull', true);
