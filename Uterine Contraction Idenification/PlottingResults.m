% This program is for plotting results

clc;
close all;
clear all;


%% load UCI results

% threshold 
load('Eva1_ThresholdDetector_Czech.mat');
Czech_Thr = Eva1_ThresholdDetector;
load('Eva1_ThresholdDetector_SBU.mat');
SBU_Thr = Eva1_ThresholdDetector;
% derivative
load('UCIResult_Czech_Oxsys.mat');
Czech_Oxsys = Eva1_Oxsys;  
load('UCIResult_SBU_Oxsys.mat');
SBU_Oxsys = Eva1_Oxsys;
% template
load('UCIResult_Czech_Template_12_7.mat');
Czech_Template = UCIResult;
load('UCIResult_SBU_Template_12_7.mat');
SBU_Template = UCIResult;
% energy
load('UCIResult_Czech_Energy.mat');
Czech_Energy = Eva1_OnlyEnergyDetector;
load('UCIResult_SBU_Energy.mat');
SBU_Energy = Eva1_OnlyEnergyDetector;
% differenceOP
load('UCIResult_Czech_OnlyDiff.mat');
Czech_DiffOp = Eva1_OnlyDifferenceOperator;
load('UCIResult_SBU_OnlyDiff.mat');
SBU_DiffOp = Eva1_OnlyDifferenceOperator;
% diff + energy
load('Eval_DifferenceOperator_EnergyAdjust_Czech.mat');
Czech_DiffOpEng = Eval_DifferenceOperator_EnergyAdjust;
load('Eval_DifferenceOperator_EnergyAdjust_SBU.mat');
SBU_DiffOpEng = Eval_DifferenceOperator_EnergyAdjust;

% ALL
load('UCIResult_Czech_ALL_3_1.mat');
Czech_All = UCIResult;
load('UCIResult_SBU_ALL_3_12.mat')
SBU_All = UCIResult;

% BasicFeatures
load('UCIResult_Czech_BASIC_3_9.mat')
Czech_Basic = UCIResult;
load('UCIResult_SBU_Basic_3_13.mat')
SBU_Basic = UCIResult;

% Basic and AG Features
load('UCIResult_Czech_BasicAG_3_10.mat')
Czech_BasicAG = UCIResult;
load('UCIResult_SBU_BasicAG_3_14.mat')
SBU_BasicAG = UCIResult;

% Basic, AG and GP Features
load('UCIResult_Czech_BasicAGGP_3_10.mat')
Czech_BasicAGGP = UCIResult;
load('UCIResult_SBU_BasicAGGP_3_14.mat')
SBU_BasicAGGP = UCIResult;

% GLRT 
load('UCIResult_Czech_GLRT_3_9.mat')
Czech_GLRT = UCIResult;
load('UCIResult_SBU_GLRT_3_14.mat')
SBU_GLRT = UCIResult;


%% Read dataset
% read Czech data
load('CTUdataAll.mat');
[N,~] = size(CTUdata);  % number of FHR recordings
L = 21620; % Maximum time length

RawFHR = NaN(L,N);
RawUA = NaN(L,N);
IDseq = NaN(N,1);
ph = NaN(N,1);
apgar1 = NaN(N,1);
apgar5 = NaN(N,1);
BDecf = NaN(N,1);
for n = 1:N
    temp = length(CTUdata{n,1}.rawFHR);
    RawFHR(1:temp,n) = CTUdata{n,1}.rawFHR;
    RawUA(1:temp,n) = CTUdata{n,1}.rawUA;
    IDseq(n) = CTUdata{n,1}.ID;
    ph(n) = CTUdata{n,1}.Param.pH;
    apgar1(n) = CTUdata{n,1}.Param.Apgar1;
    apgar5(n) = CTUdata{n,1}.Param.Apgar5;
    BDecf(n) = CTUdata{n,1}.Param.BDecf;
end
clear temp;

CzechUA = RawUA;

% read SBU data
RawUA_SBU = readmatrix('UA.csv');
RawFHR_SBU = readmatrix('FHR.csv');

SBUUA = RawUA_SBU';

%% Read annotation (Ground Truth)

GroundTruth_Czech_G1 = readmatrix('Czech Y_Y.csv');
GroundTruth_Czech_G2 = readmatrix('Czech Y_Y Y_M.csv');
GroundTruth_Czech_G3 = readmatrix('Czech Y_Y Y_M M_M Y_N.csv');
GroundTruth_Czech_G4 = readmatrix('Czech Y_Y Y_M M_M Y_N M_N.csv');

Score_Czech_1 = readmatrix('Czech Score 1.csv');
Score_Czech_2 = readmatrix('Czech Score 2.csv');
Score_Czech_3 = readmatrix('Czech Score 3.csv');
Score_Czech_4 = readmatrix('Czech Score 4.csv');

GroundTruth_SBU_G1 = readmatrix('SBU Y_Y.csv');
GroundTruth_SBU_G2 = readmatrix('SBU Y_Y Y_M.csv');
GroundTruth_SBU_G3 = readmatrix('SBU Y_Y Y_M M_M Y_N.csv');
GroundTruth_SBU_G4 = readmatrix('SBU Y_Y Y_M M_M Y_N M_N.csv');

Score_SBU_1 = readmatrix('SBU Score 1.csv');
Score_SBU_2 = readmatrix('SBU Score 2.csv');
Score_SBU_3 = readmatrix('SBU Score 3.csv');
Score_SBU_4 = readmatrix('SBU Score 4.csv');

CzechID = [1,10,15,39,107,120,136,143,160,202,294,338,352,426,459];
Czechlabel = ['g','p','g','m','a','m','b','g','a','p','b','a','m','b','p'];

SBUID = [596,726,757,783,2103,2105,2362,4879,5655,6696,7176,8149,8837,10601,10606];
SBUlabel = ['p','g','g','a','g','p','a','m','b','a','m','m','b','p','b'];


%% Plot statistics of ground truth

poor1 = 0; poor2 = 0; poor3 = 0; poor4 = 0;
below1 = 0; below2 = 0; below3 = 0; below4 = 0;
average1 = 0; average2 = 0; average3 = 0; average4 = 0;
above1 = 0; above2 = 0; above3 = 0; above4 = 0;
good1 = 0; good2 = 0; good3 = 0; good4 = 0;
for i = 1:15
    id = CzechID(i);
    edge = Score_Czech_1((Score_Czech_1(:,1)==id),3:end);
    temp = edge(1,~isnan(edge(1,:)));
    num1 = size(temp,2);
    edge = Score_Czech_2((Score_Czech_2(:,1)==id),3:end);
    temp = edge(1,~isnan(edge(1,:)));
    num2 = size(temp,2);  
    edge = Score_Czech_3((Score_Czech_3(:,1)==id),3:end);
    temp = edge(1,~isnan(edge(1,:)));
    num3 = size(temp,2);
    edge = Score_Czech_4((Score_Czech_4(:,1)==id),3:end);
    temp = edge(1,~isnan(edge(1,:)));
    num4 = size(temp,2);
    switch Czechlabel(i)
        case 'p'
            poor1 = poor1 + num1;
            poor2 = poor2 + num2;
            poor3 = poor3 + num3;
            poor4 = poor4 + num4;
        case 'b'
            below1 = below1 + num1;
            below2 = below2 + num2;
            below3 = below3 + num3;
            below4 = below4 + num4;
        case 'm'
            average1 = average1 + num1;
            average2 = average2 + num2;
            average3 = average3 + num3;
            average4 = average4 + num4;
        case 'a'
            above1 = above1 + num1;
            above2 = above2 + num2;
            above3 = above3 + num3;
            above4 = above4 + num4;
        otherwise
            good1 = good1 + num1;
            good2 = good2 + num2;
            good3 = good3 + num3;
            good4 = good4 + num4;
    end
end
NUM = [poor1 poor2 poor3 poor4
    below1 below2 below3 below4
    average1 average2 average3 average4
    above1 above2 above3 above4
    good1 good2 good3 good4];
label = categorical({'Poor','Below Average','Average','Above Average','Good'});
label = reordercats(label,{'Poor','Below Average','Average','Above Average','Good'});
figure()
b = bar(label,NUM);
xtips1 = b(1).XEndPoints;
ytips1 = b(1).YEndPoints;
labels1 = string(b(1).YData);
text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
xtips2 = b(2).XEndPoints;
ytips2 = b(2).YEndPoints;
labels2 = string(b(2).YData);
text(xtips2,ytips2,labels2,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
xtips3 = b(3).XEndPoints;
ytips3 = b(3).YEndPoints;
labels3 = string(b(3).YData);
text(xtips3,ytips3,labels3,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
xtips4 = b(4).XEndPoints;
ytips4 = b(4).YEndPoints;
labels4 = string(b(4).YData);
text(xtips4,ytips4,labels4,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
legend('Score 1','Score 2','Score 3','Score 4');
ylabel('Amount');

poor1 = 0; poor2 = 0; poor3 = 0; poor4 = 0;
below1 = 0; below2 = 0; below3 = 0; below4 = 0;
average1 = 0; average2 = 0; average3 = 0; average4 = 0;
above1 = 0; above2 = 0; above3 = 0; above4 = 0;
good1 = 0; good2 = 0; good3 = 0; good4 = 0;
for i = 1:15
    id = SBUID(i);
    edge = Score_SBU_1((Score_SBU_1(:,1)==id),3:end);
    temp = edge(1,~isnan(edge(1,:)));
    num1 = size(temp,2);
    edge = Score_SBU_2((Score_SBU_2(:,1)==id),3:end);
    temp = edge(1,~isnan(edge(1,:)));
    num2 = size(temp,2);  
    edge = Score_SBU_3((Score_SBU_3(:,1)==id),3:end);
    temp = edge(1,~isnan(edge(1,:)));
    num3 = size(temp,2);
    edge = Score_SBU_4((Score_SBU_4(:,1)==id),3:end);
    temp = edge(1,~isnan(edge(1,:)));
    num4 = size(temp,2);
    switch SBUlabel(i)
        case 'p'
            poor1 = poor1 + num1;
            poor2 = poor2 + num2;
            poor3 = poor3 + num3;
            poor4 = poor4 + num4;
        case 'b'
            below1 = below1 + num1;
            below2 = below2 + num2;
            below3 = below3 + num3;
            below4 = below4 + num4;
        case 'm'
            average1 = average1 + num1;
            average2 = average2 + num2;
            average3 = average3 + num3;
            average4 = average4 + num4;
        case 'a'
            above1 = above1 + num1;
            above2 = above2 + num2;
            above3 = above3 + num3;
            above4 = above4 + num4;
        otherwise
            good1 = good1 + num1;
            good2 = good2 + num2;
            good3 = good3 + num3;
            good4 = good4 + num4;
    end
end
NUM = [poor1 poor2 poor3 poor4
    below1 below2 below3 below4
    average1 average2 average3 average4
    above1 above2 above3 above4
    good1 good2 good3 good4];
label = categorical({'Poor','Below Average','Average','Above Average','Good'});
label = reordercats(label,{'Poor','Below Average','Average','Above Average','Good'});
figure()
b = bar(label,NUM);
xtips1 = b(1).XEndPoints;
ytips1 = b(1).YEndPoints;
labels1 = string(b(1).YData);
text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
xtips2 = b(2).XEndPoints;
ytips2 = b(2).YEndPoints;
labels2 = string(b(2).YData);
text(xtips2,ytips2,labels2,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
xtips3 = b(3).XEndPoints;
ytips3 = b(3).YEndPoints;
labels3 = string(b(3).YData);
text(xtips3,ytips3,labels3,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
xtips4 = b(4).XEndPoints;
ytips4 = b(4).YEndPoints;
labels4 = string(b(4).YData);
text(xtips4,ytips4,labels4,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
legend('Score 1','Score 2','Score 3','Score 4');
ylabel('Amount');
