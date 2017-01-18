%% run the experiment 
clc; 
clear; 
close all;


addpath('algorithms/');
addpath('utils/');
addpath('data/');

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
%% plot the results 
clc;
clear; 
close all;

files = dir('../results/*alpha*');
all_err = zeros(length(files)-7, 11);
all_kap = zeros(length(files)-7, 11);

nn = 1;
for f = files'
  if ~isempty(strfind(f.name, 'ozone'))
    continue; 
  end
  if ~isempty(strfind(f.name, 'hill-valley'))
    continue; 
  end
  if ~isempty(strfind(f.name, 'cylinder-bands'))
    continue; 
  end
  if ~isempty(strfind(f.name, 'connect-4'))
    continue; 
  end
  if ~isempty(strfind(f.name, 'breast-cancer-wisc-prog'))
    continue; 
  end
  if ~isempty(strfind(f.name, 'breast-cancer'))
    continue; 
  end
  if ~isempty(strfind(f.name, 'statlog-australian-credit'))
    continue; 
  end
  
  load(['../results/', f.name]);
  close all;

  err_cvx00 = mean(err_cvx00, 2);
  err_cvx10 = mean(err_cvx10, 2);
  err_cvx20 = mean(err_cvx20, 2);
  err_cvx30 = mean(err_cvx30, 2);
  err_cvx40 = mean(err_cvx40, 2);
  err_cvx50 = mean(err_cvx50, 2);
  err_cvx60 = mean(err_cvx60, 2);
  err_cvx70 = mean(err_cvx70, 2);
  err_cvx80 = mean(err_cvx80, 2);
  err_cvx90 = mean(err_cvx90, 2);
  err_cvx100 = mean(err_cvx100, 2);
  
  kappa_cvx00 = nanmean(kappa_cvx00, 2);
  kappa_cvx10 = nanmean(kappa_cvx10, 2);
  kappa_cvx20 = nanmean(kappa_cvx20, 2);
  kappa_cvx30 = nanmean(kappa_cvx30, 2);
  kappa_cvx40 = nanmean(kappa_cvx40, 2);
  kappa_cvx50 = nanmean(kappa_cvx50, 2);
  kappa_cvx60 = nanmean(kappa_cvx60, 2);
  kappa_cvx70 = nanmean(kappa_cvx70, 2);
  kappa_cvx80 = nanmean(kappa_cvx80, 2);
  kappa_cvx90 = nanmean(kappa_cvx90, 2);
  kappa_cvx100 = nanmean(kappa_cvx100, 2);
  
  timez = 1:numel(err_cvx00);
  lw = 2;
  
  all_err(nn, :) = [mean(err_cvx00), mean(err_cvx10), mean(err_cvx20), mean(err_cvx30), ...
    mean(err_cvx40), mean(err_cvx50), mean(err_cvx60), mean(err_cvx70), mean(err_cvx80), ...
    mean(err_cvx90), mean(err_cvx100)];
  all_kap(nn, :) = [mean(kappa_cvx00), mean(kappa_cvx10), mean(kappa_cvx20), mean(kappa_cvx30), ...
    mean(kappa_cvx40), mean(kappa_cvx50), mean(kappa_cvx60), mean(kappa_cvx70), mean(kappa_cvx80), ...
    mean(kappa_cvx90), mean(kappa_cvx100)];
  nn = nn+1;


  hh=figure; 
  hold on;
  box on;
%   plot(timez, smooth(err_cvx00), 'color', [0,0,0], 'LineWidth', lw)
%   % plot(timez, smooth(err_cvx10), 'color', [0,0,0]+.1, 'LineWidth', lw)
%   plot(timez, smooth(err_cvx20), 'color', [0,0,0]+.2, 'LineWidth', lw)
%   % plot(timez, smooth(err_cvx30), 'color', [0,0,0]+.3, 'LineWidth', lw)
%   plot(timez, smooth(err_cvx40), 'color', [0,0,0]+.4, 'LineWidth', lw)
%   % plot(timez, smooth(err_cvx50), 'color', [0,0,0]+.5, 'LineWidth', lw)
%   plot(timez, smooth(err_cvx60), 'color', [0,0,0]+.6, 'LineWidth', lw)
%   % plot(timez, smooth(err_cvx70), 'color', [0,0,0]+.7, 'LineWidth', lw)
%   plot(timez, smooth(err_cvx80), 'color', [0,0,0]+.8, 'LineWidth', lw)
%   % plot(timez, smooth(err_cvx90), 'color', [0,0,0]+.9, 'LineWidth', lw)
%   plot(timez, smooth(err_cvx100), 'color', [0,0,0]+.9, 'LineWidth', lw)
  
  plot(timez, err_cvx00, 'color', [0,0,0]+0, 'LineWidth', lw)
  % plot(timez, err_cvx10, 'color', [0,0,0]+.1, 'LineWidth', lw)
  plot(timez, err_cvx20, 'color', [0,0,0]+.2, 'LineWidth', lw)
  % plot(timez, err_cvx30, 'color', [0,0,0]+.3, 'LineWidth', lw)
  plot(timez, err_cvx40, 'color', [0,0,0]+.4, 'LineWidth', lw)
  % plot(timez, err_cvx50, 'color', [0,0,0]+.5, 'LineWidth', lw)
  plot(timez, err_cvx60, 'color', [0,0,0]+.6, 'LineWidth', lw)
  % plot(timez, err_cvx70, 'color', [0,0,0]+.7, 'LineWidth', lw)
  plot(timez, err_cvx80, 'color', [0,0,0]+.8, 'LineWidth', lw)
  % plot(timez, err_cvx90, 'color', [0,0,0]+.9, 'LineWidth', lw)
  plot(timez, err_cvx100, 'color', [0,0,0]+.9, 'LineWidth', lw)
  axis tight;
  set(gca, 'fontsize', 22)
  xlabel('Time Stamp', 'FontSize', 22)
  ylabel('Kappa', 'FontSize', 22)
%   saveas(hh, ['../results/', f.name, '.fig'])
end


%% 
close all
Re = rank_rows(all_err);
Rem = mean(Re);
X = 0:0.1:1;
L = {};
for i = 1:numel(X)
  L{i} = num2str(X(i));
end
hh=figure;
% box on;
% stem(X, Rem, 'LineWidth', 3, 'MarkerSize', 10)
boxplot(Re, 'Notch', 'on', 'Labels', L, 'BoxStyle', 'outline', 'MedianStyle', 'target')
set(gca, 'fontsize', 20)
saveas(hh, '../results/box_error.fig');
saveas(hh, '../results/box_error.eps', 'eps2c');

% all_kap(isnan(all_kap)) = -1;
Rk = rank_rows(all_kap);
Rkm = mean(Rk);
X = 0:0.1:1;
hh=figure;
% box on;
% stem(X, Rkm, 'LineWidth', 3, 'MarkerSize', 10)
% set(gca, 'fontsize', 22)
boxplot(Rk, 'Notch', 'on', 'Labels', L, 'BoxStyle', 'outline', 'MedianStyle', 'target')
set(gca, 'fontsize', 20)
saveas(hh, '../results/box_kappa.fig');
saveas(hh, '../results/box_kappa.eps', 'eps2c');

