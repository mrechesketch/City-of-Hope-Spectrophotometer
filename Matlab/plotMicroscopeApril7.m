%% This plots the transect

ds = getDataSet('4/7/2017');

% apply transforms
[corr, cfactors] = ds.applyProcess(ds.data, 'corr');
[norm, nfactors] = ds.applyProcess(ds.data, 'norm');
[normCorr, cnfactors] = ds.applyProcess(corr, 'norm');
[firstDeriv , dfactors] = ds.applyProcess(normCorr, '1deriv');

wavenumbers = ds.x;

% get reference
ref = normCorr(1:end, 38);
% split transects
transect1 = normCorr(1:end, 3);
transect1 = [transect1, normCorr(1:end, 8:15)]; 
transect1 = [transect1, normCorr(1:end, 4:5)];
%transect1 = transect1 - ref; 
% and now snr data
healthyAndTumor = normCorr(1:end, 6:7);
%healthyAndTumor = [healthyAndTumor ref];
%healthyAndTumor = healthyAndTumor - ref;


% Spatial offsets hardcoded
offsets1 = [155 153 151 151 149 147 145 143 141 139 137];


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
    title('Transect')
    xlabel('Raman Shift cm^-^1')
    hold on
end
xlim([175 3200])

subplot(2,1,2)
plot(wavenumbers, healthyAndTumor);
title('Healthy vs Tumor 3 scans 1 sec')
xlabel('Raman Shift cm^-^1')


