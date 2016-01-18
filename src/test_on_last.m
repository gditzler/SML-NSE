clc; 
clear; 
close all;

addpath('data/')
% delete(gcp('nocreate'));
avg = 20; 
% dats = {'poker', 'noaa', 'elec2', 'spam', 'sea', 'air'};
% parpool(avg);
dats = { 'spam'};

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
    win_size = 1200;   
  
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
    win_size = 2000; 
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
    error('Unknown data.')
    
  end

  [data_train, data_test, labels_train, labels_test] = test_then_train(alldata, allclass, win_size, true);
  
  for q = 1:length(data_test)-1
    data_test{q} = data_test{end};
    labels_test{q} = labels_test{end};
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

  kappa_sml = zeros(length(data_train), avg); 
  kappa_mle = zeros(length(data_train), avg); 
  kappa_map = zeros(length(data_train), avg); 
  kappa_avg_cor = zeros(length(data_train), avg); 
  kappa_avg = zeros(length(data_train), avg); 
  kappa_ftl = zeros(length(data_train), avg); 
  kappa_nse = zeros(length(data_train), avg); 
  
  time_sml = zeros(length(data_train), avg); 
  time_mle = zeros(length(data_train), avg); 
  time_map = zeros(length(data_train), avg); 
  time_avg_cor = zeros(length(data_train), avg); 
  time_avg = zeros(length(data_train), avg); 
  time_ftl = zeros(length(data_train), avg); 
  time_nse = zeros(length(data_train), avg); 


  parfor i = 1:avg
    disp(['  -Avg ', num2str(i), '/', num2str(avg)]);

    [data_train, data_test, labels_train, labels_test] = test_then_train(alldata, ...
      allclass, win_size, true);
    for q = 1:length(data_test)-1
      data_test{q} = data_test{end};
      labels_test{q} = labels_test{end};
    end

    disp('     >FTL')
    [err_ftl(:,i), kappa_ftl(:,i), time_nse(:, i)] = follow_the_leader(netFTL, data_train, ...
      labels_train, data_test, labels_test);

    disp('     >NSE')
    [err_nse(:,i), kappa_nse(:,i)] = learn_nse(netNSE, data_train, labels_train, ...
      data_test, labels_test);

    disp('     >SML, MLE, MAP, AVG')
    [err_sml(:,i), err_mle(:,i), err_map(:,i), err_avg_cor(:,i), err_avg(:,i), ~, ...
      kappa_sml(:,i), kappa_mle(:,i), kappa_map(:,i), kappa_avg_cor(:,i), ...
      kappa_avg(:,i), ~, time_sml(:,i), time_mle(:,i), time_map(:,i), ...
      time_avg_cor(:,i), time_avg(:,i), ~] = incremental_learner(data_train, data_test, labels_train, ...
      labels_test, model, max_learners);
  end
  
%   err_sml = mean(err_sml, 2); 
%   err_mle = mean(err_mle, 2); 
%   err_map = mean(err_map, 2); 
%   err_avg_cor = mean(err_avg_cor, 2); 
%   err_avg = mean(err_avg, 2);
%   err_nse = mean(err_nse, 2); 
%   err_ftl = mean(err_ftl, 2);
% 
%   kappa_sml = mean(kappa_sml, 2); 
%   kappa_mle = mean(kappa_mle, 2); 
%   kappa_map = mean(kappa_map, 2); 
%   kappa_avg_cor = mean(kappa_avg_cor, 2); 
%   kappa_avg = mean(kappa_avg, 2); 
%   kappa_nse = mean(kappa_nse, 2); 
%   kappa_ftl = mean(kappa_ftl, 2);


  save(['../results/', dat, '_END_err_kappa.mat']);
end

delete(gcp('nocreate'));
