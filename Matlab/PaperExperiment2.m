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
ds_3 = getDataSet('2/24/2017');
ds_4 = getDataSet('3/3/2017');

%% Apply transforms to normalize area and correct for fluorescence
[corr_3, cfactors_3] = ds_3.applyProcess(ds_3.data, 'corr');
[corr_4, cfactors_4] = ds_4.applyProcess(ds_4.data, 'corr');
[norm_3, nfactors_3] = ds_3.applyProcess(ds_3.data, 'norm');
[norm_4, nfactors_4] = ds_4.applyProcess(ds_4.data, 'norm');
[normCorr_3, cnfactors_3] = ds_3.applyProcess(corr_3, 'norm');
[normCorr_4, cnfactors_4] = ds_4.applyProcess(corr_4, 'norm');

wavenumbers_3 = ds_3.x;
wavenumbers_4 = ds_4.x;

%% Split the corrected spectra into the corresponding transects. Note that
% indexing samples is weird cuz the numbering is 'sample1,10,11,etc.' in 
% the database on Google drive.

% Patient 3
transect1_3 = normCorr_3(1:end, 23); %transect1_3 (actually uses sample3 not sample5)
transect1_3 = [transect1_3, normCorr_3(1:end, 35:38)]; %transect1_3 
transect1_3 = [transect1_3, normCorr_3(1:end, 2:7)]; %transect1_3 
transect2_3 = normCorr_3(1:end, 8:11); %transect2_3 
transect2_3 = [transect2_3, normCorr_3(1:end, 13:16)]; %transect2_3
transect3_3 = normCorr_3(1:end, 17:21); %transect3_3
transect4_3 = normCorr_3(1:end, 22); %transect4_3 
transect4_3 = [transect4_3, normCorr_3(1:end, 24:31)]; %transect4_3

% Patient 4
transect1_4 = normCorr_4(1:end, 21:24);
transect1_4 = [transect1_4, normCorr_4(1:end, 14:20)];
transect2_4 = normCorr_4(1:end, 25:34); 


%% Which spectra are healthy? Which are malignant? Hard-coded, for now...
healthy_3 = [transect1_3(:,1:3), transect2_3(:,7:8)];
tumor_3 = [transect1_3(:,7:11),transect2_3(:,1:3),transect3_3(:,3:4),transect4_3(:,1:4)];
unknown_3 = [transect1_3(:,4:6),transect2_3(:,4:6),transect3_3(:,1:2),transect3_3(:,5),transect4_3(:,5:9)];

tumor_4 = [transect1_4(:,1:end-4), transect2_4(:,5:end)];
healthy_4 = [transect1_4(:,(end-2):end), transect2_4(:,1:3)];
unknown_4 = [transect1_4(:,(end-3)), transect2_4(:,4)];

%% Averages, standard deviations, sample sizes, and t-stats for the groups
aveHealthy_3 = mean(healthy_3')';
aveTumor_3 = mean(tumor_3')';
aveUnknown_3 = mean(unknown_3')';
stdHealthy_3 = std(healthy_3')';
stdTumor_3 = std(tumor_3')';
nHealthy_3 = size(healthy_3,2);
nTumor_3 = size(tumor_3,2);
tHealthy_3 = tinv(0.975,(nHealthy_3-1));
tTumor_3 = tinv(0.975,(nTumor_3-1));

aveHealthy_4 = mean(healthy_4')';
aveTumor_4 = mean(tumor_4')';
aveUnknown_4 = mean(unknown_4')';
stdHealthy_4 = std(healthy_4')';
stdTumor_4 = std(tumor_4')';
nHealthy_4 = size(healthy_4,2);
nTumor_4 = size(tumor_4,2);
tHealthy_4 = tinv(0.975,(nHealthy_4-1));
tTumor_4 = tinv(0.975,(nTumor_4-1));

%% Vectors for the error bars in order to make 95% confidence intervals
% for each tissue type at each wavenumber
errHealthy_3 = tHealthy_3.*stdHealthy_3;
errTumor_3 = tTumor_3.*stdTumor_3;

errHealthy_4 = tHealthy_4.*stdHealthy_4;
errTumor_4 = tTumor_4.*stdTumor_4;

% Plot the averages with confidence intervals
hold on
errorbar(aveHealthy_3,errHealthy_3)
errorbar(aveTumor_3,errTumor_3)
figure
hold on
errorbar(aveHealthy_4,errHealthy_4)
errorbar(aveTumor_4,errTumor_4)

%% Identify regions of no overlap between the confidence intervals. For 
% each, note the wavenumber (WOI), wavenumber index (XOI), and region 
% of no overlap between the confidence intervals (OOI)
WOI_3 = []; %Wavenumber Of Interest
XOI_3 = []; %Index of Interest 
OOI_3 = []; %Overlap of Interest
WOI_4 = []; %Wavenumber Of Interest
XOI_4 = []; %Index of Interest 
OOI_4 = []; %Overlap of Interest

% loop through every wavenumber
for i = 1:length(wavenumbers_3)
    % If the difference between the means is greater than the sum of 
    % the halves of the confidence intervals, there is no overlap
    aveDiff_3 = abs(aveHealthy_3(i)-aveTumor_3(i));
    overlap_3 = aveDiff_3 - (errHealthy_3(i) + errTumor_3(i));
     if overlap_3 > 0
         WOI_3 = [WOI_3 wavenumbers_3(i)];
         XOI_3 = [XOI_3 i];
         OOI_3 = [OOI_3 overlap_3];
     end
end

for i = 1:length(wavenumbers_4)
    % If the difference between the means is greater than the sum of 
    % the halves of the confidence intervals, there is no overlap
    aveDiff_4 = abs(aveHealthy_4(i)-aveTumor_4(i));
    overlap_4 = aveDiff_4 - (errHealthy_4(i) + errTumor_4(i));
     if overlap_4 > 0
         WOI_4 = [WOI_4 wavenumbers_4(i)];
         XOI_4 = [XOI_4 i];
         OOI_4 = [OOI_4 overlap_4];
     end
end


%% Consolidate the discrete wavenumbers_3 of interest into larger regions
% of interest that include consecutive wavenumbers_3 and the total 
% whitespace summed across the included wavenumbers_3
i_3 = 1;
ROI_3 = []; % Regions of Interest
count_3 = 0;
overlap_3 = 0;
i_4 = 1;
ROI_4 = []; % Regions of Interest
count_4 = 0;
overlap_4 = 0;

% Loop across every wavenumber
while i_3 <= length(XOI_3)-1
    if(XOI_3(i_3+1) - XOI_3(i_3)) == 1
        count_3 = count_3 + 1;        
    % This case would account for instances in which only one wavenumber
    % separates the two regions, however we have not computed the OOI for 
    % the separating wavenumber, therefore that wouldn't be included in the
    % sum in the else case...
    %elseif(XOI(i+1) - XOI(i)) == 2
    %    count = count + 1;    
    else
        ROI_3 = [ROI_3; (count_3+1) sum(OOI_3(i_3-count_3:i_3)) XOI_3(i_3-count_3) WOI_3(i_3-count_3)];
        count_3 = 0;
    end
    i_3 = i_3+1;
end
while i_4 <= length(XOI_4)-1
    if(XOI_4(i_4+1) - XOI_4(i_4)) == 1
        count_4 = count_4 + 1;        
    % This case would account for instances in which only one wavenumber
    % separates the two regions, however we have not computed the OOI for 
    % the separating wavenumber, therefore that wouldn't be included in the
    % sum in the else case...
    %elseif(XOI(i+1) - XOI(i)) == 2
    %    count = count + 1;    
    else
        ROI_4 = [ROI_4; (count_4+1) sum(OOI_4(i_4-count_4:i_4)) XOI_4(i_4-count_4) WOI_4(i_4-count_4)];
        count_4 = 0;
    end
    i_4 = i_4+1;
end

% This line includes the last wavenumber
ROI_3 = [ROI_3; count_3+1 sum(OOI_3(i_3-count_3:i_3)) XOI_3(i_3-count_3) WOI_3(i_3-count_3)];
ROI_4 = [ROI_4; count_4+1 sum(OOI_4(i_4-count_4:i_4)) XOI_4(i_4-count_4) WOI_4(i_4-count_4)];

% Sort the regions in descending order according to the integrated OOI's
ROI_3 = sortrows(ROI_3,2);
ROI_3 = flipud(ROI_3);
ROI_4 = sortrows(ROI_4,2);
ROI_4 = flipud(ROI_4);

%% Integrate the top 15 peaks (as defined from the ROI matrix) from each spectra
peakSpectra_3 = zeros(15,size(normCorr_3,2));
peakSpectra_4 = zeros(15,size(normCorr_4,2));

for i = 1:15
    for j_3 = 1:size(normCorr_3,2)
        % Patient 3 with patient 3 classification
        %peakSpectra_3(i,j_3) = sum(normCorr_3(ROI_3(i,3):(ROI_3(i,1)+ROI_3(i,3)-1),j_3));
        % Patient 3 with patient 4 classification
        peakSpectra_3(i,j_3) = sum(normCorr_3(ROI_4(i,3):(ROI_4(i,1)+ROI_4(i,3)-1),j_3));
    end
    for j_4 = 1:size(normCorr_4,2)
        % Patient 4 with patient 4 classification       
        %peakSpectra_4(i,j_4) = sum(normCorr_4(ROI_4(i,3):(ROI_4(i,1)+ROI_4(i,3)-1),j_4));
        % Patient 4 with patient 3 classification
        peakSpectra_4(i,j_4) = sum(normCorr_4(ROI_3(i,3):(ROI_3(i,1)+ROI_3(i,3)-1),j_4));
    end
end

%% Conduct PCA on the integrated peaks for all spectra

% Transpose of 'peakSpectra' because rows correspond to observations and
% colummns correspond to variables
% columns of coeff are the relative weightings of each of the 15 peaks

%[coeff_3,score_3,latent_3,tsquared_3,explained_3,mu_3] = pca(peakSpectra_3');   % use this line to use all 15 bands
%[coeff_3,score_3,latent_3,tsquared_3,explained_3,mu_3] = pca([peakSpectra_3(2:4,:);peakSpectra_3(6:end,:)]'); % use this line if ROI_3 is used to take 13 peaks
%[coeff_3,score_3,latent_3,tsquared_3,explained_3,mu_3] = pca([peakSpectra_3(2:9,:);peakSpectra_3(11:end,:)]'); % use this line if ROI_4 is used to take 13 peaks  
%[coeff_3,score_3,latent_3,tsquared_3,explained_3,mu_3] = pca([peakSpectra_3(1,:);peakSpectra_3(5,:)]'); % use this line if ROI_3 is used to take 2 peaks
[coeff_3,score_3,latent_3,tsquared_3,explained_3,mu_3] = pca([peakSpectra_3(1,:);peakSpectra_3(10,:)]'); % use this line if ROI_4 is used to take 2 peaks


%[coeff_4,score_4,latent_4,tsquared_4,explained_4,mu_4] = pca(peakSpectra_4');   % use this line to use all 15 bands
%[coeff_4,score_4,latent_4,tsquared_4,explained_4,mu_4] = pca([peakSpectra_4(2:9,:);peakSpectra_4(11:end,:)]'); % use this line if ROI_4 is used to take 13 peaks  
%[coeff_4,score_4,latent_4,tsquared_4,explained_4,mu_4] = pca([peakSpectra_4(2:4,:);peakSpectra_4(6:end,:)]'); % use this line if ROI_3 is used to take 13 peaks
%[coeff_4,score_4,latent_4,tsquared_4,explained_4,mu_4] = pca([peakSpectra_4(1,:);peakSpectra_4(10,:)]'); % use this line if ROI_4 is used to take 13 peaks  
[coeff_4,score_4,latent_4,tsquared_4,explained_4,mu_4] = pca([peakSpectra_4(1,:);peakSpectra_4(5,:)]'); % use this line if ROI_3 is used to take 13 peaks


% Extract the first coefficient since the first principal component
% explains 93% of the variation in our data
% columns of score are the magnitude of the principal component for each
% spectra
% firstcoeff is the magnitude of the first coefficient for each spectra
firstCoeff_3 = score_3(:,1);
firstCoeff_4 = score_4(:,1);

% Define transects again, this time based only on the value of the first
% principal component coefficient
transect1_3 = firstCoeff_3(23); %transect1_3 (actually uses sample3 not sample5)
transect1_3 = [transect1_3; firstCoeff_3(35:38)]; %transect1_3 
transect1_3 = [transect1_3; firstCoeff_3(2:7)]; %transect1_3 
transect2_3 = firstCoeff_3(8:11); %transect2_3 
transect2_3 = [transect2_3; firstCoeff_3(13:16)]; %transect2_3
transect3_3 = firstCoeff_3(17:21); %transect3_3
transect4_3 = firstCoeff_3(22); %transect4_3 
transect4_3 = [transect4_3; firstCoeff_3(24:31)]; %transect4_3

transect1_4 = firstCoeff_4(21:24);
transect1_4 = [transect1_4; firstCoeff_4(14:20)];
transect2_4 = firstCoeff_4(25:34); 

% Split the transects into 3 groups
healthy2_3 = [transect1_3(1:3); transect2_3(7:8)];
tumor2_3 = [transect1_3(7:11);transect2_3(1:3);transect3_3(3:4);transect4_3(1:4)];
unknown2_3 = [transect1_3(4:6);transect2_3(4:6);transect3_3(1:2);transect3_3(5);transect4_3(5:9)];

tumor2_4 = [transect1_4(1:end-4); transect2_4(5:end)];
healthy2_4 = [transect1_4((end-2):end); transect2_4(1:3)];
unknown2_4 = [transect1_4((end-3)); transect2_4(4)];


%% Apply the same method for the magnitude of the second principal component
secondCoeff_3 = score_3(:,2);
secondCoeff_4 = score_4(:,2);

% Define transects again, this time based only on the value of the first
% principal component coefficient
transect1_3 = secondCoeff_3(23); %transect1_3 (actually uses sample3 not sample5)
transect1_3 = [transect1_3; secondCoeff_3(35:38)]; %transect1_3 
transect1_3 = [transect1_3; secondCoeff_3(2:7)]; %transect1_3 
transect2_3 = secondCoeff_3(8:11); %transect2_3 
transect2_3 = [transect2_3; secondCoeff_3(13:16)]; %transect2_3
transect3_3 = secondCoeff_3(17:21); %transect3_3
transect4_3 = secondCoeff_3(22); %transect4_3 
transect4_3 = [transect4_3; secondCoeff_3(24:31)]; %transect4_3

transect1_4 = secondCoeff_4(21:24);
transect1_4 = [transect1_4; secondCoeff_4(14:20)];
transect2_4 = secondCoeff_4(25:34); 


% Split the transects into 3 groups
healthy3_3 = [transect1_3(1:3); transect2_3(7:8)];
tumor3_3 = [transect1_3(7:11);transect2_3(1:3);transect3_3(3:4);transect4_3(1:4)];
unknown3_3 = [transect1_3(4:6);transect2_3(4:6);transect3_3(1:2);transect3_3(5);transect4_3(5:9)];

tumor3_4 = [transect1_4(1:end-4); transect2_4(5:end)];
healthy3_4 = [transect1_4((end-2):end); transect2_4(1:3)];
unknown3_4 = [transect1_4((end-3)); transect2_4(4)];


% %% Create Discriminant Analysis Classifiers
% % Trains a linear discriminant analysis classifier
% % Then classifies samples in COH teams's Raman spectra data
% 
% %% Get the data
% % Data has two parts:
% % First is observations (PCA), second is truths (classes)
% PCA = coeff_3;
% 
% % Take the 5 healthy, then 14 tumor
% %PCA1 = [PCA1(1:3); PCA1(8:11); PCA1(7:11);PCA1(1:3);PCA1(3:4);PCA1(1:4)];
% %PCA2 = [PCA2(1:3); PCA2(8:11); PCA2(7:11);PCA2(1:3);PCA2(3:4);PCA2(1:4)];
% PCA1 = [healthy2_3;tumor2_3];
% PCA2 = [healthy3_3;tumor3_3];
% PCA = [PCA1,PCA2];
% % Define the healthy and tumor classifications
% % This is ugly. Created an array of chars (which need to be same size,
% % hence spaces after tumor, then converted to a cell for the fitcdiscr
% % function
% classes = ['healthy';'healthy';'healthy';'healthy';'healthy';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  '];
% classes = cellstr(classes);
% classesUnknowns = [classes; 'unknown';'unknown';'unknown';'unknown';'unknown';'unknown';'unknown';'unknown';'unknown';'unknown';'unknown';'unknown';'unknown';'unknown'];
% classesUnknowns = cellstr(classesUnknowns);
% %% Create a linear discriminant analysis classifier.
% MdlLinear = fitcdiscr(PCA,classes);
% 
% %% Retrieve linear boundary coefficients
% MdlLinear.ClassNames([1 2]);
% K = MdlLinear.Coeffs(1,2).Const;
% L = MdlLinear.Coeffs(1,2).Linear;
% 
% %% Scoring
% xMax = max(PCA);
% xMin = min(PCA);
% d = 0.001;
% [x1Grid,x2Grid] = meshgrid(xMin(1):d:xMax(1),xMin(2):d:xMax(2));
% [~,score2] = predict(MdlLinear,[x1Grid(:),x2Grid(:)]);
% [label,score_3,cost] = predict(MdlLinear,PCA);
% 
% %% Plotting
% % Plot Data
% figure
% %h1 = gscatter(PCA1,PCA2,classes,'krb','ov^',[],'off'); %may need to remove 1 letter from krb and ov^
% h1 = gscatter([PCA1;unknown2_3],[PCA2;unknown3_3],classesUnknowns,'grk','ooo',[],'off'); %may need to remove 1 letter from krb and ov^
% h1(1).LineWidth = 2;
% h1(2).LineWidth = 2;
% %legend('Healthy','Tumor','Unknown','Location','best')
% hold on
% 
% % Plot curve separating classes
% f = @(x1,x2) K + L(1)*x1 + L(2)*x2;
% %h2 = ezplot(f); 
% h2 = ezplot(f,[-1 1 -1 1]); %if we want to set window
% h3.Color = 'r';
% h3.LineWidth = 2;
% axis([-.08 0.12 -0.0006 0.0004]) %set this
% xlabel('PCA 1')
% ylabel('PCA 2')
% title('{\bf Linear Classification for Patient 3 Using PCA1 and PCA2}')
% legend('Healthy','Tumor','Unknown','Boundary')
% 
% % Plot posterior probability Contour
% figure;
% contourf(x1Grid,x2Grid,reshape(score2(:,2),size(x1Grid,1),size(x1Grid,2)));
% h = colorbar;
% caxis([0 1]);
% colormap jet;
% hold on
% gscatter(PCA(:,1),PCA(:,2),classes,'mcy','.x+');
% axis tight
% title('Posterior Probability of versicolor');
% hold off



%% Create Discriminant Analysis Classifiers
% Trains a linear discriminant analysis classifier
% Then classifies samples in COH teams's Raman spectra data

%% Get the data
% Data has two parts:
% First is observations (PCA), second is truths (classes)
PCA = coeff_4;

% Take the 5 healthy, then 14 tumor
%PCA1 = [PCA1(1:3); PCA1(8:11); PCA1(7:11);PCA1(1:3);PCA1(3:4);PCA1(1:4)];
%PCA2 = [PCA2(1:3); PCA2(8:11); PCA2(7:11);PCA2(1:3);PCA2(3:4);PCA2(1:4)];
PCA1 = [healthy2_4;tumor2_4];
PCA2 = [healthy3_4;tumor3_4];
PCA = [PCA1,PCA2];
% Define the healthy and tumor classifications
% This is ugly. Created an array of chars (which need to be same size,
% hence spaces after tumor, then converted to a cell for the fitcdiscr
% function
classes = ['healthy';'healthy';'healthy';'healthy';'healthy';'healthy';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  ';'tumor  '];
classes = cellstr(classes);
classesUnknowns = [classes; 'unknown';'unknown'];
classesUnknowns = cellstr(classesUnknowns);
%% Create a linear discriminant analysis classifier.
MdlLinear = fitcdiscr(PCA,classes);

%% Retrieve linear boundary coefficients
MdlLinear.ClassNames([1 2]);
K = MdlLinear.Coeffs(1,2).Const;
L = MdlLinear.Coeffs(1,2).Linear;

%% Scoring
xMax = max(PCA);
xMin = min(PCA);
d = 0.001;
[x1Grid,x2Grid] = meshgrid(xMin(1):d:xMax(1),xMin(2):d:xMax(2));
[~,score2] = predict(MdlLinear,[x1Grid(:),x2Grid(:)]);
[label,score_3,cost] = predict(MdlLinear,PCA);

%% Plotting
% Plot Data
figure
%h1 = gscatter(PCA1,PCA2,classes,'krb','ov^',[],'off'); %may need to remove 1 letter from krb and ov^
h1 = gscatter([PCA1;unknown2_4],[PCA2;unknown3_4],classesUnknowns,'grk','ooo',[],'off'); %may need to remove 1 letter from krb and ov^
h1(1).LineWidth = 2;
h1(2).LineWidth = 2;
%legend('Healthy','Tumor','Unknown','Location','best')
hold on

% Plot curve separating classes
f = @(x1,x2) K + L(1)*x1 + L(2)*x2;
%h2 = ezplot(f); 
h2 = ezplot(f,[-1 1 -1 1]); %if we want to set window
h3.Color = 'r';
h3.LineWidth = 2;
axis([-.04 0.04 -.001 0.0012]) %set this
xlabel('PCA 1')
ylabel('PCA 2')
title('{\bf Linear Classification for Patient 4 Using PCA1 and PCA2}')
legend('Healthy','Tumor','Unknown','Boundary')

% Plot posterior probability Contour
figure;
contourf(x1Grid,x2Grid,reshape(score2(:,2),size(x1Grid,1),size(x1Grid,2)));
h = colorbar;
caxis([0 1]);
colormap jet;
hold on
gscatter(PCA(:,1),PCA(:,2),classes,'mcy','.x+');
axis tight
title('Posterior Probability of versicolor');
hold off




%% Plot the average spectra for patient 3 and 4
figure

gray = [ .9 .9 .9]; 

subplot(2,1,1)

hold on

for i = 1:15
    left = wavenumbers_3(ROI_3(i,3));
    right = wavenumbers_3(ROI_3(i,1)+ROI_3(i,3)-1);
    h = patch([left right right left],[-1 -1 1 1],gray);
    set(h,'EdgeColor',[1 1 1]);
end

h(1) = plot(wavenumbers_3,aveHealthy_3)
h(2) = plot(wavenumbers_3,aveTumor_3)
h(3) = plot(wavenumbers_3,aveUnknown_3)
%legend('Average Healthy','Average Tumor','Average Unknown')
axis([0 3500 -0.001 0.006])
title('Patient 3')
legend(h([1 2 3]),'Healthy Average (n = 5)','Tumor Average (n = 14)','Boundary Average (n = 14)')
xlabel('Wavenumbers (cm^-^1)')
ylabel('Rel Intensity (arb. units)')

subplot(2,1,2)

hold on

for i = 1:15
    left = wavenumbers_4(ROI_4(i,3));
    right = wavenumbers_4(ROI_4(i,1)+ROI_4(i,3)-1);
    h = patch([left right right left],[-1 -1 1 1],gray);
    set(h,'EdgeColor',[1 1 1]);
end

h(1) = plot(wavenumbers_4,aveHealthy_4)
h(2) = plot(wavenumbers_4,aveTumor_4)
h(3) = plot(wavenumbers_4,aveUnknown_4)
%legend('Average Healthy','Average Tumor','Average Unknown')
axis([0 3500 -0.001 0.006])
title('Patient 4')
legend(h([1 2 3]),'Healthy Average (n = 6)','Tumor Average (n = 13)','Boundary Average (n = 2)')
xlabel('Wavenumbers (cm^-^1)')
ylabel('Rel Intensity (arb. units)')





