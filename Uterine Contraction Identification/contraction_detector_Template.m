function contractions = contraction_detector_Template(detection_segment,TemplateParas,delta,rho,minConInt,minConLen,pointer)

N = length(detection_segment);

timestamps = delta:delta:N-delta;

f_similarity = zeros(1,length(timestamps));
f_para = zeros(3,length(timestamps));


% for i = 1:length(timestamps)
%     f = 0;
%     for j = 1:length(duration)-1
%         if (timestamps(i)*2<mean(duration(j:j+1))) || ((N-timestamps(i))*2<mean(duration(j:j+1)))
%             break
%         else
%             S = detection_segment(timestamps(i)-0.5*mean(duration(j:j+1))+1:timestamps(i)+0.5*mean(duration(j:j+1)));
%             np = 0.5*mean(duration(j:j+1));
%             para = TemplateParas((TemplateParas(:,3)>=duration(j))&(TemplateParas(:,3)<=duration(j+1)),1:2);
%             if isempty(para)
%                 break
%             end
%             a = mean(para(:,1));
%             sigma = mean(para(:,2));
% 
%             T = @(a,sigma) a.*exp(-((1:2*np)-np).^2./(sigma)^2);
%             W = @(sigma) T(1,3*sigma)./sum(T(1,3*sigma));
%             d = @(a,sigma) (S'-T(a,sigma)).^2;
%             fun = @(a,sigma) exp(-rho*d(a,sigma)*W(sigma)'/a^2);
% 
%             fnew = fun(a,sigma);
%             if fnew>f
%                 f_similarity(i)=fnew;
%             end
%         end
%     end
% 
%     if (timestamps(i)*2<duration(end)) || ((N-timestamps(i))*2<duration(end))
%         continue
%     else
%         S = detection_segment(timestamps(i)-0.5*duration(end)+1:timestamps(i)+0.5*duration(end));
%         np = 0.5*duration(end);
%         para = TemplateParas((TemplateParas(:,3)>=duration(end)),1:2);
%         if isempty(para)
%             continue
%         end
%         a = mean(para(:,1));
%         sigma = mean(para(:,2));
% 
%         T = @(a,sigma) a.*exp(-((1:2*np)-np).^2./(sigma)^2);
%         W = @(sigma) T(1,3*sigma)./sum(T(1,3*sigma));
%         d = @(a,sigma) (S'-T(a,sigma)).^2;
%         fun = @(a,sigma) exp(-rho*d(a,sigma)*W(sigma)'/a^2);
% 
%         fnew = fun(a,sigma);
%         if fnew>f
%             f_similarity(i)=fnew;
%         end
%     end
% end

for i = 1:length(timestamps)
    f=0;
    for j = 1:length(TemplateParas(:,1))
        if (timestamps(i)*2<TemplateParas(j,3)) || ((N-timestamps(i))*2<TemplateParas(j,3))
            break
        else
            S = detection_segment(timestamps(i)-0.5*TemplateParas(j,3)+1:timestamps(i)+0.5*TemplateParas(j,3));
            np = 0.5*TemplateParas(j,3);
            a = TemplateParas(j,1);
            sigma = TemplateParas(j,2);

            T = @(a,sigma) a.*exp(-((1:2*np)-np).^2./(sigma)^2);
            W = @(sigma) T(1,3*sigma)./sum(T(1,3*sigma));
            d = @(a,sigma) (S'-T(a,sigma)).^2;
            fun = @(a,sigma) exp(-rho*d(a,sigma)*W(sigma)'/a^2);

            fnew = fun(a,sigma);
            if fnew>f
                f_similarity(i)=fnew;
                f_para(:,i) = [a;sigma;2*np];
                f = fnew;
            end
        end
    end
end

[~,peaks] = findpeaks(f_similarity,'MinPeakProminence',0.5,'MinPeakDistance',30*4/delta,'MinPeakHeight',0.5);
location = timestamps(peaks);

if isempty(peaks)
    contractions = NaN;
    return
else
    contractions = zeros(length(peaks),2);
end

for i = 1:length(peaks)
    contractions(i,:) = [location(i)-0.5*f_para(3,peaks(i)) location(i)+0.5*f_para(3,peaks(i))];
end

%contractions = Fun_UApostprocessing(contractions,[minConInt,minConLen]);


end
