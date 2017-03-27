%% experiment_missing_training
clc;
clear;
close all;
%% experiment_nonstationary_datastreams
clc;
clear;
close all;
%% experiment_nonstationary_missing_datastreams
clc;
clear;
close all;
addpath('utils/')

files = dir('../results/experiment_missing_nse_*');
n = 0;
algorithms = {'SML', 'MLE', 'MAP', 'AVG1', 'AVG2', 'FTL', 'NSE', 'CVX', 'SCARG'};
data_names = {};
keepers = [1 4 6 7 8 9];
errors_all = [];
kappas_all = [];
times_all = [];

for file = files'
  n = n+1;
  data_names{n} = file.name(25:end-18);
  load(['../results/', file.name], '-regexp', '^err_*');
  load(['../results/', file.name], '-regexp', '^kappa_*');
  load(['../results/', file.name], '-regexp', '^time_*');
  
  err_sml = nanmean(err_sml, 2); 
  err_mle = nanmean(err_mle, 2); 
  err_map = nanmean(err_map, 2); 
  err_avg_cor = nanmean(err_avg_cor, 2); 
  err_avg = nanmean(err_avg, 2); 
  err_ftl = nanmean(err_ftl, 2); 
  err_nse = nanmean(err_nse, 2);
  err_cvx = nanmean(err_cvx, 2);
  err_scar = nanmean(err_scar, 2);
  errors_all = [errors_all; nanmean(err_sml(2:end-1)) nanmean(err_mle(2:end-1)) nanmean(err_map(2:end-1)) nanmean(err_avg_cor(2:end-1)) ...
    nanmean(err_avg(2:end-1)) nanmean(err_ftl(2:end-1)) nanmean(err_nse(2:end-1)) nanmean(err_cvx(2:end-1)) nanmean(err_scar(2:end-1))];
  
  kappa_sml = nanmean(kappa_sml, 2); 
  kappa_mle = nanmean(kappa_mle, 2); 
  kappa_map = nanmean(kappa_map, 2); 
  kappa_avg_cor = nanmean(kappa_avg_cor, 2); 
  kappa_avg = nanmean(kappa_avg, 2); 
  kappa_ftl = nanmean(kappa_ftl, 2); 
  kappa_nse = nanmean(kappa_nse, 2);
  kappa_cvx = nanmean(kappa_cvx, 2);
  kappa_scar = nanmean(kappa_scar, 2);
  kappas_all = [kappas_all; nanmean(kappa_sml(2:end-1)) nanmean(kappa_mle(2:end-1)) nanmean(kappa_map(2:end-1)) nanmean(kappa_avg_cor(2:end-1)) ...
    nanmean(kappa_avg(2:end-1)) nanmean(kappa_ftl(2:end-1)) nanmean(kappa_nse(2:end-1)) nanmean(kappa_cvx(2:end-1)) nanmean(kappa_scar(2:end-1))];
  
  time_sml = nanmean(time_sml, 2); 
  time_mle = nanmean(time_mle, 2); 
  time_map = nanmean(time_map, 2); 
  time_avg_cor = nanmean(time_avg_cor, 2); 
  time_avg = nanmean(time_avg, 2); 
  time_ftl = nanmean(time_ftl, 2); 
  time_nse = nanmean(time_nse, 2);
  time_cvx = nanmean(time_cvx, 2);
  time_scar = nanmean(time_scar, 2);
  times_all = [times_all; nanmean(time_sml(2:end-1)) nanmean(time_mle(2:end-1)) nanmean(time_map(2:end-1)) nanmean(time_avg_cor(2:end-1)) ...
    nanmean(time_avg(2:end-1)) nanmean(time_ftl(2:end-1)) nanmean(time_nse(2:end-1)) nanmean(time_cvx(2:end-1)) nanmean(time_scar(2:end-1))];
  
end

errors_all = errors_all(:, keepers);
nanrow = isnan(sum(errors_all, 2));
errors_all(nanrow, :) = [];
kappas_all = kappas_all(:, keepers);
kappas_all(nanrow, :) = [];
data_names = data_names(~nanrow);

[hZtest_err, pZtest_err, pFtest_err] = friedman_demsar(errors_all, 'two', .05);
R_err = rank_rows(errors_all);
[hZtest_kap, pZtest_kap, pFtest_kap] = friedman_demsar(1-kappas_all, 'two', .05);
R_kap = rank_rows(1-kappas_all);

print_table(algorithms(keepers), data_names, round(1000*errors_all)/10, R_err)
print_table(algorithms(keepers), data_names, round(1000*kappas_all)/10, R_kap)

%% experiment_stationary_datastreams
clc;
clear;
close all;
addpath('utils/')

files = dir('../results/experiment_stationary_*');
algorithms = {'SML', 'MLE', 'MAP', 'AVG1', 'AVG2', 'FTL', 'NSE', 'CVX', 'SCARG'};
data_names = {};
keepers = [1 4 6 7 8 9];

errors_all = [];
kappas_all = [];
times_all = [];
n = 0;
for file = files'
  n = n+1;
  
  data_names{n} = file.name(23:end-4);
  
  load(['../results/', file.name], '-regexp', '^err_*');
  load(['../results/', file.name], '-regexp', '^kappa_*');
  load(['../results/', file.name], '-regexp', '^time_*');
  
  err_sml = nanmean(err_sml, 2); 
  err_mle = nanmean(err_mle, 2); 
  err_map = nanmean(err_map, 2); 
  err_avg_cor = nanmean(err_avg_cor, 2); 
  err_avg = nanmean(err_avg, 2); 
  err_ftl = nanmean(err_ftl, 2); 
  err_nse = nanmean(err_nse, 2);
  err_cvx = nanmean(err_cvx, 2);
  err_scar = nanmean(err_scar, 2);
  errors_all = [errors_all; nanmean(err_sml(2:end-1)) nanmean(err_mle(2:end-1)) nanmean(err_map(2:end-1)) nanmean(err_avg_cor(2:end-1)) ...
    nanmean(err_avg(2:end-1)) nanmean(err_ftl(2:end-1)) nanmean(err_nse(2:end-1)) nanmean(err_cvx(2:end-1)) nanmean(err_scar(2:end-1))];
  
  kappa_sml = nanmean(kappa_sml, 2); 
  kappa_mle = nanmean(kappa_mle, 2); 
  kappa_map = nanmean(kappa_map, 2); 
  kappa_avg_cor = nanmean(kappa_avg_cor, 2); 
  kappa_avg = nanmean(kappa_avg, 2); 
  kappa_ftl = nanmean(kappa_ftl, 2); 
  kappa_nse = nanmean(kappa_nse, 2);
  kappa_cvx = nanmean(kappa_cvx, 2);
  kappa_scar = nanmean(kappa_scar, 2);
  kappas_all = [kappas_all; nanmean(kappa_sml(2:end-1)) nanmean(kappa_mle(2:end-1)) nanmean(kappa_map(2:end-1)) nanmean(kappa_avg_cor(2:end-1)) ...
    nanmean(kappa_avg(2:end-1)) nanmean(kappa_ftl(2:end-1)) nanmean(kappa_nse(2:end-1)) nanmean(kappa_cvx(2:end-1)) nanmean(kappa_scar(2:end-1))];
  
  time_sml = nanmean(time_sml, 2); 
  time_mle = nanmean(time_mle, 2); 
  time_map = nanmean(time_map, 2); 
  time_avg_cor = nanmean(time_avg_cor, 2); 
  time_avg = nanmean(time_avg, 2); 
  time_ftl = nanmean(time_ftl, 2); 
  time_nse = nanmean(time_nse, 2);
  time_cvx = nanmean(time_cvx, 2);
  time_scar = nanmean(time_scar, 2);
  times_all = [times_all; nanmean(time_sml(2:end-1)) nanmean(time_mle(2:end-1)) nanmean(time_map(2:end-1)) nanmean(time_avg_cor(2:end-1)) ...
    nanmean(time_avg(2:end-1)) nanmean(time_ftl(2:end-1)) nanmean(time_nse(2:end-1)) nanmean(time_cvx(2:end-1)) nanmean(time_scar(2:end-1))];
  
end

errors_all = errors_all(:, keepers);
nanrow = isnan(sum(errors_all, 2));
errors_all(nanrow, :) = [];
kappas_all = kappas_all(:, keepers);
kappas_all(nanrow, :) = [];
data_names = data_names(~nanrow);

[hZtest_err, pZtest_err, pFtest_err] = friedman_demsar(errors_all, 'two', .05);
R_err = rank_rows(errors_all);
[hZtest_kap, pZtest_kap, pFtest_kap] = friedman_demsar(1-kappas_all, 'two', .05);
R_kap = rank_rows(1-kappas_all);

print_table(algorithms(keepers), data_names, round(1000*errors_all)/10, R_err)
print_table(algorithms(keepers), data_names, round(1000*kappas_all)/10, R_kap)


%% experiment_alpha_variation
clc;
clear;
close all;
addpath('utils/')

files = dir('../results/experiment_missing_stationary_*');
algorithms = {'SML', 'MLE', 'MAP', 'AVG1', 'AVG2', 'FTL', 'NSE', 'CVX', 'SCARG'};
data_names = {};
keepers = [1 4 6 7 8];

errors_all = [];
kappas_all = [];
times_all = [];
n = 0;
for file = files'
  n = n+1;
  
  data_names{n} = file.name(33:end-4);
  
  load(['../results/', file.name], '-regexp', '^err_*');
  load(['../results/', file.name], '-regexp', '^kappa_*');
  load(['../results/', file.name], '-regexp', '^time_*');
  
  err_sml = nanmean(err_sml, 2); 
  err_mle = nanmean(err_mle, 2); 
  err_map = nanmean(err_map, 2); 
  err_avg_cor = nanmean(err_avg_cor, 2); 
  err_avg = nanmean(err_avg, 2); 
  err_ftl = nanmean(err_ftl, 2); 
  err_nse = nanmean(err_nse, 2);
  err_cvx = nanmean(err_cvx, 2);
  err_scar = nanmean(err_scar, 2);
  errors_all = [errors_all; nanmean(err_sml(2:end-1)) nanmean(err_mle(2:end-1)) nanmean(err_map(2:end-1)) nanmean(err_avg_cor(2:end-1)) ...
    nanmean(err_avg(2:end-1)) nanmean(err_ftl(2:end-1)) nanmean(err_nse(2:end-1)) nanmean(err_cvx(2:end-1)) nanmean(err_scar(2:end-1))];
  
  kappa_sml = nanmean(kappa_sml, 2); 
  kappa_mle = nanmean(kappa_mle, 2); 
  kappa_map = nanmean(kappa_map, 2); 
  kappa_avg_cor = nanmean(kappa_avg_cor, 2); 
  kappa_avg = nanmean(kappa_avg, 2); 
  kappa_ftl = nanmean(kappa_ftl, 2); 
  kappa_nse = nanmean(kappa_nse, 2);
  kappa_cvx = nanmean(kappa_cvx, 2);
  kappa_scar = nanmean(kappa_scar, 2);
  kappas_all = [kappas_all; nanmean(kappa_sml(2:end-1)) nanmean(kappa_mle(2:end-1)) nanmean(kappa_map(2:end-1)) nanmean(kappa_avg_cor(2:end-1)) ...
    nanmean(kappa_avg(2:end-1)) nanmean(kappa_ftl(2:end-1)) nanmean(kappa_nse(2:end-1)) nanmean(kappa_cvx(2:end-1)) nanmean(kappa_scar(2:end-1))];
  
  time_sml = nanmean(time_sml, 2); 
  time_mle = nanmean(time_mle, 2); 
  time_map = nanmean(time_map, 2); 
  time_avg_cor = nanmean(time_avg_cor, 2); 
  time_avg = nanmean(time_avg, 2); 
  time_ftl = nanmean(time_ftl, 2); 
  time_nse = nanmean(time_nse, 2);
  time_cvx = nanmean(time_cvx, 2);
  time_scar = nanmean(time_scar, 2);
  times_all = [times_all; nanmean(time_sml(2:end-1)) nanmean(time_mle(2:end-1)) nanmean(time_map(2:end-1)) nanmean(time_avg_cor(2:end-1)) ...
    nanmean(time_avg(2:end-1)) nanmean(time_ftl(2:end-1)) nanmean(time_nse(2:end-1)) nanmean(time_cvx(2:end-1)) nanmean(time_scar(2:end-1))];
  
end

errors_all = errors_all(:, keepers);
nanrow = isnan(sum(errors_all, 2));
errors_all(nanrow, :) = [];
kappas_all = kappas_all(:, keepers);
kappas_all(nanrow, :) = [];
data_names = data_names(~nanrow);

[hZtest_err, pZtest_err, pFtest_err] = friedman_demsar(errors_all, 'two', .05);
R_err = rank_rows(errors_all);
[hZtest_kap, pZtest_kap, pFtest_kap] = friedman_demsar(1-kappas_all, 'two', .05);
R_kap = rank_rows(1-kappas_all);

print_table(algorithms(keepers), data_names, round(1000*errors_all)/10, R_err);
print_table(algorithms(keepers), data_names, round(1000*kappas_all)/10, R_kap);
