clc; 
clear; 
close all;


addpath('algorithms/');
addpath('utils/');
addpath('data/');

%     'connect-4.csv'
%     'ozone.csv'


avg = 10; 
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
    'miniboone.csv'
  };
% dats = {  'air'};
alpha = .7;
beta = .8;
parpool(avg);
mclass = 2;

end_experiment = 0;


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
  
  if nos < 1000
    win_size = 50;
  elseif nos < 10000
    win_size = 100;
  elseif nos < 15000
    win_size = 250;
  else
    win_size = 500;
  end
  
  if end_experiment == 1
    [data_train, data_test, labels_train, labels_test] = test_on_last(alldata, allclass, win_size, true);
  else
    [data_train, data_test, labels_train, labels_test] = test_then_train(alldata, allclass, win_size, true);
  end
  
  max_learners = length(data_train) + 1;
  model.type = 'CART';             % base classifier

  err_cvx00 = zeros(length(data_train), avg);
  err_cvx10 = zeros(length(data_train), avg);
  err_cvx20 = zeros(length(data_train), avg);
  err_cvx30 = zeros(length(data_train), avg);
  err_cvx40 = zeros(length(data_train), avg);
  err_cvx50 = zeros(length(data_train), avg);
  err_cvx60 = zeros(length(data_train), avg);
  err_cvx70 = zeros(length(data_train), avg);
  err_cvx80 = zeros(length(data_train), avg);
  err_cvx90 = zeros(length(data_train), avg);
  err_cvx100 = zeros(length(data_train), avg);

  kappa_cvx00 = zeros(length(data_train), avg);
  kappa_cvx10 = zeros(length(data_train), avg);
  kappa_cvx20 = zeros(length(data_train), avg);
  kappa_cvx30 = zeros(length(data_train), avg);
  kappa_cvx40 = zeros(length(data_train), avg);
  kappa_cvx50 = zeros(length(data_train), avg);
  kappa_cvx60 = zeros(length(data_train), avg);
  kappa_cvx70 = zeros(length(data_train), avg);
  kappa_cvx80 = zeros(length(data_train), avg);
  kappa_cvx90 = zeros(length(data_train), avg);
  kappa_cvx100 = zeros(length(data_train), avg);
  
  
  
  parfor i = 1:avg
    disp(['  -Avg ', num2str(i), '/', num2str(avg)]);

    if end_experiment == 1
      [data_train, data_test, labels_train, labels_test] = test_on_last(alldata, allclass, win_size, true);
    else
      [data_train, data_test, labels_train, labels_test] = test_then_train(alldata, allclass, win_size, true);
    end
    
    [err_cvx00(:,i), kappa_cvx00(:,i), ~] = cvx_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, .0, beta);
    [err_cvx10(:,i), kappa_cvx10(:,i), ~] = cvx_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, .1, beta);
    [err_cvx20(:,i), kappa_cvx20(:,i), ~] = cvx_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, .2, beta);
    [err_cvx30(:,i), kappa_cvx30(:,i), ~] = cvx_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, .3, beta);
    [err_cvx40(:,i), kappa_cvx40(:,i), ~] = cvx_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, .4, beta);
    [err_cvx50(:,i), kappa_cvx50(:,i), ~] = cvx_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, .5, beta);
    [err_cvx60(:,i), kappa_cvx60(:,i), ~] = cvx_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, .6, beta);
    [err_cvx70(:,i), kappa_cvx70(:,i), ~] = cvx_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, .7, beta);
    [err_cvx80(:,i), kappa_cvx80(:,i), ~] = cvx_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, .8, beta);
    [err_cvx90(:,i), kappa_cvx90(:,i), ~] = cvx_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, .9, beta);
    [err_cvx100(:,i), kappa_cvx100(:,i), ~] = cvx_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, 1.0, beta);
    
  end
  
  if end_experiment == 1
    save(['../results/all_alpha_', strrep(dat,'.csv', ''), '_END_err_kappa.mat']);
  else
    save(['../results/all_alpha_', strrep(dat,'.csv', ''), '_err_kappa.mat']);
  end

end

delete(gcp('nocreate'));
