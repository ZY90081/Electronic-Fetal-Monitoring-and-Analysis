% pick a UA recording
SIGua = RawUA(:,n);
SIGua = SIGua(~isnan(SIGua));
Lua = length(SIGua);                                  % the total sample length of UA signal

% Step1: Remove artifacts (spikes and jiggles)
Nartiua = medfilt1(SIGua,15*4);

% Step2: Smooth the shape
[b,a] = butter(2,0.04/2);                             % cutoff frequency 0.04Hz
Shapeua = filtfilt(b,a,Nartiua);

% Step3: Detrend signals
[pks,locs] = findpeaks(-Shapeua,'MinPeakWidth',200,'MinPeakDistance',50,'MinPeakProminence',1);
if sum(Shapeua>0.1)==0
    temp=1;
else
    temp = find(Shapeua>0.1);
end
locs = unique([1;temp(1);locs;temp(end);Lua]);
pks = Shapeua(locs);
restingtone = interp1(locs,pks,1:Lua,'pchip')';
Detua = Shapeua - restingtone;

figure(); hold on;
plot(SIGua);
plot(Shapeua);
plot(restingtone); 
plot(Detua);
plot(locs,pks,'or');
