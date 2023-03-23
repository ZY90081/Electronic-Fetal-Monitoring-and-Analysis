function [flag,contractions] = contraction_detector_Derivative(detection_segment,parameters,pointer)


LL = parameters(1);
alpha= parameters(2);
alphas = parameters(3);
min_con = parameters(4);
min_gap = parameters(5);


DT = diff(detection_segment);
endTH = prctile(DT,alpha);
beginTH = prctile(DT,100-alpha);


onsetcandi = []; offsetcandi = [];
for i = 1:LL-2
    if (DT(i)<=beginTH) && (DT(i+1)>=beginTH) 
        onsetcandi = [onsetcandi i];
    elseif (DT(i)<=endTH) && (DT(i+1)>=endTH)
        offsetcandi = [offsetcandi i+1];
    end
end

if isempty(onsetcandi) || isempty(offsetcandi)
    flag = 0;
    contractions = NaN;
    return    
end

% contractions = onsetoffsetPair(onsetcandi,offsetcandi,detection_segment,15);

i = 1;
onset = []; onset_temp = [];
offset = []; offset_temp = [];
contractions = [];
while i<=LL
    flag = 0;
    if sum(onsetcandi==i)==0
        i = i+1;
        continue;
    elseif sum(onsetcandi==i)==1
        onset_temp = i;
        j = i+1;
        while j<=LL
            if  (sum(onsetcandi==j)==0)&&(sum(offsetcandi==j)==0)
                j = j+1;
                continue;
            elseif (sum(onsetcandi==j)==1)&&(flag==0)
                onset_temp = [onset_temp j];
                j = j+1;
                continue;
%             elseif (sum(onsetcandi==j)==1)&&(sum(signal_segment(onset_temp:j).^2)/length(onset_temp:j)<=th)&&(flag==0)
%                 onset_temp = j;
%                 j = j+1;
%                 continue;
            elseif (sum(offsetcandi==j)==1)&&(flag==0)
                offset_temp = j;
                flag = 1;
                j = j+1;
                continue;
            elseif (sum(onsetcandi==j)==1)&&(flag==1)
                break;
            elseif (sum(offsetcandi==j)==1)&&(flag==1)
                offset_temp = [offset_temp j];
                j = j+1;
                continue;
                %             elseif (sum(offsetcandi==j)==1)&&(flag==1)&&(sum(signal_segment(offset_temp:j).^2)/length(offset_temp:j)<=th)
                %                 break;
            end
        end
    end
    if flag == 1
        t = 1e3;
        for m = 1:length(onset_temp)
            for n = 1:length(offset_temp)
                if (onset_temp(m)<offset_temp(n)) && abs((offset_temp(n)-onset_temp(m))/4/60-2)<t
                    t = abs((offset_temp(n)-onset_temp(m))/4/60-2);
                    onset = onset_temp(m);
                    offset = offset_temp(n);
                end
            end
        end
        contractions = [contractions; onset,offset];
        i = offset+1;
        continue;
    else
        break;
    end
end



new = [];
if isempty(contractions)
    flag = 0;
else
    for i = 1:size(contractions,1)
        if (contractions(i,2)-contractions(i,1)>min_con) && std(detection_segment(contractions(i,1):contractions(i,2)))>2
%            if contractions(i,1)-2*60*4<=0 
%                new_segment = detection_segment(1:contractions(i,2)+2*60*4);
%                base = 0;
%            elseif contractions(i,2)+2*60*4>LL
%                new_segment = detection_segment(contractions(i,1)-2*60*4:end);
%                base = contractions(i,1)-2*60*4-1;
%            else
%                new_segment = detection_segment(contractions(i,1)-2*60*4:contractions(i,2)+2*60*4);
%                base = contractions(i,1)-2*60*4-1;
%            end
            new_onset = contractions(i,1); new_offset = contractions(i,2);
            new_segment = detection_segment(contractions(i,1):contractions(i,2));
            base = contractions(i,1)-1;
            new_derivative = diff(new_segment);
            new_endTH = prctile(new_derivative,alpha*alphas);
            new_beginTH = prctile(new_derivative,100-alpha*alphas);
            j = 1;
            while j <= length(new_derivative)-1
                if (new_derivative(j)<=new_beginTH) && (new_derivative(j+1)>=new_beginTH) 
                    new_onset = [new_onset, j + base];
                elseif (new_derivative(j)<=new_endTH) && (new_derivative(j+1)>=new_endTH)
                    new_offset = [new_offset, j+1 + base];
                end
                j = j+1;
            end
            t = 2;
            for m = 1:length(new_onset)
                for n = 1:length(new_offset)
                    if (new_onset(m)<new_offset(n)) && abs((new_offset(n)-new_onset(m))/4/60-2)<t
                        t = abs((new_offset(n)-new_onset(m))/4/60-2);
                        contractions(i,1) = new_onset(m);
                        contractions(i,2) = new_offset(n);
                    end
                end
            end
            
            
%             j = 1;
%             onsetcandi = []; offsetcandi = [];
%             for j = 1:length(new_derivative)-1
%                 if (new_derivative(j)<=new_beginTH) && (new_derivative(j+1)>=new_beginTH)
%                     onsetcandi = [onsetcandi j];
%                 elseif (new_derivative(j)>=new_endTH) && (new_derivative(j+1)<=new_endTH)
%                     offsetcandi = [offsetcandi j+1];
%                 end
%             end
%             contractions(i,1) = onsetcandi(1) + base;
%             contractions(i,2) = offsetcandi(1) + base;
%             j = 1;
%             onset = []; onset_temp = [];
%             offset = []; offset_temp = [];
%             while j<=length(new_segment)
%                 flag = 0;
%                 if sum(onsetcandi==j)==0
%                     j = j+1;
%                     continue;
%                 elseif sum(onsetcandi==j)==1
%                     onset_temp = j;
%                     k = j+1;
%                     while k<=length(new_segment)
%                         if  (sum(onsetcandi==k)==0)&&(sum(offsetcandi==k)==0)
%                             k = k+1;
%                             continue;
%                         elseif (sum(onsetcandi==k)==1)&&(flag==0)
%                             onset_temp = [onset_temp k];
%                             k = k+1;
%                             continue;
%                             %             elseif (sum(onsetcandi==j)==1)&&(sum(signal_segment(onset_temp:j).^2)/length(onset_temp:j)<=th)&&(flag==0)
%                             %                 onset_temp = j;
%                             %                 j = j+1;
%                             %                 continue;
%                         elseif (sum(offsetcandi==k)==1)&&(flag==0)
%                             offset_temp = k;
%                             flag = 1;
%                             k = k+1;
%                             continue;
%                         elseif (sum(onsetcandi==k)==1)&&(flag==1)
%                             break;
%                         elseif (sum(offsetcandi==k)==1)&&(flag==1)
%                             offset_temp = [offset_temp k];
%                             break;
%                             %             elseif (sum(offsetcandi==j)==1)&&(flag==1)&&(sum(signal_segment(offset_temp:j).^2)/length(offset_temp:j)<=th)
%                             %                 break;
%                         end
%                     end
%                     if flag == 1
%                         t = 2;
%                         for m = 1:length(onset_temp)
%                             for n = 1:length(offset_temp)
%                                 if abs((offset_temp(n)-onset_temp(m))/4/60-2)<t
%                                     t = abs((offset_temp(n)-onset_temp(m))/4/60-2);
%                                     onset = onset_temp(m);
%                                     offset = offset_temp(n);
%                                 end
%                             end
%                         end
%                         new = [new; onset,offset];
%                         j = offset;
%                         continue;
%                     else
%                         break;
%                     end
%                 end
%             end
        end
            
            
        if (i>1) && (contractions(i,1)-contractions(i-1,2)>min_gap) && std(detection_segment(contractions(i-1,2):contractions(i,1)))>2
            new_onset = []; new_offset = [];
            new_segment = detection_segment(contractions(i-1,2):contractions(i,1));
            base = contractions(i-1,2)-1;
            new_derivative = diff(new_segment);
            new_endTH = prctile(new_derivative,alpha*alphas);
            new_beginTH = prctile(new_derivative,100-alpha*alphas);
            j = 1;
            while j <= length(new_derivative)-1
                if (new_derivative(j)<=new_beginTH) && (new_derivative(j+1)>=new_beginTH) 
                    new_onset = [new_onset, j + base];
                elseif (new_derivative(j)<=new_endTH) && (new_derivative(j+1)>=new_endTH)
                    new_offset = [new_offset, j + base];
                end
                j = j+1;
            end
            if ~isempty(new_onset) && ~isempty(new_offset)
                temp = onsetoffsetPair(new_onset,new_offset,detection_segment,15);
                new = [new; temp];
            end
        end
    end
    flag = 1;
end

contractions = [contractions; new];
contractions = sortrows(contractions);
contractions = contractions + pointer.*ones(size(contractions,1),2);


end

