function output = AsymmetricGamma(x,m,alpha,lambda,k)

output = lambda^alpha./gamma(alpha)./(1/k^alpha+k^alpha).*(m-x).^(alpha-1).*exp( (x-m).*lambda./k ).*(sign(m-x)+1)./2 +...
    lambda^alpha./gamma(alpha)./(1/k^alpha+k^alpha).*(x-m).^(alpha-1).*exp( -(x-m).*lambda.*k ).*(sign(x-m)+1)./2;

output(x==m)=1e10;

end
