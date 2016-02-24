clc; 
clear; 
close all;


addpath('algorithms/');
addpath('utils/');
addpath('data/');

avg = 10; 
datasets = {'a8a', 'german', 'magic04', 'spambase', 'splice', 'svmguide3', ... 
  'ionosphere', 'ovariancancer', 'arrhythmia', 'sido0',...
  'miniboone.csv', 'breast-cancer-wisc-diag.csv', 'breast-cancer-wisc-prog.csv', 'chess-krvkp.csv','conn-bench-sonar-mines-rocks.csv',...
  'connect-4.csv','molec-biol-promoter.csv', 'parkinsons.csv', 'spect_train.csv'};
% dats = {  'air'};
alpha = .7;
beta = .5;
parpool(avg);

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
  netFTL.mclass = mclass;          % number of classes in the prediciton problem
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

  kappa_sml = zeros(length(data_train), avg); 
  kappa_mle = zeros(length(data_train), avg); 
  kappa_map = zeros(length(data_train), avg); 
  kappa_avg_cor = zeros(length(data_train), avg); 
  kappa_avg = zeros(length(data_train), avg); 
  kappa_ftl = zeros(length(data_train), avg); 
  kappa_nse = zeros(length(data_train), avg);
  kappa_cvx = zeros(length(data_train), avg);
  
  time_sml = zeros(length(data_train), avg); 
  time_mle = zeros(length(data_train), avg); 
  time_map = zeros(length(data_train), avg); 
  time_avg_cor = zeros(length(data_train), avg); 
  time_avg = zeros(length(data_train), avg); 
  time_ftl = zeros(length(data_train), avg); 
  time_nse = zeros(length(data_train), avg);
  time_cvx = zeros(length(data_train), avg);
  
  
  err_sml25 = zeros(length(data_train), avg); 
  err_mle25 = zeros(length(data_train), avg); 
  err_map25 = zeros(length(data_train), avg); 
  err_avg_cor25 = zeros(length(data_train), avg); 
  err_avg25 = zeros(length(data_train), avg); 
  err_ftl25 = zeros(length(data_train), avg); 
  err_nse25 = zeros(length(data_train), avg);
  err_cvx25 = zeros(length(data_train), avg);

  kappa_sml25 = zeros(length(data_train), avg); 
  kappa_mle25 = zeros(length(data_train), avg); 
  kappa_map25 = zeros(length(data_train), avg); 
  kappa_avg_cor25 = zeros(length(data_train), avg); 
  kappa_avg25 = zeros(length(data_train), avg); 
  kappa_ftl25 = zeros(length(data_train), avg); 
  kappa_nse25 = zeros(length(data_train), avg);
  kappa_cvx25 = zeros(length(data_train), avg);
  
  time_sml25 = zeros(length(data_train), avg); 
  time_mle25 = zeros(length(data_train), avg); 
  time_map25 = zeros(length(data_train), avg); 
  time_avg_cor25 = zeros(length(data_train), avg); 
  time_avg25 = zeros(length(data_train), avg); 
  time_ftl25 = zeros(length(data_train), avg); 
  time_nse25 = zeros(length(data_train), avg);
  time_cvx25 = zeros(length(data_train), avg);

  parfor i = 1:avg
    disp(['  -Avg ', num2str(i), '/', num2str(avg)]);

    if end_experiment == 1
      [data_train, data_test, labels_train, labels_test] = test_on_last(alldata, allclass, win_size, true);
    else
      [data_train, data_test, labels_train, labels_test] = test_then_train(alldata, allclass, win_size, true);
    end

    disp('     >FTL')
    [err_ftl(:,i), kappa_ftl(:,i), time_ftl(:,i)] = follow_the_leader(netFTL, data_train, ...
      labels_train, data_test, labels_test);

    disp('     >NSE')
    [err_nse(:,i), kappa_nse(:,i), time_nse(:, i)] = learn_nse(netNSE, data_train, labels_train, ...
      data_test, labels_test);

    disp('     >SML')
    [err_sml(:,i), kappa_sml(:,i), time_sml(:,i)] = incremental_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, 'sml');
    
    disp('     >MLE')
    [err_mle(:,i), kappa_mle(:,i), time_mle(:,i)] = incremental_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, 'mle');
    
    disp('     >MAP')
    [err_map(:,i), kappa_map(:,i), time_map(:,i)] = incremental_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, 'map');
     
    disp('     >AVG1')
    [err_avg(:,i), kappa_avg(:,i), time_avg(:,i)] = incremental_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, 'avg1');
    
    disp('     >AVG2')
    [err_avg_cor(:,i), kappa_avg_cor(:,i), time_avg_cor(:,i)] = incremental_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, 'avg2');
    
    disp('     >CVX')
    [err_cvx(:,i), kappa_cvx(:,i), time_cvx(:,i)] = cvx_learner(data_train, ...
      data_test, labels_train, labels_test, model, max_learners, alpha, beta);
    
    
%     disp('     >SML')
%     [err_sml25(:,i), kappa_sml25(:,i), time_sml25(:,i)] = incremental_learner(data_train, ...
%       data_test, labels_train, labels_test, model, 25, 'sml');
%     
%     disp('     >MLE')
%     [err_mle25(:,i), kappa_mle25(:,i), time_mle25(:,i)] = incremental_learner(data_train, ...
%       data_test, labels_train, labels_test, model, 25, 'mle');
%     
%     disp('     >MAP')
%     [err_map25(:,i), kappa_map25(:,i), time_map25(:,i)] = incremental_learner(data_train, ...
%       data_test, labels_train, labels_test, model, 25, 'map');
%      
%     disp('     >AVG1')
%     [err_avg25(:,i), kappa_avg25(:,i), time_avg25(:,i)] = incremental_learner(data_train, ...
%       data_test, labels_train, labels_test, model, 25, 'avg1');
%     
%     disp('     >AVG2')
%     [err_avg_cor25(:,i), kappa_avg_cor25(:,i), time_avg_cor25(:,i)] = incremental_learner(data_train, ...
%       data_test, labels_train, labels_test, model, 25, 'avg2');
%     
%     disp('     >CVX')
%     [err_cvx25(:,i), kappa_cvx25(:,i), time_cvx25(:,i)] = cvx_learner(data_train, ...
%       data_test, labels_train, labels_test, model, 25, alpha, beta);
    
  end
  
  if end_experiment == 1
    save(['../results/', dat, '_END_err_kappa.mat']);
  else
    save(['../results/', dat, '_err_kappa.mat']);
  end

end

delete(gcp('nocreate'));
