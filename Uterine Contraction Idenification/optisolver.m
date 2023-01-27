function [theta_est,f_theta,neglog] = optisolver(x,np,theta0,para)

len = length(x);

f = @(theta) ((1:len)'<=np).*(theta(2)*ones(len,1)+(theta(1)-theta(2)).*exp(-(np-((1:len)')).^theta(3)./theta(4))) + ...
    ((1:len)'>np).*(theta(5)*ones(len,1)+(theta(1)-theta(5)).*exp(-(((1:len)')-np).^theta(6)./theta(7)));

fun = @(theta) x'*x + f(theta)'*f(theta) - 2*x'*f(theta);

% MLE
location = para(1); shape = para(2); scale = para(3); skew = para(4);

pdf_agamma = @(x,m,alpha,lambda,k) AsymmetricGamma(x,m,alpha,lambda,k);

neglogpdf = @(theta) -sum(log(pdf_agamma(x - f(theta),location,shape,scale,skew)));
options = optimset('Display','off');
theta_est = fminsearch(neglogpdf,theta0,options);
f_theta = f(theta_est);
neglog = neglogpdf(theta_est);

end
