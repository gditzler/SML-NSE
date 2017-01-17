% This script implements the a data stream scenario where the testing data 
% are made available at each time stamp; however, the proportion of training
% data can be controlled (i.e., other time stamp, etc.). The proportion of
% missing training data can be controlled by changing the ``miss_amt'' 
% variable located at the top of the code. You can also control whether the 
% models are evaluated in a test-then-train setting or test-on-last setting 
% by chaning ``end_experiment''. For the purposes of this script it does not
% make too much sense to set end_experiment=1. Keep it at zero. 
clc; 
clear; 
close all;

% add the paths for the algorithms we are going to compare against 
addpath('algorithms/');
addpath('utils/');
addpath('data/');
addpath(genpath('SCARGC_codes/'));

% free parameters of the experiement
miss_amt = 2;         % percentange of missing training data 
end_experiment = 0;   % test-then-train or test-on-last
avg = 10;             % number of averages to perform  
alpha = .7;           % exponential forgetting factor for CVX-sense
beta = .5;            % convex combination parameter for CVX-sense

% data must be downloaded from the UAMLDA Gitlab data set repo 
datasets = {
    'adult_train.csv'
    'bank.csv'
    'blood.csv'
    'breast-cancer-wisc-diag.csv'
    'breast-cancer-wisc-prog.csv'
    'breast-cancer-wisc.csv'
    'breast-cancer.csv'
    'chess-krvkp.csv'
    'congressional-voting.csv'
    'conn-bench-sonar-mines-rocks.csv'
    'credit-approval.csv'
    'cylinder-bands.csv'
    'heart-hungarian.csv'
    'hill-valley_train.csv'
    'horse-colic_train.csv'
    'ilpd-indian-liver.csv'
    'ionosphere.csv'
    'magic.csv'
    'mammographic.csv'
    'mushroom.csv'
    'musk-2.csv'
    'oocytes_merluccius_nucleus_4d.csv'
    'oocytes_trisopterus_nucleus_2f.csv'
    'pima.csv'
    'ringnorm.csv'
    'spambase.csv'
    'statlog-australian-credit.csv'
    'statlog-german-credit.csv'
    'statlog-heart.csv'
    'tic-tac-toe.csv'
    'titanic.csv'
    'twonorm.csv'
    'vertebral-column-2clases.csv'
  };
% delete(gcp('nocreate'));
% parpool(4);
mclass = 2;


for dd = 1:length(datasets)
  % print out who we are currently working with just in case there is an
  % error in the experiemnt 
  dat = datasets{dd};
  disp(['Running ', dat])
  
  % some of the data sets are formatted differently from others, so in
  % these cases we need to make sure that all of the data from different
  % sources are formated the same when we exit the conditional statements.
  % the data will be stored in alldata and allclass. 
  if strcmp(datasets{dd}, 'ionosphere')
    load ionosphere
    [~,~,y] = unique(Y);
    allclass = y;
    alldata(:, 2) = [];
  elseif strcmp(datasets{dd}, 'ovariancancer')
    load ovariancancer
    [~,~,y] = unique(grp);
    allclass = y;
    alldata = obs;
  elseif strcmp(datasets{dd}, 'arrhythmia')
    load arrhythmia
    dels = find(Y==16);
    Y(dels) = [];
    X(dels, :) = [];
    X(:, [11,2,14]) = [];
    z = sum(isnan(X),2);
    X(z==1, :) = [];
    Y(z==1) = [];
    Y(Y~=1) = -1;
    Y(Y==-1) = 2;
    data = [Y X];
    alldata = X;
    allclass = Y;
    clear dels Description VarNames X Y z
  elseif length(findstr('csv', datasets{dd})) > 0
    data = load(['../../ClassificationDatasets/csv/', datasets{dd}]);
    X = data(:, 1:end-1);
    Y = data(:, end);
    Y(Y == 0) = 2;
    X = X(:, std(X)~=0);
    alldata = X;
    allclass = Y;
  else
    load(['../../OFSE/data/', datasets{dd}, '.mat'])
    X = data(:, 2:end);
    Y = data(:, 1);
    X = X(:, std(X)~=0);
    Y(Y==-1) = 2;
    alldata = X;
    allclass = Y;
  end
  
  [nos, nof] = size(alldata);
  
  shuffs = randperm(nos);
  alldata = alldata(shuffs, :);
  allclass = allclass(shuffs);
  
  % set a window size based on the size of the data set. given that we have
  % very different data set sizes, we need to have a way to make sure we do
  % not have a data set with 2 time stamps and 2000 time stamps. 
  if nos < 1000
    win_size = 50;
  elseif nos < 10000
    win_size = 100;
  elseif nos < 15000
    win_size = 250;
  else
    win_size = 500;
  end
  
  % several of the models need to know the number of time stamps in
  % advance, so partition the data into a stream to determine the number of
  % batches in the data stream 
  if end_experiment == 1
    [data_train, data_test, labels_train, labels_test] = test_on_last(...
      alldata, allclass, win_size, true);
  else
    [data_train, data_test, labels_train, labels_test] = test_then_train(...
      alldata, allclass, win_size, true);
  end
  
  
  max_learners = length(data_train) + 1;
  model.type = 'CART';             % base classifier
  netFTL.mclass = 2;               % number of classes in the prediciton problem
  netFTL.base_classifier = model;  % set the base classifier in the net struct
  netFTL.n_classifiers = max_learners;
  netNSE.a = .5;                   % slope parameter to a sigmoid
  netNSE.b = 10;                   % cutoff parameter to a sigmoid
  netNSE.threshold = 0.01;         % how small is too small for error
  netNSE.mclass = mclass;          % number of classes in the prediciton problem
  netNSE.base_classifier = model;  % set the base classifier in the net struct

  % set up variables to save the error, kappa, and evaluation times 
  err_sml = zeros(length(data_train), avg); 
  err_mle = zeros(length(data_train), avg); 
  err_map = zeros(length(data_train), avg); 
  err_avg_cor = zeros(length(data_train), avg); 
  err_avg = zeros(length(data_train), avg); 
  err_ftl = zeros(length(data_train), avg); 
  err_nse = zeros(length(data_train), avg);
  err_cvx = zeros(length(data_train), avg);
  err_scar = zeros(length(data_train), avg);
  
  kappa_sml = zeros(length(data_train), avg); 
  kappa_mle = zeros(length(data_train), avg); 
  kappa_map = zeros(length(data_train), avg); 
  kappa_avg_cor = zeros(length(data_train), avg); 
  kappa_avg = zeros(length(data_train), avg); 
  kappa_ftl = zeros(length(data_train), avg); 
  kappa_nse = zeros(length(data_train), avg);
  kappa_cvx = zeros(length(data_train), avg);
  kappa_scar = zeros(length(data_train), avg);
  
  time_sml = zeros(length(data_train), avg); 
  time_mle = zeros(length(data_train), avg); 
  time_map = zeros(length(data_train), avg); 
  time_avg_cor = zeros(length(data_train), avg); 
  time_avg = zeros(length(data_train), avg); 
  time_ftl = zeros(length(data_train), avg); 
  time_nse = zeros(length(data_train), avg);
  time_cvx = zeros(length(data_train), avg);
  time_scar = zeros(length(data_train), avg);
  
  for i = 1:avg
    disp(['  -Avg ', num2str(i), '/', num2str(avg)]);
    
    % since these are stationary data streams, we can permuate the entire
    % stream without worry. This is imporant if we are to use scargc, which
    % is really not a fair comparison. 
    shuffs = randperm(nos);
    alldata2 = alldata(shuffs, :);
    allclass2 = allclass(shuffs);
  
    % split up the data into a training and testing data stream 
    if end_experiment == 1
      [data_train, data_test, labels_train, labels_test] = test_on_last(...
        alldata2, allclass2, win_size, false);
    else
      [data_train, data_test, labels_train, labels_test] = test_then_train(...
        alldata2, allclass2, win_size, false);
    end
    
    for z = 1:length(data_train)
    	if mod(z+miss_amt-1, miss_amt) ~= 0
        data_train{z} = [];
        labels_train{z} = [];
      end
    end

    % follow the leader
    [err_ftl(:,i), kappa_ftl(:,i), time_ftl(:,i)] = follow_the_leader(...
      netFTL, data_train, labels_train, data_test, labels_test, 1);
    % learn++.nse
    [err_nse(:,i), kappa_nse(:,i), time_nse(:, i)] = learn_nse(netNSE, ...
      data_train, labels_train, data_test, labels_test);
    % sml
    [err_sml(:,i), kappa_sml(:,i), time_sml(:,i)] = incremental_learner(...
      data_train, data_test, labels_train, labels_test, model, max_learners, ...
      'sml2', 1);
    % sml with mle
    %[err_mle(:,i), kappa_mle(:,i), time_mle(:,i)] = incremental_learner(...
    %  data_train, data_test, labels_train, labels_test, model, max_learners, ...
    %  'mle', 1);
    % sml with map
    %[err_map(:,i), kappa_map(:,i), time_map(:,i)] = incremental_learner(...
    %  data_train, data_test, labels_train, labels_test, model, max_learners, ...
    %  'map', 1);
    % simple averging
    %[err_avg(:,i), kappa_avg(:,i), time_avg(:,i)] = incremental_learner(...
    %  data_train, data_test, labels_train, labels_test, model, max_learners, ...
    %  'avg1', 1);
    % corrected averaging
    [err_avg_cor(:,i), kappa_avg_cor(:,i), time_avg_cor(:,i)] = ...
      incremental_learner(data_train, data_test, labels_train, labels_test, ...
      model, max_learners, 'avg2', 1);
    % cvx-sense
    [err_cvx(:,i), kappa_cvx(:,i), time_cvx(:,i)] = cvx_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, alpha, beta, 1);        
  end
  
  if end_experiment == 1
    save(['../results/missing_', num2str(miss_amt), strrep(dat,'.csv', ''), ...
      '_END_err_kappa.mat']);
  else
    save(['../results/missing_', num2str(miss_amt), strrep(dat,'.csv', ''), ...
      '_err_kappa.mat']);
  end
end

delete(gcp('nocreate'));
