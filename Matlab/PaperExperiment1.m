%% WHOLE DATA PROCESSING SCRIPT
% This finds the 15 most meaningful peaks 
% based on known spectra for healthy and malignant tissue. Then, the 
% 15 peaks are integrated for each imported spectra for post-processing 
% through PCA and LDA


% close all figures
close all

% clear all variables 
clear all

%% Get the datasets 
ds_1 = getDataSet('12/3/2016');
ds_5 = getDataSet('4/7/2017');

%% Apply transforms to normalize area and correct for fluorescence
% corr_1 = ds_1.getCorr();
% corr_5 = ds_5.getCorr();
norm_1 = ds_1.getNorm();
norm_5 = ds_5.getNorm();
normCorr_1 = ds_1.getNormCorr();
normCorr_5 = ds_5.getNormCorr();

titles_1 = ds_1.titles;
titles_5 = ds_5.titles;


wavenumbers_1 = ds_1.x;
wavenumbers_5 = ds_5.x;

%% Split the corrected spectra into the corresponding transects. Note that
% indexing samples is weird cuz the numbering is 'sample1,10,11,etc.' in 
% the database on Google drive.

% healthy and tumor are easy for 12/3
healthy_1 = normCorr_1(1:end, 2:28);
havg_1 = mean(healthy_1,2);
tumor_1 = normCorr_1(1:end, 30:end);
tavg_1 = mean(tumor_1, 2);


% not the case for 4/7 lol

% numbers span 16 - 65 leave out 
    % 16,27,38 (probe_1,2,3) beginning stuff not great
    % 47,48,50 ->(probe_38,39,40) something wrong
healthy_5 = normCorr_5(1:end, [17:22 29:37 39 55:59 61 64:65]); %healthy colums
havg_5 = mean(healthy_5,2);
tumor_5 = normCorr_5(1:end, [23:26 40:46 49 51:54 60 62:63]); %tumor columns
tavg_5 = mean(tumor_5,2);

healthyN_5 = norm_5(1:end, [17:22 29:37 39 55:59 61 64:65]); %healthy colums
havgN_5 = mean(healthyN_5,2);
tumorN_5 = norm_5(1:end, [23:26 40:46 49 51:54 60 62:63]); %tumor columns
tavgN_5 = mean(tumorN_5,2);

subplot(2,1,1)
hold on

plot(wavenumbers_5, havgN_5);
plot(wavenumbers_5, tavgN_5);
xlim([250 3200])
title('Avg. Normalized Spectra; ex=785nm; n=24 healthy, 19 neoplasia; time=10sec, scans=1')
%title('Avg. Normalized Spectra; ex=1064nm; n=27 healthy, 28 neoplasia; time=10sec, scans=3')
ylabel('Rel. Intensity (arb. units)')
xlabel('Wavenumber cm^-^1')

subplot(2,1,2)
hold on

plot(wavenumbers_5, havg_5);
plot(wavenumbers_5, tavg_5);
xlim([250 3200])
title('Avg. Normalized & Corrected Spectra; ex=785nm; n=24 healthy, 19 neoplasia; time=10sec, scans=1')
ylabel('Rel. Intensity (arb. units)')
xlabel('Wavenumber cm^-^1')



