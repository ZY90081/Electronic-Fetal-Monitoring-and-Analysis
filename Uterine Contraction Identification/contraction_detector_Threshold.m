function [flag,contractions] = contraction_detector_Threshold(detection_segment,parameters,pointer)


Amin = parameters(1);
Tmin = parameters(2);
DL = parameters(3);

detection_segment = detection_segment - DL;
detection_segment(detection_segment<0)=0;
idx = find(detection_segment>0);
isgap = find(diff(idx)~=1);

if isempty(idx)
    flag = 0;
    contractions = NaN;
    return
else
    if isempty(isgap)
        T = length(idx);
        A = max(detection_segment(idx));
        if (T>=Tmin) && (A>=Amin)
            flag = 1;
            contractions = [pointer+idx(1) pointer+idx(end)];
            return
        else
            flag = 0;
            contractions = NaN;
            return
        end
        
    end
end
    
contractions = [];
for i = 1:length(isgap)
    if i == 1
        candidateidx = idx(1:isgap(i));
    else
        candidateidx = idx(isgap(i-1)+1:isgap(i));
    end
    T = length(candidateidx);
    A = max(detection_segment(candidateidx));
    if (T>=Tmin) && (A>=Amin)
        contractions = [contractions; pointer+candidateidx(1),pointer+candidateidx(end)];
    end
end
candidateidx = idx(isgap(end)+1:end);
T = length(candidateidx);
A = max(detection_segment(candidateidx));
if (T>=Tmin) && (A>=Amin)
    contractions = [contractions; pointer+candidateidx(1),pointer+candidateidx(end)];
end

if isempty(contractions)
    flag = 0;
else
    flag = 1;
end



end

