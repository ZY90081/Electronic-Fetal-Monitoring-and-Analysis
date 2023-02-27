function contractions = onsetoffsetPair(onsetcandi,offsetcandi,signal_segment,th)

M = length(onsetcandi);
N = length(offsetcandi);
L = length(signal_segment);

if M==0 || N==0
    contractions = [];
    return
end

temp = sort([onsetcandi offsetcandi]);
difftemp = diff(temp);
idxtemp = find(difftemp<5*4);
if ~isempty(idxtemp)
    for i = 1:length(idxtemp)
        if ismember(temp(idxtemp(i)),onsetcandi) && ismember(temp(idxtemp(i)+1),offsetcandi)
            onsetcandi((onsetcandi==temp(idxtemp(i))))= temp(idxtemp(i)+1);
            offsetcandi((offsetcandi==temp(idxtemp(i)+1)))= temp(idxtemp(i));
        end
    end
end

i = 1;
onset = [];
offset = [];
while i<=L
    flag = 0;
    if sum(onsetcandi==i)==0
        i = i+1;
        continue;
    elseif sum(onsetcandi==i)==1
        onset_temp = i;
        j = i+1;
        while j<=L
            if  (sum(onsetcandi==j)==0)&&(sum(offsetcandi==j)==0)
                j = j+1;
                continue;
            elseif (sum(onsetcandi==j)==1)&&(sum(signal_segment(onset_temp:j).^2)/length(onset_temp:j)>th)&&(flag==0)
                j = j+1;
                continue;
            elseif (sum(onsetcandi==j)==1)&&(sum(signal_segment(onset_temp:j).^2)/length(onset_temp:j)<=th)&&(flag==0)
                onset_temp = j;
                j = j+1;
                continue;
            elseif (sum(offsetcandi==j)==1)&&(flag==0)
                offset_temp = j;
                flag = 1;
                j = j+1;
                continue;
            elseif (sum(onsetcandi==j)==1)&&(flag==1)
                break;
            elseif (sum(offsetcandi==j)==1)&&(flag==1)&&(sum(signal_segment(offset_temp:j).^2)/length(offset_temp:j)>th)
                offset_temp = j;
                break; 
            elseif (sum(offsetcandi==j)==1)&&(flag==1)&&(sum(signal_segment(offset_temp:j).^2)/length(offset_temp:j)<=th)
                break;
            else
                j = j+1;
            end
        end
        if flag == 1
            onset = [onset;onset_temp];
            offset = [offset;offset_temp];
            i = offset_temp;
            continue;
        else
            break;
        end
    end
end

contractions = [onset offset];

end

