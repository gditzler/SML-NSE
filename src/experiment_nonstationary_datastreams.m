% This script compares FTL, SML, CVX-SML, and L++.NSE of a lage collection 
% of binary prediction problems that come from nonstationary data streams. Unlike
% other experiments, this script will make sure that the training and testing 
% data are always available. 
clc; 
clear; 
close all;

% add the paths for the algorithms we are going to compare against 
addpath('algorithms/');
addpath('utils/');
addpath('data/');
addpath('SCARGC_codes/'); 

% free parameters of the experiement
avg = 10;             % number of averages to perform  
alpha = .95;           % exponential forgetting factor for CVX-sense
beta = .5;            % convex combination parameter for CVX-sense
end_experiment = 1;   % test-then-train or test-on-last
% parpool(4);

% data must be downloaded from the UAMLDA Gitlab data set repo 
dats = {
  'noaa'
  'poker'
  'elec2'
  'spam'
  'sea'
  'air'
  };

for dd = 1:length(dats)
  dat = dats{dd};
  
  disp(['Running ', dat])
  
  if strcmp(dat,'noaa')
    load neweather_rain;
    alldata = alldata';   % old format of data needs transpose
    allclass = allclass'; % ^^^^^
    win_size = 120;    % size of train / test batch (3 months - 1 season)
    mclass = 2;
  elseif strcmp(dat,'air')
    alldata = load('data/air2.arff');
    mclass = 2;
    allclass = alldata(:, 8);
    allclass = allclass + 1;
    alldata(:, 8) = [];
    win_size = 5000;     
  elseif strcmp(dat,'poker')
    alldata = load('data/poker.arff');
    alldata(alldata(:, end) == 9, :) = [];
    alldata(alldata(:, end) == 8, :) = [];
    alldata(alldata(:, end) == 7, :) = [];
    alldata(alldata(:, end) == 6, :) = [];
    alldata(alldata(:, end) == 5, :) = [];
    alldata(alldata(:, end) == 4, :) = [];
    alldata(alldata(:, end) == 3, :) = [];
    allclass = alldata(:, end);
    allclass = allclass + 1;
    allclass(allclass == 3) = 2;
    alldata(:, end) = [];
    win_size = 5000; 
    mclass = 2;
    % figure; hold on
    % plot(find(allclass==1), cumsum(allclass(allclass==1)))
    % plot(find(allclass==2), cumsum(allclass(allclass==2)==2))
  elseif strcmp(dat,'rbf')
    alldata = load('data/rbf150k.arff');
    mclass = 2;
    allclass = alldata(:, end);
    allclass = allclass + 1;
    alldata(:, end) = [];
    win_size = 1200; 
  elseif strcmp(dat,'elec2')
    load elec2;
    alldata(3,:) = []; % remove the "cheating" features
    alldata(4,:) = []; 
    win_size = 125;    % size of train / test batch
    alldata = alldata';   % old format of data needs transpose
    allclass = allclass'; % ^^^^^
    mclass = 2;
  elseif strcmp(dat,'dataLU')
    load dataLU
    alldata = dataLU.X';
    allclass = dataLU.y' + 1;
    win_size = 100;
    mclass = max(allclass);
  elseif strcmp(dat,'chess')
    load chessIZ
    alldata = alldata';   % old format of data needs transpose
    allclass = allclass'; % ^^^^^
    alldata(allclass==3, :) = [];
    allclass(allclass==3) = [];
    mclass = max(allclass);
    win_size = 35;
  elseif strcmp(dat,'spam')
    load spam2
    alldata = alldata';   % old format of data needs transpose
    allclass = allclass'; % ^^^^^
    mclass = max(allclass);
    win_size = 100;
  elseif strcmp(dat, 'sea')
    win_size = 250;
    len = 200;
    noise = .1;
    alldata = 10 * rand(win_size * len,3);
    s1 = sum(alldata(1:floor(win_size * len / 4),1:2),2);
    s1(s1 > 8) = 1;
    s1(s1 ~= 1) = 2;
    s2 = sum(alldata(1+floor(win_size * len / 4):2*floor(win_size * len / 4),1:2),2);
    s2(s2 > 9) = 1;
    s2(s2 ~= 1) = 2;
    s3 = sum(alldata(1+2*floor(win_size * len / 4):3*floor(win_size * len / 4),1:2),2);
    s3(s3 > 7.5) = 1;
    s3(s3 ~= 1) = 2;
    s4 = sum(alldata(1+3*floor(win_size * len / 4):end,1:2),2);
    s4(s4 > 9.5) = 1;
    s4(s4 ~= 1) = 2;
    allclass = [s1;s2;s3;s4];
    mclass = 2;
    win_size = win_size-1;
  else
    data = load(dat);
    allclass = data(:, end)+1;
    alldata = data(:, 1:end-1);    
    win_size = numel(allclass)/2000;
    mclass = length(unique(allclass));
    clear data
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
  netFTL.mclass = mclass;          % number of classes in the prediciton problem
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

    % split up the data into a training and testing data stream
    if end_experiment == 1
      [data_train, data_test, labels_train, labels_test] = test_on_last(...
        alldata, allclass, win_size, true);
    else
      [data_train, data_test, labels_train, labels_test] = test_then_train(...
        alldata, allclass, win_size, true);
    end

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
      win_size, win_size, mclass);    
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
  
  if end_experiment == 1
    save(['../results/experiment_nse_', dat, '_testOnLast.mat']);
  else
    save(['../results/experiment_nse_', dat, '_testThenTrain.mat']);
  end

end

delete(gcp('nocreate'));
