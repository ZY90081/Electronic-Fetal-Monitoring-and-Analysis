ContractionLabel = [];
ContractionLabel.ID = [1030;1157;1189;1269;1370;1450;1485;1501;1069;1094];
ContractionLabel.NumofID = length(ContractionLabel.ID);
ContractionLabel.Edge{1} = [1 370;590 1130;1388 1671;1739 1997;2200 2608;2760 3057;4502 4682;4926 5211;5605 5948;6145 6546;6678 6959;7222 7509;7657 8061;8287 8643;8825 9206;9407 9795;9980 10450;10580 11010];
ContractionLabel.Edge{2} = [91 584;5044 5313;5493 5800;6534 6815;8508 8761;9086 9279;9443 9848;10510 10770;11240 11490; 11590 11850];
ContractionLabel.Edge{3} = [3464 3886;5070 5425;5536 5890;6292 6633;6808 7053;7233 7586;7750 8102;8296 8577;8662 9022;9289 9605;9796 10170;10650 10990;11150 11400;11500 11800;12400 12680;12850 13160;13320 13830;14410 14660;14720 15010;15060 15330; 15370 15580];
ContractionLabel.Edge{4} = [436 757;849 1089;1730 2207;2414 2729;3366 4316;5046 5426; 5693 6090; 6313 6760; 6906 7390; 8023 8338; 8448 8667; 9474 9854; 10570 10900; 12100 12410; 13160 14400; 14640 14980; 15110 15430; 16040 16510; 16510 16850; 17040 17270];
ContractionLabel.Edge{5} = [143 544;939 1444;2865 3169;3237 3498;3536 4225;5117 5414;5613 5992;6228 6463;6711 6959;7282 7549;7828 8296;9027 9269;9615 9861;10040 10460;11730 12010;14560 14960;15090 15470;15520 15840;15870 16620];
ContractionLabel.Edge{6} = [4289 4567;4916 5181;5285 5505;5752 6061;6184 6397;6549 6821;7019 7282;7340 7565;7868 8091;8175 8381;8550 8784;9003 9332;9489 9799;9978 10210;10410 10690;11030 11350;11560 11850;11970 12300;12950 13130;13290 13650];
ContractionLabel.Edge{7} = [1468 1902;2064 2551;2653 3390;3483 4191;4595 4944;5000 5406;6278 7846;8659 9794;10170 11330;11660 13600;13750 14590;14720 15090;15240 15760; 16500 17580; 17820 18500;18730 19000];
ContractionLabel.Edge{8} = [526 872;960 1302;1458 1700;1808 2125;2415 2750;2799 3145;3375 3803;4082 4396;4517 4870;8688 9157;9565 9935;11320 11730;11890 12260;12390 12740;13130 13540;13700 14020;14510 15150;15410 15760;15860 16050;16270 16640;16820 17040;17190 17320;17620 18070;18110 18360;18400 18630];
ContractionLabel.Edge{9} = [2038 3031;3188 3553;3704 3975;4063 4370;4544 4820;5178 5414;5577 5775;5909 6111;7132 8434;9016 9704;9843 10240;10380 10820];
ContractionLabel.Edge{10} = [1330 1840;3330 3768;4531 4965;5456 5873;5960 6260;6409 7164;7344 7717;7871 8238;8355 8627;8705 9166;9355 9730;9882 10150;10900 11200;11360 11670;11790 12210;12300 12780;12940 13720;13730 14320;14550 15500;16610 16950;17070 17400;17570 18020;18430 19090;19180 19540;20240 20740];

% Statistics.
for i = 1:ContractionLabel.NumofID
    idx = find(IDseq==ContractionLabel.ID(i));
    rawUA = RawUA(:,idx);
    rawUA = rawUA(~isnan(rawUA));
    preUA = PrepUA(:,idx);
    preUA = preUA(~isnan(preUA));    
    
    NumofCont = size(ContractionLabel.Edge{i},1);
    ContractionLabel.Duration{i} =  (ContractionLabel.Edge{i}(:,2)-ContractionLabel.Edge{i}(:,1)+ones(NumofCont,1))./4./60;  % unit: min
    ContractionLabel.Interval{i} = (ContractionLabel.Edge{i}(2:end,1)-ContractionLabel.Edge{i}(1:end-1,1))./4./60; % unit: min
    
    figure(); hold on;
    plot(rawUA);
    plot(preUA,'LineWidth',2);
    
    for j = 1:NumofCont
        conttemp = preUA(ContractionLabel.Edge{i}(j,1):ContractionLabel.Edge{i}(j,2));
        [PeakValue,t_p] = max(conttemp);
        ContractionLabel.DeltaPeak{i}(j,1) = t_p/4/60;  % unit: min
        bl = min(conttemp(1:t_p))-(1e-3);
        br = min(conttemp(t_p:end))-(1e-3);
        Al = PeakValue - bl;
        Ar = PeakValue - br;
        tl = 1:t_p-1;
        tr = t_p+1:length(conttemp);
        yl = log(-log((conttemp(tl)-bl)./Al));
        yr = log(-log((conttemp(tr)-br)./Ar));
        Hl = [log(abs(tl-(tl(end)+1)))' -ones(length(tl),1)];
        Hr = [log(abs(tr-(tr(1)-1)))' -ones(length(tr),1)];
        thetal = inv(Hl'*Hl)*Hl'*yl;
        thetar = inv(Hr'*Hr)*Hr'*yr;
        alphal = thetal(1);
        betal = exp(thetal(2));
        alphar = thetar(1);
        betar = exp(thetar(2));
        ContrPredi = [Al*exp(-abs(tl-(tl(end)+1)).^(alphal)/betal)+bl PeakValue Ar*exp(-abs(tr-(tr(1)-1)).^(alphar)/betar)+br]';
        
        ContractionLabel.A_l{i}(j,1) = Al;
        ContractionLabel.A_r{i}(j,1) = Ar;
        ContractionLabel.b_l{i}(j,1) = bl;
        ContractionLabel.b_r{i}(j,1) = br;
        ContractionLabel.Alpha_l{i}(j,1) = alphal;
        ContractionLabel.Beta_l{i}(j,1) = betal;
        ContractionLabel.Alpha_r{i}(j,1) = alphar;
        ContractionLabel.Beta_r{i}(j,1) = betar;
        
        plot(ContractionLabel.Edge{i}(j,1):ContractionLabel.Edge{i}(j,2),rawUA(ContractionLabel.Edge{i}(j,1):ContractionLabel.Edge{i}(j,2)),'r');
        plot(ContractionLabel.DeltaPeak{i}(j,1)*60*4+ContractionLabel.Edge{i}(j,1)-1,zeros(1,1),'+','LineWidth',2);
        plot(ContractionLabel.Edge{i}(j,1):ContractionLabel.Edge{i}(j,2),ContrPredi,'b','LineWidth',2);
    end

end

figure(); hold on;
for i = 1:ContractionLabel.NumofID
    NumofCont = size(ContractionLabel.Edge{i},1);
    plot(i*ones(NumofCont),ContractionLabel.Duration{i},'x','MarkerSize',10);
    ylabel('Duration (mins)');
end

figure(); hold on;
for i = 1:ContractionLabel.NumofID
    NumofCont = size(ContractionLabel.Edge{i},1);
    plot(i*ones(NumofCont-1),ContractionLabel.Interval{i},'x','MarkerSize',10);
    ylabel('Interval (mins)');
end

figure(); hold on;
for i = 1:ContractionLabel.NumofID
    NumofCont = size(ContractionLabel.Edge{i},1);
    plot(i*ones(NumofCont),ContractionLabel.DeltaPeak{i},'x','MarkerSize',10);
    ylabel('\Delta Peak (mins)');
end

% figure(); hold on;
% for i = 1:ContractionLabel.NumofID
%     plot(ContractionLabel.Duration{i},ContractionLabel.DeltaPeak{i},'+');
% end
% 
% figure(); hold on;
% for i = 1:ContractionLabel.NumofID
%     plot(ContractionLabel.A_l{i},ContractionLabel.A_r{i},'+');
% end
% 
% figure(); hold on;
% for i = 1:ContractionLabel.NumofID
%     plot(ContractionLabel.b_l{i},ContractionLabel.b_r{i},'+');
% end

save ContractionLabel
