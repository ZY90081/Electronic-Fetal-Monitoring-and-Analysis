function [NoiseModelParas,AGaussian,SVMClassifier] = training_com_features(Contractions,NonContractions,Noise,Method)
% Method options:
% 'Basic'
% 'GLRT'
% 'Basic+AG'
% 'Basic+AG+GP'
% 'All'

pdf_agamma = @(x,m,alpha,lambda,k) AsymmetricGamma(x,m,alpha,lambda,k); 

% kernel definition for GPs
hypertheta0=[0,0];
kse = @(x1,x2,logsigma_f,logl) exp(logsigma_f)^2.*exp(-1./(2*exp(logl)^2).*pdist2(x1,x2).^2);
kfcn = @(x1,x2,theta) kse(x1,x2,theta(1),theta(2));

[location,shape,scale,skew] = Fun_fitAsymmetricGamma(Noise); % initial location,shape,scale,skew
NoiseModelParas = [location,shape,scale,skew];

theta0 = [40,3,2,2e4,3,2,2e4]; % initial parameters of asymmetric Gaussian model

% for contraction segments
M = length(Contractions); % number of contrations.
THETA = zeros(M,7);     % for saving parameters of asymmetric Gaussian model
FEATURES_basic = zeros(M,4); % basic features
FEATURES_AG = zeros(M,4);  % features from asymmetric Gaussian model
FEATURES_GLRT = zeros(M,1); % features from GLRT (GLRT score)
FEATURES_GP = zeros(M,2); % features from GP regression (hyperparameters)
parfor i = 1:M
    i
    % fit the asymmetric Gaussian model and estimate the optimal parameters
    [~,np] = max(Contractions{i});
    [theta_est,f_theta,~] = optisolver(Contractions{i},np,theta0,NoiseModelParas);
    THETA(i,:) = theta_est;
    % extract features from different methods
    switch Method
        case 'Basic'
            %disp('Basic')
            [FEATURES_basic(i,:),FEATURES_AG(i,:)] = Fun_extractfeatures(theta_est,f_theta);
        case 'GLRT'
            %disp('GLRT')
            FEATURES_GLRT(i) = sum(log(pdf_agamma(Contractions{i}-f_theta,location,shape,scale,skew)./pdf_agamma(Contractions{i},location,shape,scale,skew)));
        case 'Basic+AG'
            %disp('Basic and Asymmetric Gaussian Model')
            [FEATURES_basic(i,:),FEATURES_AG(i,:)] = Fun_extractfeatures(theta_est,f_theta);
        case 'Basic+AG+GP'
            %disp('Basic, Asymmetric Gaussian Model and GP')
            [FEATURES_basic(i,:),FEATURES_AG(i,:)] = Fun_extractfeatures(theta_est,f_theta);
            gprMdl = fitrgp((1:length(Contractions{i}))',(Contractions{i})','KernelFunction',kfcn,'KernelParameters',hypertheta0,'FitMethod','exact','Sigma',1e-2, 'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',struct('Verbose',0,'ShowPlots',false,'MaxObjectiveEvaluations',30,'MaxTime',inf));
            FEATURES_GP(i,:) = gprMdl.KernelInformation.KernelParameters';
        case 'All'
            %disp('All')
            [FEATURES_basic(i,:),FEATURES_AG(i,:)] = Fun_extractfeatures(theta_est,f_theta);
            FEATURES_GLRT(i) = sum(log(pdf_agamma(Contractions{i}-f_theta,location,shape,scale,skew)./pdf_agamma(Contractions{i},location,shape,scale,skew)));
            gprMdl = fitrgp((1:length(Contractions{i}))',(Contractions{i})','KernelFunction',kfcn,'KernelParameters',hypertheta0,'FitMethod','exact','Sigma',1e-2, 'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',struct('Verbose',0,'ShowPlots',false,'MaxObjectiveEvaluations',30,'MaxTime',inf));
            FEATURES_GP(i,:) = gprMdl.KernelInformation.KernelParameters';
    end
end
AGaussian = mean(THETA);

% for non-contraction segments
N = length(NonContractions); % number of non-contrations.
FEATURES_basic_N = zeros(N,4); % basic features
FEATURES_AG_N = zeros(N,4);  % features from asymmetric Gaussian model
FEATURES_GLRT_N = zeros(N,1); % features from GLRT (GLRT score)
FEATURES_GP_N = zeros(N,2); % features from GP regression (hyperparameters)
parfor i = 1:N
    i
    [~,np] = max(NonContractions{i});
    [theta_est,f_theta] = optisolver(NonContractions{i},np,theta0,NoiseModelParas);
    % extract features from different methods
    switch Method
        case 'Basic'
            %disp('Basic')
            [FEATURES_basic_N(i,:),FEATURES_AG_N(i,:)] = Fun_extractfeatures(theta_est,f_theta);
        case 'GLRT'
            %disp('GLRT')
            FEATURES_GLRT_N(i) = sum(log(pdf_agamma(NonContractions{i}-f_theta,location,shape,scale,skew)./pdf_agamma(NonContractions{i},location,shape,scale,skew)));
        case 'Basic+AG'
            %disp('Basic and Asymmetric Gaussian Model')
            [FEATURES_basic_N(i,:),FEATURES_AG_N(i,:)] = Fun_extractfeatures(theta_est,f_theta);
        case 'Basic+AG+GP'
            %disp('Basic, Asymmetric Gaussian Model and GP')
            [FEATURES_basic_N(i,:),FEATURES_AG_N(i,:)] = Fun_extractfeatures(theta_est,f_theta);
            gprMdl = fitrgp((1:length(NonContractions{i}))',(NonContractions{i})','KernelFunction',kfcn,'KernelParameters',hypertheta0,'FitMethod','exact','Sigma',1e-2, 'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',struct('Verbose',0,'ShowPlots',false,'MaxObjectiveEvaluations',30,'MaxTime',inf));
            FEATURES_GP_N(i,:) = gprMdl.KernelInformation.KernelParameters';
        case 'All'
            %disp('All')
            [FEATURES_basic_N(i,:),FEATURES_AG_N(i,:)] = Fun_extractfeatures(theta_est,f_theta);
            FEATURES_GLRT_N(i) = sum(log(pdf_agamma(NonContractions{i}-f_theta,location,shape,scale,skew)./pdf_agamma(NonContractions{i},location,shape,scale,skew)));
            gprMdl = fitrgp((1:length(NonContractions{i}))',(NonContractions{i})','KernelFunction',kfcn,'KernelParameters',hypertheta0,'FitMethod','exact','Sigma',1e-2, 'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',struct('Verbose',0,'ShowPlots',false,'MaxObjectiveEvaluations',30,'MaxTime',inf));
            FEATURES_GP_N(i,:) = gprMdl.KernelInformation.KernelParameters';
    end  
end


% Classifier
TrainingLabels = [ones(1,M),-ones(1,N)];
switch Method
    case 'Basic'
        disp('Basic')
        TrainingInputs = [FEATURES_basic',FEATURES_basic_N'];
    case 'GLRT'
        disp('GLRT')
        TrainingInputs = [FEATURES_GLRT',FEATURES_GLRT_N'];
    case 'Basic+AG'
        disp('Basic and Asymmetric Gaussian Model')
        TrainingInputs = [[FEATURES_basic FEATURES_AG]',[FEATURES_basic_N FEATURES_AG_N]'];
    case 'Basic+AG+GP'
        disp('Basic, Asymmetric Gaussian Model and GP') 
        TrainingInputs = [[FEATURES_basic FEATURES_AG FEATURES_GP]',[FEATURES_basic_N FEATURES_AG_N FEATURES_GP_N]'];
    case 'All'
        disp('All')
        TrainingInputs = [[FEATURES_basic FEATURES_AG FEATURES_GP FEATURES_GLRT]',[FEATURES_basic_N FEATURES_AG_N FEATURES_GP_N FEATURES_GLRT_N]'];
end

% SVMModel = fitcsvm(TrainingInputs',TrainingLabels');
SVMModel = fitcsvm(TrainingInputs',TrainingLabels','Standardize',true,'KernelFunction','RBF','KernelScale','auto');
CompactSVMModel = compact(SVMModel);
SVMClassifier = fitPosterior(CompactSVMModel,TrainingInputs',TrainingLabels');
% [labels,PostProbs] = predict(CompactSVMModel,0:10:2000');

end
