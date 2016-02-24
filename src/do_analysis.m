clc
clear
close all 

tail = 'left';
alpha = .05;
dats2 = {'poker', 'noaa', 'elec2', 'spam', 'sea', 'air'};
% dats = {'elec2'};
errs = [];
kapp = [];


for qq = 1:length(dats2)
  dat = dats2{qq};
%   load(['../results/', dat, '_END_err_kappa.mat']);
  load(['../results/', dat, '_err_kappa.mat']);
  
  range = 2:size(err_avg,1)-2;
  
  err_sml = nanmean(err_sml, 2);
  err_cvx = nanmean(err_cvx, 2);
  err_mle = nanmean(err_mle, 2); 
  err_map = nanmean(err_map, 2); 
  err_avg_cor = nanmean(err_avg_cor, 2); 
  %err_avg = nanmean(err_avg, 2);
  err_nse = nanmean(err_nse, 2); 
  err_ftl = nanmean(err_ftl, 2);
%   errs = [errs; [mean(err_sml(range,:)), ...
%     mean(err_mle(range,:)), ...
%     mean(err_map(range,:)), ...
%     mean(err_avg_cor(range,:)), ...
%     mean(err_nse(range,:)), ...
%     mean(err_ftl(range,:))]];
  errs = [errs; ...
    [nanmean(err_sml(range,:)), ...
    nanmean(err_cvx(range,:)), ...
    nanmean(err_avg_cor(range,:)), ...
    nanmean(err_nse(range,:)), ...
    nanmean(err_ftl(range,:))]];

  kappa_sml = nanmean(kappa_sml, 2); 
  kappa_cvx = nanmean(kappa_cvx, 2);
  kappa_mle = nanmean(kappa_mle, 2); 
  kappa_map = nanmean(kappa_map, 2); 
  kappa_avg_cor = nanmean(kappa_avg_cor, 2); 
  %kappa_avg = nanmean(kappa_avg, 2); 
  kappa_nse = nanmean(kappa_nse, 2); 
  kappa_ftl = nanmean(kappa_ftl, 2);
%   kapp = [kapp; ...
%     [mean(kappa_sml(range,:)), ...
%     mean(kappa_mle(range,:)), ...
%     mean(kappa_map(range,:)), ...
%     mean(kappa_avg_cor(range,:)), ...
%     mean(kappa_nse(range,:)), ...
%     mean(kappa_ftl(range,:))]];
  kapp = [kapp; ...
    [nanmean(kappa_sml(range,:)), ...
    nanmean(kappa_cvx(range,:)), ...
    nanmean(kappa_avg_cor(range,:)), ...
    nanmean(kappa_nse(range,:)), ...
    nanmean(kappa_ftl(range,:))]];
  
end
alg = 'SML & CVX & AVG & NSE & FTL';

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
% for i = 1:size(rank_errs, 1)
%   s = [dats2{i} ' & '];
%   for j = 1:size(rank_errs, 2)-1
%     s = [s, num2str(rank_errs(i, j)), ' & '];
%   end
%   disp([s, num2str(rank_errs(i, end)), ' \\ '])
% end

for i = 1:size(rank_errs, 1)
  s = [dats2{i} ' & '];
  if i ~= size(rank_errs, 1)
    for j = 1:size(rank_errs, 2)-1
      s = [s, num2str(100*errs(i, j)), ' (',num2str(rank_errs(i, j)),')', ' & '];
    end
    disp([s, num2str(100*errs(i, end)), ' (',num2str(rank_errs(i, end)),')', ' \\ '])
  else
    s = [dats2{i} ' & '];
    for j = 1:size(rank_errs, 2)-1
      s = [s, num2str(rank_errs(i, j)), ' & '];
    end
    disp([s, num2str(rank_errs(i, end)), ' \\ '])
  end
end

disp(' ')
disp('Kappa Table')
disp(alg)
% for i = 1:size(rank_kappa, 1)
%   s = [dats2{i} ' & '];
%   for j = 1:size(rank_kappa, 2)-1
%     s = [s, num2str(rank_kappa(i, j)), ' & '];
%   end
%   disp([s, num2str(rank_kappa(i, end)), ' \\ '])
% end

for i = 1:size(rank_kappa, 1)
  s = [dats2{i} ' & '];
  if i ~= size(rank_kappa, 1)
    for j = 1:size(rank_kappa, 2)-1
      s = [s, num2str(100*kapp(i, j)), ' (',num2str(rank_kappa(i, j)),')', ' & '];
    end
    disp([s, num2str(100*kapp(i, end)), ' (',num2str(rank_kappa(i, end)),')', ' \\ '])
  else
    s = [dats2{i} ' & '];
    for j = 1:size(rank_kappa, 2)-1
      s = [s, num2str(rank_kappa(i, j)), ' & '];
    end
    disp([s, num2str(rank_kappa(i, end)), ' \\ '])
  end
end

