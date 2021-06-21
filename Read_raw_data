load('CTUdataAll.mat');        % Load CTU-CHB Intrapartum Cardiotocography Database (https://physionet.org/content/ctu-uhb-ctgdb/1.0.0/)
[N,~] = size(CTUdata);         % Number of FHR recordings
L = 21620;                     % Maximum time length

RawFHR = NaN(L,N);             
RawUA = NaN(L,N);
IDseq = NaN(N,1);
ph = NaN(N,1);
apgar1 = NaN(N,1);
apgar5 = NaN(N,1);
for n = 1:N
    temp = length(CTUdata{n,1}.rawFHR);
    RawFHR(1:temp,n) = CTUdata{n,1}.rawFHR;    % Save raw FHR
    RawUA(1:temp,n) = CTUdata{n,1}.rawUA;      % Save raw UA
    IDseq(n) = CTUdata{n,1}.ID;                % Extract ID sequences
    ph(n) = CTUdata{n,1}.Param.pH;             % Extract pH values
    apgar1(n) = CTUdata{n,1}.Param.Apgar1;     % Extract Apgar scores at 1min
    apgar5(n) = CTUdata{n,1}.Param.Apgar5;     % Extract Apgar scores at 5min
end
clear temp;
