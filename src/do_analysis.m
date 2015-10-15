clc
clear
close all 

tail = 'left';
alpha = .05;
dats2 = {'elec2', 'noaa', 'spam', 'sea', 'air', 'poker'};
% dats = {'elec2'};
errs = [];
kapp = [];


for qq = 1:length(dats2)
  dat = dats2{qq};
  load(['../results/', dat, '_END_err_kappa.mat']);
  %load(['../results/', dat, '_err_kappa.mat']);
  
  range = 2:size(err_avg,1)-2;
  
  err_sml = mean(err_sml, 2); 
  err_mle = mean(err_mle, 2); 
  err_map = mean(err_map, 2); 
  err_avg_cor = mean(err_avg_cor, 2); 
  %err_avg = mean(err_avg, 2);
  err_nse = mean(err_nse, 2); 
  err_ftl = mean(err_ftl, 2);
  errs = [errs; [mean(err_sml(range,:)), mean(err_mle(range,:)), ...
    mean(err_map(range,:)), mean(err_avg_cor(range,:)), ...
    mean(err_nse(range,:)), mean(err_ftl(range,:))]];

  kappa_sml = mean(kappa_sml, 2); 
  kappa_mle = mean(kappa_mle, 2); 
  kappa_map = mean(kappa_map, 2); 
  kappa_avg_cor = mean(kappa_avg_cor, 2); 
  %kappa_avg = mean(kappa_avg, 2); 
  kappa_nse = mean(kappa_nse, 2); 
  kappa_ftl = mean(kappa_ftl, 2);
  kapp = [kapp; [mean(kappa_sml(range,:)), mean(kappa_mle(range,:)), ...
    mean(kappa_map(range,:)), mean(kappa_avg_cor(range,:)), ...
    mean(kappa_nse(range,:)), mean(kappa_ftl(range,:))]];
  
end
alg = 'SML & MLE & MAP & AVG & NSE & FTL';

rank_errs = rank_rows(errs);
rank_errs(end + 1, :) = mean(rank_errs);
rank_kappa = rank_rows(1 - kapp);
rank_kappa(end + 1, :) = mean(rank_kappa);
dats2{end+1} = '';

[hZtest_err, pZtest_err, pFtest_err] = friedman_demsar(errs, tail, alpha);
[hZtest_kapp, pZtest_kapp, pFtest_kapp] = friedman_demsar(1 - kapp, tail, alpha);

disp(' ')
disp('Error Table')
disp(alg)
for i = 1:size(rank_errs, 1)
  s = [dats2{i} ' & '];
  for j = 1:size(rank_errs, 2)-1
    s = [s, num2str(rank_errs(i, j)), ' & '];
  end
  disp([s, num2str(rank_errs(i, end)), ' \\ '])
end

disp(' ')
disp('Kappa Table')
disp(alg)
for i = 1:size(rank_kappa, 1)
  s = [dats2{i} ' & '];
  for j = 1:size(rank_kappa, 2)-1
    s = [s, num2str(rank_kappa(i, j)), ' & '];
  end
  disp([s, num2str(rank_kappa(i, end)), ' \\ '])
end
