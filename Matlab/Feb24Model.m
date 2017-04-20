% Model for February 24th data. This finds the 15 most meaningful peaks 
% based on known spectra for healthy and malignant tissue. Then, the 
% 15 peaks are integrated for each imported spectra for post-processing 
% through PCA/HCA

%% Get the dataset 

%ic = IndexCrawler('2/24/2017'); % day 3
ds = getDataSet('2/24/2017');

%% Apply transforms to normalize area and correct for fluorescence
[corr, cfactors] = ds.applyProcess(ds.data, 'corr');
[norm, nfactors] = ds.applyProcess(ds.data, 'norm');
[normCorr, cnfactors] = ds.applyProcess(corr, 'norm');

wavenumbers = ds.x;

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

%% Which spectra are healthy? Which are malignant? Hard-coded, for now...
healthy = [transect1(:,1:3), transect2(:,7:8)];
tumor = [transect1(:,7:11),transect2(:,1:3),transect3(:,3:4),transect4(:,1:4)];
unknown = [transect1(:,4:6),transect2(:,4:6),transect3(:,1:2),transect3(:,5),transect4(:,5:9)];

%% Averages, standard deviations, sample sizes, and t-stats for the groups
aveHealthy = mean(healthy')';
aveTumor = mean(tumor')';
stdHealthy = std(healthy')';
stdTumor = std(tumor')';
nHealthy = size(healthy,2);
nTumor = size(tumor,2);
tHealthy = tinv(0.975,(nHealthy-1));
tTumor = tinv(0.975,(nTumor-1));

%% Vectors for the error bars in order to make 95% confidence intervals
% for each tissue type at each wavenumber
errHealthy = tHealthy.*stdHealthy;
errTumor = tTumor.*stdTumor;

% Plot the averages with confidence intervals
hold on
errorbar(aveHealthy,errHealthy)
errorbar(aveTumor,errTumor)

%% Identify regions of no overlap between the confidence intervals. For 
% each, note the wavenumber (WOI), wavenumber index (XOI), and region 
% of no overlap between the confidence intervals (OOI)
WOI = []; %Wavenumber Of Interest
XOI = []; %Index of Interest 
OOI = []; %Overlap of Interest

% loop through every wavenumber
for i = 1:length(wavenumbers)
    % If the difference between the means is greater than the sum of 
    % the halves of the confidence intervals, there is no overlap
    aveDiff = abs(aveHealthy(i)-aveTumor(i));
    overlap = aveDiff - (errHealthy(i) + errTumor(i));
     if overlap > 0
         WOI = [WOI wavenumbers(i)];
         XOI = [XOI i];
         OOI = [OOI overlap];
     end
end

%% Consolidate the discrete wavenumbers of interest into larger regions
% of interest that include consecutive wavenumbers and the total 
% whitespace summed across the included wavenumbers
i = 1;
ROI = []; % Regions of Interest
count = 0;
overlap = 0;

% Loop across every wavenumber
while i <= length(XOI)-1
    if(XOI(i+1) - XOI(i)) == 1
        count = count + 1;        
    % This case would account for instances in which only one wavenumber
    % separates the two regions, however we have not computed the OOI for 
    % the separating wavenumber, therefore that wouldn't be included in the
    % sum in the else case...
    %elseif(XOI(i+1) - XOI(i)) == 2
    %    count = count + 1;    
    else
        ROI = [ROI; (count+1) sum(OOI(i-count:i)) XOI(i-count) WOI(i-count)];
        count = 0;
    end
    i = i+1;
end

% This line includes the last wavenumber
ROI = [ROI; count+1 sum(OOI(i-count:i)) XOI(i-count) WOI(i-count)];

% Sort the regions in descending order according to the integrated OOI's
ROI = sortrows(ROI,2);
ROI = flipud(ROI);

%% Integrate the top 15 peaks (as defined from the ROI matrix) from each spectra
peakSpectra = zeros(15,size(normCorr,2));

for i = 1:15
    for j = 1:size(normCorr,2)
        peakSpectra(i,j) = sum(normCorr(ROI(i,3):(ROI(i,1)+ROI(i,3)-1),j));
    end
end

%% Conduct PCA on the integrated peaks for all spectra

[coeff,score,latent,tsquared,explained,mu] = pca(peakSpectra);

% Extract the first coefficient since the first principal component
% explains 93% of the variation in our data
firstCoeff = coeff(:,1);

% Define transects again, this time based only on the value of the first
% principal component coefficient
transect1 = firstCoeff(23); %transect1 (actually uses sample3 not sample5)
transect1 = [transect1; firstCoeff(35:38)]; %transect1 
transect1 = [transect1; firstCoeff(2:7)]; %transect1 
transect2 = firstCoeff(8:11); %transect2 
transect2 = [transect2; firstCoeff(13:16)]; %transect2
transect3 = firstCoeff(17:21); %transect3
transect4 = firstCoeff(22); %transect4 
transect4 = [transect4; firstCoeff(24:31)]; %transect4

% Split the transects into 3 groups
healthy2 = [transect1(1:3); transect2(7:8)];
tumor2 = [transect1(7:11);transect2(1:3);transect3(3:4);transect4(1:4)];
unknown2 = [transect1(4:6);transect2(4:6);transect3(1:2);transect3(5);transect4(5:9)];

% Run T-tests on every unknown spot, comparing the coefficient to the
% distribution of healthy coefficients and tumor coefficients
h = zeros(length(unknown2),1);
p1 = zeros(length(unknown2),1);
p2 = zeros(length(unknown2),1);

for i = 1:length(unknown2)
    [h(i),p1(i)] = ttest2(healthy2,unknown2(i));
    [h(i),p2(i)] = ttest2(tumor2,unknown2(i));
end

% Normalize the P-values so that they sum to one. Column one of 'P'
% corresponds to '% healthy' and column 2 to '% tumor'
for i = 1:length(unknown2)
    P(i,1) = p1(i)/(p1(i)+p2(i));
    P(i,2) = p2(i)/(p1(i)+p2(i));
end










%% Look at the top two principal components
% coeff = coeff';
% 
% transect1 = coeff(:,23); %transect1 (actually uses sample3 not sample5)
% transect1 = [transect1, coeff(:,35:38)]; %transect1 
% transect1 = [transect1, coeff(:,2:7)]; %transect1 
% transect2 = coeff(:,8:11); %transect2 
% transect2 = [transect2, coeff(:,13:16)]; %transect2
% transect3 = coeff(:,17:21); %transect3
% transect4 = coeff(:,22); %transect4 
% transect4 = [transect4, coeff(:,24:31)]; %transect4
% 
% healthy3 = [transect1(:,1:3), transect2(:,7:8)];
% tumor3 = [transect1(:,7:11),transect2(:,1:3),transect3(:,3:4),transect4(:,1:4)];












%% Plots to gut check the correction process
% subplot(4,1,1)
% plot(ds.data(:,23))
% xlabel('Wavenumber')
% ylabel('Rel Intensity')
% title('Raw')
% subplot(4,1,2)
% plot(corr(:,23))
% xlabel('Wavenumber')
% ylabel('Rel Intensity')
% title('Corr')
% subplot(4,1,3)
% plot(norm(:,23))
% xlabel('Wavenumber')
% ylabel('Rel Intensity')
% title('Norm')
% subplot(4,1,4)
% plot(normCorr(:,23))
% xlabel('Wavenumber')
% ylabel('Rel Intensity')
% title('NormCorr')

%% Find the t-statistic for each wavenumber for healthyAve vs tumorAve

% Choose the best peaks based on the residuals, assuming 
% h = zeros(length(wavenumbers),1);
% p = zeros(length(wavenumbers),1);
% zero = zeros(length(wavenumbers),1);
% 
%for i = 1:length(wavenumbers)
%    [h(i),p(i)] = ttest2(healthy(i,:),tumor(i,:));
%end

% subplot(3,1,1)
% plot(wavenumbers,aveHealthy-aveTumor,wavenumbers,zero)
% xlabel('Wavenumbers')
% ylabel('Rel Int')
% title('Residuals for aveHealthy - aveTumor')
% subplot(3,1,2)
% plot(wavenumbers,h)
% xlabel('Wavenumbers')
% ylabel('Zero or One?')
% title('Rejects null hypothesis?')
% subplot(3,1,3)
% plot(wavenumbers,p)
% xlabel('Wavenumbers')
% ylabel('P value')
% title('P-value (high indicates less difference)')