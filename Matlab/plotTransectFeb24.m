%% This plots trasects

%% get the ic object and gather information

%ic = IndexCrawler('2/24/2017'); % day 3
ds = getDataSet('2/24/2017');

% apply transforms
[corr, cfactors] = ds.applyProcess(ds.data, 'corr');
[norm, nfactors] = ds.applyProcess(ds.data, 'norm');
[normCorr, cnfactors] = ds.applyProcess(corr, 'norm');

wavenumbers = ds.x;

% corrected and normed

%normCorr = ds.data; %raw
%normCorr = norm;   %normalized only
%normCorr = corr;   %corrected only

%% Split the corrected spectra into the corresponding transects. Note that
% indexing samples is weird cuz the numbering is 'sample1,10,11,etc.' in 
% the database on Google drive.
transect1 = normCorr(1:end, 23); %transect1 (actually uses sample3 not sample5)
transect1 = [transect1, normCorr(1:end, 35:38)]; %transect1 
transect1 = [transect1, normCorr(1:end, 2:7)]; %transect1 

transect2 = normCorr(1:end, 8:11); %transect2 
transect2 = [transect2, normCorr(1:end, 13:16)]; %transect2

transect3 = normCorr(1:end, 17:21); %transect3

transect4 = normCorr(1:end, 22); %transect4 
transect4 = [transect4, normCorr(1:end, 24:31)]; %transect4

% Spatial offsets hardcoded
offsets1 = [-123.3 -124.5 -126.6 -128.2 -130.5 -132.1 -133.9 -135 -136.4 -138.6 -139.3];
offsets2 = [124 126 128 130 132 134 136 138];
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
    title('Transect 1 (Red)')
    xlabel('Wavenumber (cm^-^1)')
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
    title('Transect 2 (Green)')
    xlabel('Wavenumber (cm^-^1)')
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
    title('Transect 3 (Magenta)')
    xlabel('Wavenumber (cm^-^1)') 
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
    title('Transect 4 (Blue)')
    xlabel('Wavenumber (cm^-^1)')
    hold on
end
xlim([175 3200])

