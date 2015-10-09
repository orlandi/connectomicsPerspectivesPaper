%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% COMPUTEPARTICIPANTSTATISTICS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Computes the different statistics for a given participant

clear all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DEFINE THE CHALLENGE FOLDER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
currentFile = mfilename('fullpath');
% In case we decide to run the code by blocks
if(isempty(currentFile))
    challengeFolder = '~/research/connectomicsPerspectivesPaper';
else
    challengeFolder = fileparts(currentFile);
end

% 'Pathify'
cd(challengeFolder);
addpath(genpath([pwd filesep 'matlab']));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DEFINE THE INPUT FILES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
groundTruthFolder = [pwd filesep 'groundtruth'];
participantFolder = [pwd filesep 'participants_results' filesep 'aaagv'];
datasetFolder = 'small/normal-bursting';

participantName = 'AAAGV';

networkBaseFile = 'network_N100_CC0?_?.txt';
%scoresBaseFile = 'gte_N100_CC0?_?.csv';
scoresBaseFile = 'N100_CC0?_?-m=tuned-d=1.csv';


networkFile = [groundTruthFolder filesep datasetFolder filesep networkBaseFile];
scoresFile = [participantFolder filesep datasetFolder filesep scoresBaseFile ];

clusteringList = [2];
%clusteringList = [2 3 5];
networkList = 451;
%networkList = 451:468;
%networkList = 452;
inhibition_active = false;
%%
binsROC = 50;

AUCROClist = zeros(length(clusteringList), length(networkList));
AUCPRlist = zeros(length(clusteringList), length(networkList));
FPRvalues = [0 logspace(-4, 0, binsROC-1)];
TPRlist = zeros(length(clusteringList), length(networkList), binsROC);
meanTPR = cell(length(clusteringList), 1);
stdTPR = cell(length(clusteringList), 1);
meanAUCROC = zeros(length(clusteringList), 1);
stdAUCROC = zeros(length(clusteringList), 1);

%recallValues = [0 logspace(-4, 0, binsROC-1)];
recallValues = logspace(-3, 0, binsROC);
precisionList = zeros(length(clusteringList), length(networkList), binsROC);

meanPrecision = cell(length(clusteringList), 1);
stdPrecision = cell(length(clusteringList), 1);
meanAUCPR = zeros(length(clusteringList), 1);
stdAUCPR = zeros(length(clusteringList), 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ITERATE OVER THE NETWORKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for it1 = 1:length(clusteringList)
    for it2 = 1:length(networkList)
        currNetworkFile = networkFile;
        currNetworkFile = regexprep(currNetworkFile,'?',num2str(clusteringList(it1)),'once');
        currNetworkFile = regexprep(currNetworkFile,'?',num2str(networkList(it2)),'once');
        
        currScoresFile = scoresFile;
        currScoresFile = regexprep(currScoresFile,'?',num2str(clusteringList(it1)),'once');
        currScoresFile = regexprep(currScoresFile,'?',num2str(networkList(it2)),'once');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [~, tmp, ~] = fileparts(currNetworkFile);
        MSG = ['Processing network file ' tmp];
        disp([datestr(now, 'HH:MM:SS'), ' ', MSG]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Load the ground truth
        tmp = load(currNetworkFile);
        % Set inhibitory weights to 0 if inhibition was not active
        if(~inhibition_active)
            tmp(tmp(:,3) == -1,3) = 0;
        end
        groundTruth = sparse(tmp(:,1), tmp(:,2), tmp(:,3));
        
        % Load the scores
        scores = readFastNetworkScoresFromCSV(currScoresFile);
        
        [AUC, FPR, TPR, ~] = computeFastROC(groundTruth, scores, FPRvalues);
        AUCROClist(it1, it2) = AUC;
        TPRlist(it1, it2, :) = TPR;

        [AUC, precision, recall, ~] = computeFastPRC(groundTruth, scores, recallValues);
        AUCPRlist(it1, it2) = AUC;
        precisionList(it1, it2, :) = precision;
    end
    meanTPR{it1} = squeeze(mean(TPRlist(it1, :, :)));
    stdTPR{it1} = squeeze(std(TPRlist(it1, :, :)));
    meanAUCROC(it1) = mean(AUCROClist(it1, :));
    stdAUCROC(it1) = std(AUCROClist(it1, :));
    
    meanPrecision{it1} = squeeze(mean(precisionList(it1, :, :)));
    stdPrecision{it1} = squeeze(std(precisionList(it1, :, :)));
    meanAUCPR(it1) = mean(AUCPRlist(it1, :));
    stdAUCPR(it1) = std(AUCPRlist(it1, :));
end


%% ROC and PR curves together
createFigure(20, 10);
ax = multigap_subplot(1, 2, 'gap_C', 0.1, 'margin_LR', [0.075 0.075], 'margin_TB', [0.15 0.15]);

axes(ax(1));
hold on;
hl = [];
for it1 = 1:length(clusteringList)
    hl = [hl; plot(FPRvalues,squeeze(meanTPR{it1}))];
    h = boundedline(FPRvalues, meanTPR{it1}, 1.96*stdTPR{it1}/sqrt(length(networkList)), 'cmap', get(hl(it1), 'Color'), 'alpha');
    set(hl(it1), 'DisplayName', sprintf('CC = %.1f AUC = %.3f', clusteringList(it1)*0.1, meanAUCROC(it1)));
    
end
xlim([0 1]);
ylim([0 1]);
plot([0 1], [0, 1],'k--')
box on;
axis square;
xlabel('false positive ratio');
ylabel('false positive ratio');
legend(hl,'Location','SE');
legend('boxoff');
title('ROC');

% Precision recall curves
axes(ax(2));
hold on;
hl = [];
for it1 = 1:length(clusteringList)
    hl = [hl; plot(recallValues, squeeze(meanPrecision{it1}))];
    h = boundedline(recallValues, meanPrecision{it1}, 1.96*stdPrecision{it1}/sqrt(length(networkList)), 'cmap', get(hl(it1), 'Color'), 'alpha');
    set(hl(it1), 'DisplayName', sprintf('CC = %.1f AUC = %.3f', clusteringList(it1)*0.1, meanAUCPR(it1)));
end

xlim([0 1]);
ylim([0 1]);
plot([1e-3 1], [1, 1]*0.1,'k--');
box on;
axis square;
xlabel('recall');
ylabel('precision');
set(gca,'XScale','log')
legend(hl,'Location','NE');
legend('boxoff');
title('precision-recall');

mtit(sprintf('dataset: %s -- participant: %s', datasetFolder, participantName), 'yoff', 0.1);

%%
fileName = ['figures/ROCPR_', strrep(datasetFolder, filesep, '_'), '_', participantName , '.pdf'];
export_fig(fileName, '-OpenGL');


close(gcf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~, tmp, ~] = fileparts(currNetworkFile);
MSG = ['ROC and PR figure stored ' tmp];
disp([datestr(now, 'HH:MM:SS'), ' ', MSG]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

