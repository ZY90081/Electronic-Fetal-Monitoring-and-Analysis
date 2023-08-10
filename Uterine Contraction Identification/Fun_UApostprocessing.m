function output = Fun_UApostprocessing(Contractions,Parameters)

minConInt = Parameters(1);
minConLen = Parameters(2);

if isempty(Contractions)
    output = [];
    return
end


% ===== Adjust by interval and length
tempidx = find((Contractions(2:end,1)-Contractions(1:end-1,2))<=minConInt);
j=1;
while j<=length(tempidx)
    %begin = candidates(tempidx(j),1);
    beginidx = tempidx(j);
    endidx = tempidx(j)+1;
    if j<length(tempidx)
        while (j<length(tempidx)) && (diff(tempidx(j:j+1))==1) % combine multiple candidates together
            j = j+1;
            endidx = tempidx(j)+1;
        end
    end
    Contractions(beginidx,2) = Contractions(endidx,2);
    j = j+1;
end
Contractions(tempidx+1,:) = []; % remove the duplicated segments
Contractions((Contractions(:,2)-Contractions(:,1))<=minConLen,:) = [];  % remove very short segments
% ======================================

output = Contractions;
