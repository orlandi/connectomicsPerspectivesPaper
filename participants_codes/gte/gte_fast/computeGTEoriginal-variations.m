%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% computeGTEoriginal-variations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%

clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DEFINE THE CHALLENGE FOLDER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
currentInputFile = mfilename('fullpath');
% In case we decide to run the code by blocks
if(isempty(currentInputFile))
    challengeFolder = '~/research/connectomicsPerspectivesPaper/participants_codes/gte/gte_fast';
else
    challengeFolder = fileparts(currentInputFile);
end
cd(challengeFolder);

% 'Pathify'
cd(challengeFolder);
addpath(genpath([pwd filesep '../../../matlab/']));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DEFINE THE INPUT FILES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
networkName = 'valid';
baseFile = [networkName '_noise?_ls?_rate?'];
fluorescenceFile = ['../../../datasets/original-variations/' networkName filesep 'fluorescence_' baseFile '.txt'];

it1List = 1:3; %noise
it2List = 1:3; %ls
it3List = 1:3; %rate

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DEFINE THE OUTPUT FILES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scoresFile = ['../../../participants_results/gte/original-variations/' networkName filesep 'scoresGTEInPlace_' baseFile '.csv'];


%% Compute GTE over all iterations
overwrite = false;
% if(strcmp(version('-release'),'2015a'))
%     parpool(3);
% else
%     matlabpool(3);
% end

for it1 = 1:length(it1List)
    for it2 = 1:length(it2List)
        %parfor it3 = 1:length(it3List)
        for it3 = 1:length(it3List)
            
            currentInputFile = fluorescenceFile;
            currentInputFile = regexprep(currentInputFile,'?',num2str(it1List(it1)),'once');
            currentInputFile = regexprep(currentInputFile,'?',num2str(it2List(it2)),'once');
            currentInputFile = regexprep(currentInputFile,'?',num2str(it3List(it3)),'once');
            
            currentOutputFile = scoresFile;
            currentOutputFile = regexprep(currentOutputFile,'?',num2str(it1List(it1)),'once');
            currentOutputFile = regexprep(currentOutputFile,'?',num2str(it2List(it2)),'once');
            currentOutputFile = regexprep(currentOutputFile,'?',num2str(it3List(it3)),'once');
            
            % If overwrite is false and the output exists, skip
            [~, tmp, ~] = fileparts(currentOutputFile);
            if(~overwrite && exist(currentOutputFile,'file'))
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                MSG = ['Output file: ' tmp ' already exists. Skipping... '];
                disp([datestr(now, 'HH:MM:SS'), ' ', MSG]);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                continue;
            end
            
            [~, tmp, ~] = fileparts(currentInputFile);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            MSG = ['Loading Fluorescence from: ', tmp];
            disp([datestr(now, 'HH:MM:SS'), ' ', MSG]);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
            clear F;
            global F;
            F = load(currentInputFile);
            %[D, G] = discretizeFluorescenceSignal(F, 'debug', false, 'conditioningLevel', 0.15, 'bins', [-10,0.12,10]);
            G = discretizeFluorescenceSignalInPlace('debug', false, 'conditioningLevel', 0.15, 'bins', [-10,0.12,10]);
            
            P = calculateJointPDFforGTEfast(F, G,'IFT', true);
            GTE = calculateGTEfromJointPDF(P);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            MSG = 'Storing scores...';
            disp([datestr(now, 'HH:MM:SS'), ' ', MSG]);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
            writeNetworkScoresInCSV(currentOutputFile, GTE, networkName);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MSG = 'Done!';
disp([datestr(now, 'HH:MM:SS'), ' ', MSG]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



