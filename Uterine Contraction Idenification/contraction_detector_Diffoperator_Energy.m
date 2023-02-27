function [candidates] = contraction_detector_Diffoperator_Energy(detection_segment,receivedLen,diffDelta,locs,energydetLen,energyThr,pointer)

% Combination of difference operator and energy detector

% Inputs: detection_segment    -   UA recording
%         receivedLen          -   length of received recording
%         diffDelta            -   range of the distance (parameter of difference operator)
%         locs                 -   location of local minima (for determining the segment to be considered)
%         energydetLen         -   window size of energy detector
%         energyThr            -   energy detection threshold
%         pointer              -   indicator of location where the last detection ends and the new detection begins
% Output: candidates           -   onsets and offsets of contraction candidates

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
[~,oncandi] = findpeaks([zeros(1,100) DiffuaOn(1:locs(end))],'MinPeakProminence',3,'MinPeakDistance',30*4,'MinPeakHeight',5); % add 100 zeros at the begining
[~,offcandi] = findpeaks([DiffuaOff(1:locs(end)) zeros(1,100)],'MinPeakProminence',3,'MinPeakDistance',30*4,'MinPeakHeight',5); % add 100 zeros at the end
oncandi = oncandi - 100; % adjusting
offcandi(offcandi>locs(end))=[];
oncandi = oncandi(oncandi>=pointer);
offcandi = offcandi(offcandi>=pointer);
candidates = onsetoffsetPair(oncandi,offcandi,detection_segment(1:locs(end)),15);
candidates(logical(prod((candidates<=pointer),2)),:) = [];

% ------------- Adjust by Energy
if ~isnan(candidates)
    candidatesupdate = [];
    for k = 1:size(candidates,1)
        [~,temp] = contraction_detector_Energy(detection_segment(candidates(k,1):candidates(k,2)),[energydetLen,energyThr],candidates(k,1)-1);
        candidatesupdate = [candidatesupdate;temp];
    end
    candidates = candidatesupdate;
end



end
