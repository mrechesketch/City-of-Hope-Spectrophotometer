%% This plots trasects

%% get the ic object and gather information

%ic = IndexCrawler('3/3/2017'); % day 3
ds = getDataSet('4/7/2017');

% apply transforms
[corr, cfactors] = ds.applyProcess(ds.data, 'corr');
[norm, nfactors] = ds.applyProcess(ds.data, 'norm');
[normCorr, cnfactors] = ds.applyProcess(corr, 'norm');
%[firstDeriv , dfactors] = ds.applyProcess(normCorr, '1deriv');

wavenumbers = ds.x;

% subset the transects

%healthy: probe_9-14 21-30 45-50
%tumor: probe_4-8 15-20 31-44

healthy = normCorr(1:end, [18:22 30:38 40 56:60 62 66]); %healthy colums
healthyavg = mean(healthy,2);
tumor = normCorr(1:end, [23:27 29 41:49 51:55 63:65]); %tumor columns
tumoravg = mean(tumor,2);



%% Plot transects as a function of distance
figure
subplot(2,1,1)
hold on
for i = 1:size(healthy,2)
    plot(wavenumbers, healthy(:,i),'r')
    hold on
end

title('Healthy Breast Spectra')
xlabel('Raman Shift cm^-^1')
xlim([175 3200])

subplot(2,1,2)
for i = 1:size(tumor,2)
    plot(wavenumbers, tumor(:,i),'b')
    hold on
end

title('Tumor Breast Spectra')
xlabel('Raman Shift cm^-^1')
xlim([175 3200])
hold off

figure
plot(wavenumbers,healthyavg)
hold on
plot(wavenumbers,tumoravg)

title('Normal and Tumor Breast Tissue Average Spectra')
xlabel('Raman Shift cm^-^1')
legend('Healthy', 'Tumor')
xlim([175 3200])
hold off
