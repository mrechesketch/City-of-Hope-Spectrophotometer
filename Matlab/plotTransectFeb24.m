%% This plots trasects

%% get the ic object and gather information

ic = IndexCrawler('2/24/2017'); % day 3
ds = ic.getDataSet();

% apply transforms
[corr, cfactors] = ds.applyProcess(ds.data, 'corr');
[norm, nfactors] = ds.applyProcess(ds.data, 'norm');
[normCorr, cnfactors] = ds.applyProcess(corr, 'norm');

wavenumbers = ds.x;

% corrected and normed

%normCorr = ds.data; %raw
%normCorr = norm;   %normalized only
%normCorr = corr;   %corrected only

transect1 = normCorr(1:end, 5:15); %transect1 is samples 5-15
transect1 = [normCorr(1:end, 3) , transect1];   %add calibration run sample_3
transect2 = normCorr(1:end, 16:23); %transect2 is samples 16-23
transect3 = normCorr(1:end, 24:28); %transect3 is samples 24-28
transect4 = normCorr(1:end, 28:36); %transect4 is samples 29-37

% Spatial offsets hardcoded
offsets1 = [123.3 124.5 126.6 128.2 130.5 132.1 133.9 135 136.4 138.6 139.3];
offsets2 = [138 136 134 132 130 128 126 124];
offsets3 = [11.1 13 15 17 19];
offsets4 = [17.5 16.5 15.5 14.5 13.5 12.5 11.5 10.5 9.5];

%% Plot transects as a function of distance
figure



%scale by the largest mean peak size divided by the minimum offset step size
scale = max(mean(normCorr))/0.3;
scale = 0.0018;

%transect 1
subplot(2,2,1)
hold on
for i = 1:10
    %scale by distance
    transect1(:,i) = transect1(:,i) + (offsets1(i) - offsets1(1))*scale;
    plot(wavenumbers, transect1(:,i))
    title('Transect 1')
    xlabel('wavenumber')
    hold on
end
xlim([175 3200])

%transect 2
subplot(2,2,2)
hold on
for i = 1:8
    %scale by distance
    transect2(:,i) = transect2(:,i) + (offsets2(i) - offsets2(1))*scale;
    plot(wavenumbers, transect2(:,i))
    title('Transect 2')
    xlabel('wavenumber')
    hold on
end
xlim([175 3200])

%transect 3
subplot(2,2,3)
hold on
for i = 1:5
    %scale by distance
    transect3(:,i) = transect3(:,i) + (offsets3(i) - offsets3(1))*scale;
    plot(wavenumbers, transect3(:,i))
    title('Transect 3')
    xlabel('wavenumber') 
    hold on
end
xlim([175 3200])

%transect 4
subplot(2,2,4)
hold on
for i = 1:9
    %scale by distance
    transect4(:,i) = transect4(:,i) + (offsets4(i) - offsets4(1))*scale;
    plot(wavenumbers, transect4(:,i))
    title('Transect 4')
    xlabel('wavenumber')
    hold on
end
xlim([175 3200])

