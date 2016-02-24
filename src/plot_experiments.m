%% all data & errors
clc;
clear;
close all;

dats2 = {'poker', 'noaa', 'elec2', 'spam', 'sea', 'air'};
% dats2 = {'noaa'};
errs = [];
kapp = [];
timers = [];
type2 = 'end5';
FS = 24;

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
  err_cvx = mean(err_cvx, 2);
  err_mle = mean(err_mle, 2); 
  err_map = mean(err_map, 2); 
  err_avg_cor = mean(err_avg_cor, 2); 
  %err_avg = mean(err_avg, 2);
  err_nse = mean(err_nse, 2); 
  err_ftl = mean(err_ftl, 2);
  errs = [errs; [mean(err_sml(range,:)), mean(err_mle(range,:)), ...
    mean(err_map(range,:)), mean(err_avg_cor(range,:)), ...
     mean(err_nse(range,:)), mean(err_ftl(range,:)), mean(err_cvx(range,:))]];

  kappa_sml = mean(kappa_sml, 2); 
  kappa_mle = mean(kappa_mle, 2); 
  kappa_map = mean(kappa_map, 2); 
  kappa_avg_cor = mean(kappa_avg_cor, 2); 
  %kappa_avg = mean(kappa_avg, 2); 
  kappa_nse = mean(kappa_nse, 2); 
  kappa_ftl = mean(kappa_ftl, 2);
  kappa_cvx = mean(kappa_cvx, 2);
  kapp = [kapp; [mean(kappa_sml(range,:)), mean(kappa_mle(range,:)), ...
    mean(kappa_map(range,:)), mean(kappa_avg_cor(range,:)), ...
     mean(kappa_nse(range,:)), mean(kappa_ftl(range,:)), mean(kappa_cvx(range,:))]];
  
  time_sml = csum(mean(time_sml, 2)); 
  time_mle = csum(mean(time_mle, 2)); 
  time_map = csum(mean(time_map, 2)); 
  time_avg_cor = csum(mean(time_avg_cor, 2)); 
  %time_avg = csum(mean(time_avg, 2)); 
  time_nse = csum(mean(time_nse, 2)); 
  time_ftl = csum(mean(time_ftl, 2));
%   timers = [timers; [csum(mean(time_sml(range,:))), csum(mean(time_mle(range,:))), ...
%     csum(mean(time_map(range,:))), csum(mean(time_avg_cor(range,:))), ...
%      csum(mean(time_nse(range,:))), csum(mean(time_ftl(range,:)))]];
   
  h = figure;
  hold on;
  box on;
  plot(smooth(err_sml(range), 5), 'r', 'LineWidth', 2)
  %plot(smooth(err_mle(range), 5), 'b', 'LineWidth', 2)
  %plot(smooth(err_map(range), 5), 'k', 'LineWidth', 2)
  plot(smooth(err_avg_cor(range), 5), 'c', 'LineWidth', 2)
  %plot(err_avg(range), 'm', 'LineWidth', 2)
  plot(smooth(err_nse(range), 5), 'g', 'LineWidth', 2)
  plot(smooth(err_ftl(range), 5), 'color', [.5 .5 .5], 'LineWidth', 2)
  plot(smooth(err_cvx(range), 5), 'k', 'LineWidth', 2)
  %h_legend = legend('sml', 'mle', 'map', 'avgc',  'nse', 'ftl', 'Location', 'best');
  h_legend = legend('sense', 'avgc', 'nse', 'ftl', 'cvx', 'Location', 'best');
  
  set(gca, 'fontsize', 22)
  set(h_legend, 'fontsize', 26)
  xlabel('Time Stamp', 'FontSize', 22)
  ylabel('Error', 'FontSize', 22)
  
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
  %plot(smooth(kappa_mle(range), 5), 'b', 'LineWidth', 2)
  %plot(smooth(kappa_map(range), 5), 'k', 'LineWidth', 2)
  plot(smooth(kappa_avg_cor(range), 5), 'c', 'LineWidth', 2)
  %plot(kappa_avg(range), 'm', 'LineWidth', 2)
  plot(smooth(kappa_nse(range), 5), 'g', 'LineWidth', 2)
  plot(smooth(kappa_ftl(range), 5), 'color', [.5 .5 .5], 'LineWidth', 2)
  plot(smooth(kappa_cvx(range), 5), 'k', 'LineWidth', 2)
  %h_legend = legend('sml', 'mle', 'map', 'avgc', 'nse', 'ftl', 'Location', 'best');
  h_legend = legend('sense', 'avgc', 'nse', 'ftl', 'cvx', 'Location', 'best');
  ylim([0,1])
  set(gca, 'fontsize', 22)
  set(h_legend, 'fontsize', 26)
  xlabel('Time Stamp', 'FontSize', 22)
  ylabel('Kappa', 'FontSize', 22)
  if strcmp(type2, 'end')
    saveas(g, ['../results/',dat,'_END_kappa.fig'])
    saveas(g, ['../results/',dat,'_END_kappa.eps'], 'eps2c')
  else
    saveas(g, ['../results/',dat,'_kappa.fig'])
    saveas(g, ['../results/',dat,'_kappa.eps'], 'eps2c')
  end
  
  
  q = figure;
  hold on;
  box on;
  plot(smooth(time_sml(range), 5), 'r', 'LineWidth', 2)
  %plot(smooth(time_mle(range), 5), 'b', 'LineWidth', 2)
  %plot(smooth(time_map(range), 5), 'k', 'LineWidth', 2)
  plot(smooth(time_avg_cor(range), 5), 'c', 'LineWidth', 2)
  %plot(kappa_avg(range), 'm', 'LineWidth', 2)
  plot(smooth(time_nse(range), 5), 'g', 'LineWidth', 2)
  plot(smooth(time_ftl(range), 5), 'color', [.5 .5 .5], 'LineWidth', 2)
  h_legend = legend('sense', 'avgc', 'nse', 'ftl', 'Location', 'best');
  %h_legend = legend('sml', 'mle', 'map', 'avgc', 'nse', 'ftl', 'Location', 'best');
  %ylim([0,1])
  set(gca, 'fontsize', 22)
  set(h_legend, 'fontsize', 26)
  xlabel('Time Stamp', 'FontSize', 22)
  ylabel('Evaluation Time', 'FontSize', 22)
  if strcmp(type2, 'end')
    saveas(q, ['../results/',dat,'_END_time.fig'])
    saveas(q, ['../results/',dat,'_END_time.eps'], 'eps2c')
  else
    saveas(q, ['../results/',dat,'_time.fig'])
    saveas(q, ['../results/',dat,'_time.eps'], 'eps2c')
  end
  
end
%% plot cvx comp
clc;
clear;
close all;

dats2 = {'poker', 'noaa', 'elec2', 'spam', 'sea', 'air'};
% dats2 = {'noaa'};
errs = [];
kapp = [];
timers = [];
type2 = 'end5';
FS = 24;

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
  err_cvx = mean(err_cvx, 2);
  err_sml25 = mean(err_sml25, 2);
  err_cvx25 = mean(err_cvx25, 2);
  
  kappa_sml = mean(kappa_sml, 2);
  kappa_cvx = mean(kappa_cvx, 2);
  kappa_sml25 = mean(kappa_sml25, 2);
  kappa_cvx25 = mean(kappa_cvx25, 2);
  
  h = figure;
  hold on;
  box on;
  plot(smooth(err_sml(range), 5), 'r', 'LineWidth', 2)
  plot(smooth(err_sml25(range), 5), 'r:', 'LineWidth', 2)
  plot(smooth(err_cvx(range), 5), 'k', 'LineWidth', 2)
  plot(smooth(err_cvx25(range), 5), 'k:', 'LineWidth', 2)
  h_legend = legend('sense', 'sense-25', 'cvx', 'cvx-25', 'Location', 'best');
  set(gca, 'fontsize', 22)
  set(h_legend, 'fontsize', 26)
  xlabel('Time Stamp', 'FontSize', 22)
  ylabel('Error', 'FontSize', 22)
  if strcmp(type2, 'end')
    saveas(h, ['../results/',dat,'_END_error25.fig'])
    saveas(h, ['../results/',dat,'_END_error25.eps'], 'eps2c')
  else
    saveas(h, ['../results/',dat,'_error25.fig'])
    saveas(h, ['../results/',dat,'_error25.eps'], 'eps2c')
  end
  
  h = figure;
  hold on;
  box on;
  plot(smooth(kappa_sml(range), 5), 'r', 'LineWidth', 2)
  plot(smooth(kappa_sml25(range), 5), 'r:', 'LineWidth', 2)
  plot(smooth(kappa_cvx(range), 5), 'k', 'LineWidth', 2)
  plot(smooth(kappa_cvx25(range), 5), 'k:', 'LineWidth', 2)
  h_legend = legend('sense', 'sense-25', 'cvx', 'cvx-25', 'Location', 'best');
  set(gca, 'fontsize', 22)
  set(h_legend, 'fontsize', 26)
  xlabel('Time Stamp', 'FontSize', 22)
  ylabel('Kappa', 'FontSize', 22)
  if strcmp(type2, 'end')
    saveas(h, ['../results/',dat,'_END_kappa25.fig'])
    saveas(h, ['../results/',dat,'_END_kappa25.eps'], 'eps2c')
  else
    saveas(h, ['../results/',dat,'_kappa25.fig'])
    saveas(h, ['../results/',dat,'_kappa25.eps'], 'eps2c')
  end

  
end


