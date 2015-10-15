function [err_sml, err_mle, err_map, err_avg_cor, err_avg, err_cvx, kappa_sml, ...
  kappa_mle, kappa_map, kappa_avg_cor, kappa_avg, kappa_cvx] = incremental_learner(data_tr, ...
  data_te, labels_tr, labels_te, clfr, max_learners)
  %
  if ~(iscell(data_tr) && iscell(data_te) && iscell(labels_te) && iscell(labels_tr))
    error('data and labels must be cell arrays.')
  end
  if isnan(max_learners)
    max_learners = length(data_tr);
  end
  
  calc_error = @(x, y) sum(x ~= y)/numel(y);
  
  alpha = 0.1:.1:.9; % cvx combiner 
  
  T = length(data_te);
  
  % initalize variables
  err_sml = zeros(T, 1);
  err_mle = zeros(T, 1);
  err_map = zeros(T, 1);
  err_avg_cor = zeros(T, 1); 
  err_avg = zeros(T, 1);
  err_cvx = zeros(T, length(alpha));
  
  kappa_sml = zeros(T, 1);
  kappa_mle = zeros(T, 1);
  kappa_map = zeros(T, 1);
  kappa_avg_cor = zeros(T, 1); 
  kappa_avg = zeros(T, 1);
  kappa_cvx = zeros(T, length(alpha));
  ensemble = {}; %cell(max_learners, 1);
  
  % main loop 
  for t = 1:T-1
        
    tt = mod(t, max_learners); % location of current learner
    ensemble{tt} = classifier_train(clfr, data_tr{t}, labels_tr{t});
    preds_te = predictions(ensemble, data_te{t});
    preds_te(preds_te == 2) = -1;
    
    if t > 1
      % SML
      [p_sml, ~, p_mle, p_map, ~] = spectral_meta_learner(preds_te);
      p_sml(p_sml == -1) = 2;
      p_mle(p_mle == -1) = 2;
      p_map(p_map == -1) = 2;
      err_sml(t) = calc_error(p_sml, labels_te{t});
      err_mle(t) = calc_error(p_mle, labels_te{t});
      err_map(t) = calc_error(p_map, labels_te{t});
      
      kappa_sml(t) = kappa(confusionmat(labels_te{t}, p_sml));
      kappa_mle(t) = kappa(confusionmat(labels_te{t}, p_mle));
      kappa_map(t) = kappa(confusionmat(labels_te{t}, p_map));
      

      % AVG + AVG-Corrected
      [p_avg1, p_avg2] = average_meta_learner(preds_te);
      p_avg1(p_avg1 == -1) = 2;
      p_avg2(p_avg2 == -1) = 2;
      err_avg(t) = calc_error(p_avg1, labels_te{t});
      err_avg_cor(t) = calc_error(p_avg2, labels_te{t});
      
      kappa_avg(t) = kappa(confusionmat(labels_te{t}, p_avg1));
      kappa_avg_cor(t) = kappa(confusionmat(labels_te{t}, p_avg2));

      % CVX
    
    end
  
  end
  
  function H = predictions(ensemble, data)
    for j = 1:length(ensemble)
      H(:, j) = classifier_test(ensemble{j}, data);
    end
  end
  
end