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


%% Plotting edge detection accuracy 

[Czech_Thr_poorIOU,Czech_Thr_belowIOU,Czech_Thr_averageIOU,Czech_Thr_aboveIOU,Czech_Thr_goodIOU] = IOUsEdge(Czech_Thr,CzechID,Czechlabel,CzechUA,GroundTruth_Czech_G4);
[Czech_Oxsys_poorIOU,Czech_Oxsys_belowIOU,Czech_Oxsys_averageIOU,Czech_Oxsys_aboveIOU,Czech_Oxsys_goodIOU] = IOUsEdge(Czech_Oxsys,CzechID,Czechlabel,CzechUA,GroundTruth_Czech_G4);
[Czech_Energy_poorIOU,Czech_Energy_belowIOU,Czech_Energy_averageIOU,Czech_Energy_aboveIOU,Czech_Energy_goodIOU] = IOUsEdge(Czech_Energy,CzechID,Czechlabel,CzechUA,GroundTruth_Czech_G4);
[Czech_DiffOp_poorIOU,Czech_DiffOp_belowIOU,Czech_DiffOp_averageIOU,Czech_DiffOp_aboveIOU,Czech_DiffOp_goodIOU] = IOUsEdge(Czech_DiffOp,CzechID,Czechlabel,CzechUA,GroundTruth_Czech_G4);
[Czech_DiffOpEng_poorIOU,Czech_DiffOpEng_belowIOU,Czech_DiffOpEng_averageIOU,Czech_DiffOpEng_aboveIOU,Czech_DiffOpEng_goodIOU] = IOUsEdge(Czech_DiffOpEng,CzechID,Czechlabel,CzechUA,GroundTruth_Czech_G4);
[Czech_Template_poorIOU,Czech_Template_belowIOU,Czech_Template_averageIOU,Czech_Template_aboveIOU,Czech_Template_goodIOU] = IOUsEdge(Czech_Template,CzechID,Czechlabel,CzechUA,GroundTruth_Czech_G4);

figure(); hold on;
markersize = 5;
boxchart(ones(1,length(Czech_Thr_poorIOU)),Czech_Thr_poorIOU,'BoxFaceColor',[0.6350 0.0780 0.1840],'MarkerStyle','none');
boxchart(2*ones(1,length(Czech_Template_poorIOU)),Czech_Template_poorIOU,'BoxFaceColor',[0.4660 0.6740 0.1880],'MarkerStyle','none');
boxchart(3*ones(1,length(Czech_Oxsys_poorIOU)),Czech_Oxsys_poorIOU,'BoxFaceColor',[0.4940 0.1840 0.5560],'MarkerStyle','none');
boxchart(4*ones(1,length(Czech_Energy_poorIOU)),Czech_Energy_poorIOU,'BoxFaceColor',[0.9290 0.6940 0.1250],'MarkerStyle','none');
boxchart(5*ones(1,length(Czech_DiffOp_poorIOU)),Czech_DiffOp_poorIOU,'BoxFaceColor',[0.8500 0.3250 0.0980],'MarkerStyle','none');
boxchart(6*ones(1,length(Czech_DiffOpEng_poorIOU)),Czech_DiffOpEng_poorIOU,'BoxFaceColor',[0 0.4470 0.7410],'MarkerStyle','none');
scatter(ones(size(Czech_Thr_poorIOU)).*(1+(rand(size(Czech_Thr_poorIOU))-0.5)/10),Czech_Thr_poorIOU,markersize,'filled','MarkerFaceColor',[0.6350 0.0780 0.1840]);
scatter(ones(size(Czech_Template_poorIOU)).*(2+(rand(size(Czech_Template_poorIOU))-0.5)/10),Czech_Template_poorIOU,markersize,'filled','MarkerFaceColor',[0.4660 0.6740 0.1880]);
scatter(ones(size(Czech_Oxsys_poorIOU)).*(3+(rand(size(Czech_Oxsys_poorIOU))-0.5)/10),Czech_Oxsys_poorIOU,markersize,'filled','MarkerFaceColor',[0.4940 0.1840 0.5560]);
scatter(ones(size(Czech_Energy_poorIOU)).*(4+(rand(size(Czech_Energy_poorIOU))-0.5)/10),Czech_Energy_poorIOU,markersize,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250]);
scatter(ones(size(Czech_DiffOp_poorIOU)).*(5+(rand(size(Czech_DiffOp_poorIOU))-0.5)/10),Czech_DiffOp_poorIOU,markersize,'filled','MarkerFaceColor',[0.8500 0.3250 0.0980]);
scatter(ones(size(Czech_DiffOpEng_poorIOU)).*(6+(rand(size(Czech_DiffOpEng_poorIOU))-0.5)/10),Czech_DiffOpEng_poorIOU,markersize,'filled','MarkerFaceColor',[0 0.4470 0.7410]);


scatter(ones(size(Czech_Thr_belowIOU)).*(8+(rand(size(Czech_Thr_belowIOU))-0.5)/10),Czech_Thr_belowIOU,markersize,'filled','MarkerFaceColor',[0.6350 0.0780 0.1840]);
boxchart(8*ones(1,length(Czech_Thr_belowIOU)),Czech_Thr_belowIOU,'BoxFaceColor',[0.6350 0.0780 0.1840],'MarkerStyle','none');
scatter(ones(size(Czech_Template_belowIOU)).*(9+(rand(size(Czech_Template_belowIOU))-0.5)/10),Czech_Template_belowIOU,markersize,'filled','MarkerFaceColor',[0.4660 0.6740 0.1880]);
boxchart(9*ones(1,length(Czech_Template_belowIOU)),Czech_Template_belowIOU,'BoxFaceColor',[0.4660 0.6740 0.1880],'MarkerStyle','none');
scatter(ones(size(Czech_Oxsys_belowIOU)).*(10+(rand(size(Czech_Oxsys_belowIOU))-0.5)/10),Czech_Oxsys_belowIOU,markersize,'filled','MarkerFaceColor',[0.4940 0.1840 0.5560]);
boxchart(10*ones(1,length(Czech_Oxsys_belowIOU)),Czech_Oxsys_belowIOU,'BoxFaceColor',[0.4940 0.1840 0.5560],'MarkerStyle','none');
scatter(ones(size(Czech_Energy_belowIOU)).*(11+(rand(size(Czech_Energy_belowIOU))-0.5)/10),Czech_Energy_belowIOU,markersize,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250]);
boxchart(11*ones(1,length(Czech_Energy_belowIOU)),Czech_Energy_belowIOU,'BoxFaceColor',[0.9290 0.6940 0.1250],'MarkerStyle','none');
scatter(ones(size(Czech_DiffOp_belowIOU)).*(12+(rand(size(Czech_DiffOp_belowIOU))-0.5)/10),Czech_DiffOp_belowIOU,markersize,'filled','MarkerFaceColor',[0.8500 0.3250 0.0980]);
boxchart(12*ones(1,length(Czech_DiffOp_belowIOU)),Czech_DiffOp_belowIOU,'BoxFaceColor',[0.8500 0.3250 0.0980],'MarkerStyle','none');
scatter(ones(size(Czech_DiffOpEng_belowIOU)).*(13+(rand(size(Czech_DiffOpEng_belowIOU))-0.5)/10),Czech_DiffOpEng_belowIOU,markersize,'filled','MarkerFaceColor',[0 0.4470 0.7410]);
boxchart(13*ones(1,length(Czech_DiffOpEng_belowIOU)),Czech_DiffOpEng_belowIOU,'BoxFaceColor',[0 0.4470 0.7410],'MarkerStyle','none');

scatter(ones(size(Czech_Thr_averageIOU)).*(15+(rand(size(Czech_Thr_averageIOU))-0.5)/10),Czech_Thr_averageIOU,markersize,'filled','MarkerFaceColor',[0.6350 0.0780 0.1840]);
boxchart(15*ones(1,length(Czech_Thr_averageIOU)),Czech_Thr_averageIOU,'BoxFaceColor',[0.6350 0.0780 0.1840],'MarkerStyle','none');
scatter(ones(size(Czech_Template_averageIOU)).*(16+(rand(size(Czech_Template_averageIOU))-0.5)/10),Czech_Template_averageIOU,markersize,'filled','MarkerFaceColor',[0.4660 0.6740 0.1880]);
boxchart(16*ones(1,length(Czech_Template_averageIOU)),Czech_Template_averageIOU,'BoxFaceColor',[0.4660 0.6740 0.1880],'MarkerStyle','none');
scatter(ones(size(Czech_Oxsys_averageIOU)).*(17+(rand(size(Czech_Oxsys_averageIOU))-0.5)/10),Czech_Oxsys_averageIOU,markersize,'filled','MarkerFaceColor',[0.4940 0.1840 0.5560]);
boxchart(17*ones(1,length(Czech_Oxsys_averageIOU)),Czech_Oxsys_averageIOU,'BoxFaceColor',[0.4940 0.1840 0.5560],'MarkerStyle','none');
scatter(ones(size(Czech_Energy_averageIOU)).*(18+(rand(size(Czech_Energy_averageIOU))-0.5)/10),Czech_Energy_averageIOU,markersize,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250]);
boxchart(18*ones(1,length(Czech_Energy_averageIOU)),Czech_Energy_averageIOU,'BoxFaceColor',[0.9290 0.6940 0.1250],'MarkerStyle','none');
scatter(ones(size(Czech_DiffOp_averageIOU)).*(19+(rand(size(Czech_DiffOp_averageIOU))-0.5)/10),Czech_DiffOp_averageIOU,markersize,'filled','MarkerFaceColor',[0.8500 0.3250 0.0980]);
boxchart(19*ones(1,length(Czech_DiffOp_averageIOU)),Czech_DiffOp_averageIOU,'BoxFaceColor',[0.8500 0.3250 0.0980],'MarkerStyle','none');
scatter(ones(size(Czech_DiffOpEng_averageIOU)).*(20+(rand(size(Czech_DiffOpEng_averageIOU))-0.5)/10),Czech_DiffOpEng_averageIOU,markersize,'filled','MarkerFaceColor',[0 0.4470 0.7410]);
boxchart(20*ones(1,length(Czech_DiffOpEng_averageIOU)),Czech_DiffOpEng_averageIOU,'BoxFaceColor',[0 0.4470 0.7410],'MarkerStyle','none');


scatter(ones(size(Czech_Thr_aboveIOU)).*(22+(rand(size(Czech_Thr_aboveIOU))-0.5)/10),Czech_Thr_aboveIOU,markersize,'filled','MarkerFaceColor',[0.6350 0.0780 0.1840]);
boxchart(22*ones(1,length(Czech_Thr_aboveIOU)),Czech_Thr_aboveIOU,'BoxFaceColor',[0.6350 0.0780 0.1840],'MarkerStyle','none');
scatter(ones(size(Czech_Template_aboveIOU)).*(23+(rand(size(Czech_Template_aboveIOU))-0.5)/10),Czech_Template_aboveIOU,markersize,'filled','MarkerFaceColor',[0.4660 0.6740 0.1880]);
boxchart(23*ones(1,length(Czech_Template_aboveIOU)),Czech_Template_aboveIOU,'BoxFaceColor',[0.4660 0.6740 0.1880],'MarkerStyle','none');
scatter(ones(size(Czech_Oxsys_aboveIOU)).*(24+(rand(size(Czech_Oxsys_aboveIOU))-0.5)/10),Czech_Oxsys_aboveIOU,markersize,'filled','MarkerFaceColor',[0.4940 0.1840 0.5560]);
boxchart(24*ones(1,length(Czech_Oxsys_aboveIOU)),Czech_Oxsys_aboveIOU,'BoxFaceColor',[0.4940 0.1840 0.5560],'MarkerStyle','none');
scatter(ones(size(Czech_Energy_aboveIOU)).*(25+(rand(size(Czech_Energy_aboveIOU))-0.5)/10),Czech_Energy_aboveIOU,markersize,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250]);
boxchart(25*ones(1,length(Czech_Energy_aboveIOU)),Czech_Energy_aboveIOU,'BoxFaceColor',[0.9290 0.6940 0.1250],'MarkerStyle','none');
scatter(ones(size(Czech_DiffOp_aboveIOU)).*(26+(rand(size(Czech_DiffOp_aboveIOU))-0.5)/10),Czech_DiffOp_aboveIOU,markersize,'filled','MarkerFaceColor',[0.8500 0.3250 0.0980]);
boxchart(26*ones(1,length(Czech_DiffOp_aboveIOU)),Czech_DiffOp_aboveIOU,'BoxFaceColor',[0.8500 0.3250 0.0980],'MarkerStyle','none');
scatter(ones(size(Czech_DiffOpEng_aboveIOU)).*(27+(rand(size(Czech_DiffOpEng_aboveIOU))-0.5)/10),Czech_DiffOpEng_aboveIOU,markersize,'filled','MarkerFaceColor',[0 0.4470 0.7410]);
boxchart(27*ones(1,length(Czech_DiffOpEng_aboveIOU)),Czech_DiffOpEng_aboveIOU,'BoxFaceColor',[0 0.4470 0.7410],'MarkerStyle','none');

scatter(ones(size(Czech_Thr_goodIOU)).*(29+(rand(size(Czech_Thr_goodIOU))-0.5)/10),Czech_Thr_goodIOU,markersize,'filled','MarkerFaceColor',[0.6350 0.0780 0.1840]);
boxchart(29*ones(1,length(Czech_Thr_goodIOU)),Czech_Thr_goodIOU,'BoxFaceColor',[0.6350 0.0780 0.1840],'MarkerStyle','none');
scatter(ones(size(Czech_Template_goodIOU)).*(30+(rand(size(Czech_Template_goodIOU))-0.5)/10),Czech_Template_goodIOU,markersize,'filled','MarkerFaceColor',[0.4660 0.6740 0.1880]);
boxchart(30*ones(1,length(Czech_Template_goodIOU)),Czech_Template_goodIOU,'BoxFaceColor',[0.4660 0.6740 0.1880],'MarkerStyle','none');
scatter(ones(size(Czech_Oxsys_goodIOU)).*(31+(rand(size(Czech_Oxsys_goodIOU))-0.5)/10),Czech_Oxsys_goodIOU,markersize,'filled','MarkerFaceColor',[0.4940 0.1840 0.5560]);
boxchart(31*ones(1,length(Czech_Oxsys_goodIOU)),Czech_Oxsys_goodIOU,'BoxFaceColor',[0.4940 0.1840 0.5560],'MarkerStyle','none');
scatter(ones(size(Czech_Energy_goodIOU)).*(32+(rand(size(Czech_Energy_goodIOU))-0.5)/10),Czech_Energy_goodIOU,markersize,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250]);
boxchart(32*ones(1,length(Czech_Energy_goodIOU)),Czech_Energy_goodIOU,'BoxFaceColor',[0.9290 0.6940 0.1250],'MarkerStyle','none');
scatter(ones(size(Czech_DiffOp_goodIOU)).*(33+(rand(size(Czech_DiffOp_goodIOU))-0.5)/10),Czech_DiffOp_goodIOU,markersize,'filled','MarkerFaceColor',[0.8500 0.3250 0.0980]);
boxchart(33*ones(1,length(Czech_DiffOp_goodIOU)),Czech_DiffOp_goodIOU,'BoxFaceColor',[0.8500 0.3250 0.0980],'MarkerStyle','none');
scatter(ones(size(Czech_DiffOpEng_goodIOU)).*(34+(rand(size(Czech_DiffOpEng_goodIOU))-0.5)/10),Czech_DiffOpEng_goodIOU,markersize,'filled','MarkerFaceColor',[0 0.4470 0.7410]);
boxchart(34*ones(1,length(Czech_DiffOpEng_goodIOU)),Czech_DiffOpEng_goodIOU,'BoxFaceColor',[0 0.4470 0.7410],'MarkerStyle','none');



[SBU_Thr_poorIOU,SBU_Thr_belowIOU,SBU_Thr_averageIOU,SBU_Thr_aboveIOU,SBU_Thr_goodIOU] = IOUsEdge(SBU_Thr,SBUID,SBUlabel,SBUUA,GroundTruth_SBU_G4);
[SBU_Oxsys_poorIOU,SBU_Oxsys_belowIOU,SBU_Oxsys_averageIOU,SBU_Oxsys_aboveIOU,SBU_Oxsys_goodIOU] = IOUsEdge(SBU_Oxsys,SBUID,SBUlabel,SBUUA,GroundTruth_SBU_G4);
[SBU_Energy_poorIOU,SBU_Energy_belowIOU,SBU_Energy_averageIOU,SBU_Energy_aboveIOU,SBU_Energy_goodIOU] = IOUsEdge(SBU_Energy,SBUID,SBUlabel,SBUUA,GroundTruth_SBU_G4);
[SBU_DiffOp_poorIOU,SBU_DiffOp_belowIOU,SBU_DiffOp_averageIOU,SBU_DiffOp_aboveIOU,SBU_DiffOp_goodIOU] = IOUsEdge(SBU_DiffOp,SBUID,SBUlabel,SBUUA,GroundTruth_SBU_G4);
[SBU_DiffOpEng_poorIOU,SBU_DiffOpEng_belowIOU,SBU_DiffOpEng_averageIOU,SBU_DiffOpEng_aboveIOU,SBU_DiffOpEng_goodIOU] = IOUsEdge(SBU_DiffOpEng,SBUID,SBUlabel,SBUUA,GroundTruth_SBU_G4);
[SBU_Template_poorIOU,SBU_Template_belowIOU,SBU_Template_averageIOU,SBU_Template_aboveIOU,SBU_Template_goodIOU] = IOUsEdge(SBU_Template,SBUID,SBUlabel,SBUUA,GroundTruth_SBU_G4);

figure(); hold on;
markersize = 5;
boxchart(ones(1,length(SBU_Thr_poorIOU)),SBU_Thr_poorIOU,'BoxFaceColor',[0.6350 0.0780 0.1840],'MarkerStyle','none');
boxchart(2*ones(1,length(SBU_Template_poorIOU)),SBU_Template_poorIOU,'BoxFaceColor',[0.4660 0.6740 0.1880],'MarkerStyle','none');
boxchart(3*ones(1,length(SBU_Oxsys_poorIOU)),SBU_Oxsys_poorIOU,'BoxFaceColor',[0.4940 0.1840 0.5560],'MarkerStyle','none');
boxchart(4*ones(1,length(SBU_Energy_poorIOU)),SBU_Energy_poorIOU,'BoxFaceColor',[0.9290 0.6940 0.1250],'MarkerStyle','none');
boxchart(5*ones(1,length(SBU_DiffOp_poorIOU)),SBU_DiffOp_poorIOU,'BoxFaceColor',[0.8500 0.3250 0.0980],'MarkerStyle','none');
boxchart(6*ones(1,length(SBU_DiffOpEng_poorIOU)),SBU_DiffOpEng_poorIOU,'BoxFaceColor',[0 0.4470 0.7410],'MarkerStyle','none');
scatter(ones(size(SBU_Thr_poorIOU)).*(1+(rand(size(SBU_Thr_poorIOU))-0.5)/10),SBU_Thr_poorIOU,markersize,'filled','MarkerFaceColor',[0.6350 0.0780 0.1840]);
scatter(ones(size(SBU_Template_poorIOU)).*(2+(rand(size(SBU_Template_poorIOU))-0.5)/10),SBU_Template_poorIOU,markersize,'filled','MarkerFaceColor',[0.4660 0.6740 0.1880]);
scatter(ones(size(SBU_Oxsys_poorIOU)).*(3+(rand(size(SBU_Oxsys_poorIOU))-0.5)/10),SBU_Oxsys_poorIOU,markersize,'filled','MarkerFaceColor',[0.4940 0.1840 0.5560]);
scatter(ones(size(SBU_Energy_poorIOU)).*(4+(rand(size(SBU_Energy_poorIOU))-0.5)/10),SBU_Energy_poorIOU,markersize,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250]);
scatter(ones(size(SBU_DiffOp_poorIOU)).*(5+(rand(size(SBU_DiffOp_poorIOU))-0.5)/10),SBU_DiffOp_poorIOU,markersize,'filled','MarkerFaceColor',[0.8500 0.3250 0.0980]);
scatter(ones(size(SBU_DiffOpEng_poorIOU)).*(6+(rand(size(SBU_DiffOpEng_poorIOU))-0.5)/10),SBU_DiffOpEng_poorIOU,markersize,'filled','MarkerFaceColor',[0 0.4470 0.7410]);


scatter(ones(size(SBU_Thr_belowIOU)).*(8+(rand(size(SBU_Thr_belowIOU))-0.5)/10),SBU_Thr_belowIOU,markersize,'filled','MarkerFaceColor',[0.6350 0.0780 0.1840]);
boxchart(8*ones(1,length(SBU_Thr_belowIOU)),SBU_Thr_belowIOU,'BoxFaceColor',[0.6350 0.0780 0.1840],'MarkerStyle','none');
scatter(ones(size(SBU_Template_belowIOU)).*(9+(rand(size(SBU_Template_belowIOU))-0.5)/10),SBU_Template_belowIOU,markersize,'filled','MarkerFaceColor',[0.4660 0.6740 0.1880]);
boxchart(9*ones(1,length(SBU_Template_belowIOU)),SBU_Template_belowIOU,'BoxFaceColor',[0.4660 0.6740 0.1880],'MarkerStyle','none');
scatter(ones(size(SBU_Oxsys_belowIOU)).*(10+(rand(size(SBU_Oxsys_belowIOU))-0.5)/10),SBU_Oxsys_belowIOU,markersize,'filled','MarkerFaceColor',[0.4940 0.1840 0.5560]);
boxchart(10*ones(1,length(SBU_Oxsys_belowIOU)),SBU_Oxsys_belowIOU,'BoxFaceColor',[0.4940 0.1840 0.5560],'MarkerStyle','none');
scatter(ones(size(SBU_Energy_belowIOU)).*(11+(rand(size(SBU_Energy_belowIOU))-0.5)/10),SBU_Energy_belowIOU,markersize,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250]);
boxchart(11*ones(1,length(SBU_Energy_belowIOU)),SBU_Energy_belowIOU,'BoxFaceColor',[0.9290 0.6940 0.1250],'MarkerStyle','none');
scatter(ones(size(SBU_DiffOp_belowIOU)).*(12+(rand(size(SBU_DiffOp_belowIOU))-0.5)/10),SBU_DiffOp_belowIOU,markersize,'filled','MarkerFaceColor',[0.8500 0.3250 0.0980]);
boxchart(12*ones(1,length(SBU_DiffOp_belowIOU)),SBU_DiffOp_belowIOU,'BoxFaceColor',[0.8500 0.3250 0.0980],'MarkerStyle','none');
scatter(ones(size(SBU_DiffOpEng_belowIOU)).*(13+(rand(size(SBU_DiffOpEng_belowIOU))-0.5)/10),SBU_DiffOpEng_belowIOU,markersize,'filled','MarkerFaceColor',[0 0.4470 0.7410]);
boxchart(13*ones(1,length(SBU_DiffOpEng_belowIOU)),SBU_DiffOpEng_belowIOU,'BoxFaceColor',[0 0.4470 0.7410],'MarkerStyle','none');

scatter(ones(size(SBU_Thr_averageIOU)).*(15+(rand(size(SBU_Thr_averageIOU))-0.5)/10),SBU_Thr_averageIOU,markersize,'filled','MarkerFaceColor',[0.6350 0.0780 0.1840]);
boxchart(15*ones(1,length(SBU_Thr_averageIOU)),SBU_Thr_averageIOU,'BoxFaceColor',[0.6350 0.0780 0.1840],'MarkerStyle','none');
scatter(ones(size(SBU_Template_averageIOU)).*(16+(rand(size(SBU_Template_averageIOU))-0.5)/10),SBU_Template_averageIOU,markersize,'filled','MarkerFaceColor',[0.4660 0.6740 0.1880]);
boxchart(16*ones(1,length(SBU_Template_averageIOU)),SBU_Template_averageIOU,'BoxFaceColor',[0.4660 0.6740 0.1880],'MarkerStyle','none');
scatter(ones(size(SBU_Oxsys_averageIOU)).*(17+(rand(size(SBU_Oxsys_averageIOU))-0.5)/10),SBU_Oxsys_averageIOU,markersize,'filled','MarkerFaceColor',[0.4940 0.1840 0.5560]);
boxchart(17*ones(1,length(SBU_Oxsys_averageIOU)),SBU_Oxsys_averageIOU,'BoxFaceColor',[0.4940 0.1840 0.5560],'MarkerStyle','none');
scatter(ones(size(SBU_Energy_averageIOU)).*(18+(rand(size(SBU_Energy_averageIOU))-0.5)/10),SBU_Energy_averageIOU,markersize,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250]);
boxchart(18*ones(1,length(SBU_Energy_averageIOU)),SBU_Energy_averageIOU,'BoxFaceColor',[0.9290 0.6940 0.1250],'MarkerStyle','none');
scatter(ones(size(SBU_DiffOp_averageIOU)).*(19+(rand(size(SBU_DiffOp_averageIOU))-0.5)/10),SBU_DiffOp_averageIOU,markersize,'filled','MarkerFaceColor',[0.8500 0.3250 0.0980]);
boxchart(19*ones(1,length(SBU_DiffOp_averageIOU)),SBU_DiffOp_averageIOU,'BoxFaceColor',[0.8500 0.3250 0.0980],'MarkerStyle','none');
scatter(ones(size(SBU_DiffOpEng_averageIOU)).*(20+(rand(size(SBU_DiffOpEng_averageIOU))-0.5)/10),SBU_DiffOpEng_averageIOU,markersize,'filled','MarkerFaceColor',[0 0.4470 0.7410]);
boxchart(20*ones(1,length(SBU_DiffOpEng_averageIOU)),SBU_DiffOpEng_averageIOU,'BoxFaceColor',[0 0.4470 0.7410],'MarkerStyle','none');


scatter(ones(size(SBU_Thr_aboveIOU)).*(22+(rand(size(SBU_Thr_aboveIOU))-0.5)/10),SBU_Thr_aboveIOU,markersize,'filled','MarkerFaceColor',[0.6350 0.0780 0.1840]);
boxchart(22*ones(1,length(SBU_Thr_aboveIOU)),SBU_Thr_aboveIOU,'BoxFaceColor',[0.6350 0.0780 0.1840],'MarkerStyle','none');
scatter(ones(size(SBU_Template_aboveIOU)).*(23+(rand(size(SBU_Template_aboveIOU))-0.5)/10),SBU_Template_aboveIOU,markersize,'filled','MarkerFaceColor',[0.4660 0.6740 0.1880]);
boxchart(23*ones(1,length(SBU_Template_aboveIOU)),SBU_Template_aboveIOU,'BoxFaceColor',[0.4660 0.6740 0.1880],'MarkerStyle','none');
scatter(ones(size(SBU_Oxsys_aboveIOU)).*(24+(rand(size(SBU_Oxsys_aboveIOU))-0.5)/10),SBU_Oxsys_aboveIOU,markersize,'filled','MarkerFaceColor',[0.4940 0.1840 0.5560]);
boxchart(24*ones(1,length(SBU_Oxsys_aboveIOU)),SBU_Oxsys_aboveIOU,'BoxFaceColor',[0.4940 0.1840 0.5560],'MarkerStyle','none');
scatter(ones(size(SBU_Energy_aboveIOU)).*(25+(rand(size(SBU_Energy_aboveIOU))-0.5)/10),SBU_Energy_aboveIOU,markersize,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250]);
boxchart(25*ones(1,length(SBU_Energy_aboveIOU)),SBU_Energy_aboveIOU,'BoxFaceColor',[0.9290 0.6940 0.1250],'MarkerStyle','none');
scatter(ones(size(SBU_DiffOp_aboveIOU)).*(26+(rand(size(SBU_DiffOp_aboveIOU))-0.5)/10),SBU_DiffOp_aboveIOU,markersize,'filled','MarkerFaceColor',[0.8500 0.3250 0.0980]);
boxchart(26*ones(1,length(SBU_DiffOp_aboveIOU)),SBU_DiffOp_aboveIOU,'BoxFaceColor',[0.8500 0.3250 0.0980],'MarkerStyle','none');
scatter(ones(size(SBU_DiffOpEng_aboveIOU)).*(27+(rand(size(SBU_DiffOpEng_aboveIOU))-0.5)/10),SBU_DiffOpEng_aboveIOU,markersize,'filled','MarkerFaceColor',[0 0.4470 0.7410]);
boxchart(27*ones(1,length(SBU_DiffOpEng_aboveIOU)),SBU_DiffOpEng_aboveIOU,'BoxFaceColor',[0 0.4470 0.7410],'MarkerStyle','none');

scatter(ones(size(SBU_Thr_goodIOU)).*(29+(rand(size(SBU_Thr_goodIOU))-0.5)/10),SBU_Thr_goodIOU,markersize,'filled','MarkerFaceColor',[0.6350 0.0780 0.1840]);
boxchart(29*ones(1,length(SBU_Thr_goodIOU)),SBU_Thr_goodIOU,'BoxFaceColor',[0.6350 0.0780 0.1840],'MarkerStyle','none');
scatter(ones(size(SBU_Template_goodIOU)).*(30+(rand(size(SBU_Template_goodIOU))-0.5)/10),SBU_Template_goodIOU,markersize,'filled','MarkerFaceColor',[0.4660 0.6740 0.1880]);
boxchart(30*ones(1,length(SBU_Template_goodIOU)),SBU_Template_goodIOU,'BoxFaceColor',[0.4660 0.6740 0.1880],'MarkerStyle','none');
scatter(ones(size(SBU_Oxsys_goodIOU)).*(31+(rand(size(SBU_Oxsys_goodIOU))-0.5)/10),SBU_Oxsys_goodIOU,markersize,'filled','MarkerFaceColor',[0.4940 0.1840 0.5560]);
boxchart(31*ones(1,length(SBU_Oxsys_goodIOU)),SBU_Oxsys_goodIOU,'BoxFaceColor',[0.4940 0.1840 0.5560],'MarkerStyle','none');
scatter(ones(size(SBU_Energy_goodIOU)).*(32+(rand(size(SBU_Energy_goodIOU))-0.5)/10),SBU_Energy_goodIOU,markersize,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250]);
boxchart(32*ones(1,length(SBU_Energy_goodIOU)),SBU_Energy_goodIOU,'BoxFaceColor',[0.9290 0.6940 0.1250],'MarkerStyle','none');
scatter(ones(size(SBU_DiffOp_goodIOU)).*(33+(rand(size(SBU_DiffOp_goodIOU))-0.5)/10),SBU_DiffOp_goodIOU,markersize,'filled','MarkerFaceColor',[0.8500 0.3250 0.0980]);
boxchart(33*ones(1,length(SBU_DiffOp_goodIOU)),SBU_DiffOp_goodIOU,'BoxFaceColor',[0.8500 0.3250 0.0980],'MarkerStyle','none');
scatter(ones(size(SBU_DiffOpEng_goodIOU)).*(34+(rand(size(SBU_DiffOpEng_goodIOU))-0.5)/10),SBU_DiffOpEng_goodIOU,markersize,'filled','MarkerFaceColor',[0 0.4470 0.7410]);
boxchart(34*ones(1,length(SBU_DiffOpEng_goodIOU)),SBU_DiffOpEng_goodIOU,'BoxFaceColor',[0 0.4470 0.7410],'MarkerStyle','none');



%% Plotting performance (set IOUs threshold)

IOUth = 0.6;
Row = 4;
Col = 5;

figure()
for k = 1:Row*Col
    if floor(k/Col)==0
        if mod(k,Col)==1
            % Ground Truth 1 & Poor
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'p');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'p');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'p');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'p');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'p');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'p');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'p');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'p');

            subplot(Row,Col,k); hold on
            ylabel({'Ground Truth 1','','PPV / Precision'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);
            legend('Threshold','Template Matching','Derivative','GLRT','Basic','Basic+AG','Basic+AG+GP','All');

        elseif mod(k,Col)==2
            % Ground Truth 1 & Below Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'b');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'b');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'b');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'b');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'b');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'b');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'b');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'b');            

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);
            %legend('Threshold','Template Matching','Derivative','GLRT','Basic','Basic+AG','Basic+AG+GP','All');

        elseif mod(k,Col)==3
            % Ground Truth 1 & Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'m');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'m');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'m');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'m');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'m');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'m');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'m');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'m');            

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);

        elseif mod(k,Col)==4
            % Ground Truth 1 & Above
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'a');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'a');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'a');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'a');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'a');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'a');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'a');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'a');            

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);

        else
            % Ground Truth 1 & good
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'g');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'g');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'g');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'g');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'g');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'g');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'g');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G1,'g');            

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);
        end
 
    elseif floor(k/Col)==1
        if mod(k,Col)==1
            % Ground Truth 2 & Poor
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'p');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'p');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'p');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'p');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'p');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'p');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'p');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'p');

            subplot(Row,Col,k); hold on
            ylabel({'Ground Truth 2','','PPV / Precision'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);            
    
        elseif mod(k,Col)==2
            % Ground Truth 2 & Below Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'b');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'b');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'b');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'b');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'b');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'b');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'b');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'b');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);    

        elseif mod(k,Col)==3
            % Ground Truth 2 & Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'m');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'m');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'m');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'m');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'m');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'m');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'m');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'m');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);               

        elseif mod(k,Col)==4
            % Ground Truth 2 & Above
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'a');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'a');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'a');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'a');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'a');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'a');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'a');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'a');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]); 

        else
            % Ground Truth 2 & Good
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'g');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'g');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'g');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'g');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'g');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'g');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'g');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G2,'g');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);             
        end        
          
    elseif floor(k/Col)==2
        if mod(k,Col)==1
            % Ground Truth 3 & Poor
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'p');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'p');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'p');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'p');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'p');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'p');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'p');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'p');

            subplot(Row,Col,k); hold on
            ylabel({'Ground Truth 3','','PPV / Precision'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);  

        elseif mod(k,Col)==2
            % Ground Truth 3 & Below Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'b');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'b');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'b');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'b');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'b');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'b');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'b');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'b');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);  

        elseif mod(k,Col)==3
            % Ground Truth 3 & Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'m');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'m');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'m');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'m');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'m');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'m');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'m');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'m');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);              

        elseif mod(k,Col)==4
            % Ground Truth 3 & Above
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'a');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'a');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'a');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'a');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'a');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'a');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'a');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'a');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);     

        else
            % Ground Truth 3 & Good
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'g');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'g');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'g');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'g');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'g');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'g');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'g');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G3,'g');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);     
        end         
       
    else
        if mod(k,Col)==1
            % Ground Truth 4 & Poor
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'p');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'p');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'p');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'p');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'p');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'p');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'p');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'p');

            subplot(Row,Col,k); hold on
            ylabel({'Ground Truth 4','','PPV / Precision'});
            xlabel({'TPR / Sensitivity / Recall','Poor'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);  

        elseif mod(k,Col)==2
            % Ground Truth 4 & Below Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'b');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'b');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'b');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'b');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'b');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'b');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'b');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'b');

            subplot(Row,Col,k); hold on
            xlabel({'TPR / Sensitivity / Recall','Below Average'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);  
            
        elseif mod(k,Col)==3
            % Ground Truth 4 & Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'m');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'m');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'m');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'m');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'m');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'m');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'m');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'m');

            subplot(Row,Col,k); hold on
            xlabel({'TPR / Sensitivity / Recall','Average'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);  

        elseif mod(k,Col)==4
            % Ground Truth 4 & Above Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'a');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'a');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'a');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'a');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'a');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'a');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'a');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'a');

            subplot(Row,Col,k); hold on
            xlabel({'TPR / Sensitivity / Recall','Above Average'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);  

        else
            % Ground Truth 4 & Good
            [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'g');
            [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'g');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'g');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(Czech_Basic,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'g');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(Czech_GLRT,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'g');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(Czech_BasicAG,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'g');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(Czech_BasicAGGP,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'g');
            [PPV_All,TPR_All,AUC_All] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUth,GroundTruth_Czech_G4,'g');

            subplot(Row,Col,k); hold on
            xlabel({'TPR / Sensitivity / Recall','Good'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);  
        end          
    end

end


figure()
for k = 1:Row*Col
    if floor(k/Col)==0
        if mod(k,Col)==1
            % Ground Truth 1 & Poor
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'p');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'p');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'p');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'p');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'p');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'p');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'p');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'p');

            subplot(Row,Col,k); hold on
            ylabel({'Ground Truth 1','','PPV / Precision'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);
            legend('Threshold','Template Matching','Derivative','GLRT','Basic','Basic+AG','Basic+AG+GP','All');

        elseif mod(k,Col)==2
            % Ground Truth 1 & Below Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'b');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'b');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'b');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'b');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'b');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'b');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'b');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'b');            

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);
            %legend('Threshold','Template Matching','Derivative','GLRT','Basic','Basic+AG','Basic+AG+GP','All');

        elseif mod(k,Col)==3
            % Ground Truth 1 & Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'m');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'m');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'m');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'m');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'m');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'m');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'m');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'m');            

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);

        elseif mod(k,Col)==4
            % Ground Truth 1 & Above
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'a');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'a');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'a');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'a');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'a');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'a');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'a');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'a');            

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);

        else
            % Ground Truth 1 & good
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'g');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'g');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'g');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'g');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'g');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'g');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'g');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G1,'g');            

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);
        end
 
    elseif floor(k/Col)==1
        if mod(k,Col)==1
            % Ground Truth 2 & Poor
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'p');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'p');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'p');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'p');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'p');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'p');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'p');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'p');

            subplot(Row,Col,k); hold on
            ylabel({'Ground Truth 2','','PPV / Precision'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);            
    
        elseif mod(k,Col)==2
            % Ground Truth 2 & Below Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'b');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'b');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'b');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'b');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'b');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'b');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'b');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'b');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);    

        elseif mod(k,Col)==3
            % Ground Truth 2 & Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'m');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'m');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'m');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'m');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'m');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'m');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'m');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'m');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);               

        elseif mod(k,Col)==4
            % Ground Truth 2 & Above
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'a');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'a');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'a');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'a');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'a');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'a');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'a');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'a');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]); 

        else
            % Ground Truth 2 & Good
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'g');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'g');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'g');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'g');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'g');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'g');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'g');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G2,'g');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);             
        end        
          
    elseif floor(k/Col)==2
        if mod(k,Col)==1
            % Ground Truth 3 & Poor
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'p');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'p');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'p');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'p');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'p');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'p');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'p');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'p');

            subplot(Row,Col,k); hold on
            ylabel({'Ground Truth 3','','PPV / Precision'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);  

        elseif mod(k,Col)==2
            % Ground Truth 3 & Below Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'b');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'b');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'b');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'b');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'b');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'b');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'b');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'b');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);  

        elseif mod(k,Col)==3
            % Ground Truth 3 & Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'m');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'m');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'m');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'m');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'m');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'m');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'m');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'m');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);              

        elseif mod(k,Col)==4
            % Ground Truth 3 & Above
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'a');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'a');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'a');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'a');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'a');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'a');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'a');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'a');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);     

        else
            % Ground Truth 3 & Good
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'g');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'g');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'g');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'g');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'g');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'g');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'g');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G3,'g');

            subplot(Row,Col,k); hold on
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);     
        end         
       
    else
        if mod(k,Col)==1
            % Ground Truth 4 & Poor
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'p');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'p');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'p');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'p');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'p');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'p');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'p');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'p');

            subplot(Row,Col,k); hold on
            ylabel({'Ground Truth 4','','PPV / Precision'});
            xlabel({'TPR / Sensitivity / Recall','Poor'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);  

        elseif mod(k,Col)==2
            % Ground Truth 4 & Below Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'b');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'b');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'b');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'b');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'b');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'b');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'b');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'b');

            subplot(Row,Col,k); hold on
            xlabel({'TPR / Sensitivity / Recall','Below Average'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);  
            
        elseif mod(k,Col)==3
            % Ground Truth 4 & Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'m');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'m');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'m');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'m');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'m');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'m');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'m');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'m');

            subplot(Row,Col,k); hold on
            xlabel({'TPR / Sensitivity / Recall','Average'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);  

        elseif mod(k,Col)==4
            % Ground Truth 4 & Above Avg
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'a');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'a');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'a');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'a');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'a');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'a');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'a');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'a');

            subplot(Row,Col,k); hold on
            xlabel({'TPR / Sensitivity / Recall','Above Average'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);  

        else
            % Ground Truth 4 & Good
            [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'g');
            [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'g');
            [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'g');
            [PPV_Basic,TPR_Basic,AUC_Basic] = PR_plot(SBU_Basic,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'g');
            [PPV_GLRT,TPR_GLRT,AUC_GLRT] = PR_plot(SBU_GLRT,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'g');
            [PPV_BasicAG,TPR_BasicAG,AUC_BasicAG] = PR_plot(SBU_BasicAG,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'g');
            [PPV_BasicAGGP,TPR_BasicAGGP,AUC_BasicAGGP] = PR_plot(SBU_BasicAGGP,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'g');
            [PPV_All,TPR_All,AUC_All] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUth,GroundTruth_SBU_G4,'g');

            subplot(Row,Col,k); hold on
            xlabel({'TPR / Sensitivity / Recall','Good'});
            plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',[0.6350 0.0780 0.1840]);
            plot(TPR_GLRT,PPV_GLRT,'-','LineWidth',1.5,'Color',[0.4660 0.6740 0.1880]);
            plot(TPR_Basic,PPV_Basic,'-','LineWidth',1.5,'Color',[0.4940 0.1840 0.5560]);
            plot(TPR_BasicAG,PPV_BasicAG,'-','LineWidth',1.5,'Color',[0.9290 0.6940 0.1250]);
            plot(TPR_BasicAGGP,PPV_BasicAGGP,'-','LineWidth',1.5,'Color',[0.8500 0.3250 0.0980]);
            plot(TPR_All,PPV_All,'-','LineWidth',1.5,'Color',[0 0.4470 0.7410]);  
        end          
    end

end


%% Influence of IOU threshold

IOUoptions = [0.1:0.1:0.9];
Color_Thr = [0.99 0.7 0.76    % Red
    0.99 0.62 0.69
    0.99 0.55 0.64
    0.98 0.48 0.57
    0.93 0.41 0.51
    0.92 0.35 0.45
    0.82 0.25 0.36
    0.76 0.17 0.27
    0.64 0.08 0.18];

Color_Temp = [0.77 0.99 0.49    % Green
    0.69 0.91 0.4
    0.64 0.87 0.33
    0.59 0.84 0.27
    0.53 0.78 0.2
    0.45 0.69 0.13
    0.38 0.6 0.08
    0.32 0.53 0.04
    0.24 0.41 0.01];

Color_Oxsys = [0.91 0.53 0.99   % Purple
    0.89 0.45 0.98
    0.84 0.36 0.94
    0.77 0.29 0.87
    0.72 0.23 0.82
    0.66 0.18 0.76
    0.59 0.13 0.68
    0.5 0.09 0.58
    0.4 0.05 0.47];

Color_All = [0.44 0.77 0.99    % Blue
    0.39 0.76 0.99
    0.32 0.72 0.98
    0.27 0.68 0.96
    0.2 0.63 0.92
    0.15 0.6 0.89
    0.1 0.55 0.84
    0.05 0.5 0.8
    0 0.45 0.74];


figure()
for i = 1:5
    switch i
        case 1
            class = 'p';
        case 2
            class = 'b';
        case 3
            class = 'm';
        case 4
            class = 'a';
        case 5
            class = 'g';
    end
    subplot(1,5,i); hold on;
    for j = 1:length(IOUoptions)
        [PPV_Thr,TPR_Thr,~] = PR_plot(Czech_Thr,CzechID,Czechlabel,CzechUA,IOUoptions(j),GroundTruth_Czech_G4,class);
        [PPV_Temp,TPR_Temp,~] = PR_plot(Czech_Template,CzechID,Czechlabel,CzechUA,IOUoptions(j),GroundTruth_Czech_G4,class);
        [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(Czech_Oxsys,CzechID,Czechlabel,CzechUA,IOUoptions(j),GroundTruth_Czech_G4,class);
        [PPV_All,TPR_All,~] = PR_plot(Czech_All,CzechID,Czechlabel,CzechUA,IOUoptions(j),GroundTruth_Czech_G4,class);

        %xlabel({'TPR / Sensitivity / Recall','Poor'});
        %ylabel('PPV / Precision');
        plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',Color_Thr(j,:));
        plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',Color_Temp(j,:));
        plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',Color_Oxsys(j,:)); 
        plot(TPR_All,PPV_All,'-','LineWidth',2,'Color',Color_All(j,:));       
    end
end


figure()
for i = 1:5
    switch i
        case 1
            class = 'p';
        case 2
            class = 'b';
        case 3
            class = 'm';
        case 4
            class = 'a';
        case 5
            class = 'g';
    end
    subplot(1,5,i); hold on;
    for j = 1:length(IOUoptions)
        [PPV_Thr,TPR_Thr,~] = PR_plot(SBU_Thr,SBUID,SBUlabel,SBUUA,IOUoptions(j),GroundTruth_SBU_G4,class);
        [PPV_Temp,TPR_Temp,~] = PR_plot(SBU_Template,SBUID,SBUlabel,SBUUA,IOUoptions(j),GroundTruth_SBU_G4,class);
        [PPV_Oxsys,TPR_Oxsys,~] = PR_plot(SBU_Oxsys,SBUID,SBUlabel,SBUUA,IOUoptions(j),GroundTruth_SBU_G4,class);
        [PPV_All,TPR_All,~] = PR_plot(SBU_All,SBUID,SBUlabel,SBUUA,IOUoptions(j),GroundTruth_SBU_G4,class);

        %xlabel({'TPR / Sensitivity / Recall','Poor'});
        %ylabel('PPV / Precision');
        plot(TPR_Thr,PPV_Thr,'o','LineWidth',2,'Color',Color_Thr(j,:));
        plot(TPR_Temp,PPV_Temp,'+','LineWidth',2,'Color',Color_Temp(j,:));
        plot(TPR_Oxsys,PPV_Oxsys,'*','LineWidth',2,'Color',Color_Oxsys(j,:)); 
        plot(TPR_All,PPV_All,'-','LineWidth',2,'Color',Color_All(j,:));       
    end
end
