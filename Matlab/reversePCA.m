%% This is using Canonical Correlation to reconstrcut using basis components

%   "The classical canonical correlation analysis is extremely greedy to 
%   maximize the squared correlation between two sets of variables. 
%   As a result, if one of the variables in the dataset-1 is very highly 
%   correlated with another variable in the dataset-2, the canonical 
%   correlation will be very high irrespective of the correlation among 
%   the rest of the variables in the two datasets."

% https://papers.ssrn.com/sol3/papers.cfm?abstract_id=1331886

%% get the ic object and gather information

ic = IndexCrawler('12/3/2016');
ds = ic.getDataSet();

% apply transforms
[corr, cfactors] = ds.applyProcess(ds.data, 'corr');
[normCorr, cnfactors] = ds.applyProcess(corr, 'norm');

% corrected and normed
healthysNCorr = normCorr(1:end, 2:29);
tumorsNCorr = normCorr(1:end, 30:end);

% take the section from data points 69 to 69+201 - 1 =269 (length of basis
% spectra)
healthysNCorr = healthysNCorr(69:266,:);
tumorsNCorr = tumorsNCorr(69:266,:);

%% We take in PCA components generated from Haka's data (ndim)
%ndim = a;
ndim2 = a2;

%ndim2 = [ndim2(:,3),ndim2(:,5)]; %Only fat and collagen

%normalize PCA basis
temp = size(ndim2);
for i = 1:temp(2) 
    factor = sum(ndim2(:,i));
    ndim2(:,i) = ndim2(:,i)./factor;
end 

temp = size(healthysNCorr);
k1 = temp(2);
temp = size(tumorsNCorr);
k2 = temp(2);

%% Run a reverse principal component analysis for each spectra that we collected (X)
[coA_healthy, coB_healthy,rH, uH, vH ] = canoncorr(healthysNCorr,ndim2);
[coA_tumor, coB_tumor, rT, uT, vT ] = canoncorr(tumorsNCorr,ndim2);

%% Plot residuals as a function of sample
%figure
%u_combined = [uH;uT];
%plot(u_combined,'.')
figure
coA_combined = [coA_healthy;coA_tumor];
plot(coA_combined,'.')
title('All Coefficients')
xlabel('x = 1-28 is healthy, x = 29-56 is tumor')
figure
for j = 1:3
    for i = 1:3
        index = 3*(j-1)+i;
        subplot(3,3,index)
        plot(coA_combined(:,index),'.')
        title(['coefficient ' num2str(index)])
        axis([0 60 -3000 3000])
        hold on
    end
    hold on
end

