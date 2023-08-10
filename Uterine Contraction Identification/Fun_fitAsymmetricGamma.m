function [location,shape,scale,skew] = Fun_fitAsymmetricGamma(x)

%pdf_agamma = @(x,m,alpha,lambda,k) lambda^alpha./gamma(alpha)./(k+1/k).*(m-x).^(alpha-1).*exp( (x-m).*lambda./k ).*(sign(m-x)+1)./2 +...
%    lambda^alpha./gamma(alpha)./(k+1/k).*(x-m).^(alpha-1).*exp( -(x-m).*lambda.*k ).*(sign(x-m)+1)./2;

pdf_agamma = @(x,m,alpha,lambda,k) AsymmetricGamma(x,m,alpha,lambda,k);

start = [0,0.5,0.5,0.2];

x(x==0)=[];

parameters = mle(x,'pdf',pdf_agamma,'Start',start,'LowerBound',[-Inf,0,0,0],'UpperBound',[Inf,1,Inf,1]);

location=parameters(1);
shape=parameters(2);
scale=parameters(3);
skew=parameters(4);


end
