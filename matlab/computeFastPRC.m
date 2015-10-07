function [AUC, precision, recall, raw] = computeFastPRC(groundTruth, scores,  recallValues)

positivesMatrix = groundTruth > 0;
%negativesMatrix = groundTruth == 0;

[~, sortedIdx] = sort(scores(:),'descend');
sortedIdx = sortedIdx(1:(length(sortedIdx)-sqrt((length(sortedIdx)))));
cumPositives = cumsum(positivesMatrix(sortedIdx))/sum(positivesMatrix(:));
cumPrecision =  cumsum(positivesMatrix(sortedIdx))./(1:length(sortedIdx))';

raw.recall = full(cumPositives);
raw.precision = full(cumPrecision);
AUC = trapz(raw.recall, raw.precision);

recall = recallValues;
precision = zeros(size(recall));
for i = 1:length(recall)
    precision(i) = raw.precision(find(raw.recall >= recall(i), 1, 'first'));
end
