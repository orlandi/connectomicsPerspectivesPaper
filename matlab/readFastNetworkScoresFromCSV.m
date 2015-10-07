function scores = readFastNetworkScoresFromCSV(filename)
%scores = readFastNetworkScoresFromCSV(filename)
% Quickly reads the scores from the csv file.
% WARNING: It assumes the file is correct, i.e., 2 columns
% I,J iterating for i ( for j ) 
weights = csvread(filename,1,1);
scores = reshape(weights, [sqrt(length(weights)), sqrt(length(weights))]);