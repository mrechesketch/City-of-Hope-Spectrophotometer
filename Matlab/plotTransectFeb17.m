%% This plots trasects

%% get the ic object and gather information

%ic = IndexCrawler('2/17/2017'); % day 3
ds = getDataSet('2/17/2017');

% apply transforms
[corr, cfactors] = ds.applyProcess(ds.data, 'corr');
[norm, nfactors] = ds.applyProcess(ds.data, 'norm');
[normCorr, cnfactors] = ds.applyProcess(corr, 'norm');

wavenumbers = ds.x;

% corrected and normed

%normCorr = ds.data; %raw
%normCorr = norm;   %normalized only
%normCorr = corr;   %corrected only

transect1 = normCorr(1:end, 12:end); %transect1 is samples 3 - 9 
transect2 = normCorr(1:end, 2:8); %transect2 is samples 10 - 16

% Spatial offsets hardcoded
offsets1 = [141.6 141.8 142.1 144.4 145.6 146.8 149.1];
offsets2 = [149 148.8 146.9 144.9 144.3 142.7 142.5];

%% Plot transects as a function of distance
figure



%scale by the largest mean peak size divided by the minimum offset step size
scale = max(mean(normCorr))/0.3;
scale = 0.0018;

%transect 1
subplot(2,1,1)
hold on
for i = 1:7
    %scale by distance
    transect1(:,i) = transect1(:,i) + (offsets1(i) - offsets1(1))*scale;
    plot(wavenumbers, transect1(:,i))
    title('Path 1')
    xlabel('Wavenumber cm^-^1')
    hold on
end
xlim([175 3200])

%transect 2
subplot(2,1,2)
hold on
for i = 1:7
    %scale by distance
    transect2(:,i) = transect2(:,i) + (offsets2(i) - offsets2(1))*scale;
    plot(wavenumbers, transect2(:,i))
    title('Path 2')
    xlabel('Wavenumber cm^-^1')
    hold on
end
xlim([175 3200])





