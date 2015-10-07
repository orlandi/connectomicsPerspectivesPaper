function [AUC, FPR, TPR, raw] = computeFastROC(groundTruth, scores,  FPRvalues)

positivesMatrix = groundTruth > 0;
negativesMatrix = groundTruth == 0;
% Remove the diagonal elements
negativesMatrix(logical(eye(size(negativesMatrix)))) = 0;

[~, sortedIdx] = sort(scores(:),'descend');

cumPositives = cumsum(positivesMatrix(sortedIdx))/sum(positivesMatrix(:));
cumNegatives = cumsum(negativesMatrix(sortedIdx))/sum(negativesMatrix(:));

raw.FPR = full(cumNegatives);
raw.TPR = full(cumPositives);
AUC = trapz(raw.FPR, raw.TPR);

FPR = FPRvalues;
TPR = zeros(size(FPR));
for i = 1:length(FPR)
    TPR(i) = raw.TPR(find(raw.FPR >= FPR(i), 1, 'first'));
end
