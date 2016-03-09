%% nse
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


errs = round(errs*1000)/10;
kapp = round(kapp*1000)/10;


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
  if i ~= size(rank_errs, 1)
    for j = 1:size(rank_errs, 2)-1
      s = [s, num2str(errs(i, j)), ' (',num2str(rank_errs(i, j)),')', ' & '];
    end
    disp([s, num2str(errs(i, end)), ' (',num2str(rank_errs(i, end)),')', ' \\ '])
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

for i = 1:size(rank_kappa, 1)
  s = [dats2{i} ' & '];
  if i ~= size(rank_kappa, 1)
    for j = 1:size(rank_kappa, 2)-1
      s = [s, num2str(kapp(i, j)), ' (',num2str(rank_kappa(i, j)),')', ' & '];
    end
    disp([s, num2str(kapp(i, end)), ' (',num2str(rank_kappa(i, end)),')', ' \\ '])
  else
    s = [dats2{i} ' & '];
    for j = 1:size(rank_kappa, 2)-1
      s = [s, num2str(rank_kappa(i, j)), ' & '];
    end
    disp([s, num2str(rank_kappa(i, end)), ' \\ '])
  end
end


%% se
clc
clear
close all 

tail = 'left';
alpha = .05;
errs = [];
kapp = [];
dats2 = {};
files = dir('../results/all*');
all_errors = [];

for file = files'
  if ~isempty(strfind(file.name, 'ozone'))
    continue; 
  end
  if ~isempty(strfind(file.name, 'hill-valley'))
    continue; 
  end
  if ~isempty(strfind(file.name, 'cylinder-bands'))
    continue; 
  end
  if ~isempty(strfind(file.name, 'connect-4'))
    continue; 
  end
  if ~isempty(strfind(file.name, 'breast-cancer-wisc-prog'))
    continue; 
  end
  if ~isempty(strfind(file.name, 'breast-cancer'))
    continue; 
  end
  if ~isempty(strfind(file.name, 'statlog-australian-credit'))
    continue; 
  end
  load(['../results/', file.name]); 
  range = 2:size(err_avg, 1)-1;%;2:size(err_avg, 1)-1;
    
  err_sml = mean(nanmean(err_sml(range,:), 2));
  err_map = mean(nanmean(err_map(range,:), 2));
  err_mle = mean(nanmean(err_mle(range,:), 2));
  err_cvx = mean(nanmean(err_cvx(range,:), 2));
  err_nse = mean(nanmean(err_nse(range,:), 2));
  err_avg = mean(nanmean(err_avg(range,:), 2));
  err_avg_cor = mean(nanmean(err_avg_cor(range,:), 2));
  err_ftl = mean(nanmean(err_ftl(range,:), 2));
  errs = [errs; [err_sml, err_cvx, err_avg_cor, err_nse, err_ftl]];
  
  kappa_sml = mean(nanmean(kappa_sml(range,:), 2)); 
  kappa_cvx = mean(nanmean(kappa_cvx(range,:), 2));
  kappa_mle = mean(nanmean(kappa_mle(range,:), 2)); 
  kappa_map = mean(nanmean(kappa_map(range,:), 2)); 
  kappa_avg_cor = mean(nanmean(kappa_avg_cor(range,:), 2)); 
  kappa_avg = mean(nanmean(kappa_avg, 2)); 
  kappa_nse = mean(nanmean(kappa_nse(range,:), 2)); 
  kappa_ftl = mean(nanmean(kappa_ftl(range,:), 2));
  
  kapp = [kapp; [kappa_sml, kappa_cvx, kappa_avg_cor, kappa_nse, kappa_ftl]];
  dats2{end+1} = strrep(strrep(strrep(strrep(file.name, '.csv_err_kappa.mat', ''), 'all_', ''), '_train', ''), '_', ' ');
end


errs = round(errs*1000)/10;
kapp = round(kapp*1000)/10;


alg = 'SML & CVX & AVG & NSE & FTL';

disp(' ')
disp('Error Table')
disp(alg)


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

for i = 1:size(rank_errs, 1)
  s = [dats2{i} ' & '];
  if i ~= size(rank_errs, 1)
    for j = 1:size(rank_errs, 2)-1
      s = [s, num2str(errs(i, j)), ' (',num2str(rank_errs(i, j)),')', ' & '];
    end
    disp([s, num2str(errs(i, end)), ' (',num2str(rank_errs(i, end)),')', ' \\ '])
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

for i = 1:size(rank_kappa, 1)
  s = [dats2{i} ' & '];
  if i ~= size(rank_kappa, 1)
    for j = 1:size(rank_kappa, 2)-1
      s = [s, num2str(kapp(i, j)), ' (',num2str(rank_kappa(i, j)),')', ' & '];
    end
    disp([s, num2str(kapp(i, end)), ' (',num2str(rank_kappa(i, end)),')', ' \\ '])
  else
    s = [dats2{i} ' & '];
    for j = 1:size(rank_kappa, 2)-1
      s = [s, num2str(rank_kappa(i, j)), ' & '];
    end
    disp([s, num2str(rank_kappa(i, end)), ' \\ '])
  end
end

