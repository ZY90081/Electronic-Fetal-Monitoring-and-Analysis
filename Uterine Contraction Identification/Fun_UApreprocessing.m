function [Detua,locs] = Fun_UApreprocessing(ua,parameters)

fs = parameters(1);
medianLen = parameters(2);
cutoff = parameters(3);
[b,a] = butter(2,cutoff/(fs/2));
valuemin = parameters(4);
consecLen = parameters(5);
valuemax = parameters(6);

receivedLen = length(ua);

Nartiua = medfilt1(ua,medianLen);          % median filtering
Shapeua = filtfilt(b,a,Nartiua);           % zero-phase low-pass filtering
[~,locs] = findpeaks(-Shapeua,'MinPeakProminence',5,'MinPeakDistance',30*4,'MinPeakWidth',30*4,'MinPeakHeight',-inf);
locszeros = find(abs(Shapeua)<=valuemin);
d = [true; diff(ua) ~= 0; true];       % TRUE if values change
dn = diff(find(d));                    % Number of repetitions
consec = repelem(dn, dn);
if size(consec,2)>1
    consec = consec';
end
locsconsec = find((consec>=consecLen)&(ua<valuemax));
locsall = unique(sort([1;locs;receivedLen;locszeros;locsconsec]));
pks = Shapeua(locsall);
restingtone = interp1(locsall,pks,1:receivedLen,'pchip')';
Detua = Shapeua - restingtone;            % detrended UA segment

% if any(Detua<0)
%     Detua = Detua + abs(min(Detua));    % force all positive values
% end

end
