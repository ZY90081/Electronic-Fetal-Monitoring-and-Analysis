function [poorIOU,belowIOU,averageIOU,aboveIOU,goodIOU] = IOUsEdge(Results,DataID,DataLabel,Data,Groundtruth)


[M,N] = size(Results);

if M==1

poorIOU = []; belowIOU = []; averageIOU = []; aboveIOU = []; goodIOU = [];
for i = 1:N
    ContractionsSaving = Results{i}.Contractions;
    id = DataID(i);
    SIGua = Data(:,id);
    SIGua = SIGua(~isnan(SIGua));
    Lua = length(SIGua);    
    edge = Groundtruth((Groundtruth(:,1)==id),3:end);
    onsetTrue = edge(1,:);
    offsetTrue = edge(2,:);
    onsetTrue = onsetTrue(~isnan(onsetTrue));
    offsetTrue = offsetTrue(~isnan(offsetTrue));
    T = (Lua+1)./4./60;
    onsetTrue = round((onsetTrue + T)*60*4);
    offsetTrue = round((offsetTrue + T)*60*4);    
    
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
    switch DataLabel(i)
        case 'p'
            poorIOU = [poorIOU IOU];
        case 'b'
            belowIOU = [belowIOU IOU];
        case 'm'
            averageIOU = [averageIOU IOU];
        case 'a'
            aboveIOU = [aboveIOU IOU];
        otherwise
            goodIOU = [goodIOU IOU];
    end
end
poorIOU(poorIOU==0)=[];
belowIOU(belowIOU==0)=[];
averageIOU(averageIOU==0)=[];
aboveIOU(aboveIOU==0)=[];
goodIOU(goodIOU==0)=[];

else

poorIOU = []; belowIOU = []; averageIOU = []; aboveIOU = []; goodIOU = [];
for i = 1:M
    for j = 1:N
        ContractionsSaving = Results{i,j}.Contractions;
        id = Results{i,j}.ID;
        SIGua = Data(:,id);
        SIGua = SIGua(~isnan(SIGua));
        Lua = length(SIGua);
        edge = Groundtruth((Groundtruth(:,1)==id),3:end);
        onsetTrue = edge(1,:);
        offsetTrue = edge(2,:);
        onsetTrue = onsetTrue(~isnan(onsetTrue));
        offsetTrue = offsetTrue(~isnan(offsetTrue));
        T = (Lua+1)./4./60;
        onsetTrue = round((onsetTrue + T)*60*4);
        offsetTrue = round((offsetTrue + T)*60*4);

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
        switch DataLabel(DataID==id)
            case 'p'
                poorIOU = [poorIOU IOU];
            case 'b'
                belowIOU = [belowIOU IOU];
            case 'm'
                averageIOU = [averageIOU IOU];
            case 'a'
                aboveIOU = [aboveIOU IOU];
            otherwise
                goodIOU = [goodIOU IOU];
        end
    end
end
poorIOU(poorIOU==0)=[];
belowIOU(belowIOU==0)=[];
averageIOU(averageIOU==0)=[];
aboveIOU(aboveIOU==0)=[];
goodIOU(goodIOU==0)=[];


end

end
