%% This plots trasects

%% get the ic object and gather information

%ic = IndexCrawler('3/3/2017'); % day 3
ds = getDataSet('3/3/2017');

% apply transforms
[corr, cfactors] = ds.applyProcess(ds.data, 'corr');
[norm, nfactors] = ds.applyProcess(ds.data, 'norm');
[normCorr, cnfactors] = ds.applyProcess(corr, 'norm');
[firstDeriv , dfactors] = ds.applyProcess(normCorr, '1deriv');

wavenumbers = ds.x;

% subset the transects

transect1 = normCorr(1:end, 13:24); %transect1 is samples 13-24
transect2 = normCorr(1:end, 25:34); %transect2 is samples 25-34

% Spatial offsets hardcoded
offsets1 = [151 149 147 145 143 141 139 137 135 133 131];
offsets2 = [131 133 135 137 139 141 143 145 147 149];

%% Plot transects as a function of distance
figure



%scale by the largest mean peak size divided by the minimum offset step size
scale = max(mean(normCorr))/0.3;
scale = 0.0018;

%transect 1
subplot(2,1,1)
hold on
for i = 1:length(offsets1)
    %scale by distance
    transect1(:,i) = transect1(:,i) + (offsets1(i) - offsets1(1))*scale;
    plot(wavenumbers, transect1(:,i))
    title('Transect 1')
    xlabel('Raman Shift cm^-^1')
    hold on
end
xlim([175 3200])

%transect 2
subplot(2,1,2)
hold on
for i = 1:length(offsets2)
    %scale by distance
    transect2(:,i) = transect2(:,i) + (offsets2(i) - offsets2(1))*scale;
    plot(wavenumbers, transect2(:,i))
    title('Transect 2')
    xlabel('Raman Shift cm^-^1')
    hold on
end
xlim([175 3200])

