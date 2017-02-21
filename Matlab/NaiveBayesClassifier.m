%% Label Test Sample Observations of Naive Bayes Classifiers
%%
% Load Fisher's iris data set.

% Copyright 2015 The MathWorks, Inc.

ic = IndexCrawler('12/3/2016');
normMatrix = ic.getNormMatrix();
head = ic.getHeader();
labels = cellfun(@(v) v, head(1,:), 'UniformOutput', false);
remNums = cellfun(@(v) replaceBetween(v, '_', '.txt', ''), labels, 'UniformOutput', false);
remRest = cellfun(@(v) replace(v, '_', '.txt', ''), remNums, 'UniformOutput', false);


X = normMatrix(1:end,2:end)';    % Predictors
Y = remRest'; % Response
rng(1);
%%
% Train a naive Bayes classifier and specify to holdout 30% of the data for
% a test sample. It is good practice to specify the class order. Assume
% that each predictor is conditionally, normally distributed given its
% label.
CVMdl = fitcnb(X,Y,'Holdout',0.30,...
    'ClassNames',{'setosa','versicolor','virginica'});
CMdl = CVMdl.Trained{1};          % Extract trained, compact classifier
testIdx = test(CVMdl.Partition); % Extract the test indices
XTest = X(testIdx,:);
YTest = Y(testIdx);
%%
% |CVMdl| is a |ClassificationPartitionedModel| classifier. It
% contains the property |Trained|, which is a 1-by-1 cell array holding a
% |CompactClassificationNaiveBayes| classifier that the software trained using the
% training set.
%%
% Label the test sample observations.  Display the results for a random set
% of 10 observations in the test sample.
idx = randsample(sum(testIdx),10);
label = predict(CMdl,XTest);
table(YTest(idx),label(idx),'VariableNames',...
    {'TrueLabel','PredictedLabel'})