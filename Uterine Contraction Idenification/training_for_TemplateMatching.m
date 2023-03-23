function [Para_Collection] = training_for_TemplateMatching(Contractions,rho)


M = length(Contractions); % number of contrations.
theta0 = [50,100];      % a = theta(1), sigma = theta(2)

Para_Collection = zeros(M,3);
for i = 1:M
    N = length(Contractions{i});  % length of each contraction.
    np = floor(N/2);              % half length
    T = @(theta) theta(1).*exp(-((1:2*np)-np).^2./(theta(2))^2);
    W = @(theta) T([1,3*theta(2)])./sum(T([1,3*theta(2)]));
    S = Contractions{i};          % contraction
    d = @(theta) (S(1:2*np)'-T(theta)).^2;
    negf = @(theta) -exp(-rho*d(theta)*W(theta)'/theta(1)^2);    
%     T = @(a,sigma) a.*exp(-((1:2*np)-np).^2./(sigma)^2);
%     W = @(sigma) T(1,3*sigma)./sum(T(1,3*sigma));
%     S = Contractions{i};          % contraction
%     d = @(a,sigma) (S(1:2*np)'-T(a,sigma)).^2;
%     negf = @(a,sigma) -exp(-rho*d(a,sigma)*W(sigma)'/a^2);

    options = optimset('Display','off');
%     theta_est = fminsearch(negf,theta0,options);
    theta_est = fmincon(negf,theta0,[],[],[],[],[0,10],[130,1e3],[],options);

    Para_Collection(i,:) = [theta_est,2*np];
end

% plotting templates
% figure()
% for i = 1:M  
%     Temp = @(para) para(1).*exp(-((1:2*para(3))-para(3)).^2./(para(2))^2);
%     plot(Temp(Para_Collection(i,:)),'k'); hold on;
% end
% 
% figure()
% for i = 1:M  
%     Temp = @(para) para(1).*exp(-((1:2*para(3))-para(3)).^2./(para(2))^2);
%     plot(-Para_Collection(i,3)+1:Para_Collection(i,3),Temp(Para_Collection(i,:)),'k'); hold on;
% end


end
