function [PPV_Precision,TPR_Recall, AUC] = PR_plot(Results,DataID,DataLabel,Data,IOUth,GroundTruth,class)

[M,N] = size(Results);

outputs = zeros(1,3); % TP,FP,NP


if M==1
for i = 1:N
    if DataLabel(i)~=class
        continue
    end
    % RESULT
    id = DataID(i);
    ContractionsSaving = Results{i}.Contractions;
    Num_R = size(ContractionsSaving,1);
    SIGua = Data(:,id);
    SIGua = SIGua(~isnan(SIGua));
    Lua = length(SIGua);
    t=(1-Lua:0)./4./60;

    % TRUTH
    edge = GroundTruth((GroundTruth(:,1)==id),3:end);
    onsetTrue = edge(1,:);
    offsetTrue = edge(2,:);
    onsetTrue = onsetTrue(~isnan(onsetTrue));
    offsetTrue = offsetTrue(~isnan(offsetTrue));
    T = (Lua+1)./4./60;
    onsetTrue = round((onsetTrue + T)*60*4);
    offsetTrue = round((offsetTrue + T)*60*4);
    Num_T = length(onsetTrue);

    % check
    TP = 0;FP = 0;FN = 0;
    for nr = 1:Num_R
        temp = 0;
        for nt = 1:Num_T
            if isempty(intersect(ContractionsSaving(nr,1):ContractionsSaving(nr,2),onsetTrue(nt):offsetTrue(nt)))
                continue
            end
            iou = length(intersect(ContractionsSaving(nr,1):ContractionsSaving(nr,2),onsetTrue(nt):offsetTrue(nt)))/length(union(ContractionsSaving(nr,1):ContractionsSaving(nr,2),onsetTrue(nt):offsetTrue(nt)));
            if iou>=IOUth
                TP = TP + 1;
                temp = 1;
            end
        end
        if temp == 0
            FP = FP + 1;
        end
    end
    for nt = 1:Num_T
        temp = 0;
        for nr = 1:Num_R
            if ~isempty(intersect(ContractionsSaving(nr,1):ContractionsSaving(nr,2),onsetTrue(nt):offsetTrue(nt)))
                temp = 1;
            end
        end
        if temp == 0
            FN = FN + 1;
        end
    end

    outputs = outputs + [TP FP FN];
end
PPV_Precision = outputs(1)/(outputs(1)+outputs(2));
TPR_Recall = outputs(1)/(outputs(1)+outputs(3));
AUC = NaN;

else

Kfold = size(Results,1);
switch class
    case 'g'
        Col = 5;
    case 'a'
        Col = 4;
    case 'm'
        Col = 3;
    case 'b'
        Col = 2;
    case 'p'
        Col = 1;
end

Scores = [];
Target = [];
for i = 1:Kfold
    % RESULT
    id = Results{i,Col}.ID;
    ContractionsSaving = Results{i,Col}.Contractions;
    Num_R = size(ContractionsSaving,1);
    %Flag_R = Results{i,Col}.Flag;
    if isfield(Results{1,1},'Score')
        Score_R = Results{i,Col}.Score;
    else
        Score_R = ones(1,Num_R);
    end
    SIGua = Data(:,id);
    SIGua = SIGua(~isnan(SIGua));
    Lua = length(SIGua);
    t=(1-Lua:0)./4./60;
    % TRUTH
    edge = GroundTruth((GroundTruth(:,1)==id),3:end);
    onsetTrue = edge(1,:);
    offsetTrue = edge(2,:);
    onsetTrue = onsetTrue(~isnan(onsetTrue));
    offsetTrue = offsetTrue(~isnan(offsetTrue));
    T = (Lua+1)./4./60;
    onsetTrue = round((onsetTrue + T)*60*4);
    offsetTrue = round((offsetTrue + T)*60*4);
    Num_T = length(onsetTrue);

    % check
    for nr = 1:Num_R
        temp = 0;
        for nt = 1:Num_T
            if isempty(intersect(ContractionsSaving(nr,1):ContractionsSaving(nr,2),onsetTrue(nt):offsetTrue(nt)))
                continue
            end
            iou = length(intersect(ContractionsSaving(nr,1):ContractionsSaving(nr,2),onsetTrue(nt):offsetTrue(nt)))/length(union(ContractionsSaving(nr,1):ContractionsSaving(nr,2),onsetTrue(nt):offsetTrue(nt)));
            if iou>=IOUth
                Target = [Target 1];
                Scores = [Scores Score_R(nr)];
                temp = 1;
            end
        end
        if temp == 0
            Target = [Target 0];
            Scores = [Scores Score_R(nr)];
        end
    end
    for nt = 1:Num_T
        temp = 0;
        for nr = 1:Num_R
            if ~isempty(intersect(ContractionsSaving(nr,1):ContractionsSaving(nr,2),onsetTrue(nt):offsetTrue(nt)))
                temp = 1;
            end
        end
        if temp == 0
            Target = [Target 1];
            Scores = [Scores 0];
        end
    end
end

if isfield(Results{1,1},'Score')
    [TPR_Recall, PPV_Precision, T, AUC] = perfcurve(Target, Scores, 1,'XCrit', 'reca', 'YCrit', 'prec');
else
    TP = sum((Target&Scores));
    FP = sum((Target==0)&(Scores==1));
    FN = sum((Target==1)&(Scores==0));
    PPV_Precision = TP/(TP+FP);
    TPR_Recall = TP/(TP+FN);
    AUC = NaN;
end


end

