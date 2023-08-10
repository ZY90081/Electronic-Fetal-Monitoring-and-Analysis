function [flag,candidates] = contraction_detector_Diffoperator(detection_segment,receivedLen,diffDelta,locs,pointer)


% getting difference sequences
DiffuaOn = nan(1,receivedLen);
DiffuaOff = nan(1,receivedLen);
for k = 1:receivedLen
    if k <= receivedLen-max(diffDelta)
        DiffuaOn(k) = max(detection_segment(k*ones(1,length(diffDelta))+floor(diffDelta)) - detection_segment(k));
    end
    if k >= max(diffDelta)+1
        DiffuaOff(k) = max (- (detection_segment(k) - detection_segment(k*ones(1,length(diffDelta))-floor(diffDelta)) ) );
    end
end


% ------------- Difference Operator
[~,oncandi] = findpeaks([zeros(1,100) DiffuaOn(1:locs(end))],'MinPeakProminence',3,'MinPeakDistance',30*4,'MinPeakHeight',5);
[~,offcandi] = findpeaks(DiffuaOff(1:locs(end)),'MinPeakProminence',3,'MinPeakDistance',30*4,'MinPeakHeight',5);
oncandi = oncandi - 100;
oncandi = oncandi(oncandi>=pointer);
offcandi = offcandi(offcandi>=pointer);
candidates = onsetoffsetPair(oncandi,offcandi,detection_segment(1:locs(end)),15);
candidates(logical(prod((candidates<=pointer),2)),:) = [];




end
