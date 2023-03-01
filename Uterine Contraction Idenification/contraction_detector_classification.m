function [flag,prob] = contraction_detector_classification(proUA,candidates,NoiseModelParas,theta0,Classifier,Method)
% test if candiate segment is / is not a real contraction
% Inputs:     proUA           -      post-processed UA recording
%             candidates      -      UC candidates after onset/offset detection
%             NoiseModelParas -      parameters of noise pdf
%             theta0          -      initial parameters of asymmetric Gaussian model
%             Classifier      -      trained classifier
%             Method          -      "Name" of method 

% Outputs:    flag (0/1)      -      indicator of real contraction
%             prob            -      probabilities of being real contraction

% Method options:
% 'Basic'
% 'GLRT'
% 'Basic+AG'
% 'Basic+AG+GP'
% 'All'


if isempty(candidates)
    flag = [];
    prob = [];
    return
end

M = size(candidates,1);  % number of candidates
flag = zeros(1,M);       % indicator of yes/no
prob = zeros(1,M);       % probabilities of candidates being contractions

% noise
pdf_agamma = @(x,m,alpha,lambda,k) AsymmetricGamma(x,m,alpha,lambda,k);
location = NoiseModelParas(1); shape = NoiseModelParas(2); scale = NoiseModelParas(3); skew = NoiseModelParas(4);

% kernel definition for GPs
hypertheta0=[0,0];
kse = @(x1,x2,logsigma_f,logl) exp(logsigma_f)^2.*exp(-1./(2*exp(logl)^2).*pdist2(x1,x2).^2);
kfcn = @(x1,x2,theta) kse(x1,x2,theta(1),theta(2));


% test each candidate
for m = 1:M
    onset = candidates(m,1);
    offset = candidates(m,2);  
    UAsegment = proUA(onset:offset);
    %len = length(UAsegment);

    % fit the asymmetric Gaussian model and estimate the optimal parameters
    [~,np] = max(UAsegment);
    [theta_est,f_theta,~] = optisolver(UAsegment,np,theta0,NoiseModelParas);
    
    % extract features from different methods
    [FEATURES_basic,FEATURES_AG] = Fun_extractfeatures(theta_est,f_theta);
    FEATURES_GLRT = sum(log(pdf_agamma(UAsegment-f_theta,location,shape,scale,skew)./pdf_agamma(UAsegment,location,shape,scale,skew)));
    gprMdl = fitrgp((1:length(UAsegment))',UAsegment','KernelFunction',kfcn,'KernelParameters',hypertheta0,'FitMethod','exact','Sigma',1e-2, 'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',struct('Verbose',0,'ShowPlots',false,'MaxObjectiveEvaluations',30,'MaxTime',inf));
    FEATURES_GP = gprMdl.KernelInformation.KernelParameters;
    switch Method
        case 'Basic'
            %disp('Basic')
            TestInputs = FEATURES_basic';
        case 'GLRT'
            %disp('GLRT')
            TestInputs = FEATURES_GLRT';
        case 'Basic+AG'
            %disp('Basic and Asymmetric Gaussian Model')
            TestInputs = [FEATURES_basic FEATURES_AG]';
        case 'Basic+AG+GP'
            %disp('Basic, Asymmetric Gaussian Model and GP')
            TestInputs = [FEATURES_basic FEATURES_AG FEATURES_GP]';
        case 'All'
            %disp('All')
            TestInputs = [FEATURES_basic FEATURES_AG FEATURES_GP FEATURES_GLRT]';
    end

    % classification
    [label,PostProb] = predict(Classifier,TestInputs');
    if label==1
        flag(m) = 1;
    else
        flag(m) = 0;
    end
    prob(m) = PostProb(2);
end

end

