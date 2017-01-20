% This script compares FTL, SML, CVX-SML, and L++.NSE of a lage collection 
% of binary prediction problems that come from stationary data streams. Unlike
% other experiments, this script will make sure that the training and testing 
% data are always available. 
clc; 
clear; 
close all;

% add the paths for the algorithms we are going to compare against 
addpath('algorithms/');
addpath('utils/');
addpath('data/');
addpath(genpath('SCARGC_codes/'));

% free parameters of the experiement
avg = 10;             % number of averages to perform  
alpha = .95;           % exponential forgetting factor for CVX-sense
beta = .5;            % convex combination parameter for CVX-sense
mclass = 2;

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
    'spambase.csv'
    'statlog-australian-credit.csv'
    'statlog-german-credit.csv'
    'statlog-heart.csv'
    'tic-tac-toe.csv'
    'titanic.csv'
    'vertebral-column-2clases.csv'
  };


for dd = 1:length(datasets)
  dat = datasets{dd};
  
  disp(['Running ', dat])
  
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
  %[labels,data] = standardize_data(data);
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
  [data_train, data_test, labels_train, labels_test] = test_then_train(...
    alldata, allclass, win_size, true);
  
  
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
  
  parfor i = 1:avg
    disp(['  -Avg ', num2str(i), '/', num2str(avg)]);
    
    % since these are stationary data streams, we can permuate the entire
    % stream without worry. This is imporant if we are to use scargc, which
    % is really not a fair comparison. 
    shuffs = randperm(nos);
    alldata2 = alldata(shuffs, :);
    allclass2 = allclass(shuffs);
  
    % split up the data into a training and testing data stream
    [data_train, data_test, labels_train, labels_test] = test_then_train(...
      alldata2, allclass2, win_size, false);

    % follow the leader
    [err_ftl(:,i), kappa_ftl(:,i), time_ftl(:,i)] = follow_the_leader(netFTL, ...
      data_train, labels_train, data_test, labels_test, 0);
    % learn++.nse
    [err_nse(:,i), kappa_nse(:,i), time_nse(:, i)] = learn_nse(netNSE, ...
      data_train, labels_train, data_test, labels_test);
    % sml
    [err_sml(:,i), kappa_sml(:,i), time_sml(:,i)] = incremental_learner(...
      data_train, data_test, labels_train, labels_test, model, max_learners, ...
      'sml2', 0);
    % sml with mle
    %[err_mle(:,i), kappa_mle(:,i), time_mle(:,i)] = incremental_learner(...
    %  data_train, data_test, labels_train, labels_test, model, max_learners, ...
    %  'mle');
    % sml with map
    %[err_map(:,i), kappa_map(:,i), time_map(:,i)] = incremental_learner(...
    %  data_train, data_test, labels_train, labels_test, model, max_learners, ...
    %  'map');
    % simple averging
    [err_avg(:,i), kappa_avg(:,i), time_avg(:,i)] = incremental_learner(...
      data_train, data_test, labels_train, labels_test, model, max_learners, ...
      'avg1', 0);
    % corrected averaging
    [err_avg_cor(:,i), kappa_avg_cor(:,i), time_avg_cor(:,i)] = ...
      incremental_learner(data_train, data_test, labels_train, labels_test, ...
      model, max_learners, 'avg2', 0);
    % cvx-sense
    [err_cvx(:,i), kappa_cvx(:,i), time_cvx(:,i)] = cvx_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, alpha, beta, 0);
    % scargc
    X = [data_train{1}, labels_train{1}; cell2mat(data_train'), cell2mat(labels_train')];
    [~, ~, ~, err_scar(:,i), kappa_scar(:,i), time_scar(:,i)] = SCARGC_1NN(X, ...
      win_size, win_size, length(unique(allclass2)));
        
  end
  
  idx = 2:size(err_avg_cor, 1)-1;
  errors.avg = nanmean(err_avg_cor(idx, :), 2);
  errors.cvx = nanmean(err_cvx(idx, :), 2);
  errors.ftl = nanmean(err_ftl(idx, :), 2);
  errors.nse = nanmean(err_nse(idx, :), 2);
  errors.sml = nanmean(err_sml(idx, :), 2);
  errors.scar = nanmean(err_scar(idx, :), 2);
  
  kappas.avg = nanmean(kappa_avg_cor(idx, :), 2);
  kappas.cvx = nanmean(kappa_cvx(idx, :), 2);
  kappas.ftl = nanmean(kappa_ftl(idx, :), 2);
  kappas.nse = nanmean(kappa_nse(idx, :), 2);
  kappas.sml = nanmean(kappa_sml(idx, :), 2);
  kappas.scar = nanmean(kappa_scar(idx, :), 2); 
  
  all_errors = mean([errors.avg, errors.ftl, errors.nse, errors.sml, errors.cvx, errors.scar]);
  all_kappas = mean([kappas.avg, kappas.ftl, kappas.nse, kappas.sml, kappas.cvx, kappas.scar]);
  save(['results/experiment_stationary_', strrep(dat,'.csv', ''), '.mat']);

end

delete(gcp('nocreate'));
