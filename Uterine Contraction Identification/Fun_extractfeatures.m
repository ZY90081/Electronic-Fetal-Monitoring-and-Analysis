function [output1,output2] = Fun_extractfeatures(theta_est,f_theta)

A = theta_est(1);
bl = theta_est(2);
alphal = theta_est(3);
betal = theta_est(4);
br = theta_est(5);
alphar = theta_est(6);
betar = theta_est(7);

th = 10;  % detection line: 10 above the base

[~,np] = max(f_theta);

taul = find(f_theta(1:np)>=bl+th);
taur = find(f_theta(np:end)>=br+th);
if isempty(taul)
    taul = 1:np;
end
if isempty(taur)
    taur = np:length(f_theta);
end
tau = taur(end)-taul(1)+1;   % duration
amp = (2*A-bl-br)/2;         % amplitude
tangamal = (A-bl-th)/length(taul);  % slopes
tangamar = (A-br-th)/length(taur);

output1 = [tau,amp,tangamal,tangamar];    % basic/morphologic features
output2 = [alphal,betal,alphar,betar];    % asymmetric Gaussian model

end
