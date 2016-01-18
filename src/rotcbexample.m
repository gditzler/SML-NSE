clc; 
clear; 
close all;

addpath('data/')
addpath('~/Git/ConceptDriftData/')
delete(gcp('nocreate'));
parpool(3);
avg = 25; 
type = 'end2';
time_stamps = 200;
n_samples = 200;

[data_train, labels_train, data_test, labels_test] = ConceptDriftData('checkerboard', time_stamps, n_samples);
for q = 1:length(data_test)
  data_test{q} = data_test{q}';
  data_train{q} = data_train{q}';
  labels_test{q} = labels_test{q}';
  labels_train{q} = labels_train{q}';
end

for q = 1:length(data_test)-1
  data_test{q} = data_test{end};
  labels_test{q} = labels_test{end};
end

mclass = 2;
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

parfor i = 1:avg
  disp(['  -Avg ', num2str(i), '/', num2str(avg)]);

  [data_train, labels_train, data_test, labels_test] = ConceptDriftData('checkerboard', time_stamps, n_samples);
  for q = 1:length(data_test)
    data_test{q} = data_test{q}';
    data_train{q} = data_train{q}';
    labels_test{q} = labels_test{q}';
    labels_train{q} = labels_train{q}';
  end

  if strcmp(type, 'end')
    for q = 1:length(data_test)-1
      data_test{q} = data_test{end};
      labels_test{q} = labels_test{end};
    end
  end
  
  disp('     >FTL')
  [err_ftl(:,i), kappa_ftl(:,i)] = follow_the_leader(netFTL, data_train, ...
    labels_train, data_test, labels_test);

  disp('     >NSE')
  [err_nse(:,i), kappa_nse(:,i)] = learn_nse(netNSE, data_train, labels_train, ...
    data_test, labels_test);

  disp('     >SML, MLE, MAP, AVG')
  [err_sml(:,i), err_mle(:,i), err_map(:,i), err_avg_cor(:,i), err_avg(:,i), ~, ...
    kappa_sml(:,i), kappa_mle(:,i), kappa_map(:,i), kappa_avg_cor(:,i), ...
    kappa_avg(:,i), ~] = incremental_learner(data_train, data_test, labels_train, ...
    labels_test, model, max_learners);
end



if strcmp(type, 'end')
  save(['../results/checker_END_err_kappa.mat']);
else
  save(['../results/checker_err_kappa.mat']);
end


delete(gcp('nocreate'));
