% This is for reading the old (wrong) version of SBU data.

clc;
close all;
clear all;

fs = 4; 

folderpath = 'C:\Users\liuya\Desktop\selected sbu data\negative';
folderpath = fullfile(folderpath, '**');    % What is the meaning of "/**/" ???
filelist   = dir(folderpath);
name       = {filelist.name};
NegName       = name(~strncmp(name, '.', 1));   % No files starting with '.'
NumofNeg   = length(NegName);

DATA_NEG = [];
for i = 1:NumofNeg
    filename = sprintf('C:\\Users\\liuya\\Desktop\\selected sbu data\\negative\\%s', NegName{i});
    Datasheet = readmatrix(filename);
    NumofSec = size(Datasheet,1);
    FHRtemp = zeros(NumofSec*fs,1);
    TOCOtemp = zeros(NumofSec*fs,1);
    for j = 1:NumofSec
        FHRtemp((j-1)*fs+1:j*fs) = Datasheet(j,4:7)';
        TOCOtemp((j-1)*fs+1:j*fs) = Datasheet(j,16:19)';
    end
    DATA_NEG{i}.name = NegName{i};
    DATA_NEG{i}.FHR = FHRtemp;
    DATA_NEG{i}.UA = TOCOtemp; 
end

folderpath = 'C:\Users\liuya\Desktop\selected sbu data\positive';
folderpath = fullfile(folderpath, '**');    % What is the meaning of "/**/" ???
filelist   = dir(folderpath);
name       = {filelist.name};
PosName       = name(~strncmp(name, '.', 1));   % No files starting with '.'
NumofPos   = length(PosName);

DATA_POS = [];
for i = 1:NumofPos
    filename = sprintf('C:\\Users\\liuya\\Desktop\\selected sbu data\\positive\\%s', PosName{i});
    Datasheet = readmatrix(filename);
    NumofSec = size(Datasheet,1);
    FHRtemp = zeros(NumofSec*fs,1);
    TOCOtemp = zeros(NumofSec*fs,1);
    for j = 1:NumofSec
        FHRtemp((j-1)*fs+1:j*fs) = Datasheet(j,4:7)';
        TOCOtemp((j-1)*fs+1:j*fs) = Datasheet(j,16:19)';
    end
    DATA_POS{i}.name = PosName{i};
    DATA_POS{i}.FHR = FHRtemp;
    DATA_POS{i}.UA = TOCOtemp; 
end

save PaulData_POS DATA_POS
save PaulData_NEG DATA_NEG
