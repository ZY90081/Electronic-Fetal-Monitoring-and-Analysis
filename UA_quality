clc;
close all;
clear all;

%% This program is used for providing a quality index for each UA recording.
% reference: Georgieva, A., Payne, S.J. & Redman, C.W.G. Computerised electronic
% foetal heart rate monitoring in labour: automated contraction identification. 
% Med Biol Eng Comput 47, 1315 (2009).



%% Reading data

load('CTUdataAll.mat');
[N,~] = size(CTUdata);  % number of FHR recordings
L = 21620; % Maximum time length

RawFHR = NaN(L,N);
RawUA = NaN(L,N);
IDseq = NaN(N,1);
ph = NaN(N,1);
apgar1 = NaN(N,1);
apgar5 = NaN(N,1);
for n = 1:N
    temp = length(CTUdata{n,1}.rawFHR);
    RawFHR(1:temp,n) = CTUdata{n,1}.rawFHR;
    RawUA(1:temp,n) = CTUdata{n,1}.rawUA;
    IDseq(n) = CTUdata{n,1}.ID;
    ph(n) = CTUdata{n,1}.Param.pH;
    apgar1(n) = CTUdata{n,1}.Param.Apgar1;
    apgar5(n) = CTUdata{n,1}.Param.Apgar5;
end
clear temp;

%% Parameters

Window = 10;   % 16 mins
SamplingInterval = 3.75;  % seconds
Order = 9;
LowTH = 0.0033;  % Hz (1 contraction per 5 mins)
HighTH = 0.0167;  % Hz (1 contraction per 1 min)
LowTH = 2*pi*LowTH*SamplingInterval;
HighTH = 2*pi*HighTH*SamplingInterval;

Cpoor = 0.72;
Cgood = 0.9;

StrengthLevel = 5;  % for removing missing data
DurationTH = 8;     % mins


%%

% % pick a UA recording
% IDidx = 157;
% SIGua = RawUA(:,IDidx);
% SIGua = SIGua(~isnan(SIGua));
% Lua = length(SIGua); 
% 
% figure(2)
% plot(SIGua)

RedQuaInd = zeros(N,1);

for IDidx = 1:N
    fprintf('Processing... %d \n',IDidx);
    
    SIGua = RawUA(:,IDidx);
    SIGua = SIGua(~isnan(SIGua));
    Lua = length(SIGua); 
    
%% Method

% pre-processing: subsample
DT = floor(Lua/(SamplingInterval*4));
Proua = zeros(DT,1);
for dt = 1:DT
    Proua(dt) = mean(SIGua((dt-1)*SamplingInterval*4+1:dt*SamplingInterval*4));
end
Lua = length(Proua);

% pre-processing: remove missing segment
strength = Proua<StrengthLevel;
startidx = find(diff([0;strength;0]==1)==1);
endidx = find(diff([0;strength;0]==1)==-1);
misssegidx = find((endidx-startidx)>(DurationTH*60/SamplingInterval));
if ~isempty(misssegidx)
    for i = 1:length(misssegidx)
        Proua(startidx(misssegidx(i)):endidx(misssegidx(i))-1) = NaN;
    end
end
Proua = Proua(~isnan(Proua));
Lua = length(Proua);

% segmentation
segL = Window*60/SamplingInterval; % length of each segment
segN = floor(Lua/segL);
QualityInd = zeros(segN,1);
for n = 1:segN
    Segua = Proua((n-1)*segL+1:n*segL);
    ProSegua = Segua - mean(Segua);  % remove the mean
    sys = ar(ProSegua,Order);
    b = [1,zeros(1,Order)];
    a = sys.A;
    [~,pole,k] = tf2zpk(b,a);
    theta = angle(pole);
    rho = abs(pole);
    
    % Criteria
    validPoleId = find((theta>=LowTH)&(theta<=HighTH));
    if isempty(validPoleId)
        QualityInd(n) = 0;
    elseif max(rho(validPoleId))<Cpoor
        QualityInd(n) = 0;
    elseif max(rho(validPoleId))>=Cgood
        QualityInd(n) = 1;
    elseif (max(rho(validPoleId)>=Cpoor)) && (max(rho(validPoleId)<Cgood))
        QualityInd(n) = 0.5;
    end
    
    % Plotting -----------
%     fig1 = figure();
%     subplot(2,1,1)
%     plot(Segua);
%     subplot(2,1,2)
%     polarplot(LowTH*ones(1,101),0:0.01:1,'k','LineWidth',1); hold on;
%     polarplot(HighTH*ones(1,101),0:0.01:1,'k','LineWidth',1);   
%     polarplot(0:0.1:2*pi,Cpoor*ones(1,length(0:0.1:2*pi)),'b','LineWidth',1);
%     polarplot(0:0.1:2*pi,Cgood*ones(1,length(0:0.1:2*pi)),'r','LineWidth',1);
%     polarplot(pole,'o','color',[0.6 0 0]);
%     thetalim([0,180]);
%     
%     close Figure 1
end

RedQuaInd(IDidx) = sum(QualityInd)/segN*100;

end

save CzechCTU_UA_QA RedQuaInd 

