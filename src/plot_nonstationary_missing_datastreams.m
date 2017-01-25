clc
clear
close all

end_exper = '';  %'_' or '_END'
toprint = 'error';

datasets = {
  'noaa'
  'poker'
  'elec2'
  'spam'
  'sea'
  %'air'
  };
vars2load = {'err_avg'};
types = {'avg', 'ftl', 'nse', 'sml', 'cvx'};
for k = 1:length(datasets)  
  str = ' & ';
  for t = 1:length(types)-1
    str = [str, types{t}, ' & '];
  end
  str = [str, types{end}, ' \\ '];
  disp(str);
  
  str = [datasets{k}, ' & '];
  
  for i = 1:3
    j = i+1;
    fname = ['../results/missing_nse_', num2str(j), datasets{k}, end_exper,'_err_kappa.mat'];
    load(fname, '-regexp', 'err_*');
    load(fname, 'kappa_*');
    load(fname, '-regexp', 'time_*');
    clear err_mle err_map err_avg err_scar
    clear kappa_mle kappa_map kappa_avg kappa_scar
    clear time_mle time_map time_avg time_scar
    
    idx = 2:size(err_avg_cor, 1)-1;
    errors.avg = nanmean(err_avg_cor(idx, :), 2);
    errors.cvx = nanmean(err_cvx(idx, :), 2);
    errors.ftl = nanmean(err_ftl(idx, :), 2);
    errors.nse = nanmean(err_nse(idx, :), 2);
    errors.sml = nanmean(err_sml(idx, :), 2);
    
    kappas.avg = nanmean(kappa_avg_cor(idx, :), 2);
    kappas.cvx = nanmean(kappa_cvx(idx, :), 2);
    kappas.ftl = nanmean(kappa_ftl(idx, :), 2);
    kappas.nse = nanmean(kappa_nse(idx, :), 2);
    kappas.sml = nanmean(kappa_sml(idx, :), 2);
    clear kappa_* err_* time_*
     
    for t = 1:length(types)-1
      if strcmp(toprint, 'error') == 1
        str = [str, num2str(mean(getfield(errors, types{t}))), ' & '];
      else
        str = [str, num2str(mean(getfield(kappas, types{t}))), ' & '];
      end
    end
    str = [str, num2str(mean(getfield(kappas, types{end}))), ' \\ '];
    disp([str, '\n'])
  end
end

