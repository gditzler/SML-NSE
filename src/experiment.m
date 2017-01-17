clc;
clear;
close all;

    load spam2.mat
    alldata = alldata';   % old format of data needs transpose
    allclass = allclass'; % ^^^^^

    alldata(allclass==3, :) = [];
    allclass(allclass==3) = [];

    mclass = max(allclass);
    win_size = 35;

avg = 5;

% win_size = 120;
sample = true;
max_learners = 200;
clfr.type = 'CART';
[data_train, data_test, labels_train, labels_test] = test_then_train(alldata, ...
    allclass, win_size, sample);
err_sml = zeros(length(data_train), avg); 
err_mle = zeros(length(data_train), avg); 
err_map = zeros(length(data_train), avg); 
err_avg_cor = zeros(length(data_train), avg); 
err_avg = zeros(length(data_train), avg); 

kappa_sml = zeros(length(data_train), avg); 
kappa_mle = zeros(length(data_train), avg); 
kappa_map = zeros(length(data_train), avg); 
kappa_avg_cor = zeros(length(data_train), avg); 
kappa_avg = zeros(length(data_train), avg); 

for i = 1:avg
  disp(i)
  [data_train, data_test, labels_train, labels_test] = test_then_train(alldata, allclass, win_size, sample);
  [err_sml(:,i), err_mle(:,i), err_map(:,i), err_avg_cor(:,i), err_avg(:,i), ~, kappa_sml(:,i), kappa_mle(:,i), kappa_map(:,i), kappa_avg_cor(:,i), kappa_avg(:,i), ~] = incremental_learner(data_train, data_test, labels_train, labels_test, clfr, max_learners);
end

err_sml = mean(err_sml, 2); 
err_mle = mean(err_mle, 2); 
err_map = mean(err_map, 2); 
err_avg_cor = mean(err_avg_cor, 2); 
err_avg = mean(err_avg, 2); 

kappa_sml = mean(kappa_sml, 2); 
kappa_mle = mean(kappa_mle, 2); 
kappa_map = mean(kappa_map, 2); 
kappa_avg_cor = mean(kappa_avg_cor, 2); 
kappa_avg = mean(kappa_avg, 2); 


figure
hold on;
plot(err_sml, 'r', 'LineWidth', 2)
plot(err_mle, 'b', 'LineWidth', 2)
plot(err_map, 'k', 'LineWidth', 2)
plot(err_avg_cor, 'c', 'LineWidth', 2)
plot(err_avg, 'm', 'LineWidth', 2)
legend('sml', 'mle', 'map', 'avgc', 'avg')

disp(['sml:  ', num2str(mean(err_sml)), '  ', num2str(mean(kappa_sml))])
disp(['mle:  ', num2str(mean(err_mle)), '  ', num2str(mean(kappa_mle))])
disp(['map:  ', num2str(mean(err_map)), '  ', num2str(mean(kappa_map))])
disp(['avgc: ', num2str(mean(err_avg_cor)), '  ', num2str(mean(kappa_avg_cor))])
disp(['avg:  ', num2str(mean(err_avg)), '  ', num2str(mean(kappa_avg))])


figure
hold on;
plot(kappa_sml, 'r', 'LineWidth', 2)
plot(kappa_mle, 'b', 'LineWidth', 2)
plot(kappa_map, 'k', 'LineWidth', 2)
plot(kappa_avg_cor, 'c', 'LineWidth', 2)
plot(kappa_avg, 'm', 'LineWidth', 2)
legend('sml', 'mle', 'map', 'avgc', 'avg')


