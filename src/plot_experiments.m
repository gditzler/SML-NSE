clc
clear
close all

dats2 = {'elec2', 'noaa', 'spam', 'sea', 'rbf', 'air', 'poker'};
dats2 = {'checker'};
errs = [];
kapp = [];
type2 = 'end2';

for qq = 1:length(dats2)
  close all 
  dat = dats2{qq};
  
  if strcmp(type2, 'end')
    load(['../results/', dat, '_END_err_kappa.mat']);
  else
    load(['../results/', dat, '_err_kappa.mat']);
  end
  
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
  
  
  h = figure;
  hold on;
  box on;
  plot(smooth(err_sml(range), 5), 'r', 'LineWidth', 2)
  plot(smooth(err_mle(range), 5), 'b', 'LineWidth', 2)
  plot(smooth(err_map(range), 5), 'k', 'LineWidth', 2)
  plot(smooth(err_avg_cor(range), 5), 'c', 'LineWidth', 2)
  %plot(err_avg(range), 'm', 'LineWidth', 2)
  plot(smooth(err_nse(range), 5), 'g', 'LineWidth', 2)
  plot(smooth(err_ftl(range), 5), 'color', [.5 .5 .5], 'LineWidth', 2)
  legend('sml', 'mle', 'map', 'avgc',  'nse', 'ftl', 'Location', 'best')
  xlabel('Time Stamp', 'FontSize', 20)
  ylabel('Error', 'FontSize', 20)
  set(gca, 'fontsize', 20)
  if strcmp(type2, 'end')
    saveas(h, ['../results/',dat,'_END_error.fig'])
    saveas(h, ['../results/',dat,'_END_error.eps'], 'eps2c')
  else
    saveas(h, ['../results/',dat,'_error.fig'])
    saveas(h, ['../results/',dat,'_error.eps'], 'eps2c')
  end
  
  g = figure;
  hold on;
  box on;
  plot(smooth(kappa_sml(range), 5), 'r', 'LineWidth', 2)
  plot(smooth(kappa_mle(range), 5), 'b', 'LineWidth', 2)
  plot(smooth(kappa_map(range), 5), 'k', 'LineWidth', 2)
  plot(smooth(kappa_avg_cor(range), 5), 'c', 'LineWidth', 2)
  %plot(kappa_avg(range), 'm', 'LineWidth', 2)
  plot(smooth(kappa_nse(range), 5), 'g', 'LineWidth', 2)
  plot(smooth(kappa_ftl(range), 5), 'color', [.5 .5 .5], 'LineWidth', 2)
  legend('sml', 'mle', 'map', 'avgc', 'nse', 'ftl', 'Location', 'best')
  xlabel('Time Stamp', 'FontSize', 20)
  ylabel('Kappa', 'FontSize', 20)
  ylim([0,1])
  set(gca, 'fontsize', 20)
  if strcmp(type2, 'end')
    saveas(g, ['../results/',dat,'_END_kappa.fig'])
    saveas(g, ['../results/',dat,'_END_kappa.eps'], 'eps2c')
  else
    saveas(g, ['../results/',dat,'_kappa.fig'])
    saveas(g, ['../results/',dat,'_kappa.eps'], 'eps2c')
  end
end

