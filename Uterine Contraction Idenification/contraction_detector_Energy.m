function [flag,contractions] = contraction_detector_Energy(detection_segment,parameters,pointer)

% Inputs: detection_segment     -     signal to be processed
%         parameters ([energydetLen,energyThr])
%         pointer               -     indicator of location of last detection


L = length(detection_segment);
% energydetLen = parameters.energydetLen;
% energyThr = parameters.EnergyThr;
energydetLen = parameters(1);
energyThr = parameters(2);


Energy = zeros(L,1);

for i = energydetLen/2+1:L-energydetLen/2
    Energy(i) = sum(detection_segment(i-energydetLen/2:i+energydetLen/2).^2);
end

sigidx = find(Energy>energyThr);

if isempty(sigidx)
    flag = 0;
    contractions = [];
    return
end

iscons = find(diff(sigidx)>1);
if isempty(iscons)&&(length(sigidx)>1)
    onset = sigidx(1);
    offset = sigidx(end);
else
    onset = sigidx(1);offset = [];
    for i = 1:length(iscons)
        offset = [offset,sigidx(iscons(i))];
        onset = [onset,sigidx(iscons(i)+1)];
    end
    offset = [offset,sigidx(end)];
end

M = length(onset);
contractions = [];
for m = 1:M  
    contractions = [contractions; pointer+onset(m),pointer+offset(m)];
end

if isempty(contractions)
    flag = 0;
else
    flag = 1;
end


end
