clc;
close all;
clear all;


% Extract MotherID-ChildID-BirthTime
IDlink = readtable('D:\PHD\Research\Projects\FHR\Paul''s SBU data\mother_child_link.csv');
Birthtime = readtable('D:\PHD\Research\Projects\FHR\Paul''s SBU data\birth_times.csv');
ID_Birth = [IDlink(:,1:2) table(cell(height(IDlink(:,1)),1),'VariableNames',{'BirthTime'})];
for i = 1:height(ID_Birth)
    childID = ID_Birth.CHILD_PERSON_ID(i);
    idx = find(Birthtime.PERSON_ID == childID);
    if ~isempty(idx)
        ID_Birth.BirthTime(i) = {string(Birthtime.BIRTH_DT_TM(idx))};
    end
end



folderpath = 'D:\PHD\Research\Projects\FHR\Paul''s SBU data\Negative';
folderpath = fullfile(folderpath, '*');    % What is the meaning of "/**/" ???
filelist   = dir(folderpath);
name       = {filelist.name};
NegName       = name(~strncmp(name, '.', 1));   % No files starting with '.'
NumofNeg   = length(NegName);

DATA_NEG = [];
for i = 1:NumofNeg
    folderpath = sprintf('D:\\PHD\\Research\\Projects\\FHR\\Paul''s SBU data\\Negative\\%s', NegName{i});
    folderpath = fullfile(folderpath, '*');
    filelist   = dir(folderpath);
    name  = {filelist.name};
    name  = name(~strncmp(name, '.', 1));
    numoffiles = length(name);
    id = num2str(numoffiles,'%02d');
    for j = 1:numoffiles
        if name{j}(1:2)==id
            filename = sprintf('D:\\PHD\\Research\\Projects\\FHR\\Paul''s SBU data\\Negative\\%s\\%s', NegName{i}, name{j});
            Datasheet = readtable(filename);
        end
    end
    
    
    
    

    
end

