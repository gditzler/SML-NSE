clc
clear
close all

end_exper = '';  %'_' or '_END'

datasets = {
  'noaa'
  'poker'
  'elec2'
  'spam'
  'sea'
  %'air'
  };
vars2load = {'err_avg'};

for i = 1:3
  j = i+1;
  for k = 1:length(datasets)
    load(['../results/missing_nse_', num2str(j), datasets{k}, end_exper,'_err_kappa.mat'], '-regexp', 'err_*');
    load('../results/missing_nse_2sea_END_err_kappa.mat', '-regexp', 'kappa_*');
    load('../results/missing_nse_2sea_END_err_kappa.mat', '-regexp', 'time_*');
    clear err_mle err_map err_avg err_scar
    clear kappa_mle kappa_map kappa_avg kappa_scar
    clear time_mle time_map time_avg time_scar
  end
end

