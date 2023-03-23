clc;
close all;
clear all;


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

Training_Czech_G1 = readmatrix('Czech Y_Y.csv');
GroundTruth_Czech_G2 = readmatrix('Czech Y_Y Y_M.csv');
GroundTruth_Czech_G3 = readmatrix('Czech Y_Y Y_M M_M Y_N.csv');
GroundTruth_Czech_G4 = readmatrix('Czech Y_Y Y_M M_M Y_N M_N.csv');

Training_SBU_G1 = readmatrix('SBU Y_Y.csv');
GroundTruth_SBU_G2 = readmatrix('SBU Y_Y Y_M.csv');
GroundTruth_SBU_G3 = readmatrix('SBU Y_Y Y_M M_M Y_N.csv');
GroundTruth_SBU_G4 = readmatrix('SBU Y_Y Y_M M_M Y_N M_N.csv');


CzechID = [1,10,15,39,107,120,136,143,160,202,294,338,352,426,459];
Czechlabel = ['g','p','g','m','a','m','b','g','a','p','b','a','m','b','p'];

SBUID = [596,726,757,783,2103,2105,2362,4879,5655,6696,7176,8149,8837,10601,10606];
SBUlabel = ['p','g','g','a','g','p','a','m','b','a','m','m','b','p','b'];

%% Parameters

% parameters for segmentation
fs = 4;                 % sampling frequency (Hz)
delay = 5 * fs;         % delay of prcoessing: 5 secconds
minWin = 60 * fs;       % minimum length of processing: 60 seconds
maxWin = 10*60 * fs;    % maximum length of processing: 10 minutes

% parameters for pre-processing
medianLen = 15 * fs;    % length of median filtering: 15 seconds
[b,a] = butter(2,0.04/(fs/2));% design Butterworth low-pass filter： cutoff frequency 0.04Hz
valuemin = 0.1;         % minimum ua value for determining baseline
valuemax = 100;         % maximum ua value for determining baseline
consecLen = 10 * fs;     % maximum length of consecutive identical values for determining baseline
localmin = [];          % for saving local minimum

% parameters for contraction detection
pointer = 0;            % initial pointer indicating the location of detection
%DetLen = 1*60 * fs;     % length of detection window : 1 minute
energydetLen = 2* fs;   % small window size for energy detector: 2 seconds
%energyStandard = 1e5;   % Normalization standard of energy
energyThr = 100;         % learn from annotation?
refineRes = 5*fs;        % resolution for refining edges : 2 sec
refineWindow = 15.*fs;  % window for searching optimal edges: 15 sec
diffDelta = [0.2:0.1:0.6]*60*fs;  % 
%diffDeltaoff = [0.2:0.1:0.8]*60*fs;
GLRTThr = 400;        % learn from annotation?
NoiseModelParas = [0,0.6321,0.2641,0.2843];   % initial location,shape,scale,skew
AGaussian = [40,3,2,2e4,3,2,2e4];  % initial para of Asymmetric Gaussian model.
minConLen = 10*fs;     % minimum length of valid contractions
minConInt = 5*fs;      % minimum length of valid intervals between two contractions


% ============= for Oxsys method
%M = 4.38*60*fs;
LL = 17.5*60*fs;
alpha=10;
alphas = 1.45;
min_con = 2*60*fs;
min_gap = 2.75*60*fs;
% =============

load('PDFofHyperparameters.mat');

% parameters for plotting
ShowLen = 10*60 * fs;   % length of display: 10 minutes
ymin = 0;ymax = 100;    % limitation of y-axis

FLAG = [];



%% Processing (Czech)

Eva1_Oxsys = [];


for i = 1:15
    i
    pointer = 0; 
    localmin = [];         
    ContractionsSaving = [];
    id = CzechID(i);
    SIGua = CzechUA(:,id);
    SIGua = SIGua(~isnan(SIGua));
    Lua = length(SIGua);
    t=(1-Lua:0)./4./60;
    
    
    edge = Training_Czech_G1(find(Training_Czech_G1(:,1)==id),3:end);
    onsetTrue = edge(1,:);
    offsetTrue = edge(2,:);
    onsetTrue = onsetTrue(~isnan(onsetTrue));
    offsetTrue = offsetTrue(~isnan(offsetTrue));
    T = (Lua+1)./4./60;
    onsetTrue = round((onsetTrue + T)*60*4);
    offsetTrue = round((offsetTrue + T)*60*4);
    
%     figure()
    
    for n = 1:numel(t)
        if n < minWin+delay
            continue;
        end
        
        received_signal = SIGua(1:n-delay);
        receivedLen = length(received_signal);
        
        % ==============pre-processing
        Nartiua = medfilt1(received_signal,medianLen);     % median filtering
        Shapeua = filtfilt(b,a,Nartiua);           % zero-phase low-pass filtering
        [~,locs] = findpeaks(-Shapeua,'MinPeakProminence',5,'MinPeakDistance',30*4,'MinPeakWidth',30*4,'MinPeakHeight',-inf);
        locszeros = find(abs(Shapeua)<=valuemin);
        d = [true; diff(received_signal) ~= 0; true];  % TRUE if values change
        dn = diff(find(d));                    % Number of repetitions
        consec = repelem(dn, dn);
        if size(consec,2)>1
            consec = consec';
        end
        locsconsec = find((consec>=consecLen)&(received_signal<valuemax));
        locsall = unique(sort([1;locs;receivedLen;locszeros;locsconsec]));
        pks = Shapeua(locsall);
        restingtone = interp1(locsall,pks,1:receivedLen,'pchip')';
        Detua = Shapeua - restingtone;                       % detrended UA segment
        
        % ================ Energy detector (update)
%         if any(FLAG==1)
%             parameters.EnergyThr = Fun_updateEnergyThr(Detua,RefineContractionsSaving,FLAG,energydetLen);
%         else
%             parameters.EnergyThr = energyThr;
%         end
        
        % ================ Start UC detection when every new local minima found
        if ~isempty(locs) && (pointer<locs(end)) && (n ~= numel(t))
            while floor(length(pointer+1:locs(end))/LL)>=1
                [~,candidates] = contraction_detector_Oxsys(Detua(pointer+1:pointer+LL),[LL,alpha,alphas,min_con,min_gap],pointer);

                if ~isnan(candidates)
                    if ~isempty(ContractionsSaving)&& ~isempty(intersect(candidates(1,1):candidates(1,2),ContractionsSaving(end,1):ContractionsSaving(end,2)))
                        ContractionsSaving(end,:) = [];
                    end
                    
                    ContractionsSaving = [ContractionsSaving;candidates];
                    pointer = candidates(end,2);
                else
                    pointer = pointer+LL;
                end
            end
              
        elseif n == numel(t)
            %while floor(length(pointer+1:receivedLen)/LL)>=1
            LL = length(Detua(pointer+1:end));
                [~,candidates] = contraction_detector_Oxsys(Detua(pointer+1:pointer+LL),[LL,alpha,alphas,min_con,min_gap],pointer);
                
                if ~isnan(candidates)
                    ContractionsSaving = [ContractionsSaving;candidates];
                    pointer = candidates(end,2);
                else
                    pointer = pointer+LL;
                end    
            %end
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

%     % ===== Adjust by interval and length
%     tempidx = find((ContractionsSaving(2:end,1)-ContractionsSaving(1:end-1,2))<=minConInt);
%     j=1;
%     while j<=length(tempidx)
%         %begin = candidates(tempidx(j),1);
%         beginidx = tempidx(j);
%         endidx = tempidx(j)+1;
%         if j<length(tempidx)
%             while (j<length(tempidx)) && (diff(tempidx(j:j+1))==1)
%                 j = j+1;
%                 endidx = tempidx(j)+1;
%             end
%         end
%         ContractionsSaving(beginidx,2) = ContractionsSaving(endidx,2);
%         j = j+1;
%     end
%     ContractionsSaving(tempidx+1,:) = [];
%     ContractionsSaving((ContractionsSaving(:,2)-ContractionsSaving(:,1))<=minConLen,:) = [];    % remove very short segments
%     % ======================================    
    
    
    Eva1_Oxsys{i}.ID = id;
    Eva1_Oxsys{i}.Contractions = ContractionsSaving;
    Eva1_Oxsys{i}.GroundTruth = [onsetTrue' offsetTrue'];
    K = length(onsetTrue);
    IOU = zeros(1,K);
    for k=1:K
        temp = onsetTrue(k):offsetTrue(k);
        for j=1:size(ContractionsSaving, 1)
            iou = length(intersect(temp,ContractionsSaving(j,1):ContractionsSaving(j,2)))/length(union(temp,ContractionsSaving(j,1):ContractionsSaving(j,2)));
            if iou > IOU(k)
                IOU(k) = iou;
            end
        end
    end
    Eva1_Oxsys{i}.IOU = IOU;

end

save UCIResult_Czech_Oxsys Eva1_Oxsys

%% ======== Plot Results

IOUg = []; IOUa = []; IOUm = []; IOUb = []; IOUp = [];
for i = 1:15
    switch Czechlabel(i)
        case 'g'
            IOUg = [IOUg Eva1_Oxsys{i}.IOU];
        case 'a'
            IOUa = [IOUa Eva1_Oxsys{i}.IOU];
        case 'm'
            IOUm = [IOUm Eva1_Oxsys{i}.IOU];
        case 'b'
            IOUb = [IOUb Eva1_Oxsys{i}.IOU];
        case 'p'
            IOUp = [IOUp Eva1_Oxsys{i}.IOU];
    end
end
% Eva1_OnlyEnergyDetector_Czech = [mean(IOUg) mean(IOUa) mean(IOUm) mean(IOUb) mean(IOUp)];
Eva1_Oxsys_Czech = [median(IOUg) median(IOUa) median(IOUm) median(IOUb) median(IOUp)];

plot(Eva1_Oxsys_Czech,'*-');


%% checking

for i = 1:15
    id = CzechID(i);
    SIGua = CzechUA(:,id);
    SIGua = SIGua(~isnan(SIGua));
    Lua = length(SIGua);
    t=(1-Lua:0)./4./60;
    
    figure()
    plot(SIGua);
    hold on;
    for k = 1:size(Eva1_Oxsys{i}.GroundTruth,1)
        plot(Eva1_Oxsys{i}.GroundTruth(k,1):Eva1_Oxsys{i}.GroundTruth(k,2),95*ones(1,length(Eva1_Oxsys{i}.GroundTruth(k,1):Eva1_Oxsys{i}.GroundTruth(k,2))),'r-','LineWidth',6);
    end
    for k = 1:size(Eva1_Oxsys{i}.Contractions,1)
        patch([Eva1_Oxsys{i}.Contractions(k,1) Eva1_Oxsys{i}.Contractions(k,2) Eva1_Oxsys{i}.Contractions(k,2) Eva1_Oxsys{i}.Contractions(k,1)], [150 150 0 0], 'y', 'FaceAlpha', .3);
    end
end

%% Processing (SBU)

Eva1_Oxsys = [];

for i = 1:15
    i
    pointer = 0;
    localmin = [];
    ContractionsSaving = [];
    id = SBUID(i);
    SIGua = SBUUA(:,id);
    SIGua = SIGua(~isnan(SIGua));
    Lua = length(SIGua);
    t=(1-Lua:0)./4./60;
    
    
    edge = Training_SBU_G1(find(Training_SBU_G1(:,1)==id),3:end);
    onsetTrue = edge(1,:);
    offsetTrue = edge(2,:);
    onsetTrue = onsetTrue(~isnan(onsetTrue));
    offsetTrue = offsetTrue(~isnan(offsetTrue));
    T = (Lua+1)./4./60;
    onsetTrue = round((onsetTrue + T)*60*4);
    offsetTrue = round((offsetTrue + T)*60*4);
    
%     figure()
    for n = 1:numel(t)
        if n < minWin+delay
            continue;
        end
        
        received_signal = SIGua(1:n-delay);
        receivedLen = length(received_signal);
        
        % ==============pre-processing
        Nartiua = medfilt1(received_signal,medianLen);     % median filtering
        Shapeua = filtfilt(b,a,Nartiua);           % zero-phase low-pass filtering
        [~,locs] = findpeaks(-Shapeua,'MinPeakProminence',5,'MinPeakDistance',30*4,'MinPeakWidth',30*4,'MinPeakHeight',-inf);
        locszeros = find(abs(Shapeua)<=valuemin);
        d = [true; diff(received_signal) ~= 0; true];  % TRUE if values change
        dn = diff(find(d));                    % Number of repetitions
        consec = repelem(dn, dn);
        if size(consec,2)>1
            consec = consec';
        end
        locsconsec = find((consec>=consecLen)&(received_signal<valuemax));
        locsall = unique(sort([1;locs;receivedLen;locszeros;locsconsec]));
        pks = Shapeua(locsall);
        restingtone = interp1(locsall,pks,1:receivedLen,'pchip')';
        Detua = Shapeua - restingtone;                       % detrended UA segment
        
        % ================ Energy detector (update)
%         if any(FLAG==1)
%             parameters.EnergyThr = Fun_updateEnergyThr(Detua,RefineContractionsSaving,FLAG,energydetLen);
%         else
%             parameters.EnergyThr = energyThr;
%         end
        
        % ================ Start UC detection when every new local minima found
        if ~isempty(locs) && (pointer<locs(end)) && (n ~= numel(t))
            while floor(length(pointer+1:locs(end))/LL)>=1
                [~,candidates] = contraction_detector_Oxsys(Detua(pointer+1:pointer+LL),[LL,alpha,alphas,min_con,min_gap],pointer);

                if ~isnan(candidates)
                    if ~isempty(ContractionsSaving)&& ~isempty(intersect(candidates(1,1):candidates(1,2),ContractionsSaving(end,1):ContractionsSaving(end,2)))
                        ContractionsSaving(end,:) = [];
                    end
                    
                    ContractionsSaving = [ContractionsSaving;candidates];
                    pointer = candidates(end,2);
                else
                    pointer = pointer+LL;
                end
            end
              
        elseif n == numel(t)
%             while floor(length(pointer+1:receivedLen)/LL)>=1
            LL = length(Detua(pointer+1:end));
                [~,candidates] = contraction_detector_Oxsys(Detua(pointer+1:pointer+LL),[LL,alpha,alphas,min_con,min_gap],pointer);
                
                if ~isnan(candidates)
                    ContractionsSaving = [ContractionsSaving;candidates];
                    pointer = candidates(end,2);
                else
                    pointer = pointer+LL;
                end    
%             end
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

%     % ===== Adjust by interval and length
%     tempidx = find((ContractionsSaving(2:end,1)-ContractionsSaving(1:end-1,2))<=minConInt);
%     j=1;
%     while j<=length(tempidx)
%         %begin = candidates(tempidx(j),1);
%         beginidx = tempidx(j);
%         endidx = tempidx(j)+1;
%         if j<length(tempidx)
%             while (j<length(tempidx)) && (diff(tempidx(j:j+1))==1)
%                 j = j+1;
%                 endidx = tempidx(j)+1;
%             end
%         end
%         ContractionsSaving(beginidx,2) = ContractionsSaving(endidx,2);
%         j = j+1;
%     end
%     ContractionsSaving(tempidx+1,:) = [];
%     ContractionsSaving((ContractionsSaving(:,2)-ContractionsSaving(:,1))<=minConLen,:) = [];    % remove very short segments
%     % ======================================    
    
    Eva1_Oxsys{i}.ID = id;
    Eva1_Oxsys{i}.Contractions = ContractionsSaving;
    Eva1_Oxsys{i}.GroundTruth = [onsetTrue' offsetTrue'];
    K = length(onsetTrue);
    IOU = zeros(1,K);
    for k=1:K
        temp = onsetTrue(k):offsetTrue(k);
        for j=1:size(ContractionsSaving, 1)
            iou = length(intersect(temp,ContractionsSaving(j,1):ContractionsSaving(j,2)))/length(union(temp,ContractionsSaving(j,1):ContractionsSaving(j,2)));
            if iou > IOU(k)
                IOU(k) = iou;
            end
        end
    end
    Eva1_Oxsys{i}.IOU = IOU;

end

save UCIResult_SBU_Oxsys Eva1_Oxsys

%% ======== Plot Results

IOUg = []; IOUa = []; IOUm = []; IOUb = []; IOUp = [];
for i = 1:15
    switch SBUlabel(i)
        case 'g'
            IOUg = [IOUg Eva1_Oxsys{i}.IOU];
        case 'a'
            IOUa = [IOUa Eva1_Oxsys{i}.IOU];
        case 'm'
            IOUm = [IOUm Eva1_Oxsys{i}.IOU];
        case 'b'
            IOUb = [IOUb Eva1_Oxsys{i}.IOU];
        case 'p'
            IOUp = [IOUp Eva1_Oxsys{i}.IOU];
    end
end
% Eva1_OnlyEnergyDetector_SBU = [mean(IOUg) mean(IOUa) mean(IOUm) mean(IOUb) mean(IOUp)];
Eva1_Oxsys_SBU = [median(IOUg) median(IOUa) median(IOUm) median(IOUb) median(IOUp)];

figure
plot(Eva1_Oxsys_SBU,'*-');


%% checking

for i = 1:15
    id = SBUID(i);
    SIGua = SBUUA(:,id);
    SIGua = SIGua(~isnan(SIGua));
    Lua = length(SIGua);
    t=(1-Lua:0)./4./60;
    
    figure()
    plot(SIGua);
    hold on;
    for k = 1:size(Eva1_Oxsys{i}.GroundTruth,1)
        plot(Eva1_Oxsys{i}.GroundTruth(k,1):Eva1_Oxsys{i}.GroundTruth(k,2),95*ones(1,length(Eva1_Oxsys{i}.GroundTruth(k,1):Eva1_Oxsys{i}.GroundTruth(k,2))),'r-','LineWidth',6);
    end
    for k = 1:size(Eva1_Oxsys{i}.Contractions,1)
        patch([Eva1_Oxsys{i}.Contractions(k,1) Eva1_Oxsys{i}.Contractions(k,2) Eva1_Oxsys{i}.Contractions(k,2) Eva1_Oxsys{i}.Contractions(k,1)], [150 150 0 0], 'y', 'FaceAlpha', .3);
    end
end
