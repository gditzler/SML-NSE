clc; 
clear; 
close all;


addpath('algorithms/');
addpath('utils/');
addpath('data/');
addpath(genpath('SCARGC_codes/'));

miss_amt = 1;


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
    %'miniboone.csv'
  };
% dats = {  'air'};
alpha = .7;
beta = .5;
% delete(gcp('nocreate'));
% parpool(4);
mclass = 2;
% miss_amt = 2;
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
  netFTL.mclass = 2;          % number of classes in the prediciton problem
  netFTL.base_classifier = model;  % set the base classifier in the net struct
  netFTL.n_classifiers = max_learners;
  netNSE.a = .5;                   % slope parameter to a sigmoid
  netNSE.b = 10;                   % cutoff parameter to a sigmoid
  netNSE.threshold = 0.01;         % how small is too small for error
  netNSE.mclass = mclass;          % number of classes in the prediciton problem
  netNSE.base_classifier = model;  % set the base classifier in the net struct

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
    
    shuffs = randperm(nos);
    alldata2 = alldata(shuffs, :);
    allclass2 = allclass(shuffs);
  
    if end_experiment == 1
      [data_train, data_test, labels_train, labels_test] = test_on_last(alldata2, allclass2, win_size, false);
    else
      [data_train, data_test, labels_train, labels_test] = test_then_train(alldata2, allclass2, win_size, false);
    end
    
    for z = 1:length(data_train)
    	if mod(z+miss_amt-1, miss_amt) ~= 0
        data_train{z} = [];
        labels_train{z} = [];
      end
    end

    % follow the leader
    [err_ftl(:,i), kappa_ftl(:,i), time_ftl(:,i)] = follow_the_leader(netFTL, data_train, labels_train, data_test, labels_test, 1);
    % learn++.nse
    [err_nse(:,i), kappa_nse(:,i), time_nse(:, i)] = learn_nse(netNSE, data_train, labels_train, data_test, labels_test);
    % sml
    [err_sml(:,i), kappa_sml(:,i), time_sml(:,i)] = incremental_learner(data_train, data_test, labels_train, labels_test, model, max_learners, 'sml', 1);
    % sml with mle
    [err_mle(:,i), kappa_mle(:,i), time_mle(:,i)] = incremental_learner(data_train, data_test, labels_train, labels_test, model, max_learners, 'mle', 1);
    % sml with map
    [err_map(:,i), kappa_map(:,i), time_map(:,i)] = incremental_learner(data_train, data_test, labels_train, labels_test, model, max_learners, 'map', 1);
    % simple averging
    [err_avg(:,i), kappa_avg(:,i), time_avg(:,i)] = incremental_learner(data_train, data_test, labels_train, labels_test, model, max_learners, 'avg1', 1);
    % corrected averaging
    [err_avg_cor(:,i), kappa_avg_cor(:,i), time_avg_cor(:,i)] = incremental_learner(data_train, data_test, labels_train, labels_test, model, max_learners, 'avg2', 1);
    % cvx-sense
    [err_cvx(:,i), kappa_cvx(:,i), time_cvx(:,i)] = cvx_learner(data_train, data_test, labels_train, labels_test, model, max_learners, alpha, beta, 1);
    % scargc
    %X = [data_train{1}, labels_train{1}; cell2mat(data_train'), cell2mat(labels_train')];
    %[~, ~, ~, err_scar(:,i), kappa_scar(:,i), time_scar(:,i)] = SCARGC_1NN(X, win_size, win_size, length(unique(allclass2)));
        
  end
  
  if end_experiment == 1
    
    save(['../results/missing_', num2str(miss_amt), strrep(dat,'.csv', ''), '_END_err_kappa.mat']);
  else
    save(['../results/missing_', num2str(miss_amt), strrep(dat,'.csv', ''), '_err_kappa.mat']);
  end

end

delete(gcp('nocreate'));
