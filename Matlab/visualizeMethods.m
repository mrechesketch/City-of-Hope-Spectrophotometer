% Visualize Different Aspects of the Data

% get the ic object and gather information

ic = IndexCrawler('12/3/2016');
ds = ic.getDataSet();

% apply transforms
[corr, cfactors] = ds.applyProcess(ds.data, 'corr');
[normCorr, cnfactors] = ds.applyProcess(corr, 'norm');

% select vectors
    % unprocessed
healthys = ds.data(1:end, 2:29);
tumors = ds.data(1:end, 30:end);
    % corrected
healthysCorr = corr(1:end, 2:29);
tumorsCorr = corr(1:end, 30:end);
    % corrected and normed
healthysNCorr = normCorr(1:end, 2:29);
tumorsNCorr = normCorr(1:end, 30:end);

% average
    % unprocessed
tumor = mean(tumors, 2);
healthy = mean(healthys, 2);
    % corrected
tumorCorr = mean(tumorsCorr, 2);
healthyCorr = mean(healthysCorr, 2);
    % corrected and normed
tumorNCorr = mean(tumorsNCorr, 2);
healthyNCorr = mean(healthysNCorr, 2);

% plot
figure;
plot(x, tumor, 'color', 'r'); hold on;
plot(x, healthy, 'color', 'b'); hold on;
plot(x, tumorCorr, 'color', 'm'); hold on;
plot(x, healthyCorr, 'color', 'k'); %hold on;
% plot(x, tumorSubNorm, 'color', 'c'); hold on;
% plot(x, healthySubNorm, 'color', 'g');
