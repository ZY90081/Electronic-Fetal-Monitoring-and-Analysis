clc;
close all;
clear all;
% warning off

%% Read dataset
% read Czech data
load('CTUdataAll.mat');
[N,~] = size(CTUdata);  % number of FHR recordings
L = 21620; % Maximum time length

RawFHR = NaN(L,N);
RawUA = NaN(L,N);
IDseq = NaN(N,1);
ph = NaN(N,1);
apgar1 = NaN(N,1);
apgar5 = NaN(N,1);
BDecf = NaN(N,1);
for n = 1:N
    temp = length(CTUdata{n,1}.rawFHR);
    RawFHR(1:temp,n) = CTUdata{n,1}.rawFHR;
    RawUA(1:temp,n) = CTUdata{n,1}.rawUA;
    IDseq(n) = CTUdata{n,1}.ID;
    ph(n) = CTUdata{n,1}.Param.pH;
    apgar1(n) = CTUdata{n,1}.Param.Apgar1;
    apgar5(n) = CTUdata{n,1}.Param.Apgar5;
    BDecf(n) = CTUdata{n,1}.Param.BDecf;
end
clear temp;

CzechUA = RawUA;

% read SBU data
RawUA_SBU = readmatrix('UA.csv');
RawFHR_SBU = readmatrix('FHR.csv');

SBUUA = RawUA_SBU';

%% Read annotation (Ground Truth)

GroundTruth_Czech_G1 = readmatrix('Czech Y_Y.csv');
GroundTruth_Czech_G2 = readmatrix('Czech Y_Y Y_M.csv');
GroundTruth_Czech_G3 = readmatrix('Czech Y_Y Y_M M_M Y_N.csv');
GroundTruth_Czech_G4 = readmatrix('Czech Y_Y Y_M M_M Y_N M_N.csv');

Score_Czech_1 = readmatrix('Czech Score 1.csv');
Score_Czech_2 = readmatrix('Czech Score 2.csv');
Score_Czech_3 = readmatrix('Czech Score 3.csv');
Score_Czech_4 = readmatrix('Czech Score 4.csv');

GroundTruth_SBU_G1 = readmatrix('SBU Y_Y.csv');
GroundTruth_SBU_G2 = readmatrix('SBU Y_Y Y_M.csv');
GroundTruth_SBU_G3 = readmatrix('SBU Y_Y Y_M M_M Y_N.csv');
GroundTruth_SBU_G4 = readmatrix('SBU Y_Y Y_M M_M Y_N M_N.csv');

Score_SBU_1 = readmatrix('SBU Score 1.csv');
Score_SBU_2 = readmatrix('SBU Score 2.csv');
Score_SBU_3 = readmatrix('SBU Score 3.csv');
Score_SBU_4 = readmatrix('SBU Score 4.csv');


CzechID = [1,10,15,39,107,120,136,143,160,202,294,338,352,426,459];
Czechlabel = ['g','p','g','m','a','m','b','g','a','p','b','a','m','b','p'];

SBUID = [596,726,757,783,2103,2105,2362,4879,5655,6696,7176,8149,8837,10601,10606];
SBUlabel = ['p','g','g','a','g','p','a','m','b','a','m','m','b','p','b'];

%% Parameters

% parameters for online processing
fs = 4;                 % sampling frequency (Hz)
delay = 5 * fs;         % delay of prcoessing: 5 secconds
minWin = 60 * fs;       % minimum length of processing: 60 seconds
maxWin = 10*60 * fs;    % maximum length of processing: 10 minutes

% parameters for pre-processing
medianLen = 15 * fs;    % length of median filtering: 15 seconds
[b,a] = butter(2,0.04/(fs/2));% design Butterworth low-pass filter： cutoff frequency 0.04Hz
valuemin = 0.1;         % minimum ua value for determining baseline
valuemax = 100;         % maximum ua value for determining baseline
consecLen = 10 * fs;    % maximum length of consecutive identical values for determining baseline
localmin = [];          % for saving local minimum

% parameters for candidate detection
%pointer = 0;            % initial pointer indicating the location of detection
%DetLen = 1*60 * fs;     % length of detection window : 1 minute
energydetLen = 2* fs;   % small window size for energy detector: 2 seconds
%energyStandard = 1e5;   % Normalization standard of energy
energyThr = 100;         % initial energy detection threshold
refineRes = 5*fs;        % resolution for refining edges : 2 sec
refineWindow = 15.*fs;  % window for searching optimal edges: 15 sec
diffDelta = [0.2:0.1:0.6]*60*fs;  %
%diffDeltaoff = [0.2:0.1:0.8]*60*fs;
%GLRTThr = 400;        % learn from annotation?
%NoiseModelParas = [0,0.6321,0.2641,0.2843];   % initial location,shape,scale,skew
%AGaussian = [40,3,2,2e4,3,2,2e4];  % initial para of Asymmetric Gaussian model.
template_rho = 10;    % for template-matching method
template_duration = 0:200:1200;   % range of template length
template_delta = 5*fs;      % 5 seconds
Method = 'Basic+AG+GP';       % method of classification

% parameters for post-processing
minConLen = 10*fs;     % minimum length of valid contractions
minConInt = 5*fs;      % minimum length of valid intervals between two contractions


% parameters for plotting
ShowLen = 10*60 * fs;   % length of display: 10 minutes
ymin = 0;ymax = 100;    % limitation of y-axis
ContractionsSaving = [];
Flag = [];



%% Processing (Czech)
fprintf('Czech\n');

rng('default')
rng(1);        % for controling random number generator

% randomly select test sets for cross validation
pclass = CzechID((Czechlabel=='p'));
bclass = CzechID((Czechlabel=='b'));
mclass = CzechID((Czechlabel=='m'));
aclass = CzechID((Czechlabel=='a'));
gclass = CzechID((Czechlabel=='g'));
kfold = 10;   
CV_TEST = zeros(kfold,5);    % saving indices for CV test
CV_TRAINING = zeros(kfold,10);  % saving indices for CV training
for i = 1:kfold
    CV_TEST(i,:) = [pclass(randsample(3,1)) bclass(randsample(3,1)) mclass(randsample(3,1)) aclass(randsample(3,1)) gclass(randsample(3,1))];
    CV_TRAINING(i,:) = CzechID(~ismember(CzechID,CV_TEST(i,:)));
end

for i = 1:kfold
    fprintf('This is the No.%d run.\n',i);
    
    % Training...
    fprintf('Training...\n');
    count_C = 1;  % for counting number of contractions
    count_N = 1;  % for counting number of non-contractions
    ContractionsCollection = [];
    NonContractionsCollection = [];
    NoiseCollection = [];
    for j = 1:size(CV_TRAINING,2)
        % extract raw signal
        id = CV_TRAINING(i,j);
        SIGua = CzechUA(:,id);
        SIGua = SIGua(~isnan(SIGua));
        Lua = length(SIGua);
        % preprocessing
        [Detua,locs] = Fun_UApreprocessing(SIGua,[fs,medianLen,0.04,valuemin,consecLen,valuemax]);
        % extract ground truth
        edge = GroundTruth_Czech_G1((GroundTruth_Czech_G1(:,1)==id),3:end);
        onsetTrue = edge(1,:);
        offsetTrue = edge(2,:);
        onsetTrue = onsetTrue(~isnan(onsetTrue));
        offsetTrue = offsetTrue(~isnan(offsetTrue));
        T = (Lua+1)./4./60;
        onsetTrue = round((onsetTrue + T)*60*4);
        offsetTrue = round((offsetTrue + T)*60*4); 
        % divide contractions and noncontraction segments according to GT1
        ContractionIdx = [];
        for k = 1:length(onsetTrue)
            ContractionIdx = [ContractionIdx,onsetTrue(k):offsetTrue(k)];
            ContractionsCollection{count_C} = Detua(onsetTrue(k):offsetTrue(k));
            count_C = count_C + 1;
        end
        NoncontractionIdx = 1:length(Detua);
        NoncontractionIdx(ContractionIdx)=[];
        NoiseCollection = [NoiseCollection, Detua(NoncontractionIdx)'];
        % detection for extracting non-contraction segments
        candidates = contraction_detector_Diffoperator_Energy(Detua,length(Detua),diffDelta,locs,energydetLen,energyThr,0);
        candidates = Fun_UApostprocessing(candidates,[minConInt,minConLen]);
        for k = 1:size(candidates,1)
            if length(intersect(candidates(k,1):candidates(k,2),ContractionIdx))/length(candidates(k,1):candidates(k,2))<0.5
            %if isempty(intersect(candidates(k,1):candidates(k,2),ContractionIdx))
                NonContractionsCollection{count_N} = Detua(candidates(k,1):candidates(k,2));
                count_N = count_N + 1;
            end
        end
    end
    % for template matching
%     [TemplateParas] = training_for_TemplateMatching(ContractionsCollection,template_rho);

    % for GLRT
%     [NoiseModelParas,AGaussian,GLRTClassifier] = training_for_GLRT(ContractionsCollection,NonContractionsCollection,NoiseCollection);
    % for GP hyperparameters test
%      [HyperParameters,PDFofHyperparameters,GPHTThr] = training_for_GPHT(ContractionsCollection);
    % for AGaussian model-based features
%     [NoiseModelParas,AGaussian,AGFClassifier] = training_for_AGFeatures(ContractionsCollection,NonContractionsCollection,NoiseCollection);
    
    % feature extraction and training
    [NoiseModelParas,AGaussian,Classifier] = training_com_features(ContractionsCollection,NonContractionsCollection,NoiseCollection,Method,i);
   

    % Testing...
    fprintf('Testing...\n');
    for j = 1:size(CV_TEST,2)
        fprintf('Czech ID:%d\n',CV_TEST(i,j));
        % extract raw signal
        id = CV_TEST(i,j);
        SIGua = CzechUA(:,id);
        SIGua = SIGua(~isnan(SIGua));
        Lua = length(SIGua);
        t=(1-Lua:0)./4./60;
        pointer = 0;
        
        ContractionsSaving = [];
        Flag = [];
        Score = [];
        
        %figure()
        for n = 1:numel(t)
            if n < minWin+delay
                continue;
            end
            
            received_signal = SIGua(1:n-delay);
            receivedLen = length(received_signal);
            % preprocessing
            [Detua,locs] = Fun_UApreprocessing(received_signal,[fs,medianLen,0.04,valuemin,consecLen,valuemax]);
            
            % edge detection
%             % method 1 Energy detector: update parameters
%             if any(Flag==1)
%                 energyThr = Fun_updateEnergyThr(Detua,ContractionsSaving,Flag,energydetLen);
%             end
                    
            % ================ when every new local minima found
            if ~isempty(locs) && (pointer<locs(end)) && (n ~= numel(t))
                % Edge Detection -------------------------------
                % method 1 Energy detector:
%                [~,candidates] = contraction_detector_Energy(Detua(pointer+1:locs(end)),[energydetLen,energyThr],pointer);
                
                % method 2 Difference operator:
%                [~,candidates] = contraction_detector_Diffoperator(Detua,receivedLen,diffDelta,locs,pointer);
                
                % method 3 Difference operator and energy detector:
                candidates = contraction_detector_Diffoperator_Energy(Detua,receivedLen,diffDelta,locs,energydetLen,energyThr,pointer);
                candidates = Fun_UApostprocessing(candidates,[minConInt,minConLen]); % Post-processing


                % Contraction Identification -----------------------

                [flag,prob] = contraction_detector_classification(Detua,candidates,NoiseModelParas,AGaussian,Classifier,Method);

            
                if ~isnan(candidates)
                    if ~isempty(ContractionsSaving)&& ~isempty(intersect(candidates(1,1):candidates(1,2),ContractionsSaving(end,1):ContractionsSaving(end,2)))
                        ContractionsSaving(end,:) = [];
                        Flag(end) = [];
                        Score(end) = [];
                    end                 
                    ContractionsSaving = [ContractionsSaving;candidates];
                    Flag = [Flag,flag];
                    Score = [Score,prob];
                    pointer = candidates(end,1);
                end
            elseif n == numel(t)
                % method 1 Energy detector:
%                [~,candidates] = contraction_detector_Energy(Detua(pointer+1:receivedLen),[energydetLen,energyThr],pointer);
                % method 2 Difference operator:
%                [~,candidates] = contraction_detector_Diffoperator(Detua,receivedLen,diffDelta,locs,pointer);
                % method 3 Difference operator and energy detector:
                candidates = contraction_detector_Diffoperator_Energy(Detua,receivedLen,diffDelta,locs,energydetLen,energyThr,pointer);
                candidates = Fun_UApostprocessing(candidates,[minConInt,minConLen]); % Post-processing

                
                % Contraction Identification -----------------------
                [flag,prob] = contraction_detector_classification(Detua,candidates,NoiseModelParas,AGaussian,Classifier,Method);
                     
                % method: Template matching:
                % candidates = contraction_detector_Template(Detua,TemplateParas,template_delta,template_rho,minConInt,minConLen,pointer);

                if ~isnan(candidates)
                    if ~isempty(ContractionsSaving)&& ~isempty(intersect(candidates(1,1):candidates(1,2),ContractionsSaving(end,1):ContractionsSaving(end,2)))
                        ContractionsSaving(end,:) = [];
                        Flag(end) = [];
                        Score(end) = [];
                    end
                    ContractionsSaving = [ContractionsSaving;candidates];
                    Flag = [Flag,flag];
                    Score = [Score,prob];
                end
                
            end
            
            
            %     T = (length(SIGua)+1)./4./60;
            %     onsetTrue = round((onsetTrue + T)*60*4);
            %     offsetTrue = round((offsetTrue + T)*60*4);
            
            
            %         % =================== plotting
            %         plot(t(1:n),SIGua(1:n),'k','LineWidth',1); hold on
            %         plot(t(1:n-delay),Shapeua,'r','LineWidth',1);
            %         plot(t(1:n-delay),restingtone,'b','LineWidth',1);
            %         plot(t(1:n-delay),Detua,'c','LineWidth',1);
            %
            %         for k = 1:length(onsetTrue)
            %             if offsetTrue(k)<= n-delay
            %                 plot(t(onsetTrue(k)):0.1:t(offsetTrue(k)),95*ones(1,length(t(onsetTrue(k)):0.1:t(offsetTrue(k)))),'r-','LineWidth',6);
            %             end
            %         end
            %
            %         for k = 1:size(ContractionsSaving,1)
            %             patch([t(ContractionsSaving(k,1)) t(ContractionsSaving(k,2)) t(ContractionsSaving(k,2)) t(ContractionsSaving(k,1))], [150 150 0 0], 'y', 'FaceAlpha', .3);
            %         end
            %
            %         hold off;
            %         if n <= max(ShowLen, maxWin+delay)
            %             axis([t(1),t(1)+ShowLen/60/fs, ymin, ymax]);
            %         else
            %             axis([t(n)-0.8*ShowLen/60/fs,t(n)+0.2*ShowLen/60/fs, ymin, ymax]);
            %         end
            %         %             ylabel('TOCO UA (mmHg)');
            %         %             xlabel('Time (mins)');
            %         %             grid on;
            %         drawnow
            
        end
        
        UCIResult{i,j}.ID = id;
        UCIResult{i,j}.Contractions = ContractionsSaving;
        UCIResult{i,j}.Flag = Flag;   
        UCIResult{i,j}.Score = Score;
        
%         % plotting
%         figure()
%         plot(SIGua); hold on;
%         for k = 1:size(ContractionsSaving,1)
%             if Flag(k)== 1
%                 patch([ContractionsSaving(k,1) ContractionsSaving(k,2) ContractionsSaving(k,2) ContractionsSaving(k,1)], [150 150 0 0], 'y', 'FaceAlpha', .3);
%             else
%                 patch([ContractionsSaving(k,1) ContractionsSaving(k,2) ContractionsSaving(k,2) ContractionsSaving(k,1)], [150 150 0 0], [0.5,0.5,0.5], 'FaceAlpha', .3);
%             end
%             text(ContractionsSaving(k,1)+16,5,sprintf('%.2f', Score(k)));
%             
%         end
%         
%         edge = Score_Czech_1((Score_Czech_1(:,1)==id),3:end);
%         onsetTrue = edge(1,:);
%         offsetTrue = edge(2,:);
%         onsetTrue = onsetTrue(~isnan(onsetTrue));
%         offsetTrue = offsetTrue(~isnan(offsetTrue));
%         T = (Lua+1)./4./60;
%         onsetTrue = round((onsetTrue + T)*60*4);
%         offsetTrue = round((offsetTrue + T)*60*4);
%         for k = 1:length(onsetTrue)
%             plot(onsetTrue(k):offsetTrue(k),95*ones(1,length(onsetTrue(k):offsetTrue(k))),'y-','LineWidth',6);
%         end
%         
%         edge = Score_Czech_2((Score_Czech_2(:,1)==id),3:end);
%         onsetTrue = edge(1,:);
%         offsetTrue = edge(2,:);
%         onsetTrue = onsetTrue(~isnan(onsetTrue));
%         offsetTrue = offsetTrue(~isnan(offsetTrue));
%         T = (Lua+1)./4./60;
%         onsetTrue = round((onsetTrue + T)*60*4);
%         offsetTrue = round((offsetTrue + T)*60*4);
%         for k = 1:length(onsetTrue)
%             plot(onsetTrue(k):offsetTrue(k),95*ones(1,length(onsetTrue(k):offsetTrue(k))),'g-','LineWidth',6);
%         end
%         
%         edge = Score_Czech_3((Score_Czech_3(:,1)==id),3:end);
%         onsetTrue = edge(1,:);
%         offsetTrue = edge(2,:);
%         onsetTrue = onsetTrue(~isnan(onsetTrue));
%         offsetTrue = offsetTrue(~isnan(offsetTrue));
%         T = (Lua+1)./4./60;
%         onsetTrue = round((onsetTrue + T)*60*4);
%         offsetTrue = round((offsetTrue + T)*60*4);
%         for k = 1:length(onsetTrue)
%             plot(onsetTrue(k):offsetTrue(k),95*ones(1,length(onsetTrue(k):offsetTrue(k))),'b-','LineWidth',6);
%         end
%         
%         edge = Score_Czech_4((Score_Czech_4(:,1)==id),3:end);
%         onsetTrue = edge(1,:);
%         offsetTrue = edge(2,:);
%         onsetTrue = onsetTrue(~isnan(onsetTrue));
%         offsetTrue = offsetTrue(~isnan(offsetTrue));
%         T = (Lua+1)./4./60;
%         onsetTrue = round((onsetTrue + T)*60*4);
%         offsetTrue = round((offsetTrue + T)*60*4);
%         for k = 1:length(onsetTrue)
%             plot(onsetTrue(k):offsetTrue(k),95*ones(1,length(onsetTrue(k):offsetTrue(k))),'r-','LineWidth',6);
%         end
        
    end
    
    
end

save UCIResult_Czech_BasicAGGP_3_10 UCIResult



%% Processing (SBU)
fprintf('SBU\n');

rng('default')
rng(1);        % for controling random number generator

% randomly select test sets for cross validation
pclass = SBUID((SBUlabel=='p'));
bclass = SBUID((SBUlabel=='b'));
mclass = SBUID((SBUlabel=='m'));
aclass = SBUID((SBUlabel=='a'));
gclass = SBUID((SBUlabel=='g'));
kfold = 10;   
CV_TEST = zeros(kfold,5);    % saving indices for CV test
CV_TRAINING = zeros(kfold,10);  % saving indices for CV training
for i = 1:kfold
    CV_TEST(i,:) = [pclass(randsample(3,1)) bclass(randsample(3,1)) mclass(randsample(3,1)) aclass(randsample(3,1)) gclass(randsample(3,1))];
    CV_TRAINING(i,:) = SBUID(~ismember(SBUID,CV_TEST(i,:)));
end

for i = 1:kfold
    fprintf('This is the No.%d run.\n',i);
    
    % Training...
    fprintf('Training...\n');
    count_C = 1;  % for counting number of contractions
    count_N = 1;  % for counting number of non-contractions
    ContractionsCollection = [];
    NonContractionsCollection = [];
    NoiseCollection = [];
    for j = 1:size(CV_TRAINING,2)
        % extract raw signal
        id = CV_TRAINING(i,j);
        SIGua = SBUUA(:,id);
        SIGua = SIGua(~isnan(SIGua));
        Lua = length(SIGua);
        % preprocessing
        [Detua,locs] = Fun_UApreprocessing(SIGua,[fs,medianLen,0.04,valuemin,consecLen,valuemax]);
        % extract ground truth
        edge = GroundTruth_SBU_G1((GroundTruth_SBU_G1(:,1)==id),3:end);
        onsetTrue = edge(1,:);
        offsetTrue = edge(2,:);
        onsetTrue = onsetTrue(~isnan(onsetTrue));
        offsetTrue = offsetTrue(~isnan(offsetTrue));
        T = (Lua+1)./4./60;
        onsetTrue = round((onsetTrue + T)*60*4);
        offsetTrue = round((offsetTrue + T)*60*4); 
        % divide contractions and noncontraction segments according to GT1
        ContractionIdx = [];
        for k = 1:length(onsetTrue)
            ContractionIdx = [ContractionIdx,onsetTrue(k):offsetTrue(k)];
            ContractionsCollection{count_C} = Detua(onsetTrue(k):offsetTrue(k));
            count_C = count_C + 1;
        end
        NoncontractionIdx = 1:length(Detua);
        NoncontractionIdx(ContractionIdx)=[];
        NoiseCollection = [NoiseCollection, Detua(NoncontractionIdx)'];
        % detection for extracting non-contraction segments
        candidates = contraction_detector_Diffoperator_Energy(Detua,length(Detua),diffDelta,locs,energydetLen,energyThr,0);
        candidates = Fun_UApostprocessing(candidates,[minConInt,minConLen]);
        for k = 1:size(candidates,1)
            if length(intersect(candidates(k,1):candidates(k,2),ContractionIdx))/length(candidates(k,1):candidates(k,2))<0.5
            %if isempty(intersect(candidates(k,1):candidates(k,2),ContractionIdx))
                NonContractionsCollection{count_N} = Detua(candidates(k,1):candidates(k,2));
                count_N = count_N + 1;
            end
        end
    end
    % for template matching
    %[TemplateParas] = training_for_TemplateMatching(ContractionsCollection,template_rho);

    % for GLRT
%     [NoiseModelParas,AGaussian,GLRTClassifier] = training_for_GLRT(ContractionsCollection,NonContractionsCollection,NoiseCollection);
    % for GP hyperparameters test
%      [HyperParameters,PDFofHyperparameters,GPHTThr] = training_for_GPHT(ContractionsCollection);
    % for AGaussian model-based features
%     [NoiseModelParas,AGaussian,AGFClassifier] = training_for_AGFeatures(ContractionsCollection,NonContractionsCollection,NoiseCollection);
 % feature extraction and training
    [NoiseModelParas,AGaussian,Classifier] = training_com_features(ContractionsCollection,NonContractionsCollection,NoiseCollection,Method,i);
       

    % Testing...
    fprintf('Testing...\n');
    for j = 1:size(CV_TEST,2)
        fprintf('SBU ID:%d\n',CV_TEST(i,j));
        % extract raw signal
        id = CV_TEST(i,j);
        SIGua = SBUUA(:,id);
        SIGua = SIGua(~isnan(SIGua));
        Lua = length(SIGua);
        t=(1-Lua:0)./4./60;
        pointer = 0;
        
        ContractionsSaving = [];
        Flag = [];
        Score = [];
        
        %figure()
        for n = 1:numel(t)
            if n < minWin+delay
                continue;
            end
            
            received_signal = SIGua(1:n-delay);
            receivedLen = length(received_signal);
            % preprocessing
            [Detua,locs] = Fun_UApreprocessing(received_signal,[fs,medianLen,0.04,valuemin,consecLen,valuemax]);
           
                    
            % ================ when every new local minima found
            if ~isempty(locs) && (pointer<locs(end)) && (n ~= numel(t))
                % Edge Detection -------------------------------
                % method 1 Energy detector:
%                [~,candidates] = contraction_detector_Energy(Detua(pointer+1:locs(end)),[energydetLen,energyThr],pointer);
                
                % method 2 Difference operator:
%                [~,candidates] = contraction_detector_Diffoperator(Detua,receivedLen,diffDelta,locs,pointer);
                
                % method 3 Difference operator and energy detector:
                candidates = contraction_detector_Diffoperator_Energy(Detua,receivedLen,diffDelta,locs,energydetLen,energyThr,pointer);
                candidates = Fun_UApostprocessing(candidates,[minConInt,minConLen]); % Post-processing                

                % Contraction Identification -----------------------

                [flag,prob] = contraction_detector_classification(Detua,candidates,NoiseModelParas,AGaussian,Classifier,Method);

                
                if ~isnan(candidates)
                    if ~isempty(ContractionsSaving)&& ~isempty(intersect(candidates(1,1):candidates(1,2),ContractionsSaving(end,1):ContractionsSaving(end,2)))
                        ContractionsSaving(end,:) = [];
                        Flag(end) = [];
                        Score(end) = [];
                    end                 
                    ContractionsSaving = [ContractionsSaving;candidates];
                    Flag = [Flag,flag];
                    Score = [Score,prob];
                    pointer = candidates(end,1);
                end
            elseif n == numel(t)
                % method 1 Energy detector:
%                [~,candidates] = contraction_detector_Energy(Detua(pointer+1:receivedLen),[energydetLen,energyThr],pointer);
                % method 2 Difference operator:
%                [~,candidates] = contraction_detector_Diffoperator(Detua,receivedLen,diffDelta,locs,pointer);
                % method 3 Difference operator and energy detector:
                candidates = contraction_detector_Diffoperator_Energy(Detua,receivedLen,diffDelta,locs,energydetLen,energyThr,pointer);
                candidates = Fun_UApostprocessing(candidates,[minConInt,minConLen]); % Post-processing
                
                % Contraction Identification -----------------------
                  
                [flag,prob] = contraction_detector_classification(Detua,candidates,NoiseModelParas,AGaussian,Classifier,Method);

                % method : Template matching:
                %candidates = contraction_detector_Template(Detua,TemplateParas,template_delta,template_rho,minConInt,minConLen,pointer);                

                if ~isnan(candidates)
                    if ~isempty(ContractionsSaving)&& ~isempty(intersect(candidates(1,1):candidates(1,2),ContractionsSaving(end,1):ContractionsSaving(end,2)))
                        ContractionsSaving(end,:) = [];
                         Flag(end) = [];
                         Score(end) = [];
                    end
                    ContractionsSaving = [ContractionsSaving;candidates];
                    Flag = [Flag,flag];
                    Score = [Score,prob];
                end
                
            end
            
        end
        
        UCIResult{i,j}.ID = id;
        UCIResult{i,j}.Contractions = ContractionsSaving;
        UCIResult{i,j}.Flag = Flag;   
        UCIResult{i,j}.Score = Score;
        
%         % plotting
%         figure()
%         plot(SIGua); hold on;
%         for k = 1:size(ContractionsSaving,1)
%             if Flag(k)== 1
%                 patch([ContractionsSaving(k,1) ContractionsSaving(k,2) ContractionsSaving(k,2) ContractionsSaving(k,1)], [150 150 0 0], 'y', 'FaceAlpha', .3);
%             else
%                 patch([ContractionsSaving(k,1) ContractionsSaving(k,2) ContractionsSaving(k,2) ContractionsSaving(k,1)], [150 150 0 0], [0.5,0.5,0.5], 'FaceAlpha', .3);
%             end
%             text(ContractionsSaving(k,1)+16,5,sprintf('%.2f', Score(k)));
%             
%         end
%         
%         edge = Score_Czech_1((Score_Czech_1(:,1)==id),3:end);
%         onsetTrue = edge(1,:);
%         offsetTrue = edge(2,:);
%         onsetTrue = onsetTrue(~isnan(onsetTrue));
%         offsetTrue = offsetTrue(~isnan(offsetTrue));
%         T = (Lua+1)./4./60;
%         onsetTrue = round((onsetTrue + T)*60*4);
%         offsetTrue = round((offsetTrue + T)*60*4);
%         for k = 1:length(onsetTrue)
%             plot(onsetTrue(k):offsetTrue(k),95*ones(1,length(onsetTrue(k):offsetTrue(k))),'y-','LineWidth',6);
%         end
%         
%         edge = Score_Czech_2((Score_Czech_2(:,1)==id),3:end);
%         onsetTrue = edge(1,:);
%         offsetTrue = edge(2,:);
%         onsetTrue = onsetTrue(~isnan(onsetTrue));
%         offsetTrue = offsetTrue(~isnan(offsetTrue));
%         T = (Lua+1)./4./60;
%         onsetTrue = round((onsetTrue + T)*60*4);
%         offsetTrue = round((offsetTrue + T)*60*4);
%         for k = 1:length(onsetTrue)
%             plot(onsetTrue(k):offsetTrue(k),95*ones(1,length(onsetTrue(k):offsetTrue(k))),'g-','LineWidth',6);
%         end
%         
%         edge = Score_Czech_3((Score_Czech_3(:,1)==id),3:end);
%         onsetTrue = edge(1,:);
%         offsetTrue = edge(2,:);
%         onsetTrue = onsetTrue(~isnan(onsetTrue));
%         offsetTrue = offsetTrue(~isnan(offsetTrue));
%         T = (Lua+1)./4./60;
%         onsetTrue = round((onsetTrue + T)*60*4);
%         offsetTrue = round((offsetTrue + T)*60*4);
%         for k = 1:length(onsetTrue)
%             plot(onsetTrue(k):offsetTrue(k),95*ones(1,length(onsetTrue(k):offsetTrue(k))),'b-','LineWidth',6);
%         end
%         
%         edge = Score_Czech_4((Score_Czech_4(:,1)==id),3:end);
%         onsetTrue = edge(1,:);
%         offsetTrue = edge(2,:);
%         onsetTrue = onsetTrue(~isnan(onsetTrue));
%         offsetTrue = offsetTrue(~isnan(offsetTrue));
%         T = (Lua+1)./4./60;
%         onsetTrue = round((onsetTrue + T)*60*4);
%         offsetTrue = round((offsetTrue + T)*60*4);
%         for k = 1:length(onsetTrue)
%             plot(onsetTrue(k):offsetTrue(k),95*ones(1,length(onsetTrue(k):offsetTrue(k))),'r-','LineWidth',6);
%         end
        
    end
    
    
end

save UCIResult_SBU_BasicAGGP_3_14 UCIResult
