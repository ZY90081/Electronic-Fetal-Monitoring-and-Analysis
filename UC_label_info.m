ContractionLabel = [];
ContractionLabel.ID = [1030;1157;1189;1269;1370;1450;1154;1501;1069;1094;1053;1090;1092;1176;2034];
ContractionLabel.NumofID = length(ContractionLabel.ID);
ContractionLabel.Edge{1} = [1 370;590 1130;1388 1671;1739 1997;2200 2608;2760 3057;4502 4682;4926 5211;5605 5948;6145 6546;6678 6959;7222 7509;7657 8061;8287 8643;8825 9206;9407 9795;9980 10450;10580 11010];
ContractionLabel.Edge{2} = [91 584;5044 5313;5493 5800;6534 6815;8508 8761;9086 9279;9443 9848;10510 10770;11240 11490; 11590 11850];
ContractionLabel.Edge{3} = [3464 3886;5070 5425;5536 5890;6292 6633;6808 7053;7233 7586;7750 8102;8296 8577;8662 9022;9289 9605;9796 10170;10650 10990;11150 11400;11500 11800;12400 12680;12850 13160;13320 13830;14410 14640;14760 14990;15060 15330; 15370 15580];
ContractionLabel.Edge{4} = [436 757;849 1089;1730 2207;2414 2729;3366 4316;5046 5426; 5693 6090; 6313 6760; 6906 7390; 8023 8338; 8448 8667; 9474 9854; 10570 10900; 12100 12410; 13160 14400; 14640 14980; 15110 15430; 16040 16350; 16530 16850; 17090 17240];
ContractionLabel.Edge{5} = [143 544;939 1444;2865 3169;3237 3498;5117 5414;5613 5992;6228 6463;6711 6913;7282 7549;7828 8296;9027 9224;9615 9861;10040 10460;11730 12010;14560 14960;15090 15380;15560 15840];
ContractionLabel.Edge{6} = [4289 4567;4916 5181;5285 5505;5752 6061;6184 6397;6549 6821;7019 7282;7340 7565;7868 8091;8175 8381;8550 8784;9003 9332;9489 9799;9978 10210;10410 10690;11030 11350;11560 11850;11970 12300;12950 13130;13290 13650];
ContractionLabel.Edge{7} = [628 991;1319 1837;2976 3468;3774 4026;4260 4574;4988 5272;5500 5677;5823 6255;6446 6703;6957 7247;7789 8067;8332 8838;8996 9511;9645 10080;10350 10670;10810 11190;11380 11640;13210 13630;13910 14280];
ContractionLabel.Edge{8} = [526 872;960 1302;1458 1700;1808 2125;2415 2750;2852 3222;3375 3803;4082 4396;4517 4800;8688 9396;9565 9935;11320 11730;11890 12260;12390 12740;13130 13540;13700 14020;14510 15150;15410 15760;15860 16050;16270 16640;16820 17040;17190 17320;17620 18070;18110 18360;18400 18630];
ContractionLabel.Edge{9} = [3188 3553;3704 3975;4063 4370;4544 4820;5178 5414;5577 5775;5909 6111;9843 10240;10380 10820];
ContractionLabel.Edge{10} = [1330 1840;3330 3768;4531 4965;5456 5873;5960 6260;7344 7717;7871 8238;8355 8627;8705 9166;9355 9730;9882 10150;10900 11200;11360 11670;11790 12210;12300 12780;14550 15500;16610 16950;17070 17400;17570 18020;18430 19090;19180 19540;20240 20740];
ContractionLabel.Edge{11} = [748 1053;1388 1717;2142 2446;2850 3211;3436 3832;4050 4418;4756 5113;5440 5713;6093 6442;6862 7132;8311 8667;11890 12280;12730 12950;14410 14680;14850 15270];
ContractionLabel.Edge{12} = [669 1228;1421 1767;2065 2503;4943 5428;5714 6165;6306 6628;7024 7441;7765 8186;8438 8909;9153 9636;10000 10460;10930 11440;11600 11910;12240 12580;12860 13430;13580 13890];
ContractionLabel.Edge{13} = [8054 8288;8468 8772;8839 9212;10350 10730;10970 11250; 11510 11820;11970 12310;12650 12920;13610 13910;14030 14310;14400 14600;14980 15360];
ContractionLabel.Edge{14} = [395 732;1028 1317;1576 1922;2276 2607;2833 3103;3335 3644;3975 4313;4467 4774;6239 6611;6840 7169;7340 7748;7968 8304;8389 8879;9039 9339;9561 9903;10150 10520;10570 10960;11240 11620;11780 12060;12440 12860;12970 13370];
ContractionLabel.Edge{15} = [3846 4113;4376 4682;4899 5097;5365 5609;5762 6291;6489 6808;7116 7307;7893 8260;8556 8803;9298 9622;9907 10330;10620 11030];

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
